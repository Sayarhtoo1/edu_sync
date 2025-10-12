# Amazon Q Automation Master Rules

## 🤖 Auto-Execution Framework

This file enables Amazon Q to automatically execute complex tasks with full autonomy using MCP servers and project context.

---

## 📚 Available Plans & Rules

### 1. Finance Module Enhancement
- **Plan:** `finance-module-enhancement-plan.md`
- **Rules:** `finance-automation-rules.md`
- **Routing:** `finance-routing-guide.md`
- **Status:** ✅ Ready for execution
- **MCP Access:** Supabase (database operations)

---

## 🎯 Execution Triggers

### Trigger Keywords for Finance Module:

**Start Phase 1:**
- "implement phase 1 of finance module"
- "start finance enhancement phase 1"
- "begin fee payment implementation"
- "execute finance automation phase 1"

**Start Phase 2:**
- "implement phase 2 of finance module"
- "start financial reports implementation"
- "begin budget management"

**Start Phase 3:**
- "implement phase 3 of finance module"
- "start approval workflow"
- "begin audit trail implementation"

**Full Automation:**
- "implement complete finance module enhancement"
- "execute full finance automation"
- "implement all finance phases"

---

## 🔧 MCP Server Configuration

### Supabase MCP
**Capabilities:**
- ✅ Execute SQL queries
- ✅ Apply database migrations
- ✅ List tables and schemas
- ✅ Query data for analysis
- ✅ Verify migrations

**Tools Available:**
- `execute_sql` - Run SQL queries
- `apply_migration` - Create and apply migrations
- `list_tables` - View database schema
- `list_extensions` - Check installed extensions
- `list_migrations` - View migration history

---

## 🚀 Automation Workflow

### Step 1: Context Loading
When triggered, Amazon Q will:
1. Read enhancement plan from `.amazonq/rules/finance-module-enhancement-plan.md`
2. Read automation rules from `.amazonq/rules/finance-automation-rules.md`
3. Load project structure via `listDirectory`
4. Check database schema via MCP `list_tables`
5. Identify existing code patterns via `fsRead`

### Step 2: Pre-Execution Validation
Amazon Q will verify:
- [ ] MCP server connectivity
- [ ] Database access
- [ ] Required dependencies
- [ ] File write permissions
- [ ] No conflicting files

### Step 3: Sequential Execution
Amazon Q will execute tasks in order:
1. **Database Layer** - Create migrations via MCP
2. **Model Layer** - Create data models
3. **Service Layer** - Implement business logic
4. **Widget Layer** - Create reusable UI components
5. **Screen Layer** - Compose full screens
6. **Routing Layer** - Add routes to router.dart (CRITICAL)
7. **Navigation Layer** - Update navigation in existing screens
8. **Integration Layer** - Connect providers and test end-to-end

### Step 4: Validation & Testing
After each task, Amazon Q will:
- Verify file creation
- Check compilation
- Validate database operations
- Test basic functionality
- Report status

### Step 5: Error Handling
If errors occur, Amazon Q will:
- Log the error
- Attempt automatic fix
- Rollback if necessary
- Report to user
- Continue with next task

---

## 📋 Automation Rules Summary

### Database Operations (via MCP)
```
ALWAYS use MCP for database operations:
- Check schema: list_tables()
- Create tables: apply_migration(name, query)
- Query data: execute_sql(query)
- Verify: execute_sql(validation_query)
```

### File Operations
```
ALWAYS follow hierarchy:
1. Models (lib/models/)
2. Services (lib/services/)
3. Widgets (lib/widgets/)
4. Screens (lib/screens/)
5. Config (lib/config/)
```

### Code Standards
```
ALWAYS maintain consistency:
- Follow existing patterns
- Use proper error handling
- Add logging statements
- Include null safety
- Write minimal code
```

### UI/UX Standards
```
ALWAYS use project colors:
- Income: #4CAF50 (Green)
- Expense: #F44336 (Red)
- Info: #2196F3 (Blue)
- Warning: #FF9800 (Orange)
- Background: #F5F7FA
```

---

## 🎨 Code Generation Templates

### Service Method Template
```dart
Future<List<Model>> getItems(int schoolId) async {
  try {
    final response = await _supabase
        .from('table_name')
        .select()
        .eq('school_id', schoolId)
        .order('created_at', ascending: false);
    return (response as List).map((e) => Model.fromJson(e)).toList();
  } catch (e) {
    logger.e('Error fetching items: $e');
    return [];
  }
}
```

### Screen Template
```dart
class ScreenName extends StatefulWidget {
  const ScreenName({super.key});

  @override
  State<ScreenName> createState() => _ScreenNameState();
}

class _ScreenNameState extends State<ScreenName> {
  bool _isLoading = true;
  List<Model> _data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId != null) {
      final data = await context.read<Service>().getData(schoolId);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Screen Title')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    // Implementation
  }
}
```

### Widget Template
```dart
class WidgetName extends StatelessWidget {
  final Model data;
  final VoidCallback? onTap;

  const WidgetName({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: // Implementation
    );
  }
}
```

---

## 🔍 Validation Checklist

### After Each File Creation:
- [ ] File created in correct location
- [ ] Imports are correct
- [ ] No syntax errors
- [ ] Follows naming conventions
- [ ] Includes error handling
- [ ] Has proper documentation

### After Each Database Operation:
- [ ] Migration applied successfully
- [ ] Table structure verified
- [ ] Indexes created
- [ ] Default data inserted
- [ ] Constraints working

### After Each Screen Implementation:
- [ ] Screen renders without errors
- [ ] Data loads correctly
- [ ] User interactions work
- [ ] Navigation functions
- [ ] Loading states display
- [ ] Empty states display
- [ ] Error states display

---

## 📊 Progress Reporting

### Amazon Q will report:
```
✅ Task: Create fee_payments migration
   Status: Completed
   Files: 1 migration file
   Database: Table created successfully

✅ Task: Create FeePayment model
   Status: Completed
   Files: lib/models/fee_payment.dart
   
✅ Task: Enhance FeePaymentService
   Status: Completed
   Files: lib/services/fee_payment_service.dart
   Methods: 6 new methods added

⏳ Task: Create FeePaymentManagementScreen
   Status: In Progress
   Progress: 60%
```

---

## 🚨 Error Handling Protocol

### If Database Error:
1. Log error details
2. Check MCP connection
3. Verify SQL syntax
4. Attempt rollback if needed
5. Report to user
6. Suggest manual fix if auto-fix fails

### If File Creation Error:
1. Check file path
2. Verify directory exists
3. Check write permissions
4. Attempt retry
5. Report to user

### If Compilation Error:
1. Check syntax
2. Verify imports
3. Check dependencies
4. Fix automatically if possible
5. Report to user with details

---

## 🎯 Success Metrics

### Automation Success When:
- ✅ All planned files created
- ✅ All migrations applied
- ✅ No compilation errors
- ✅ Basic functionality works
- ✅ Code follows standards
- ✅ Documentation complete

### Quality Metrics:
- Code coverage: Aim for 80%+
- Error handling: 100% of async operations
- Null safety: 100% compliance
- Performance: <100ms for UI operations
- Accessibility: WCAG 2.1 AA compliance

---

## 🔄 Continuous Improvement

### After Each Phase:
1. Review what worked well
2. Identify bottlenecks
3. Update automation rules
4. Improve templates
5. Enhance error handling

### Learning from Errors:
- Document common errors
- Create prevention rules
- Update validation checks
- Improve error messages

---

## 📞 User Interaction Points

### Amazon Q will ask user when:
- Critical decision needed
- Multiple valid approaches exist
- Destructive operation required
- Unclear requirements
- External dependency needed

### Amazon Q will inform user about:
- Phase completion
- Critical errors
- Major milestones
- Required manual steps
- Testing recommendations

---

## 🚀 Quick Start Commands

### For Users:
```
"Start finance module automation"
"Implement phase 1 automatically"
"Execute finance enhancement with MCP"
"Auto-implement fee payment management"
```

### For Developers:
```
"Show automation status"
"List completed tasks"
"Validate current implementation"
"Check database schema"
"Review generated code"
```

---

## 📖 Documentation

### Auto-Generated Docs:
- [ ] API documentation
- [ ] Database schema docs
- [ ] Component documentation
- [ ] User guide
- [ ] Developer guide

### Manual Docs Required:
- [ ] Deployment guide
- [ ] Configuration guide
- [ ] Troubleshooting guide
- [ ] Best practices

---

## ✅ Final Checklist

### Before Declaring Success:
- [ ] All phases completed
- [ ] All tests passed
- [ ] Documentation complete
- [ ] User can test features
- [ ] No critical bugs
- [ ] Performance acceptable
- [ ] Security validated
- [ ] Accessibility checked

---

## 🎉 Completion Message

When automation completes successfully, Amazon Q will report:

```
🎉 Finance Module Enhancement Complete!

✅ Phase 1: Critical Features - DONE
   - Fee Payment Management
   - Enhanced Finance Overview
   - Category Management

✅ Phase 2: Advanced Features - DONE
   - Financial Reports
   - Budget Management
   - Recurring Transactions

✅ Phase 3: Workflow & Automation - DONE
   - Approval Workflow
   - Financial Forecasting
   - Audit Trail

📊 Statistics:
   - Files Created: XX
   - Database Tables: XX
   - Lines of Code: XXXX
   - Features Implemented: XX

🚀 Next Steps:
   1. Test all features thoroughly
   2. Review generated code
   3. Deploy to staging
   4. Gather user feedback
   5. Plan next iteration

📚 Documentation:
   - User Guide: docs/finance_user_guide.md
   - API Docs: docs/finance_api.md
   - Developer Guide: docs/finance_dev_guide.md
```

---

**Status:** ✅ Active - Ready for Automation  
**Version:** 1.0  
**Last Updated:** 2025-01-XX
