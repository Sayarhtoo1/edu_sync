# Phase 2 Caching Implementation Plan

## Status: Schema Ready, Services Need Integration

### ✅ Completed:
1. Drift schema expanded with 3 new tables:
   - FinanceEntries
   - CustomForms  
   - FormResponses
2. CacheService methods added for all 3 tables
3. Schema version bumped to 3 with migration

### 🔧 Next Steps:

#### 1. Run Code Generation
```bash
dart run build_runner build --delete-conflicting-outputs
```

#### 2. Update FinanceService (2 methods)
Add to `getIncomes()` and `getExpenses()`:
```dart
try {
  // existing Supabase code
  await _cache.cacheFinanceEntries(response);
  return incomes;
} catch (e) {
  logger.w('Supabase failed, using cache: $e');
  final cached = await _cache.getCachedFinanceEntries(schoolId, 'Income');
  return cached.map((e) => Income.fromMap(e)).toList();
}
```

#### 3. Update CustomFormService (1 method)
Add to `getCustomFormsForSchool()`:
```dart
try {
  // existing Supabase code
  await _cache.cacheCustomForms(response);
  return forms;
} catch (e) {
  logger.w('Supabase failed, using cache: $e');
  final cached = await _cache.getCachedCustomForms(schoolId);
  return cached.map((e) => CustomForm.fromJson(e)).toList();
}
```

#### 4. Update FormResponseService (1 method)
Add to `getRecentResponses()`:
```dart
try {
  // existing Supabase code
  await _cache.cacheFormResponses(responses);
  return responses;
} catch (e) {
  logger.w('Supabase failed, using cache: $e');
  return await _cache.getCachedFormResponses(formId);
}
```

#### 5. Update providers.dart
Add CacheService parameter to services:
```dart
Provider<FinanceService>(create: (context) => FinanceService(context.read<CacheService>())),
Provider<CustomFormService>(create: (context) => CustomFormService(context.read<CacheService>())),
Provider<FormResponseService>(create: (context) => FormResponseService(context.read<CacheService>())),
```

### 📊 Impact:
- 3 more services with offline support
- 3 new cached tables
- ~200 lines of code changes

### ⏱️ Estimated Time: 30 minutes
