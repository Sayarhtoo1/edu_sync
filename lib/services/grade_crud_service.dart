import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grade.dart';

class GradeCrudService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> addGrade({
    required int schoolId,
    required String gradeName,
    required int minPercentage,
    required int maxPercentage,
    required String remarks,
  }) async {
    await _supabaseClient.rpc('add_grade', params: {
      'p_school_id': schoolId,
      'p_grade_name': gradeName,
      'p_min_percentage': minPercentage,
      'p_max_percentage': maxPercentage,
      'p_remarks': remarks,
    });
  }

  Future<void> updateGrade({
    required String id,
    required int schoolId,
    required String gradeName,
    required int minPercentage,
    required int maxPercentage,
    required String remarks,
  }) async {
    await _supabaseClient.rpc('update_grade', params: {
      'p_grade_id': id,
      'p_school_id': schoolId,
      'p_grade_name': gradeName,
      'p_min_percentage': minPercentage,
      'p_max_percentage': maxPercentage,
      'p_remarks': remarks,
    });
  }

  Future<void> deleteGrade(String id) async {
    await _supabaseClient.rpc('delete_grade', params: {
      'p_grade_id': id,
    });
  }

  Future<List<Grade>> getGradesBySchoolId(int schoolId) async {
    final response = await _supabaseClient
        .from('grades')
        .select('id, school_id, grade_name, min_percentage, max_percentage, remarks, created_at')
        .eq('school_id', schoolId)
        .order('min_percentage', ascending: false);
    return (response as List).map((e) => Grade.fromMap(e)).toList();
  }
}
