import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/income.dart';
import '../models/expense.dart';

class FinanceService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // === Income Methods ===

  Future<List<Income>> getIncomeRecords(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('income') // Assuming table name is 'income'
          .select()
          .eq('school_id', schoolId)
          .order('date', ascending: false);
      return response.map((data) => Income.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching income records: $e');
      return [];
    }
  }

  Future<Income?> createIncomeRecord(Income income) async {
    try {
      final response = await _supabaseClient
          .from('income')
          .insert(income.toMap()..remove('id'))
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
      await _supabaseClient
          .from('income')
          .update(income.toMap()..remove('id')) // Don't update ID
          .eq('id', income.id!); // Use null-check operator
      return true;
    } catch (e) {
      print('Error updating income record: $e');
      return false;
    }
  }

  Future<bool> deleteIncomeRecord(int incomeId) async {
    try {
      await _supabaseClient
          .from('income') // Corrected table
          .delete()
          .eq('id', incomeId); // Corrected parameter
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
          .from('expenses') // Assuming table name is 'expenses'
          .select()
          .eq('school_id', schoolId)
          .order('date', ascending: false);
      return response.map((data) => Expense.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching expense records: $e');
      return [];
    }
  }

  Future<Expense?> createExpenseRecord(Expense expense) async {
    try {
      final response = await _supabaseClient
          .from('expenses')
          .insert(expense.toMap()..remove('id'))
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
      await _supabaseClient
          .from('expenses')
          .update(expense.toMap()..remove('id'))
          .eq('id', expense.id!); // Use null-check operator
      return true;
    } catch (e) {
      print('Error updating expense record: $e');
      return false;
    }
  }

  Future<bool> deleteExpenseRecord(int expenseId) async {
    try {
      await _supabaseClient
          .from('expenses')
          .delete()
          .eq('id', expenseId);
      return true;
    } catch (e) {
      print('Error deleting expense record: $e');
      return false;
    }
  }
}
