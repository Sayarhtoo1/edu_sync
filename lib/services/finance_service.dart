import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/income.dart';
import '../models/expense.dart';
import 'cache_service.dart';

class FinanceService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cacheService = CacheService();

  // === Income Methods ===

  Future<List<Income>> getIncomes(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('finance_entries')
          .select()
          .eq('school_id', schoolId)
          .eq('entry_type', 'Income');

      final incomes = response.map((record) {
        // Ensure amount is parsed as double
        record['amount'] = (record['amount'] as num).toDouble();
        return Income.fromMap(record);
      }).toList();
          
      return incomes;
    } catch (e) {
      print('Error fetching income records: $e');
      // Depending on the app's requirements, you might want to return an empty list
      // or re-throw the exception to be handled by the UI layer.
      return [];
    }
  }

  Future<Income?> createIncomeRecord(Income income) async {
    try {
      // Create a map with income data and add entry_type
      final dataMap = income.toMap()..remove('id');
      dataMap['entry_type'] = 'Income'; // Add entry_type field
      
      final response = await _supabaseClient
          .from('finance_entries') // Using the finance_entries table
          .insert(dataMap)
          .select()
          .single();
      return Income.fromMap(response);
    } catch (e) {
      print('Error creating income record: $e');
      return null;
    }
  }

  Future<bool> updateIncomeRecord(Income income) async {
    try {
      if (income.id == null) {
        print('Error: Income ID is null, cannot update.');
        return false;
      }
      
      // Create a map with income data and add entry_type
      final dataMap = income.toMap()..remove('id');
      dataMap['entry_type'] = 'Income'; // Add entry_type field
      
      await _supabaseClient
          .from('finance_entries') // Using the finance_entries table
          .update(dataMap)
          .eq('id', income.id!)
          .eq('entry_type', 'Income'); // Ensure we're updating an Income record
      return true;
    } catch (e) {
      print('Error updating income record: $e');
      return false;
    }
  }

  Future<bool> deleteIncomeRecord(int incomeId) async {
    try {
      await _supabaseClient
          .from('finance_entries') // Using the finance_entries table
          .delete()
          .eq('id', incomeId)
          .eq('entry_type', 'Income'); // Ensure we're deleting an Income record
      return true;
    } catch (e) {
      print('Error deleting income record: $e');
      return false;
    }
  }

  // === Expense Methods ===

  Future<List<Expense>> getExpenses(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('finance_entries')
          .select()
          .eq('school_id', schoolId)
          .eq('entry_type', 'Expense');

      final expenses = response.map((record) {
        // Ensure amount is parsed as double
        record['amount'] = (record['amount'] as num).toDouble();
        return Expense.fromMap(record);
      }).toList();
          
      return expenses;
    } catch (e) {
      print('Error fetching expense records: $e');
      return [];
    }
  }

  Future<Expense?> createExpenseRecord(Expense expense) async {
    try {
      // Create a map with expense data and add entry_type
      final dataMap = expense.toMap()..remove('id');
      dataMap['entry_type'] = 'Expense'; // Add entry_type field
      
      final response = await _supabaseClient
          .from('finance_entries') // Using the finance_entries table
          .insert(dataMap)
          .select()
          .single();
      return Expense.fromMap(response);
    } catch (e) {
      print('Error creating expense record: $e');
      return null;
    }
  }

  Future<bool> updateExpenseRecord(Expense expense) async {
    try {
      if (expense.id == null) {
        print('Error: Expense ID is null, cannot update.');
        return false;
      }
      
      // Create a map with expense data and add entry_type
      final dataMap = expense.toMap()..remove('id');
      dataMap['entry_type'] = 'Expense'; // Add entry_type field
      
      await _supabaseClient
          .from('finance_entries') // Using the finance_entries table
          .update(dataMap)
          .eq('id', expense.id!)
          .eq('entry_type', 'Expense'); // Ensure we're updating an Expense record
      return true;
    } catch (e) {
      print('Error updating expense record: $e');
      return false;
    }
  }

  Future<bool> deleteExpenseRecord(int expenseId) async {
    try {
      await _supabaseClient
          .from('finance_entries') // Using the finance_entries table
          .delete()
          .eq('id', expenseId)
          .eq('entry_type', 'Expense'); // Ensure we're deleting an Expense record
      return true;
    } catch (e) {
      print('Error deleting expense record: $e');
      return false;
    }
  }

  // === Financial Overview Methods ===

  /// Fetches the total income and outcome for the specified period.
  /// It queries the 'finance_entries' table, filtering by date and summing up amounts
  /// based on the 'entry_type' ('Income' or 'Expense').
  Future<FinancialSummary> getFinancialSummaryWithComparison(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      // Fetch current period summary
      final currentSummary = await getFinancialSummary(schoolId, startDate, endDate);

      // Calculate previous period
      final previousEndDate = startDate.subtract(const Duration(days: 1));
      final previousStartDate = DateTime(previousEndDate.year, previousEndDate.month, 1);
      
      // Fetch previous period summary
      final previousSummary = await getFinancialSummary(schoolId, previousStartDate, previousEndDate);

      // Calculate percentage changes
      final incomeChange = _calculatePercentageChange(previousSummary['income']!, currentSummary['income']!);
      final expenseChange = _calculatePercentageChange(previousSummary['outcome']!, currentSummary['outcome']!);
      final netProfitChange = _calculatePercentageChange(
        previousSummary['income']! - previousSummary['outcome']!,
        currentSummary['income']! - currentSummary['outcome']!,
      );

      return FinancialSummary(
        totalIncome: currentSummary['income']!,
        totalOutcome: currentSummary['outcome']!,
        incomePercentageChange: incomeChange,
        expensePercentageChange: expenseChange,
        netProfitPercentageChange: netProfitChange,
      );
    } catch (e) {
      print('Error fetching financial summary with comparison: $e');
      return FinancialSummary(totalIncome: 0, totalOutcome: 0);
    }
  }

  double _calculatePercentageChange(double previous, double current) {
    if (previous == 0) {
      return current > 0 ? 100.0 : 0.0;
    }
    return ((current - previous) / previous) * 100;
  }

  Future<Map<String, double>> getFinancialSummary(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabaseClient
          .from('finance_entries')
          .select('entry_type, amount')
          .eq('school_id', schoolId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      double totalIncome = 0;
      double totalOutcome = 0;

      for (var record in response) {
        if (record['entry_type'] == 'Income') {
          totalIncome += record['amount'];
        } else if (record['entry_type'] == 'Expense') {
          totalOutcome += record['amount'];
        }
      }

      return {'income': totalIncome, 'outcome': totalOutcome};
    } catch (e) {
      print('Error fetching financial summary: $e');
      return {'income': 0, 'outcome': 0};
    }
  }

  /// Fetches aggregated data points for the financial chart over a specified period.
  /// It groups entries by date and calculates the total income and outcome for each day.
  Future<List<FinancialDataPoint>> getFinancialChartData(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabaseClient
          .from('finance_entries')
          .select('date, entry_type, amount')
          .eq('school_id', schoolId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: true);

      final Map<DateTime, FinancialDataPoint> dataMap = {};

      for (var record in response) {
        final date = DateTime.parse(record['date']).toLocal();
        final day = DateTime(date.year, date.month, date.day);
        final amount = record['amount'] as double;

        final dataPoint = dataMap.putIfAbsent(
          day,
          () => FinancialDataPoint(date: day, totalIncome: 0, totalOutcome: 0),
        );

        if (record['entry_type'] == 'Income') {
          dataMap[day] = FinancialDataPoint(
            date: day,
            totalIncome: dataPoint.totalIncome + amount,
            totalOutcome: dataPoint.totalOutcome,
          );
        } else if (record['entry_type'] == 'Expense') {
          dataMap[day] = FinancialDataPoint(
            date: day,
            totalIncome: dataPoint.totalIncome,
            totalOutcome: dataPoint.totalOutcome + amount,
          );
        }
      }

      return dataMap.values.toList();
    } catch (e) {
      print('Error fetching financial chart data: $e');
      return [];
    }
  }

  Future<Map<String, double>> getCategorizedIncome(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabaseClient
          .from('finance_entries')
          .select('description, amount')
          .eq('school_id', schoolId)
          .eq('entry_type', 'Income')
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      final Map<String, double> categorizedIncome = {};
      for (var record in response) {
        final description = record['description'] as String? ?? 'Uncategorized';
        final amount = record['amount'] as double;
        categorizedIncome[description] = (categorizedIncome[description] ?? 0) + amount;
      }
      return categorizedIncome;
    } catch (e) {
      print('Error fetching categorized income: $e');
      return {};
    }
  }

  Future<Map<String, double>> getCategorizedExpenses(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabaseClient
          .from('finance_entries')
          .select('description, amount')
          .eq('school_id', schoolId)
          .eq('entry_type', 'Expense')
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      final Map<String, double> categorizedExpenses = {};
      for (var record in response) {
        final description = record['description'] as String? ?? 'Uncategorized';
        final amount = record['amount'] as double;
        categorizedExpenses[description] = (categorizedExpenses[description] ?? 0) + amount;
      }
      return categorizedExpenses;
    } catch (e) {
      print('Error fetching categorized expenses: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabaseClient
          .from('finance_entries')
          .select('date, description, amount, entry_type')
          .eq('school_id', schoolId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);

      return response.map((record) {
        return {
          'date': DateTime.parse(record['date']),
          'description': record['description'],
          'amount': record['amount'],
          'type': (record['entry_type'] as String).toLowerCase(),
        };
      }).toList();
    } catch (e) {
      print('Error fetching transaction history: $e');
      return [];
    }
  }
}

class FinancialSummary {
  final double totalIncome;
  final double totalOutcome;
  final double incomePercentageChange;
  final double expensePercentageChange;
  final double netProfitPercentageChange;

  FinancialSummary({
    required this.totalIncome,
    required this.totalOutcome,
    this.incomePercentageChange = 0.0,
    this.expensePercentageChange = 0.0,
    this.netProfitPercentageChange = 0.0,
  });
}

class FinancialDataPoint {
  final DateTime date;
  final double totalIncome;
  final double totalOutcome;

  FinancialDataPoint({
    required this.date,
    required this.totalIncome,
    required this.totalOutcome,
  });
}
