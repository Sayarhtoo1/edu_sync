# Finance Screen Enhancements Design

This document outlines the architectural and design enhancements for the "Finance Overview" screen in the application. The goal is to create a more professional, mobile-friendly, and analytically powerful interface.

## 1. Tabbed Interface in `finance_overview_screen.dart`

To improve organization and user experience, the `finance_overview_screen.dart` will be refactored to use a `TabBar` and `TabBarView`. This will separate the high-level summary from a more detailed breakdown of financial data.

The `Scaffold` will contain an `AppBar` with a `TabBar` configured with two tabs:

-   **Overview**: This tab will house the existing components, including the summary cards (Total Income, Total Expenses, Net Profit) and the line chart showing financial trends over time.
-   **Breakdown**: This new tab will provide a more granular view of finances, featuring categorical analysis and a detailed transaction list.

### Example `build` method structure:

```dart
@override
Widget build(BuildContext context) {
  return DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: Text('Finance Overview'),
        bottom: TabBar(
          tabs: [
            Tab(text: 'Overview'),
            Tab(text: 'Breakdown'),
          ],
        ),
      ),
      body: TabBarView(
        children: [
          // 1. Overview Tab Widget
          _buildOverviewTab(),
          // 2. Breakdown Tab Widget
          _buildBreakdownTab(),
        ],
      ),
    ),
  );
}
```

## 2. "Breakdown" Tab Design

The "Breakdown" tab is designed to give administrators a deeper insight into income and expense categories. It will consist of two main components: pie charts for a visual breakdown and a detailed list of transactions.

### 2.1. Categorical Pie Charts

This section will feature two pie charts side-by-side (or in a column on smaller screens) to visualize the distribution of income and expenses by category.

-   **Package**: `fl_chart` will be used to create the pie charts.
-   **Income Categories Pie Chart**: Displays the proportion of total income from different categories (e.g., "Tuition Fees," "Donations," "Grants").
-   **Expense Categories Pie Chart**: Displays the proportion of total expenses across different categories (e.g., "Salaries," "Utilities," "Supplies").

Each chart will be interactive, allowing users to tap on a section to see more details.

### 2.2. Detailed Transaction List

Below the pie charts, a scrollable list will display individual income and expense transactions for the selected time period. This provides full transparency and allows for easy auditing.

-   **Combined List**: The list will fetch and display both income and expense records, sorted by date.
-   **List Item Details**: Each item in the list will be a `Card` or `ListTile` and clearly display:
    -   **Date**: The date of the transaction.
    -   **Description**: A brief description of the transaction.
    -   **Category**: The assigned income or expense category.
    -   **Amount**: The transaction amount, formatted as currency. Income and expense amounts could be color-coded (e.g., green for income, red for expense) for quick identification.

## 3. Data Model Enhancements

To support categorization, the `Income` and `Expense` models need to be updated.

### 3.1. `Income` Model (`lib/models/income.dart`)

A `category` field will be added to the `Income` class.

```dart
class Income {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String category; // New field

  Income({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });

  // ... existing methods (copyWith, fromMap, toMap) should be updated
}
```

### 3.2. `Expense` Model (`lib/models/expense.dart`)

Similarly, a `category` field will be added to the `Expense` class.

```dart
class Expense {
  final String id;
  final double amount;
  final String description;
  final DateTime date;
  final String category; // New field

  Expense({
    required this.id,
    required this.amount,
    required this.description,
    required this.date,
    required this.category,
  });

  // ... existing methods (copyWith, fromMap, toMap) should be updated
}
```

## 4. `FinanceService` Enhancements (`lib/services/finance_service.dart`)

New methods are required in the `FinanceService` to fetch the data needed for the new UI components.

### 4.1. Categorized Data Functions

These methods will aggregate financial data by category, which is necessary for the pie charts.

```dart
/// Aggregates total income for each category within the given date range.
/// Returns a map where keys are category names and values are total amounts.
Future<Map<String, double>> getCategorizedIncome(DateTime startDate, DateTime endDate);

/// Aggregates total expenses for each category within the given date range.
/// Returns a map where keys are category names and values are total amounts.
Future<Map<String, double>> getCategorizedExpenses(DateTime startDate, DateTime endDate);
```

### 4.2. Combined Transactions Function

This method will fetch a list of all income and expense transactions, allowing them to be displayed together in the detailed transaction list. A new wrapper class or a `Map` could be used to differentiate between income and expense items in the returned list.

```dart
/// Fetches a combined list of income and expense transactions, sorted by date.
/// Each item in the list should be identifiable as either an income or an expense.
/// A potential return type could be `List<Map<String, dynamic>>` or a list of a custom transaction model.
Future<List<dynamic>> getCombinedTransactions(DateTime startDate, DateTime endDate);