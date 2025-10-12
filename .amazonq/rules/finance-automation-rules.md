# Finance Module Automation Rules for Amazon Q

## 🤖 Automation Configuration

**Purpose:** Enable Amazon Q to automatically implement the Finance Module Enhancement Plan with full MCP server access for database operations.

**Reference Plan:** `.amazonq/rules/finance-module-enhancement-plan.md`

---

## 🔧 MCP Server Access Configuration

### Supabase MCP Server
- **Server:** Supabase MCP (already configured)
- **Capabilities:** 
  - Execute SQL queries via `execute_sql`
  - Apply migrations via `apply_migration`
  - List tables via `list_tables`
  - Query data for analysis
- **Authentication:** Configured in `.kilocode/mcp.json`

### Required Tools Access
```json
{
  "supabase": {
    "tools": [
      "execute_sql",
      "apply_migration",
      "list_tables",
      "list_extensions",
      "list_migrations"
    ]
  },
  "filesystem": {
    "tools": [
      "fsRead",
      "fsWrite",
      "fsReplace",
      "listDirectory",
      "fileSearch"
    ]
  }
}
```

---

## 📋 Automation Workflow Rules

### Rule 1: Database Schema Management
**Trigger:** When implementing any phase that requires database changes
**Actions:**
1. Check existing schema using `list_tables`
2. Create migration file with timestamp naming
3. Apply migration using `apply_migration`
4. Verify migration success with `execute_sql`
5. Update migration tracking

**Example:**
```
When creating finance_categories table:
1. Check if table exists: list_tables()
2. Create migration: apply_migration(name="create_finance_categories", query="CREATE TABLE...")
3. Verify: execute_sql("SELECT COUNT(*) FROM finance_categories")
```

### Rule 2: File Creation Hierarchy
**Trigger:** When creating new Flutter components
**Actions:**
1. Create models first (data layer)
2. Create services second (business logic)
3. Create widgets third (reusable UI)
4. Create screens last (composition)
5. **ALWAYS update router configuration** (lib/config/router.dart)
6. Update providers if needed
7. Update navigation in existing screens if needed

**Order:**
```
lib/models/ → lib/services/ → lib/widgets/ → lib/screens/ → lib/config/router.dart → Update navigation
```

**Router Update Rules:**
- Add GoRoute for each new screen
- Use descriptive path names (e.g., '/admin/fee-payment-management')
- Add route name for programmatic navigation
- Include path parameters if needed (e.g., ':id')
- Pass data via state.extra when needed
- Group related routes together
- Follow existing route patterns

### Rule 3: Dependency Management
**Trigger:** When new packages are required
**Actions:**
1. Read current `pubspec.yaml`
2. Add new dependencies in correct section
3. Maintain version compatibility
4. Add comments for package purpose
5. Run `flutter pub get` (inform user)

**Auto-add packages:**
- `fl_chart: ^0.66.0` for charts
- `pdf: ^3.10.0` for PDF generation
- `excel: ^4.0.0` for Excel export
- `printing: ^5.11.0` for printing

### Rule 4: Code Style Consistency
**Trigger:** When writing any Dart code
**Actions:**
1. Follow existing code patterns in project
2. Use consistent naming conventions
3. Add proper imports
4. Include error handling
5. Add logging statements
6. Write minimal, focused code

**Standards:**
- Services: `ClassName + Service` (e.g., `FeePaymentService`)
- Screens: `ScreenName + Screen` (e.g., `FeePaymentManagementScreen`)
- Widgets: `WidgetName + Widget` (e.g., `FeePaymentCard`)
- Models: `EntityName` (e.g., `FeePayment`)

### Rule 5: Database Query Patterns
**Trigger:** When writing service methods that query database
**Actions:**
1. Always use parameterized queries
2. Include proper error handling
3. Use `try-catch` blocks
4. Log errors with `logger.e()`
5. Return empty lists/null on error
6. Add proper type conversions

**Template:**
```dart
Future<List<Model>> getData(int schoolId) async {
  try {
    final response = await _supabase
        .from('table_name')
        .select()
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Model.fromJson(e)).toList();
  } catch (e) {
    logger.e('Error fetching data: $e');
    return [];
  }
}
```

---

## 🎯 Phase-Specific Automation Rules

### PHASE 1: Critical Features

#### Task 1.1: Fee Payment Management
**Auto-execute steps:**
1. ✅ Check `fee_payments` table schema via MCP
2. ✅ Enhance `FeePaymentService` with missing methods
3. ✅ Create `FeePaymentManagementScreen` with filters
4. ✅ Create `AddEditFeePaymentScreen` for CRUD
5. ✅ Create `FeePaymentCard` widget
6. ✅ **Add routes to `router.dart`:**
   - `/admin/fee-payment-management` → FeePaymentManagementScreen
   - `/admin/fee-payment-detail/:id` → FeePaymentDetailScreen
   - `/admin/add-fee-payment` → AddEditFeePaymentScreen
7. ✅ **Update FinanceOverviewScreen navigation** to include fee payments
8. ✅ Test database connectivity and navigation

**Validation:**
- Screen renders without errors
- Can fetch fee payments from database
- Can create new fee payment
- Filters work correctly

#### Task 1.2: Enhanced Finance Overview
**Auto-execute steps:**
1. ✅ Add `fl_chart` to `pubspec.yaml`
2. ✅ Create `FinancialTrendChart` widget
3. ✅ Create `CategoryBreakdownChart` widget
4. ✅ Modify `FinanceOverviewScreen` with tabs
5. ✅ Add chart data methods to `FinanceService`
6. ✅ Implement date range picker
7. ✅ Add real-time data refresh

**Validation:**
- Charts render with real data
- Tabs switch smoothly
- Date picker updates charts
- Performance is acceptable

#### Task 1.3: Category Management
**Auto-execute steps:**
1. ✅ Create migration for `finance_categories` table via MCP
2. ✅ Apply migration using `apply_migration`
3. ✅ Insert default categories via `execute_sql`
4. ✅ Create `FinanceCategory` model
5. ✅ Create `FinanceCategoryService`
6. ✅ Create `CategoryManagementScreen`
7. ✅ Update existing screens to use categories

**Validation:**
- Table created successfully
- Default categories inserted
- Can CRUD categories
- Categories appear in dropdowns

### PHASE 2: Advanced Features

#### Task 2.1: Financial Reports
**Auto-execute steps:**
1. ✅ Add PDF/Excel packages to `pubspec.yaml`
2. ✅ Create `FinancialReportService`
3. ✅ Create `PdfGenerator` utility
4. ✅ Create `FinancialReportsScreen`
5. ✅ Implement report generation methods
6. ✅ Add export functionality
7. ✅ Test PDF generation

**Validation:**
- Reports generate correctly
- PDF exports successfully
- Excel exports successfully
- Data accuracy verified

#### Task 2.2: Budget Management
**Auto-execute steps:**
1. ✅ Create `budgets` table migration via MCP
2. ✅ Apply migration
3. ✅ Create `Budget` model
4. ✅ Create `BudgetService`
5. ✅ Create `BudgetManagementScreen`
6. ✅ Create `BudgetProgressCard` widget
7. ✅ Implement budget tracking logic

**Validation:**
- Budgets can be created
- Progress tracking works
- Alerts trigger correctly
- Visual indicators accurate

#### Task 2.3: Recurring Transactions
**Auto-execute steps:**
1. ✅ Create `recurring_transactions` table via MCP
2. ✅ Create `RecurringTransaction` model
3. ✅ Create `RecurringTransactionService`
4. ✅ Create `RecurringTransactionsScreen`
5. ✅ Implement scheduler utility
6. ✅ Add auto-generation logic

**Validation:**
- Recurring items created
- Auto-generation works
- Frequency calculations correct
- Can pause/resume items

### PHASE 3: Workflow & Automation

#### Task 3.1: Approval Workflow
**Auto-execute steps:**
1. ✅ Create approval tables via MCP
2. ✅ Create approval models
3. ✅ Create approval service
4. ✅ Add approval UI components
5. ✅ Implement notification system
6. ✅ Add approval history view

#### Task 3.2: Financial Forecasting
**Auto-execute steps:**
1. ✅ Create forecast service
2. ✅ Implement prediction algorithms
3. ✅ Create forecast screen
4. ✅ Add visualization components
5. ✅ Implement what-if scenarios

#### Task 3.3: Audit Trail
**Auto-execute steps:**
1. ✅ Create `finance_audit_log` table via MCP
2. ✅ Implement audit logging in services
3. ✅ Create audit log viewer
4. ✅ Add filtering and search
5. ✅ Implement export functionality

---

## 🔄 Continuous Automation Rules

### Rule 6: Error Handling Pattern
**Always apply:**
```dart
try {
  // Database operation
  final result = await _supabase.from('table').select();
  return processResult(result);
} catch (e) {
  logger.e('Error in methodName: $e');
  // Return safe default
  return [];
}
```

### Rule 7: Loading States
**Always implement:**
```dart
bool _isLoading = false;

Future<void> _loadData() async {
  setState(() => _isLoading = true);
  try {
    // Fetch data
  } finally {
    setState(() => _isLoading = false);
  }
}
```

### Rule 8: Null Safety
**Always check:**
- Use `?.` for nullable access
- Provide default values with `??`
- Check null before operations
- Use `!` only when absolutely certain

### Rule 9: Performance Optimization
**Always consider:**
- Paginate large lists
- Cache frequently accessed data
- Debounce search inputs
- Use `const` constructors where possible
- Lazy load heavy components

### Rule 10: Accessibility
**Always include:**
- Semantic labels for screen readers
- Sufficient color contrast
- Touch targets min 48x48
- Keyboard navigation support
- Error messages that are clear

---

## 🧪 Testing Automation Rules

### Rule 11: Pre-Implementation Checks
**Before creating any component:**
1. ✅ Check if similar component exists
2. ✅ Verify database table exists (via MCP)
3. ✅ Confirm dependencies are available
4. ✅ Review existing code patterns
5. ✅ Plan file structure

### Rule 12: Post-Implementation Validation
**After creating any component:**
1. ✅ Verify file compiles without errors
2. ✅ Check imports are correct
3. ✅ Ensure proper error handling
4. ✅ Validate database queries work
5. ✅ Test basic functionality

### Rule 13: Integration Testing
**When connecting components:**
1. ✅ Test data flow from service to UI
2. ✅ Verify state management works
3. ✅ Check navigation between screens
4. ✅ Validate form submissions
5. ✅ Test error scenarios

---

## 📊 Progress Tracking Rules

### Rule 14: Task Completion Checklist
**For each task, verify:**
- [ ] Files created in correct locations
- [ ] Database migrations applied successfully
- [ ] Services implemented with error handling
- [ ] UI components render correctly
- [ ] Navigation routes added
- [ ] Data flows end-to-end
- [ ] No compilation errors
- [ ] Basic functionality tested

### Rule 15: Phase Completion Criteria
**Before moving to next phase:**
- [ ] All tasks in current phase completed
- [ ] All validation checks passed
- [ ] No critical bugs identified
- [ ] Code follows project standards
- [ ] Documentation updated
- [ ] User can test features

---

## 🚨 Error Recovery Rules

### Rule 16: Database Migration Failures
**If migration fails:**
1. Check error message via MCP
2. Verify table doesn't already exist
3. Check for constraint violations
4. Rollback if necessary
5. Fix SQL and retry
6. Document issue

### Rule 17: Compilation Errors
**If code doesn't compile:**
1. Check import statements
2. Verify package dependencies
3. Check for typos in names
4. Validate syntax
5. Review error messages
6. Fix and recompile

### Rule 18: Runtime Errors
**If app crashes:**
1. Check error logs
2. Verify null safety
3. Check database connectivity
4. Validate data types
5. Add defensive checks
6. Test thoroughly

---

## 🎨 UI/UX Automation Rules

### Rule 19: Consistent Styling
**Always use:**
```dart
// Colors from existing theme
Color(0xFF4CAF50) // Income/Success
Color(0xFFF44336) // Expense/Error
Color(0xFF2196F3) // Info/Primary
Color(0xFFFF9800) // Warning/Donation
Color(0xFFF5F7FA) // Background

// Spacing
EdgeInsets.all(16) // Standard padding
BorderRadius.circular(16) // Card radius
BorderRadius.circular(12) // Button radius
```

### Rule 20: Responsive Design
**Always implement:**
- Use `MediaQuery` for screen size
- Implement breakpoints for tablet/desktop
- Use `Flexible` and `Expanded` appropriately
- Test on multiple screen sizes
- Ensure touch targets are adequate

### Rule 21: Loading & Empty States
**Always provide:**
```dart
// Loading state
if (_isLoading) return Center(child: CircularProgressIndicator());

// Empty state
if (_data.isEmpty) return Center(
  child: Column(
    children: [
      Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
      Text('No data available'),
    ],
  ),
);
```

---

## 🔐 Security Automation Rules

### Rule 22: Data Validation
**Always validate:**
- User inputs before submission
- Amounts are positive numbers
- Dates are valid
- Required fields are filled
- Email formats are correct

### Rule 23: Permission Checks
**Always verify:**
- User has permission for action
- School ID matches user's school
- User role allows operation
- Sensitive data is protected

### Rule 24: SQL Injection Prevention
**Always use:**
- Parameterized queries
- Supabase client methods (not raw SQL)
- Input sanitization
- Type checking

---

## 📝 Documentation Automation Rules

### Rule 25: Code Comments
**Add comments for:**
- Complex business logic
- Non-obvious calculations
- Important decisions
- API integrations
- Workarounds

### Rule 26: Method Documentation
**Document:**
```dart
/// Fetches all fee payments for a school
/// 
/// [schoolId] The ID of the school
/// Returns list of [FeePayment] objects
/// Returns empty list on error
Future<List<FeePayment>> getAllPayments(int schoolId) async {
  // Implementation
}
```

---

## ✅ Execution Checklist

### Before Starting Automation:
- [ ] Finance enhancement plan reviewed
- [ ] MCP server connection verified
- [ ] Database access confirmed
- [ ] Project structure understood
- [ ] Existing code patterns identified

### During Automation:
- [ ] Follow phase order strictly
- [ ] Complete tasks sequentially
- [ ] Validate after each task
- [ ] Handle errors gracefully
- [ ] Document decisions

### After Automation:
- [ ] All features implemented
- [ ] All tests passed
- [ ] Documentation updated
- [ ] User guide created
- [ ] Deployment ready

---

## 🎯 Success Criteria

**Automation is successful when:**
1. ✅ All Phase 1 features working
2. ✅ Database migrations applied
3. ✅ UI components render correctly
4. ✅ Data flows end-to-end
5. ✅ No critical errors
6. ✅ Code follows standards
7. ✅ User can perform all operations
8. ✅ Performance is acceptable

---

## 🚀 Execution Command

**To start automation, user should say:**
```
"Implement Phase 1 of the finance module enhancement plan using the automation rules"
```

**Amazon Q will then:**
1. Read the enhancement plan
2. Access Supabase via MCP
3. Create necessary migrations
4. Generate all required files
5. Implement features sequentially
6. Validate each step
7. Report progress
8. Handle errors automatically

---

**Document Version:** 1.0  
**Last Updated:** 2025-01-XX  
**Status:** Active - Ready for Automation
