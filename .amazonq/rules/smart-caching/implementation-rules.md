# Smart Caching Implementation Rules

## Core Principles

### 0. MCP Server for Supabase Backend
- ALWAYS use MCP server tools to verify Supabase schema before creating Drift tables
- Use `list_tables` to check table structure and column names
- Use `execute_sql` to verify data types and constraints
- Ensure Drift schema matches Supabase schema exactly

```dart
// Before creating Drift table, verify with MCP:
// 1. Check table exists: list_tables(schemas: ['public'])
// 2. Verify columns: execute_sql(query: "SELECT * FROM students LIMIT 0")
// 3. Match column names exactly (snake_case)
```

### 1. Cache Strategy
- ALWAYS try Supabase first when online
- ONLY use cache as fallback when offline or on error
- Cache is READ-ONLY - no offline writes
- Supabase is ALWAYS the source of truth

### 2. Service Pattern
```dart
// CORRECT Pattern:
class StudentService {
  final SupabaseClient _supabase;
  final CacheService _cache;
  final Connectivity _connectivity;
  
  Future<List<Student>> getStudents(int schoolId) async {
    try {
      // Try Supabase first
      final response = await _supabase.from('students').select().eq('school_id', schoolId);
      final students = response.map((e) => Student.fromMap(e)).toList();
      
      // Cache for offline use
      await _cache.cacheStudents(students);
      
      return students;
    } catch (e) {
      logger.w('Supabase failed, using cache: $e');
      // Fallback to cache
      return await _cache.getCachedStudents(schoolId);
    }
  }
}

// WRONG - Don't do this:
class StudentService {
  Future<List<Student>> getStudents(int schoolId) async {
    // ❌ Checking cache first
    final cached = await _cache.getCachedStudents(schoolId);
    if (cached.isNotEmpty) return cached;
    
    return await _supabase.from('students').select();
  }
}
```

### 3. Drift Table Definition Rules
- ALWAYS match Supabase column names exactly
- ALWAYS use snake_case for column names
- ALWAYS add indexes for foreign keys
- ALWAYS add primary key constraints
- ALWAYS handle nullable fields correctly

```dart
// CORRECT:
class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get schoolId => integer().named('school_id')();  // Match Supabase
  IntColumn get classId => integer().named('class_id').nullable()();
  TextColumn get fullName => text().named('full_name')();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// WRONG:
class Students extends Table {
  IntColumn get id => integer()();  // ❌ No autoIncrement
  IntColumn get schoolId => integer()();  // ❌ Wrong column name
  TextColumn get fullName => text()();  // ❌ Wrong column name
}
```

### 4. Cache Service Pattern
```dart
class CacheService {
  final AppDatabase _db;
  
  CacheService(this._db);
  
  // Cache data
  Future<void> cacheStudents(List<Student> students) async {
    await _db.batch((batch) {
      batch.insertAllOnConflictUpdate(_db.students, students.map((s) => 
        StudentsCompanion.insert(
          id: Value(s.id),
          schoolId: s.schoolId,
          fullName: s.fullName,
          // ... map all fields
        )
      ));
    });
  }
  
  // Retrieve cached data
  Future<List<Student>> getCachedStudents(int schoolId) async {
    final rows = await (_db.select(_db.students)
      ..where((s) => s.schoolId.equals(schoolId))).get();
    
    return rows.map((row) => Student(
      id: row.id,
      schoolId: row.schoolId,
      fullName: row.fullName,
      // ... map all fields
    )).toList();
  }
  
  // Clear cache
  Future<void> clearStudentsCache() async {
    await _db.delete(_db.students).go();
  }
}
```

### 5. Error Handling Pattern
```dart
Future<List<Student>> getStudents(int schoolId) async {
  try {
    // Try online first
    final students = await _fetchFromSupabase(schoolId);
    await _cache.cacheStudents(students);
    return students;
  } on SocketException catch (e) {
    // Network error - use cache
    logger.w('Network error, using cache: $e');
    return await _cache.getCachedStudents(schoolId);
  } on PostgrestException catch (e) {
    // Supabase error - use cache
    logger.e('Supabase error, using cache: $e');
    return await _cache.getCachedStudents(schoolId);
  } catch (e) {
    // Unknown error - use cache
    logger.e('Unknown error, using cache: $e');
    return await _cache.getCachedStudents(schoolId);
  }
}
```

### 6. Connectivity Check Pattern
```dart
Future<List<Student>> getStudents(int schoolId) async {
  final connectivityResult = await _connectivity.checkConnectivity();
  
  if (connectivityResult.contains(ConnectivityResult.none)) {
    // Offline - use cache immediately
    logger.i('Offline mode, using cache');
    return await _cache.getCachedStudents(schoolId);
  }
  
  // Online - try Supabase
  try {
    final students = await _fetchFromSupabase(schoolId);
    await _cache.cacheStudents(students);
    return students;
  } catch (e) {
    logger.w('Supabase failed, using cache: $e');
    return await _cache.getCachedStudents(schoolId);
  }
}
```

## Drift Schema Rules

### Table Naming
- Use PascalCase for table class names: `Students`, `Attendance`, `Exams`
- Use snake_case for column names: `school_id`, `full_name`, `created_at`

### Column Types Mapping
| Supabase Type | Drift Type | Example |
|---------------|------------|---------|
| `integer` | `IntColumn` | `IntColumn get id => integer()()` |
| `text` | `TextColumn` | `TextColumn get name => text()()` |
| `boolean` | `BoolColumn` | `BoolColumn get isActive => boolean()()` |
| `timestamptz` | `DateTimeColumn` | `DateTimeColumn get createdAt => dateTime()()` |
| `date` | `DateTimeColumn` | `DateTimeColumn get dateOfBirth => dateTime()()` |
| `uuid` | `TextColumn` | `TextColumn get id => text()()` |
| `numeric` | `RealColumn` | `RealColumn get amount => real()()` |

### Indexes
```dart
@override
List<Index> get indexes => [
  Index('students_school_id_idx', [schoolId]),
  Index('students_class_id_idx', [classId]),
];
```

### Foreign Keys
```dart
@override
List<Set<Column>> get customConstraints => [
  {
    'FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE',
  },
];
```

## Cache Service Implementation Rules

### 1. Batch Operations
- ALWAYS use batch operations for multiple inserts
- Use `insertAllOnConflictUpdate` for upsert behavior

```dart
Future<void> cacheMultiple(List<Student> students) async {
  await _db.batch((batch) {
    batch.insertAllOnConflictUpdate(_db.students, students.map(toCompanion));
  });
}
```

### 2. Query Optimization
- ALWAYS add WHERE clauses to limit results
- Use indexes for frequently queried columns
- Avoid SELECT * - select only needed columns

```dart
// CORRECT:
Future<List<Student>> getCachedStudents(int schoolId) async {
  return await (_db.select(_db.students)
    ..where((s) => s.schoolId.equals(schoolId))
    ..limit(100)).get();
}

// WRONG:
Future<List<Student>> getCachedStudents(int schoolId) async {
  final all = await _db.select(_db.students).get();
  return all.where((s) => s.schoolId == schoolId).toList();  // ❌ Inefficient
}
```

### 3. Cache Invalidation
```dart
// Clear specific cache
Future<void> clearStudentCache(int studentId) async {
  await (_db.delete(_db.students)..where((s) => s.id.equals(studentId))).go();
}

// Clear all cache
Future<void> clearAllCache() async {
  await _db.delete(_db.students).go();
  await _db.delete(_db.attendance).go();
  // ... clear all tables
}

// Clear old cache (older than 24 hours)
Future<void> clearOldCache() async {
  final yesterday = DateTime.now().subtract(Duration(hours: 24));
  await (_db.delete(_db.students)
    ..where((s) => s.cachedAt.isSmallerThanValue(yesterday))).go();
}
```

## Service Integration Rules

### 1. Minimal Changes
- DON'T rewrite entire service
- ADD caching to existing methods
- KEEP existing logic intact
- TEST each method after adding cache

### 2. Service Constructor
```dart
// BEFORE:
class StudentService {
  final SupabaseClient _supabase;
  
  StudentService(this._supabase);
}

// AFTER:
class StudentService {
  final SupabaseClient _supabase;
  final CacheService _cache;
  final Connectivity _connectivity;
  
  StudentService(this._supabase, this._cache, this._connectivity);
}
```

### 3. Method Pattern
```dart
// Template for all GET methods:
Future<List<Model>> getModels(int filterId) async {
  try {
    // 1. Fetch from Supabase
    final response = await _supabase.from('table').select().eq('filter', filterId);
    final models = response.map((e) => Model.fromMap(e)).toList();
    
    // 2. Cache the result
    await _cache.cacheModels(models);
    
    // 3. Return fresh data
    return models;
  } catch (e) {
    // 4. Fallback to cache
    logger.w('Using cache due to error: $e');
    return await _cache.getCachedModels(filterId);
  }
}
```

### 4. CREATE/UPDATE/DELETE Methods
```dart
// For write operations, invalidate cache after success
Future<Student> createStudent(Student student) async {
  final created = await _supabase.from('students').insert(student.toMap()).single();
  
  // Invalidate cache to force refresh
  await _cache.clearStudentsCache();
  
  return Student.fromMap(created);
}

Future<void> deleteStudent(int studentId) async {
  await _supabase.from('students').delete().eq('id', studentId);
  
  // Remove from cache
  await _cache.clearStudentCache(studentId);
}
```

## UI Integration Rules

### 1. Offline Indicator
```dart
class OfflineIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ConnectivityResult>>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline = snapshot.data?.contains(ConnectivityResult.none) ?? false;
        
        if (!isOffline) return SizedBox.shrink();
        
        return Container(
          padding: EdgeInsets.all(8),
          color: Colors.orange,
          child: Row(
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Offline - Showing cached data', style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }
}
```

### 2. Error Messages
```dart
// Show user-friendly messages
try {
  final students = await _studentService.getStudents(schoolId);
  // Show data
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Showing cached data. Connect to internet for latest updates.'),
      backgroundColor: Colors.orange,
    ),
  );
}
```

### 3. Pull to Refresh
```dart
RefreshIndicator(
  onRefresh: () async {
    // Force refresh from Supabase
    await _studentService.refreshStudents(schoolId);
  },
  child: ListView.builder(...),
)
```

## Testing Rules

### 1. Unit Tests
```dart
void main() {
  late MockSupabaseClient mockSupabase;
  late MockCacheService mockCache;
  late StudentService service;
  
  setUp(() {
    mockSupabase = MockSupabaseClient();
    mockCache = MockCacheService();
    service = StudentService(mockSupabase, mockCache, Connectivity());
  });
  
  test('Should fetch from Supabase and cache', () async {
    when(mockSupabase.from('students').select()).thenReturn([{'id': 1}]);
    
    await service.getStudents(1);
    
    verify(mockCache.cacheStudents(any)).called(1);
  });
  
  test('Should use cache when Supabase fails', () async {
    when(mockSupabase.from('students').select()).thenThrow(Exception());
    when(mockCache.getCachedStudents(1)).thenReturn([Student(id: 1)]);
    
    final result = await service.getStudents(1);
    
    expect(result.length, 1);
    verify(mockCache.getCachedStudents(1)).called(1);
  });
}
```

### 2. Integration Tests
```dart
testWidgets('Should show cached data when offline', (tester) async {
  // Setup offline mode
  await tester.pumpWidget(MyApp());
  
  // Verify cached data is shown
  expect(find.text('Offline - Showing cached data'), findsOneWidget);
  expect(find.byType(StudentList), findsOneWidget);
});
```

## Performance Rules

### 1. Batch Operations
- Use batch inserts for >10 records
- Limit query results (use pagination)
- Use indexes on foreign keys

### 2. Memory Management
- Don't load all data at once
- Use pagination for large lists
- Clear old cache periodically

### 3. Database Size
- Monitor cache size
- Implement cache size limits
- Clear old data automatically

```dart
Future<void> manageCacheSize() async {
  final size = await _db.customSelect('SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()').getSingle();
  
  if (size['size'] > 50 * 1024 * 1024) {  // 50MB limit
    await clearOldCache();
  }
}
```

## Critical Rules Summary

1. ✅ ALWAYS try Supabase first when online
2. ✅ ONLY use cache as fallback
3. ✅ Cache is READ-ONLY
4. ✅ Supabase is source of truth
5. ✅ Match Supabase column names exactly
6. ✅ Use batch operations for multiple inserts
7. ✅ Add indexes for foreign keys
8. ✅ Handle errors gracefully
9. ✅ Show offline indicators
10. ✅ Test offline scenarios
11. ✅ always check error before next step implementation.
 
## follow error-checking.md

## Common Mistakes to Avoid

❌ Don't check cache before Supabase
❌ Don't allow offline writes
❌ Don't forget to cache after Supabase fetch
❌ Don't use wrong column names
❌ Don't forget error handling
❌ Don't load all data at once
❌ Don't forget to clear cache on writes
❌ Don't ignore cache size
❌ Don't forget offline indicators
❌ Don't skip testing
