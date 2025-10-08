import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/student.dart';

class StudentExamMarkService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> upsertStudentExamMark({
    required String examId,
    required String studentId,
    required String subjectId,
    required int marksObtained,
  }) async {
    await _supabaseClient.rpc('upsert_student_exam_mark', params: {
      'p_exam_id': examId,
      'p_student_id': studentId,
      'p_subject_id': subjectId,
      'p_marks_obtained': marksObtained,
    });
  }

  Future<List<Student>> getStudentsByClassId(int classId) async {
    final response = await _supabaseClient
        .from('students')
        .select()
        .eq('class_id', classId)
        .order('full_name', ascending: true);
    return (response as List).map((e) => Student.fromMap(e)).toList();
  }
}
