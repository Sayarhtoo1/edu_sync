# MCP Server Usage for Smart Caching Implementation

## 🎯 Purpose
Use MCP server tools to verify Supabase backend schema before creating Drift tables to ensure exact column name and type matching.

## 🔧 MCP Server Tools Available

### 1. list_tables
**Purpose:** Get complete table structure from Supabase
**Usage:**
```
list_tables(schemas: ['public'])
```
**Returns:** All tables with columns, data types, constraints, foreign keys

### 2. execute_sql
**Purpose:** Query Supabase database to verify schema details
**Usage:**
```
execute_sql(query: "SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'students'")
```
**Returns:** Column details, data types, nullability

### 3. get_advisors
**Purpose:** Check for security and performance issues
**Usage:**
```
get_advisors(type: 'security')
get_advisors(type: 'performance')
```
**Returns:** RLS policies, missing indexes, security vulnerabilities

## 📋 Workflow: Before Creating Drift Tables

### Step 1: Verify Table Exists
```
ALWAYS use: list_tables(schemas: ['public'])

Check:
- Table name exists
- All column names (exact snake_case)
- Data types
- Primary keys
- Foreign keys
- Nullable fields
```

### Step 2: Verify Column Details
```
Use: execute_sql(query: "SELECT * FROM students LIMIT 0")

Verify:
- Exact column names (school_id not schoolId)
- Data types (integer, text, timestamptz, etc.)
- Nullability (nullable vs NOT NULL)
```

### Step 3: Check Indexes and Constraints
```
Use: execute_sql(query: "SELECT * FROM pg_indexes WHERE tablename = 'students'")

Verify:
- Primary key indexes
- Foreign key indexes
- Performance indexes
```

### Step 4: Create Matching Drift Table
```dart
// After MCP verification, create Drift table with EXACT match
class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get schoolId => integer().named('school_id')();  // ✅ Exact match
  TextColumn get fullName => text().named('full_name')();    // ✅ Exact match
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();  // ✅ Exact match
  
  @override
  Set<Column> get primaryKey => {id};
}
```

## 🎯 Example: Creating Students Table

### Step 1: Use MCP to Check Supabase
```
list_tables(schemas: ['public'])

Result:
{
  "name": "students",
  "columns": [
    {"name": "id", "data_type": "integer", "nullable": false},
    {"name": "school_id", "data_type": "integer", "nullable": false},
    {"name": "class_id", "data_type": "integer", "nullable": true},
    {"name": "full_name", "data_type": "text", "nullable": false},
    {"name": "date_of_birth", "data_type": "date", "nullable": true},
    {"name": "gender", "data_type": "text", "nullable": true},
    {"name": "profile_photo_url", "data_type": "text", "nullable": true},
    {"name": "created_at", "data_type": "timestamptz", "nullable": true}
  ],
  "primary_keys": ["id"],
  "foreign_keys": [
    {"source": "school_id", "target": "schools.id"},
    {"source": "class_id", "target": "classes.id"}
  ]
}
```

### Step 2: Create Matching Drift Table
```dart
class Students extends Table {
  // Match: id (integer, NOT NULL, PRIMARY KEY)
  IntColumn get id => integer().autoIncrement()();
  
  // Match: school_id (integer, NOT NULL, FOREIGN KEY)
  IntColumn get schoolId => integer().named('school_id')();
  
  // Match: class_id (integer, NULLABLE, FOREIGN KEY)
  IntColumn get classId => integer().named('class_id').nullable()();
  
  // Match: full_name (text, NOT NULL)
  TextColumn get fullName => text().named('full_name')();
  
  // Match: date_of_birth (date, NULLABLE)
  DateTimeColumn get dateOfBirth => dateTime().named('date_of_birth').nullable()();
  
  // Match: gender (text, NULLABLE)
  TextColumn get gender => text().nullable()();
  
  // Match: profile_photo_url (text, NULLABLE)
  TextColumn get profilePhotoUrl => text().named('profile_photo_url').nullable()();
  
  // Match: created_at (timestamptz, NULLABLE)
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
  
  @override
  List<Index> get indexes => [
    Index('students_school_id_idx', [schoolId]),
    Index('students_class_id_idx', [classId]),
  ];
}
```

## ✅ Verification Checklist

Before creating any Drift table:
- [ ] Used `list_tables` to get Supabase schema
- [ ] Verified all column names (exact snake_case)
- [ ] Verified all data types match
- [ ] Verified nullable fields match
- [ ] Verified primary keys match
- [ ] Verified foreign keys match
- [ ] Added indexes for foreign keys
- [ ] Tested with code generation

## 🚨 Common Mistakes to Avoid

### ❌ Wrong: Guessing Column Names
```dart
class Students extends Table {
  IntColumn get schoolId => integer()();  // ❌ Missing .named('school_id')
  TextColumn get fullName => text()();    // ❌ Missing .named('full_name')
}
```

### ✅ Correct: Using MCP to Verify
```dart
// 1. Check with MCP first: list_tables(schemas: ['public'])
// 2. Match exactly:
class Students extends Table {
  IntColumn get schoolId => integer().named('school_id')();  // ✅
  TextColumn get fullName => text().named('full_name')();    // ✅
}
```

### ❌ Wrong: Wrong Data Types
```dart
class Students extends Table {
  TextColumn get id => text()();  // ❌ Should be IntColumn
  IntColumn get createdAt => integer()();  // ❌ Should be DateTimeColumn
}
```

### ✅ Correct: Matching Data Types
```dart
// Verified with MCP: id is integer, created_at is timestamptz
class Students extends Table {
  IntColumn get id => integer().autoIncrement()();  // ✅
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();  // ✅
}
```

## 📊 MCP Server Commands Reference

### Get All Tables
```
list_tables(schemas: ['public'])
```

### Get Specific Table Details
```
execute_sql(query: "SELECT column_name, data_type, is_nullable FROM information_schema.columns WHERE table_name = 'students' ORDER BY ordinal_position")
```

### Check Foreign Keys
```
execute_sql(query: "SELECT tc.constraint_name, tc.table_name, kcu.column_name, ccu.table_name AS foreign_table_name, ccu.column_name AS foreign_column_name FROM information_schema.table_constraints AS tc JOIN information_schema.key_column_usage AS kcu ON tc.constraint_name = kcu.constraint_name JOIN information_schema.constraint_column_usage AS ccu ON ccu.constraint_name = tc.constraint_name WHERE tc.constraint_type = 'FOREIGN KEY' AND tc.table_name = 'students'")
```

### Check Indexes
```
execute_sql(query: "SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'students'")
```

### Check Primary Keys
```
execute_sql(query: "SELECT a.attname FROM pg_index i JOIN pg_attribute a ON a.attrelid = i.indrelid AND a.attnum = ANY(i.indkey) WHERE i.indrelid = 'students'::regclass AND i.indisprimary")
```

## 🎯 Integration with Implementation

### Day 1: Core Tables
```
1. Use MCP: list_tables(schemas: ['public'])
2. Verify: students, users, attendance, classes, schools
3. Create Drift tables matching exactly
4. Run code generation
5. Test
```

### Day 2: Academic Tables
```
1. Use MCP: list_tables(schemas: ['public'])
2. Verify: exams, subjects, grades, student_exam_marks
3. Create Drift tables matching exactly
4. Run code generation
5. Test
```

### Day 3-4: Continue Pattern
```
Always: MCP verify → Create Drift table → Generate code → Test
```

## 🔍 Debugging with MCP

### If Drift table doesn't match:
```
1. Use MCP: list_tables to see actual Supabase schema
2. Compare with your Drift table
3. Fix mismatches (column names, types, nullability)
4. Regenerate code
5. Test again
```

### If foreign keys fail:
```
1. Use MCP: Check foreign key constraints
2. Verify referenced tables exist in Drift
3. Add missing tables
4. Regenerate code
```

## 📚 Best Practices

1. **Always verify first**: Never create Drift tables without MCP verification
2. **Exact match**: Column names must match exactly (snake_case)
3. **Data types**: Use correct Drift types for Supabase types
4. **Nullability**: Match nullable fields exactly
5. **Indexes**: Add indexes for all foreign keys
6. **Test**: Always test after code generation

## ✅ Success Criteria

You've done it right when:
- [ ] Used MCP to verify Supabase schema
- [ ] All column names match exactly
- [ ] All data types match
- [ ] All nullable fields match
- [ ] All foreign keys work
- [ ] Code generation succeeds
- [ ] Tests pass
- [ ] No runtime errors

Remember: **MCP server is your source of truth for Supabase schema!** 🎯
