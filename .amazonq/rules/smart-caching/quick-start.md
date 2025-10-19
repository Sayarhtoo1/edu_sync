# Smart Caching Quick Start Guide

## 🚀 Implementation in 3 Steps

### Step 1: Expand Drift Schema (Day 1)
### Step 2: Create Cache Service (Day 2)
### Step 3: Update Services (Day 3-5)

---

## Step 1: Expand Drift Schema

### Verify Supabase Schema with MCP Server
```bash
# ALWAYS verify Supabase schema first using MCP server tools:
# 1. list_tables - Check all tables and columns
# 2. execute_sql - Verify data types and constraints
# 3. Match column names exactly (snake_case)
```

### Add Table to app_database.dart
```dart
// lib/database/app_database.dart

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().named('full_name').nullable()();
  TextColumn get role => text()();
  IntColumn get schoolId => integer().named('school_id').nullable()();
  TextColumn get email => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Attendance extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().named('student_id')();
  IntColumn get classId => integer().named('class_id')();
  DateTimeColumn get date => dateTime()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// Update database class
@DriftDatabase(tables: [Schools, Students, Classes, Users, Attendance])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);
  
  @override
  int get schemaVersion => 2;  // Increment version
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(users);
        await m.createTable(attendance);
      }
    },
  );
}
```

### Run Code Generation
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Step 2: Create Cache Service

### Create cache_service.dart
```dart
// lib/services/cache_service.dart
import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/student.dart';
import '../models/user.dart' as app_user;
import '../models/attendance.dart' as app_attendance;

class CacheService {
  final AppDatabase _db;
  
  CacheService(this._db);
  
  // Students
  Future<void> cacheStudents(List<Student> students) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.students,
        students.map((s) => StudentsCompanion.insert(
          id: Value(s.id),
          schoolId: s.schoolId,
          name: s.fullName,
          dateOfBirth: Value(s.dateOfBirth),
          gender: s.gender ?? '',
          profilePhotoUrl: Value(s.profilePhotoUrl),
        )),
      );
    });
  }
  
  Future<List<Student>> getCachedStudents(int schoolId) async {
    final rows = await (_db.select(_db.students)
      ..where((s) => s.schoolId.equals(schoolId))).get();
    
    return rows.map((row) => Student(
      id: row.id,
      schoolId: row.schoolId,
      fullName: row.name,
      dateOfBirth: row.dateOfBirth,
      gender: row.gender,
      profilePhotoUrl: row.profilePhotoUrl,
    )).toList();
  }
  
  // Users
  Future<void> cacheUsers(List<app_user.User> users) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.users,
        users.map((u) => UsersCompanion.insert(
          id: u.id,
          fullName: Value(u.fullName),
          role: u.role,
          schoolId: Value(u.schoolId),
          email: Value(u.email),
        )),
      );
    });
  }
  
  Future<List<app_user.User>> getCachedUsers(int schoolId) async {
    final rows = await (_db.select(_db.users)
      ..where((u) => u.schoolId.equals(schoolId))).get();
    
    return rows.map((row) => app_user.User(
      id: row.id,
      fullName: row.fullName,
      role: row.role,
      schoolId: row.schoolId,
      email: row.email,
    )).toList();
  }
  
  // Attendance
  Future<void> cacheAttendance(List<app_attendance.Attendance> records) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.attendance,
        records.map((a) => AttendanceCompanion.insert(
          id: Value(a.id),
          studentId: a.studentId,
          classId: a.classId,
          date: a.date,
          status: a.status,
        )),
      );
    });
  }
  
  Future<List<app_attendance.Attendance>> getCachedAttendance(int classId, DateTime date) async {
    final rows = await (_db.select(_db.attendance)
      ..where((a) => a.classId.equals(classId) & a.date.equals(date))).get();
    
    return rows.map((row) => app_attendance.Attendance(
      id: row.id,
      studentId: row.studentId,
      classId: row.classId,
      date: row.date,
      status: row.status,
    )).toList();
  }
  
  // Clear cache
  Future<void> clearAllCache() async {
    await _db.delete(_db.students).go();
    await _db.delete(_db.users).go();
    await _db.delete(_db.attendance).go();
  }
}
```

---

## Step 3: Update Services

### Update StudentService
```dart
// lib/services/student_service.dart
class StudentService {
  final SupabaseClient _supabaseClient;
  final AppDatabase _appDatabase;
  final CacheService _cache;
  
  StudentService(this._supabaseClient, this._appDatabase, this._cache);
  
  Future<List<Student>> getStudentsBySchool(int schoolId, {int? classId}) async {
    try {
      // Try Supabase first
      var query = _supabaseClient
          .from('school_students_view')
          .select()
          .eq('school_id', schoolId);
      
      if (classId != null) {
        query = query.eq('class_id', classId);
      }
      
      final response = await query.order('full_name', ascending: true);
      final students = response.map((data) => Student.fromMap(data)).toList();
      
      // Cache the result
      await _cache.cacheStudents(students);
      
      return students;
    } catch (e) {
      logger.w('Supabase failed, using cache: $e');
      // Fallback to cache
      return await _cache.getCachedStudents(schoolId);
    }
  }
}
```

### Update AttendanceService
```dart
// lib/services/attendance_service.dart
class AttendanceService {
  final SupabaseClient _supabase;
  final CacheService _cache;
  
  AttendanceService(this._supabase, this._cache);
  
  Future<List<app_attendance.Attendance>> getAttendanceForClassByDate(
    int classId,
    DateTime date,
  ) async {
    try {
      // Try Supabase first
      final response = await _supabase
          .from('attendance')
          .select()
          .eq('class_id', classId)
          .eq('date', DateFormat('yyyy-MM-dd').format(date));
      
      final attendance = response.map((item) => 
        app_attendance.Attendance.fromMap(item)
      ).toList();
      
      // Cache the result
      await _cache.cacheAttendance(attendance);
      
      return attendance;
    } catch (e) {
      logger.w('Supabase failed, using cache: $e');
      // Fallback to cache
      return await _cache.getCachedAttendance(classId, date);
    }
  }
}
```

---

## Step 4: Update Dependency Injection

### Update providers.dart
```dart
// lib/config/providers.dart
Future<List<Provider>> initializeProviders() async {
  final supabaseClient = Supabase.instance.client;
  final sharedPreferences = await SharedPreferences.getInstance();
  final connectivity = Connectivity();
  
  // Initialize database
  final database = AppDatabase(
    NativeDatabase.createInBackground(
      File(join((await getApplicationDocumentsDirectory()).path, 'edusync.db')),
    ),
  );
  
  // Initialize cache service
  final cacheService = CacheService(database);
  
  // Initialize services with cache
  final studentService = StudentService(supabaseClient, database, cacheService);
  final attendanceService = AttendanceService(supabaseClient, cacheService);
  
  return [
    Provider<AppDatabase>.value(value: database),
    Provider<CacheService>.value(value: cacheService),
    Provider<StudentService>.value(value: studentService),
    Provider<AttendanceService>.value(value: attendanceService),
    // ... other providers
  ];
}
```

---

## Step 5: Add Offline Indicator

### Create offline_indicator.dart
```dart
// lib/widgets/offline_indicator.dart
class OfflineIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline = snapshot.data?.contains(ConnectivityResult.none) ?? false;
        
        if (!isOffline) return SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Colors.orange.shade700,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text(
                'Offline - Showing cached data',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Add to screens
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Students')),
    body: Column(
      children: [
        OfflineIndicator(),  // Add this
        Expanded(
          child: StudentList(),
        ),
      ],
    ),
  );
}
```

---

## Testing

### Test Offline Behavior
```dart
void main() {
  test('Should use cache when offline', () async {
    final mockSupabase = MockSupabaseClient();
    final mockCache = MockCacheService();
    final service = StudentService(mockSupabase, mockDb, mockCache);
    
    when(mockSupabase.from('students').select()).thenThrow(SocketException(''));
    when(mockCache.getCachedStudents(1)).thenReturn([Student(id: 1)]);
    
    final result = await service.getStudentsBySchool(1);
    
    expect(result.length, 1);
    verify(mockCache.getCachedStudents(1)).called(1);
  });
}
```

---

## Quick Commands

```bash
# Generate Drift code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode
flutter pub run build_runner watch

# Clean and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Run tests
flutter test

# Test specific file
flutter test test/services/student_service_test.dart
```

---

## Checklist

### Day 1
- [ ] Add tables to app_database.dart
- [ ] Update schemaVersion
- [ ] Add migration logic
- [ ] Run code generation
- [ ] Test database initialization

### Day 2
- [ ] Create cache_service.dart
- [ ] Implement cache methods
- [ ] Write unit tests
- [ ] Test cache operations

### Day 3-5
- [ ] Update StudentService
- [ ] Update AttendanceService
- [ ] Update other services
- [ ] Add offline indicator
- [ ] Test offline scenarios
- [ ] Update providers.dart

---

## Success Criteria

✅ App works offline with cached data
✅ Data refreshes when online
✅ Offline indicator shows when disconnected
✅ No crashes when offline
✅ Tests pass

---

## Next Steps

After basic implementation:
1. Add more tables as needed
2. Implement cache expiration
3. Add cache size management
4. Monitor performance
5. Gather user feedback
