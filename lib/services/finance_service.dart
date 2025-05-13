import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/income.dart';
import '../models/expense.dart';

class FinanceService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // === Income Methods ===

  Future<List<Income>> getIncomeRecords(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('finance_entries') // Using the finance_entries table
          .select()
          .eq('school_id', schoolId)
          .eq('entry_type', 'Income') // Filter by entry_type = Income
          .order('date', ascending: false);
      return response.map((data) => Income.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching income records: $e');
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

  Future<List<Expense>> getExpenseRecords(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('finance_entries') // Using the finance_entries table
          .select()
          .eq('school_id', schoolId)
          .eq('entry_type', 'Expense') // Filter by entry_type = Expense
          .order('date', ascending: false);
      return response.map((data) => Expense.fromMap(data)).toList();
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
}
