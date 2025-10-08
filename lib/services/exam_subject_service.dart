import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam_subject.dart';

class ExamSubjectService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> upsertExamSubject({
    String? id,
    required String examId,
    required String subjectId,
    required int maxMarks,
    required int passingMarks,
  }) async {
    await _supabaseClient.rpc('upsert_exam_subject', params: {
      'p_id': id,
      'p_exam_id': examId,
      'p_subject_id': subjectId,
      'p_max_marks': maxMarks,
      'p_passing_marks': passingMarks,
    });
  }

  Future<List<ExamSubject>> getExamSubjectsForExam(String examId) async {
    final response = await _supabaseClient
        .from('exam_subjects')
        .select()
        .eq('exam_id', examId);
    return (response as List).map((e) => ExamSubject.fromMap(e)).toList();
  }
}
