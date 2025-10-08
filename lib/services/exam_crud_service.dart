import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam.dart';

class ExamCrudService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> addExam({
    required int classId,
    required int schoolId,
    required String name,
    required DateTime examDate,
    required String examinerName,
    String? description,
    int? maxMarks,
  }) async {
    await _supabaseClient.rpc('add_exam', params: {
      'p_class_id': classId,
      'p_school_id': schoolId,
      'p_name': name,
      'p_exam_date': examDate.toIso8601String(),
      'p_examiner_name': examinerName,
      'p_description': description,
      'p_max_marks': maxMarks,
    });
  }

  Future<void> updateExam({
    required String id,
    required int classId,
    required int schoolId,
    required String name,
    required DateTime examDate,
    required String examinerName,
    String? description,
    int? maxMarks,
  }) async {
    await _supabaseClient.rpc('update_exam', params: {
      'p_exam_id': id,
      'p_class_id': classId,
      'p_school_id': schoolId,
      'p_name': name,
      'p_exam_date': examDate.toIso8601String(),
      'p_examiner_name': examinerName,
      'p_description': description,
      'p_max_marks': maxMarks,
    });
  }

  Future<void> deleteExam(String id) async {
    await _supabaseClient.rpc('delete_exam', params: {
      'p_exam_id': id,
    });
  }

  Future<List<Exam>> getExamsBySchoolId(int schoolId) async {
    final response = await _supabaseClient
        .from('exams')
        .select('id, class_id, school_id, name, exam_date, examiner_name, description, max_marks, created_at')
        .eq('school_id', schoolId)
        .order('exam_date', ascending: false);
    return (response as List).map((e) => Exam.fromMap(e)).toList();
  }
}
