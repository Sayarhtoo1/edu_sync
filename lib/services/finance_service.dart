import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/utils/logger.dart';
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
          .eq('entry_type', 'Income')
          .order('created_at', ascending: false);

      final incomes = response.map((record) {
        record['amount'] = (record['amount'] as num).toDouble();
        return Income.fromMap(record);
      }).toList();
      
      // Add donations as income
      final donations = await _getDonationIncomes(schoolId);
      incomes.addAll(donations);
      incomes.sort((a, b) => b.date.compareTo(a.date));
          
      return incomes;
    } catch (e) {
      logger.e('Error fetching income records: $e');
      return [];
    }
  }

  Future<List<Income>> _getDonationIncomes(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('donations')
          .select()
          .eq('school_id', schoolId)
          .eq('status', 'Received')
          .order('donation_date', ascending: false);
      
      return response.map((d) => Income(
        id: null,
        schoolId: schoolId,
        amount: (d['amount'] as num).toDouble(),
        description: '${d['donator_name']}${d['purpose'] != null ? ' - ${d['purpose']}' : ''}',
        date: DateTime.parse(d['donation_date']),
        category: 'Donation',
      )).toList();
    } catch (e) {
      logger.e('Error fetching donation incomes: $e');
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
      logger.e('Error creating income record: $e');
      return null;
    }
  }

  Future<bool> updateIncomeRecord(Income income) async {
    try {
      if (income.id == null) {
        logger.w('Error: Income ID is null, cannot update.');
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
      logger.e('Error updating income record: $e');
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
      logger.e('Error deleting income record: $e');
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
          .eq('entry_type', 'Expense')
          .order('created_at', ascending: false);

      final expenses = response.map((record) {
        record['amount'] = (record['amount'] as num).toDouble();
        return Expense.fromMap(record);
      }).toList();
      
      // Add salary payments as expenses
      final salaries = await _getSalaryExpensesAsList(schoolId);
      expenses.addAll(salaries);
      expenses.sort((a, b) => b.date.compareTo(a.date));
          
      return expenses;
    } catch (e) {
      logger.e('Error fetching expense records: $e');
      return [];
    }
  }

  Future<List<Expense>> _getSalaryExpensesAsList(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('salary_payments')
          .select('*, users!salary_payments_staff_id_fkey(full_name)')
          .eq('school_id', schoolId)
          .eq('status', 'Paid')
          .order('payment_date', ascending: false);
      
      return response.map((s) => Expense(
        id: null,
        schoolId: schoolId,
        amount: (s['amount'] as num).toDouble(),
        description: '${s['users']['full_name']} (${s['payment_month']})',
        date: DateTime.parse(s['payment_date']),
        category: 'Salary',
      )).toList();
    } catch (e) {
      logger.e('Error fetching salary expenses list: $e');
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
      logger.e('Error creating expense record: $e');
      return null;
    }
  }

  Future<bool> updateExpenseRecord(Expense expense) async {
    try {
      if (expense.id == null) {
        logger.w('Error: Expense ID is null, cannot update.');
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
      logger.e('Error updating expense record: $e');
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
      logger.e('Error deleting expense record: $e');
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
      logger.e('Error fetching financial summary with comparison: $e');
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

      // Add salary expenses
      final salaryExpenses = await _getSalaryExpenses(schoolId, startDate, endDate);
      totalOutcome += salaryExpenses;

      return {'income': totalIncome, 'outcome': totalOutcome};
    } catch (e) {
      logger.e('Error fetching financial summary: $e');
      return {'income': 0, 'outcome': 0};
    }
  }

  Future<double> _getSalaryExpenses(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabaseClient
          .from('salary_payments')
          .select('amount')
          .eq('school_id', schoolId)
          .eq('status', 'Paid')
          .gte('payment_date', startDate.toIso8601String())
          .lte('payment_date', endDate.toIso8601String());
      
      double total = 0;
      for (var record in response) {
        total += (record['amount'] as num).toDouble();
      }
      return total;
    } catch (e) {
      logger.e('Error fetching salary expenses: $e');
      return 0;
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
      logger.e('Error fetching financial chart data: $e');
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
      logger.e('Error fetching categorized income: $e');
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
      logger.e('Error fetching categorized expenses: $e');
      return {};
    }
  }

  Future<Map<String, double>> getCategoryBreakdown(int schoolId) async {
    try {
      final incomes = await getIncomes(schoolId);
      final expenses = await getExpenses(schoolId);
      
      final Map<String, double> breakdown = {};
      
      for (var income in incomes) {
        final category = income.category ?? 'Other Income';
        breakdown[category] = (breakdown[category] ?? 0) + income.amount;
      }
      
      for (var expense in expenses) {
        final category = expense.category ?? 'Other Expense';
        breakdown[category] = (breakdown[category] ?? 0) + expense.amount;
      }
      
      return breakdown;
    } catch (e) {
      logger.e('Error fetching category breakdown: $e');
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      final response = await _supabaseClient
          .from('finance_entries')
          .select('date, description, amount, entry_type, created_at')
          .eq('school_id', schoolId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('created_at', ascending: false); // Order by created_at descending for latest records

      return response.map((record) {
        return {
          'date': DateTime.parse(record['date']),
          'description': record['description'],
          'amount': record['amount'],
          'type': (record['entry_type'] as String).toLowerCase(),
        };
      }).toList();
    } catch (e) {
      logger.e('Error fetching transaction history: $e');
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
