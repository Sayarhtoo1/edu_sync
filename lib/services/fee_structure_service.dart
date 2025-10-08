import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fee_structure.dart';
import '../utils/logger.dart';

class FeeStructureService {
  final SupabaseClient _supabase;

  FeeStructureService(this._supabase);

  Future<List<FeeStructure>> getFeeStructuresBySchool(int schoolId) async {
    try {
      final response = await _supabase
          .from('fee_structures')
          .select()
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);
      return (response as List).map((e) => FeeStructure.fromJson(e)).toList();
    } catch (e) {
      logger.e('Error fetching fee structures: $e');
      return [];
    }
  }

  Future<FeeStructure?> createFeeStructure(FeeStructure feeStructure) async {
    try {
      final response = await _supabase
          .from('fee_structures')
          .insert(feeStructure.toJson())
          .select()
          .single();
      return FeeStructure.fromJson(response);
    } catch (e) {
      logger.e('Error creating fee structure: $e');
      return null;
    }
  }

  Future<bool> updateFeeStructure(FeeStructure feeStructure) async {
    try {
      await _supabase
          .from('fee_structures')
          .update(feeStructure.toJson())
          .eq('id', feeStructure.id);
      return true;
    } catch (e) {
      logger.e('Error updating fee structure: $e');
      return false;
    }
  }

  Future<bool> deleteFeeStructure(String id) async {
    try {
      await _supabase.from('fee_structures').delete().eq('id', id);
      return true;
    } catch (e) {
      logger.e('Error deleting fee structure: $e');
      return false;
    }
  }
}
