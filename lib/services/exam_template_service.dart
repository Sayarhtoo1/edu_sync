import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam_template.dart';
import '../utils/logger.dart';

class ExamTemplateService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<ExamTemplate>> getTemplates(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('exam_templates')
          .select()
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);

      return (response as List).map((t) => ExamTemplate.fromMap(t)).toList();
    } catch (e) {
      logger.e('Error fetching templates: $e');
      return [];
    }
  }

  Future<void> saveTemplate({
    required int schoolId,
    required String name,
    String? description,
    required List<Map<String, dynamic>> subjects,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      await _supabaseClient.from('exam_templates').insert({
        'school_id': schoolId,
        'name': name,
        'description': description,
        'subjects': subjects,
        'created_by': userId,
      });
    } catch (e) {
      logger.e('Error saving template: $e');
      rethrow;
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _supabaseClient.from('exam_templates').delete().eq('id', id);
    } catch (e) {
      logger.e('Error deleting template: $e');
      rethrow;
    }
  }
}
