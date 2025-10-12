import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grade.dart';
import '../models/exam_subject.dart';
import '../utils/logger.dart';

class ExamMarksService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getStudentsForMarksEntry({
    required String examId,
    required String subjectId,
  }) async {
    try {
      final examSubject = await _supabaseClient
          .from('exam_subjects')
          .select('max_marks, passing_marks')
          .eq('exam_id', examId)
          .eq('subject_id', subjectId)
          .single();

      final exam = await _supabaseClient
          .from('exams')
          .select('class_id')
          .eq('id', examId)
          .single();

      final students = await _supabaseClient
          .from('students')
          .select('id, full_name')
          .eq('class_id', exam['class_id'])
          .order('full_name');

      final marks = await _supabaseClient
          .from('student_exam_marks')
          .select('student_id, marks_obtained')
          .eq('exam_id', examId)
          .eq('subject_id', subjectId);

      final marksMap = {for (var m in marks) m['student_id']: m['marks_obtained']};

      return students.map((s) => {
        'studentId': s['id'],
        'studentName': s['full_name'],
        'marksObtained': marksMap[s['id']],
        'maxMarks': examSubject['max_marks'],
        'passingMarks': examSubject['passing_marks'],
      }).toList();
    } catch (e) {
      logger.e('Error fetching students for marks entry: $e');
      rethrow;
    }
  }

  Future<void> saveStudentMark({
    required String examId,
    required int studentId,
    required String subjectId,
    required int marksObtained,
  }) async {
    try {
      await _supabaseClient.rpc('upsert_student_exam_mark', params: {
        'p_exam_id': examId,
        'p_student_id': studentId,
        'p_subject_id': subjectId,
        'p_marks_obtained': marksObtained,
      });
    } catch (e) {
      logger.e('Error saving student mark: $e');
      rethrow;
    }
  }

  Future<void> bulkSaveMarks({
    required String examId,
    required String subjectId,
    required List<Map<String, dynamic>> marks,
  }) async {
    try {
      for (var mark in marks) {
        if (mark['marksObtained'] != null) {
          await saveStudentMark(
            examId: examId,
            studentId: mark['studentId'],
            subjectId: subjectId,
            marksObtained: mark['marksObtained'],
          );
        }
      }
    } catch (e) {
      logger.e('Error bulk saving marks: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMarksEntryProgress({
    required String examId,
    required String subjectId,
  }) async {
    try {
      final exam = await _supabaseClient
          .from('exams')
          .select('class_id')
          .eq('id', examId)
          .single();

      final totalStudentsResponse = await _supabaseClient
          .from('students')
          .select('id')
          .eq('class_id', exam['class_id']);

      final marksEnteredResponse = await _supabaseClient
          .from('student_exam_marks')
          .select('id')
          .eq('exam_id', examId)
          .eq('subject_id', subjectId);

      final marks = await _supabaseClient
          .from('student_exam_marks')
          .select('marks_obtained, total_marks')
          .eq('exam_id', examId)
          .eq('subject_id', subjectId);

      final examSubject = await _supabaseClient
          .from('exam_subjects')
          .select('passing_marks')
          .eq('exam_id', examId)
          .eq('subject_id', subjectId)
          .single();

      int passCount = 0;
      double totalMarks = 0;

      for (var mark in marks) {
        totalMarks += mark['marks_obtained'];
        if (mark['marks_obtained'] >= examSubject['passing_marks']) {
          passCount++;
        }
      }

      final average = marks.isEmpty ? 0.0 : totalMarks / marks.length;
      final passPercentage = marks.isEmpty ? 0.0 : (passCount / marks.length) * 100;

      return {
        'totalStudents': (totalStudentsResponse as List).length,
        'marksEntered': (marksEnteredResponse as List).length,
        'average': average,
        'passCount': passCount,
        'passPercentage': passPercentage,
      };
    } catch (e) {
      logger.e('Error getting marks entry progress: $e');
      rethrow;
    }
  }

  String calculateGrade(int marksObtained, int totalMarks, List<Grade> grades) {
    if (grades.isEmpty || totalMarks == 0) return 'N/A';
    
    final percentage = (marksObtained / totalMarks) * 100;
    grades.sort((a, b) => b.minPercentage.compareTo(a.minPercentage));

    for (var grade in grades) {
      if (percentage >= grade.minPercentage && percentage <= grade.maxPercentage) {
        return grade.gradeName ?? 'N/A';
      }
    }
    return 'F';
  }

  bool isPassed(int marksObtained, int passingMarks) {
    return marksObtained >= passingMarks;
  }

  Future<ExamSubject> getExamSubject({
    required String examId,
    required String subjectId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('exam_subjects')
          .select()
          .eq('exam_id', examId)
          .eq('subject_id', subjectId)
          .single();
      return ExamSubject.fromMap(response);
    } catch (e) {
      logger.e('Error fetching exam subject: $e');
      rethrow;
    }
  }
}
