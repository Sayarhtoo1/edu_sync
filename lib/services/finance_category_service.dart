import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/finance_category.dart';
import '../utils/logger.dart';

class FinanceCategoryService {
  final SupabaseClient _supabase;

  FinanceCategoryService(this._supabase);

  Future<List<FinanceCategory>> getCategories(int? schoolId) async {
    try {
      final response = await _supabase
          .from('finance_categories')
          .select()
          .or('school_id.is.null,school_id.eq.$schoolId')
          .eq('is_active', true)
          .order('name');
      return (response as List).map((e) => FinanceCategory.fromJson(e)).toList();
    } catch (e) {
      logger.e('Error fetching categories: $e');
      return [];
    }
  }

  Future<List<FinanceCategory>> getCategoriesByType(int? schoolId, String type) async {
    try {
      final response = await _supabase
          .from('finance_categories')
          .select()
          .or('school_id.is.null,school_id.eq.$schoolId')
          .or('type.eq.$type,type.eq.Both')
          .eq('is_active', true)
          .order('name');
      return (response as List).map((e) => FinanceCategory.fromJson(e)).toList();
    } catch (e) {
      logger.e('Error fetching categories by type: $e');
      return [];
    }
  }

  Future<FinanceCategory?> createCategory(FinanceCategory category) async {
    try {
      final response = await _supabase
          .from('finance_categories')
          .insert(category.toJson())
          .select()
          .single();
      return FinanceCategory.fromJson(response);
    } catch (e) {
      logger.e('Error creating category: $e');
      return null;
    }
  }

  Future<FinanceCategory?> updateCategory(String id, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('finance_categories')
          .update(updates)
          .eq('id', id)
          .select()
          .single();
      return FinanceCategory.fromJson(response);
    } catch (e) {
      logger.e('Error updating category: $e');
      return null;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _supabase.from('finance_categories').update({'is_active': false}).eq('id', id);
      return true;
    } catch (e) {
      logger.e('Error deleting category: $e');
      return false;
    }
  }
}
