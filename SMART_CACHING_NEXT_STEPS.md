# Smart Caching - Next Steps

## 🚨 IMMEDIATE ACTION REQUIRED

### Step 1: Generate Drift Code
Run this command in your terminal:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will generate `lib/database/app_database.g.dart` which is required for compilation.

### Step 2: Test the Implementation
1. Run the app
2. Load some students and attendance data (while online)
3. Turn off WiFi/Mobile data
4. Navigate to Students screen - should show cached data
5. Navigate to Attendance screen - should show cached data
6. Orange "Offline" banner should appear at top

### Step 3: Add Offline Indicator to Key Screens

Add this import to screens:
```dart
import 'package:edu_sync/widgets/common/offline_indicator.dart';
```

Add the widget to screen body:
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Screen Title')),
    body: Column(
      children: [
        OfflineIndicator(),  // Add this line
        Expanded(
          child: YourContentWidget(),
        ),
      ],
    ),
  );
}
```

**Recommended screens to add it to:**
- `lib/screens/admin/student_management_screen.dart`
- `lib/screens/teacher/teacher_dashboard.dart`
- `lib/screens/teacher/attendance_marking_screen.dart`
- `lib/screens/parent/parent_dashboard.dart`

## 📋 Phase 2: Academic Tables (Next Priority)

### Tables to Add
1. **Exams** - Exam information
2. **Subjects** - Subject definitions
3. **Grades** - Grading system
4. **StudentExamMarks** - Student marks

### Implementation Steps

#### 1. Add to `lib/database/app_database.dart`:

```dart
class Exams extends Table {
  TextColumn get id => text()();
  IntColumn get schoolId => integer().named('school_id').nullable()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get examDate => dateTime().named('exam_date')();
  IntColumn get maxMarks => integer().named('max_marks')();
  TextColumn get examinerName => text().named('examiner_name')();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  IntColumn get classId => integer().named('class_id')();

  @override
  Set<Column> get primaryKey => {id};
}

class Subjects extends Table {
  TextColumn get id => text()();
  IntColumn get schoolId => integer().named('school_id').nullable()();
  TextColumn get name => text()();
  TextColumn get code => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  IntColumn get classId => integer().named('class_id').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Grades extends Table {
  TextColumn get id => text()();
  IntColumn get schoolId => integer().named('school_id').nullable()();
  TextColumn get name => text()();
  IntColumn get minPercentage => integer().named('min_percentage')();
  IntColumn get maxPercentage => integer().named('max_percentage')();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  TextColumn get gradeName => text().named('grade_name').nullable()();
  TextColumn get remarks => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class StudentExamMarks extends Table {
  TextColumn get id => text()();
  IntColumn get studentId => integer().named('student_id').nullable()();
  TextColumn get examId => text().named('exam_id').nullable()();
  TextColumn get subjectId => text().named('subject_id').nullable()();
  IntColumn get marksObtained => integer().named('marks_obtained')();
  IntColumn get totalMarks => integer().named('total_marks')();
  TextColumn get gradeId => text().named('grade_id').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

#### 2. Update database class:
```dart
@DriftDatabase(tables: [
  Schools, Students, Classes, Users, Attendance,
  Exams, Subjects, Grades, StudentExamMarks  // Add these
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;  // Increment to 3
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(users);
        await m.createTable(attendance);
      }
      if (from < 3) {
        await m.createTable(exams);
        await m.createTable(subjects);
        await m.createTable(grades);
        await m.createTable(studentExamMarks);
      }
    },
  );
}
```

#### 3. Add methods to `lib/services/cache_service.dart`:

```dart
// Exams
Future<void> cacheExams(List<Exam> exams) async {
  try {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(
        _db.exams,
        exams.map((e) => ExamsCompanion.insert(
          id: e.id,
          schoolId: Value(e.schoolId),
          name: e.name,
          // ... map all fields
        )),
      );
    });
  } catch (e) {
    logger.e('Error caching exams: $e');
  }
}

Future<List<Exam>> getCachedExams(int schoolId) async {
  try {
    final rows = await (_db.select(_db.exams)
      ..where((e) => e.schoolId.equals(schoolId))).get();
    
    return rows.map((row) => Exam(
      id: row.id,
      schoolId: row.schoolId,
      name: row.name,
      // ... map all fields
    )).toList();
  } catch (e) {
    logger.e('Error getting cached exams: $e');
    return [];
  }
}
```

#### 4. Update ExamService:
```dart
class ExamService {
  final SupabaseClient _supabase;
  final CacheService _cache;
  
  ExamService(this._supabase, this._cache);
  
  Future<List<Exam>> getExamsBySchool(int schoolId) async {
    try {
      final response = await _supabase
          .from('exams')
          .select()
          .eq('school_id', schoolId);
      
      final exams = response.map((e) => Exam.fromMap(e)).toList();
      
      // Cache the result
      await _cache.cacheExams(exams);
      
      return exams;
    } catch (e) {
      logger.w('Supabase failed, using cache: $e');
      return await _cache.getCachedExams(schoolId);
    }
  }
}
```

## 🎯 Quick Wins

### Add Offline Indicator to More Screens
Priority screens that would benefit:
1. Admin Dashboard
2. Teacher Dashboard
3. Student List Screen
4. Attendance Marking Screen
5. Exam List Screen

### Test Offline Scenarios
1. Load data while online
2. Go offline
3. Verify cached data shows
4. Verify offline indicator appears
5. Go back online
6. Verify data refreshes

## 📊 Monitoring Cache Performance

Add this method to CacheService:
```dart
Future<Map<String, int>> getCacheStats() async {
  return {
    'students': await (_db.select(_db.students).get()).then((r) => r.length),
    'users': await (_db.select(_db.users).get()).then((r) => r.length),
    'attendance': await (_db.select(_db.attendance).get()).then((r) => r.length),
  };
}
```

## 🐛 Troubleshooting

### If code generation fails:
```bash
# Clean first
flutter pub run build_runner clean

# Then rebuild
flutter pub run build_runner build --delete-conflicting-outputs
```

### If app crashes on startup:
- Check that all services have CacheService injected
- Verify AppDatabase is initialized before CacheService
- Check migration strategy is correct

### If cache doesn't work:
- Verify data is being cached (add logger.i statements)
- Check getCached methods are being called on error
- Verify offline indicator shows when offline

## 📚 Resources

- Implementation Guidelines: `.amazonq/rules/smart-caching/implementation-rules.md`
- Quick Start Guide: `.amazonq/rules/smart-caching/quick-start.md`
- MCP Usage: `.amazonq/rules/smart-caching/mcp-usage.md`

---

**Current Status**: Phase 1 Complete ✅  
**Next Action**: Run code generation and test
