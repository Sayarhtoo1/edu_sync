# Finance Module Routing & Navigation Guide

## 📍 Complete Route Map

This document provides a comprehensive guide for all routing and navigation changes required for the Finance Module Enhancement.

---

## 🗺️ Current Finance Routes

### Existing Routes (Already in router.dart):
```dart
// Finance Overview
GoRoute(
  path: '/admin/finance-management',
  builder: (context, state) => const FinanceOverviewScreen(),
),

// Income Management
GoRoute(
  path: '/admin/income-management',
  builder: (context, state) => const IncomeManagementScreen(),
),

// Expense Management
GoRoute(
  path: '/admin/expense-management',
  builder: (context, state) => const ExpenseManagementScreen(),
),

// Donation Management
GoRoute(
  path: '/admin/donation-management',
  builder: (context, state) => const DonationManagementScreen(),
),

// Salary Management
GoRoute(
  path: '/admin/salary-management',
  builder: (context, state) => const SalaryManagementScreen(),
),

// Fee Structure Management
GoRoute(
  path: '/admin/fee-management',
  builder: (context, state) => const FeeStructureManagementScreen(),
),
```

---

## 🆕 New Routes to Add

### Phase 1: Critical Features

#### 1. Fee Payment Management Routes
```dart
// Main fee payment management screen
GoRoute(
  path: '/admin/fee-payment-management',
  name: 'fee-payment-management',
  builder: (context, state) => const FeePaymentManagementScreen(),
),

// Fee payment detail view
GoRoute(
  path: '/admin/fee-payment-detail/:paymentId',
  name: 'fee-payment-detail',
  builder: (context, state) {
    final paymentId = state.pathParameters['paymentId']!;
    return FeePaymentDetailScreen(paymentId: paymentId);
  },
),

// Add/Edit fee payment
GoRoute(
  path: '/admin/add-fee-payment',
  name: 'add-fee-payment',
  builder: (context, state) => AddEditFeePaymentScreen(
    payment: state.extra as FeePayment?,
  ),
),

// Outstanding fees by class
GoRoute(
  path: '/admin/outstanding-fees/:classId',
  name: 'outstanding-fees',
  builder: (context, state) {
    final classId = int.parse(state.pathParameters['classId']!);
    return OutstandingFeesScreen(classId: classId);
  },
),

// Student payment history
GoRoute(
  path: '/admin/student-payment-history/:studentId',
  name: 'student-payment-history',
  builder: (context, state) {
    final studentId = int.parse(state.pathParameters['studentId']!);
    return StudentPaymentHistoryScreen(studentId: studentId);
  },
),
```

#### 2. Category Management Routes
```dart
// Category management screen
GoRoute(
  path: '/admin/finance-categories',
  name: 'finance-categories',
  builder: (context, state) => const CategoryManagementScreen(),
),

// Add/Edit category
GoRoute(
  path: '/admin/add-finance-category',
  name: 'add-finance-category',
  builder: (context, state) => AddEditCategoryScreen(
    category: state.extra as FinanceCategory?,
  ),
),
```

### Phase 2: Advanced Features

#### 3. Financial Reports Routes
```dart
// Reports dashboard
GoRoute(
  path: '/admin/financial-reports',
  name: 'financial-reports',
  builder: (context, state) => const FinancialReportsScreen(),
),

// Profit & Loss report
GoRoute(
  path: '/admin/reports/profit-loss',
  name: 'profit-loss-report',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>?;
    return ProfitLossReportScreen(
      startDate: extra?['startDate'] as DateTime?,
      endDate: extra?['endDate'] as DateTime?,
    );
  },
),

// Cash flow report
GoRoute(
  path: '/admin/reports/cash-flow',
  name: 'cash-flow-report',
  builder: (context, state) {
    final extra = state.extra as Map<String, dynamic>?;
    return CashFlowReportScreen(
      startDate: extra?['startDate'] as DateTime?,
      endDate: extra?['endDate'] as DateTime?,
    );
  },
),

// Fee collection report
GoRoute(
  path: '/admin/reports/fee-collection',
  name: 'fee-collection-report',
  builder: (context, state) => const FeeCollectionReportScreen(),
),
```

#### 4. Budget Management Routes
```dart
// Budget management dashboard
GoRoute(
  path: '/admin/budget-management',
  name: 'budget-management',
  builder: (context, state) => const BudgetManagementScreen(),
),

// Budget tracking screen
GoRoute(
  path: '/admin/budget-tracking',
  name: 'budget-tracking',
  builder: (context, state) => const BudgetTrackingScreen(),
),

// Add/Edit budget
GoRoute(
  path: '/admin/add-budget',
  name: 'add-budget',
  builder: (context, state) => AddEditBudgetScreen(
    budget: state.extra as Budget?,
  ),
),

// Budget detail view
GoRoute(
  path: '/admin/budget-detail/:budgetId',
  name: 'budget-detail',
  builder: (context, state) {
    final budgetId = state.pathParameters['budgetId']!;
    return BudgetDetailScreen(budgetId: budgetId);
  },
),
```

#### 5. Recurring Transactions Routes
```dart
// Recurring transactions screen
GoRoute(
  path: '/admin/recurring-transactions',
  name: 'recurring-transactions',
  builder: (context, state) => const RecurringTransactionsScreen(),
),

// Add/Edit recurring transaction
GoRoute(
  path: '/admin/add-recurring-transaction',
  name: 'add-recurring-transaction',
  builder: (context, state) => AddEditRecurringTransactionScreen(
    transaction: state.extra as RecurringTransaction?,
  ),
),
```

### Phase 3: Workflow & Automation

#### 6. Approval Workflow Routes
```dart
// Approval dashboard
GoRoute(
  path: '/admin/finance-approvals',
  name: 'finance-approvals',
  builder: (context, state) => const FinanceApprovalsScreen(),
),

// Approval detail
GoRoute(
  path: '/admin/approval-detail/:approvalId',
  name: 'approval-detail',
  builder: (context, state) {
    final approvalId = state.pathParameters['approvalId']!;
    return ApprovalDetailScreen(approvalId: approvalId);
  },
),

// Approval rules management
GoRoute(
  path: '/admin/approval-rules',
  name: 'approval-rules',
  builder: (context, state) => const ApprovalRulesScreen(),
),
```

#### 7. Financial Forecasting Routes
```dart
// Forecast dashboard
GoRoute(
  path: '/admin/financial-forecast',
  name: 'financial-forecast',
  builder: (context, state) => const FinancialForecastScreen(),
),

// What-if scenarios
GoRoute(
  path: '/admin/forecast-scenarios',
  name: 'forecast-scenarios',
  builder: (context, state) => const ForecastScenariosScreen(),
),
```

#### 8. Audit Trail Routes
```dart
// Audit log viewer
GoRoute(
  path: '/admin/finance-audit-log',
  name: 'finance-audit-log',
  builder: (context, state) => const FinanceAuditLogScreen(),
),

// Audit detail
GoRoute(
  path: '/admin/audit-detail/:auditId',
  name: 'audit-detail',
  builder: (context, state) {
    final auditId = state.pathParameters['auditId']!;
    return AuditDetailScreen(auditId: auditId);
  },
),
```

---

## 🔗 Navigation Updates in Existing Screens

### 1. FinanceOverviewScreen Updates

**Add new navigation cards:**
```dart
// In _buildContent() method, add:

// Fee Payments Card
_buildCard(
  context,
  title: 'Fee Payments',
  subtitle: 'Track student fee payments',
  icon: Icons.payment,
  color: const Color(0xFF9C27B0),
  onTap: () => context.push('/admin/fee-payment-management'),
),

// Financial Reports Card
_buildCard(
  context,
  title: 'Financial Reports',
  subtitle: 'Generate and view reports',
  icon: Icons.assessment,
  color: const Color(0xFF2196F3),
  onTap: () => context.push('/admin/financial-reports'),
),

// Budgets Card
_buildCard(
  context,
  title: 'Budgets',
  subtitle: 'Plan and track budgets',
  icon: Icons.account_balance,
  color: const Color(0xFF00BCD4),
  onTap: () => context.push('/admin/budget-management'),
),

// Categories Card
_buildCard(
  context,
  title: 'Categories',
  subtitle: 'Manage finance categories',
  icon: Icons.category,
  color: const Color(0xFF795548),
  onTap: () => context.push('/admin/finance-categories'),
),
```

### 2. ModernAdminDashboard Updates

**Add finance quick actions:**
```dart
// In admin drawer or quick actions section:

ListTile(
  leading: const Icon(Icons.payment),
  title: const Text('Fee Payments'),
  onTap: () => context.push('/admin/fee-payment-management'),
),

ListTile(
  leading: const Icon(Icons.assessment),
  title: const Text('Financial Reports'),
  onTap: () => context.push('/admin/financial-reports'),
),

ListTile(
  leading: const Icon(Icons.account_balance),
  title: const Text('Budget Management'),
  onTap: () => context.push('/admin/budget-management'),
),
```

### 3. Income/Expense Management Screens

**Add category filter navigation:**
```dart
// Add button to manage categories
IconButton(
  icon: const Icon(Icons.settings),
  onTap: () => context.push('/admin/finance-categories'),
  tooltip: 'Manage Categories',
),
```

### 4. Student Management Screen

**Add fee payment quick access:**
```dart
// In student detail view or actions:
IconButton(
  icon: const Icon(Icons.payment),
  onTap: () => context.push('/admin/student-payment-history/$studentId'),
  tooltip: 'Payment History',
),
```

---

## 🎯 Navigation Patterns

### Pattern 1: Simple Navigation
```dart
// Navigate to a screen
context.push('/admin/fee-payment-management');

// Navigate with named route
context.pushNamed('fee-payment-management');
```

### Pattern 2: Navigation with Parameters
```dart
// Using path parameters
context.push('/admin/fee-payment-detail/$paymentId');

// Using named route with parameters
context.pushNamed(
  'fee-payment-detail',
  pathParameters: {'paymentId': paymentId},
);
```

### Pattern 3: Navigation with Data
```dart
// Pass data via extra
context.push(
  '/admin/add-fee-payment',
  extra: existingPayment, // Pass FeePayment object
);

// Named route with extra
context.pushNamed(
  'add-fee-payment',
  extra: existingPayment,
);
```

### Pattern 4: Navigation with Result
```dart
// Navigate and wait for result
final result = await context.push('/admin/add-fee-payment');
if (result == true) {
  // Refresh data
  _loadData();
}

// Return result when popping
Navigator.pop(context, true);
```

### Pattern 5: Replace Navigation
```dart
// Replace current route
context.pushReplacement('/admin/fee-payment-management');

// Go to route (clears stack)
context.go('/admin/fee-payment-management');
```

---

## 📱 Deep Link Support

### Configure Deep Links for Finance Module

**Android (android/app/src/main/AndroidManifest.xml):**
```xml
<intent-filter>
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data
    android:scheme="edusync"
    android:host="finance" />
</intent-filter>
```

**iOS (ios/Runner/Info.plist):**
```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>edusync</string>
    </array>
  </dict>
</array>
```

**Deep Link Examples:**
- `edusync://finance/payments` → Fee Payment Management
- `edusync://finance/reports` → Financial Reports
- `edusync://finance/budgets` → Budget Management

---

## 🧪 Navigation Testing Checklist

### For Each New Route:
- [ ] Route is added to router.dart
- [ ] Route has a unique path
- [ ] Route has a descriptive name
- [ ] Navigation works from all entry points
- [ ] Back button works correctly
- [ ] Data is passed correctly
- [ ] Deep links work (if applicable)
- [ ] Route is accessible based on user role

### For Each Navigation Update:
- [ ] Navigation button/card is visible
- [ ] Navigation triggers correct route
- [ ] Loading states are handled
- [ ] Error states are handled
- [ ] User can navigate back
- [ ] Navigation is intuitive

---

## 🔒 Role-Based Route Protection

### Add Route Guards
```dart
// In router.dart redirect function:
final role = await authService.getUserRole();

// Protect finance routes
if (state.matchedLocation.startsWith('/admin/finance') ||
    state.matchedLocation.startsWith('/admin/fee-payment') ||
    state.matchedLocation.startsWith('/admin/budget')) {
  if (role != UserRole.Admin.name && role != UserRole.Manager.name) {
    return '/'; // Redirect unauthorized users
  }
}
```

---

## 📊 Route Organization

### Recommended Route Structure in router.dart:
```dart
routes: [
  // ... existing routes ...
  
  // ========== FINANCE MODULE ROUTES ==========
  
  // Finance Overview
  GoRoute(path: '/admin/finance-management', ...),
  
  // Income & Expense
  GoRoute(path: '/admin/income-management', ...),
  GoRoute(path: '/admin/expense-management', ...),
  
  // Fee Payments (NEW)
  GoRoute(path: '/admin/fee-payment-management', ...),
  GoRoute(path: '/admin/fee-payment-detail/:paymentId', ...),
  GoRoute(path: '/admin/add-fee-payment', ...),
  
  // Donations & Salaries
  GoRoute(path: '/admin/donation-management', ...),
  GoRoute(path: '/admin/salary-management', ...),
  
  // Categories (NEW)
  GoRoute(path: '/admin/finance-categories', ...),
  
  // Reports (NEW)
  GoRoute(path: '/admin/financial-reports', ...),
  GoRoute(path: '/admin/reports/profit-loss', ...),
  GoRoute(path: '/admin/reports/cash-flow', ...),
  
  // Budgets (NEW)
  GoRoute(path: '/admin/budget-management', ...),
  GoRoute(path: '/admin/budget-tracking', ...),
  
  // Recurring Transactions (NEW)
  GoRoute(path: '/admin/recurring-transactions', ...),
  
  // Approvals (NEW)
  GoRoute(path: '/admin/finance-approvals', ...),
  
  // Audit (NEW)
  GoRoute(path: '/admin/finance-audit-log', ...),
  
  // ========== END FINANCE MODULE ==========
]
```

---

## ✅ Implementation Checklist

### Phase 1 Routes:
- [ ] Fee Payment Management routes (5 routes)
- [ ] Category Management routes (2 routes)
- [ ] Update FinanceOverviewScreen navigation
- [ ] Update ModernAdminDashboard navigation

### Phase 2 Routes:
- [ ] Financial Reports routes (4 routes)
- [ ] Budget Management routes (4 routes)
- [ ] Recurring Transactions routes (2 routes)

### Phase 3 Routes:
- [ ] Approval Workflow routes (3 routes)
- [ ] Financial Forecasting routes (2 routes)
- [ ] Audit Trail routes (2 routes)

### Testing:
- [ ] All routes navigate correctly
- [ ] Back navigation works
- [ ] Deep links work
- [ ] Role-based access works
- [ ] Data passing works
- [ ] No navigation loops

---

**Document Version:** 1.0  
**Last Updated:** 2025-01-XX  
**Status:** Ready for Implementation
