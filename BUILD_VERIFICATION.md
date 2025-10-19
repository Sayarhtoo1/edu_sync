# Build Verification Checklist

## After Build Completes

### 1. Check Generated File Exists
- [ ] File `lib/database/app_database.g.dart` exists
- [ ] File size > 0 bytes

### 2. Check for Build Errors
Look at the build output for:
- [ ] No "error" messages
- [ ] Build completed successfully
- [ ] All files processed

### 3. Check IDE Problems Panel
- [ ] No red errors in `lib/services/cache_service.dart`
- [ ] No red errors in `lib/services/student_service.dart`
- [ ] No red errors in `lib/services/attendance_service.dart`
- [ ] No red errors in `lib/config/providers.dart`

### 4. Expected Remaining Warnings (OK to ignore)
- ⚠️ Unused fields in services (expected - not all services use caching yet)
- ⚠️ TODO comments (expected - future implementation)
- ⚠️ Deprecated withOpacity (low priority UI code)

### 5. If Build Succeeded
Run these commands to verify:
```bash
# Check file exists
dir lib\database\app_database.g.dart

# Try to compile (should work now)
flutter analyze
```

### 6. If Build Failed
Check for:
- Missing dependencies in pubspec.yaml
- Syntax errors in app_database.dart
- Conflicting table definitions

## Success Criteria

✅ Build completes without errors
✅ app_database.g.dart file generated
✅ No compilation errors in cache_service.dart
✅ No compilation errors in student_service.dart
✅ No compilation errors in attendance_service.dart

## Next Steps After Successful Build

1. Test app compilation: `flutter run`
2. Test offline functionality
3. Add OfflineIndicator to screens
4. Proceed to Phase 2 (Academic tables)
