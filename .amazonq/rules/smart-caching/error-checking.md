# Error Checking and Fixing Rule

## 🚨 CRITICAL RULE: Always Check and Fix Errors Before Proceeding

### Mandatory Process for Every Implementation Step

After implementing ANY code changes, you MUST:

1. **Check for compilation errors**
2. **Fix ALL errors found**
3. **Verify the fix works**
4. **Only then proceed to next step**

## Step-by-Step Error Checking Process

### 1. After Code Changes
```
✅ Code written
↓
🔍 CHECK: Run analysis/compilation
↓
❌ Errors found? → FIX THEM
↓
✅ No errors? → Proceed to next step
```

### 2. Error Detection Methods

#### Method A: IDE Analysis
- Check Problems panel in IDE
- Look for red underlines in code
- Review error messages

#### Method B: Command Line (if available)
```bash
# Analyze code
flutter analyze

# Check for errors
dart analyze

# Try compilation
flutter build <target> --debug
```

#### Method C: Manual Code Review
- Check all imports exist
- Verify all classes/methods are defined
- Ensure proper syntax
- Validate type safety

### 3. Common Error Categories

#### Import Errors
```dart
// ❌ ERROR: Missing import
class MyService {
  final CacheService _cache;  // Error: CacheService not found
}

// ✅ FIX: Add import
import 'cache_service.dart';

class MyService {
  final CacheService _cache;  // Now works
}
```

#### Constructor Errors
```dart
// ❌ ERROR: Wrong number of parameters
StudentService(this._appDatabase);  // Missing CacheService

// ✅ FIX: Add missing parameter
StudentService(this._appDatabase, this._cache);
```

#### Type Errors
```dart
// ❌ ERROR: Type mismatch
IntColumn get id => text()();  // text() returns TextColumn

// ✅ FIX: Use correct type
IntColumn get id => integer()();
```

#### Null Safety Errors
```dart
// ❌ ERROR: Nullable used as non-nullable
String name = student.fullName;  // fullName might be null

// ✅ FIX: Handle nullability
String name = student.fullName ?? 'Unknown';
```

#### Missing Generated Code
```dart
// ❌ ERROR: app_database.g.dart not found
part 'app_database.g.dart';  // File doesn't exist

// ✅ FIX: Run code generation
// flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Error Fixing Priority

**Priority 1: Compilation Errors (MUST FIX)**
- Missing imports
- Undefined classes/methods
- Type mismatches
- Syntax errors

**Priority 2: Analysis Warnings (SHOULD FIX)**
- Unused imports
- Deprecated APIs
- Potential null errors
- Code style issues

**Priority 3: Runtime Errors (FIX DURING TESTING)**
- Logic errors
- Data validation errors
- Network errors
- State management issues

### 5. Verification Checklist

Before moving to next step, verify:

- [ ] No red underlines in code
- [ ] No errors in Problems panel
- [ ] All imports resolve correctly
- [ ] All types match correctly
- [ ] Code generation completed (if needed)
- [ ] No null safety violations
- [ ] All dependencies injected properly

## Implementation Workflow with Error Checking

### Example: Adding Cache Service

#### Step 1: Create CacheService
```dart
// 1. Write code
class CacheService {
  final AppDatabase _db;
  CacheService(this._db);
}
```

#### Step 2: CHECK FOR ERRORS
```
🔍 Check: Does AppDatabase import exist?
✅ Yes → Proceed
❌ No → Add import 'package:edu_sync/database/app_database.dart';
```

#### Step 3: Update StudentService
```dart
// 1. Add CacheService parameter
class StudentService {
  final CacheService _cache;
  StudentService(this._appDatabase, this._cache);
}
```

#### Step 4: CHECK FOR ERRORS
```
🔍 Check: Does CacheService import exist?
❌ No → Add import 'cache_service.dart';

🔍 Check: Is constructor signature correct?
✅ Yes → Proceed
```

#### Step 5: Update Providers
```dart
// 1. Update provider
Provider<StudentService>(
  create: (_) => StudentService(appDatabase, cacheService)
)
```

#### Step 6: CHECK FOR ERRORS
```
🔍 Check: Are appDatabase and cacheService defined?
✅ Yes → Proceed

🔍 Check: Is order correct (AppDatabase before CacheService)?
✅ Yes → Proceed
```

#### Step 7: FINAL VERIFICATION
```
🔍 Run full analysis
🔍 Check all files compile
🔍 Verify no breaking changes
✅ All clear → Move to next feature
```

## Error Fixing Strategies

### Strategy 1: Read Error Message Carefully
```
Error: The getter 'cache' isn't defined for the class 'StudentService'
       ↓
Analysis: Missing _cache field in StudentService
       ↓
Fix: Add 'final CacheService _cache;' to class
```

### Strategy 2: Check Dependencies
```
Error: Type 'CacheService' not found
       ↓
Check: Is CacheService file created?
Check: Is import statement present?
Check: Is import path correct?
       ↓
Fix: Add missing import or create missing file
```

### Strategy 3: Verify Generated Code
```
Error: Part file 'app_database.g.dart' not found
       ↓
Check: Has build_runner been executed?
       ↓
Fix: Run 'flutter pub run build_runner build'
```

### Strategy 4: Check Type Compatibility
```
Error: A value of type 'String' can't be assigned to 'int'
       ↓
Check: What type does the field expect?
Check: What type is being provided?
       ↓
Fix: Convert type or change field type
```

## When to Stop and Fix

### STOP IMMEDIATELY if you see:
- ❌ Compilation errors
- ❌ Missing imports
- ❌ Undefined classes/methods
- ❌ Type mismatches
- ❌ Syntax errors

### CAN CONTINUE with:
- ⚠️ Warnings (but note them for later)
- ⚠️ Info messages
- ⚠️ Linter suggestions

### MUST TEST before continuing:
- 🧪 After adding new dependencies
- 🧪 After modifying constructors
- 🧪 After changing database schema
- 🧪 After updating providers

## Error Log Template

Keep track of errors and fixes:

```markdown
## Error Log - [Feature Name]

### Error 1: [Error Message]
- **File**: path/to/file.dart
- **Line**: 42
- **Cause**: Missing import
- **Fix**: Added import 'cache_service.dart'
- **Status**: ✅ Fixed

### Error 2: [Error Message]
- **File**: path/to/file.dart
- **Line**: 56
- **Cause**: Wrong parameter count
- **Fix**: Added missing CacheService parameter
- **Status**: ✅ Fixed
```

## Summary: The Golden Rule

```
┌─────────────────────────────────────┐
│  NEVER PROCEED TO NEXT STEP WITH    │
│  UNRESOLVED COMPILATION ERRORS      │
│                                     │
│  1. Implement                       │
│  2. Check for errors                │
│  3. Fix ALL errors                  │
│  4. Verify fix works                │
│  5. THEN proceed                    │
└─────────────────────────────────────┘
```

## Enforcement

This rule applies to:
- ✅ All code implementations
- ✅ All file modifications
- ✅ All dependency changes
- ✅ All schema updates
- ✅ All service integrations

No exceptions. Quality over speed.
