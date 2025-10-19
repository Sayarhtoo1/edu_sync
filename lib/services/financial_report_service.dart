import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/utils/logger.dart';
import 'package:edu_sync/models/financial_report.dart';

class FinancialReportService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getProfitLossData(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      final income = await _supabase
          .from('finance_entries')
          .select('amount, category')
          .eq('school_id', schoolId)
          .eq('entry_type', 'Income')
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      final expense = await _supabase
          .from('finance_entries')
          .select('amount, category')
          .eq('school_id', schoolId)
          .eq('entry_type', 'Expense')
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String());

      final totalIncome = (income as List).fold<double>(0, (sum, item) => sum + (item['amount'] as num).toDouble());
      final totalExpense = (expense as List).fold<double>(0, (sum, item) => sum + (item['amount'] as num).toDouble());

      final incomeByCategory = <String, double>{};
      for (var item in income) {
        final cat = item['category'] ?? 'Uncategorized';
        incomeByCategory[cat] = (incomeByCategory[cat] ?? 0) + (item['amount'] as num).toDouble();
      }

      final expenseByCategory = <String, double>{};
      for (var item in expense) {
        final cat = item['category'] ?? 'Uncategorized';
        expenseByCategory[cat] = (expenseByCategory[cat] ?? 0) + (item['amount'] as num).toDouble();
      }

      return {
        'totalIncome': totalIncome,
        'totalExpense': totalExpense,
        'netProfit': totalIncome - totalExpense,
        'incomeByCategory': incomeByCategory,
        'expenseByCategory': expenseByCategory,
      };
    } catch (e) {
      logger.e('Error fetching profit/loss data: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getCashFlowData(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      final entries = await _supabase
          .from('finance_entries')
          .select('amount, entry_type, date')
          .eq('school_id', schoolId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date');

      double balance = 0;
      final cashFlow = <Map<String, dynamic>>[];

      for (var entry in entries as List) {
        final amount = (entry['amount'] as num).toDouble();
        balance += entry['entry_type'] == 'Income' ? amount : -amount;
        cashFlow.add({
          'date': DateTime.parse(entry['date']),
          'amount': amount,
          'type': entry['entry_type'],
          'balance': balance,
        });
      }

      return {
        'cashFlow': cashFlow,
        'finalBalance': balance,
      };
    } catch (e) {
      logger.e('Error fetching cash flow data: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getFeeCollectionData(int schoolId, DateTime startDate, DateTime endDate) async {
    try {
      final payments = await _supabase
          .from('fee_payments')
          .select('amount_paid, payment_date, status, student_id, students!inner(school_id)')
          .eq('students.school_id', schoolId)
          .gte('payment_date', startDate.toIso8601String())
          .lte('payment_date', endDate.toIso8601String());

      final totalCollected = (payments as List).fold<double>(0, (sum, item) => sum + (item['amount_paid'] as num).toDouble());

      return {
        'totalCollected': totalCollected,
        'paymentCount': payments.length,
      };
    } catch (e) {
      logger.e('Error fetching fee collection data: $e');
      return {};
    }
  }

  Future<FinancialReport> generateReport(String type, int schoolId, DateTime startDate, DateTime endDate) async {
    Map<String, dynamic> data;

    switch (type) {
      case 'profit_loss':
        data = await getProfitLossData(schoolId, startDate, endDate);
        break;
      case 'cash_flow':
        data = await getCashFlowData(schoolId, startDate, endDate);
        break;
      case 'fee_collection':
        data = await getFeeCollectionData(schoolId, startDate, endDate);
        break;
      default:
        data = {};
    }

    return FinancialReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      startDate: startDate,
      endDate: endDate,
      data: data,
      generatedAt: DateTime.now(),
    );
  }
}
