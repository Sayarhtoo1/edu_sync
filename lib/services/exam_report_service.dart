import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grade.dart';
import '../utils/logger.dart';

class ExamReportService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<Map<String, dynamic>> getStudentReportCard({
    required int studentId,
    required String examId,
  }) async {
    try {
      final student = await _supabaseClient
          .from('students')
          .select('id, full_name, class_id')
          .eq('id', studentId)
          .single();

      final exam = await _supabaseClient
          .from('exams')
          .select('id, name, exam_date, class_id')
          .eq('id', examId)
          .single();

      final marks = await _supabaseClient
          .from('student_exam_marks')
          .select('''
            marks_obtained,
            total_marks,
            subject_id,
            subjects!inner(id, name)
          ''')
          .eq('student_id', studentId)
          .eq('exam_id', examId);

      final examSubjects = await _supabaseClient
          .from('exam_subjects')
          .select('subject_id, passing_marks')
          .eq('exam_id', examId);

      final passingMarksMap = {
        for (var es in examSubjects) es['subject_id']: es['passing_marks']
      };

      int totalMarksObtained = 0;
      int totalMaxMarks = 0;
      int passedSubjects = 0;

      final subjectResults = marks.map((m) {
        final marksObtained = m['marks_obtained'] as int;
        final totalMarks = m['total_marks'] as int;
        final subjectId = m['subject_id'];
        final passingMarks = passingMarksMap[subjectId] ?? 0;
        final percentage = (marksObtained / totalMarks) * 100;
        final passed = marksObtained >= passingMarks;

        totalMarksObtained += marksObtained;
        totalMaxMarks += totalMarks;
        if (passed) passedSubjects++;

        return {
          'subjectName': m['subjects']['name'],
          'marksObtained': marksObtained,
          'totalMarks': totalMarks,
          'percentage': percentage,
          'passed': passed,
        };
      }).toList();

      final overallPercentage = totalMaxMarks > 0 ? (totalMarksObtained / totalMaxMarks) * 100 : 0.0;
      final allPassed = passedSubjects == marks.length && marks.isNotEmpty;

      return {
        'student': student,
        'exam': exam,
        'subjects': subjectResults,
        'totalMarksObtained': totalMarksObtained,
        'totalMaxMarks': totalMaxMarks,
        'overallPercentage': overallPercentage,
        'passedSubjects': passedSubjects,
        'totalSubjects': marks.length,
        'result': allPassed ? 'PASSED' : 'FAILED',
      };
    } catch (e) {
      logger.e('Error getting student report card: $e');
      rethrow;
    }
  }

  Future<int> getStudentRank({
    required int studentId,
    required String examId,
  }) async {
    try {
      final allMarks = await _supabaseClient
          .from('student_exam_marks')
          .select('student_id, marks_obtained')
          .eq('exam_id', examId);

      final studentTotals = <int, int>{};
      for (var mark in allMarks) {
        final sid = mark['student_id'] as int;
        final marks = mark['marks_obtained'] as int;
        studentTotals[sid] = (studentTotals[sid] ?? 0) + marks;
      }

      final sortedStudents = studentTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final rank = sortedStudents.indexWhere((e) => e.key == studentId) + 1;
      return rank > 0 ? rank : 0;
    } catch (e) {
      logger.e('Error getting student rank: $e');
      return 0;
    }
  }

  Future<Map<String, dynamic>> getClassAverage(String examId) async {
    try {
      final marks = await _supabaseClient
          .from('student_exam_marks')
          .select('marks_obtained, total_marks')
          .eq('exam_id', examId);

      if (marks.isEmpty) {
        return {'average': 0.0, 'percentage': 0.0};
      }

      int totalMarksObtained = 0;
      int totalMaxMarks = 0;

      for (var mark in marks) {
        totalMarksObtained += mark['marks_obtained'] as int;
        totalMaxMarks += mark['total_marks'] as int;
      }

      final average = totalMarksObtained / marks.length;
      final percentage = totalMaxMarks > 0 ? (totalMarksObtained / totalMaxMarks) * 100 : 0.0;

      return {
        'average': average,
        'percentage': percentage,
        'totalStudents': marks.length,
      };
    } catch (e) {
      logger.e('Error getting class average: $e');
      return {'average': 0.0, 'percentage': 0.0};
    }
  }

  Future<List<Map<String, dynamic>>> getTopPerformers({
    required String examId,
    int limit = 10,
  }) async {
    try {
      final allMarks = await _supabaseClient
          .from('student_exam_marks')
          .select('''
            student_id,
            marks_obtained,
            students!inner(id, full_name)
          ''')
          .eq('exam_id', examId);

      final studentTotals = <int, Map<String, dynamic>>{};
      for (var mark in allMarks) {
        final sid = mark['student_id'] as int;
        final marks = mark['marks_obtained'] as int;
        
        if (!studentTotals.containsKey(sid)) {
          studentTotals[sid] = {
            'studentId': sid,
            'studentName': mark['students']['full_name'],
            'totalMarks': 0,
          };
        }
        studentTotals[sid]!['totalMarks'] = (studentTotals[sid]!['totalMarks'] as int) + marks;
      }

      final sortedStudents = studentTotals.values.toList()
        ..sort((a, b) => (b['totalMarks'] as int).compareTo(a['totalMarks'] as int));

      return sortedStudents.take(limit).toList();
    } catch (e) {
      logger.e('Error getting top performers: $e');
      return [];
    }
  }

  String calculateOverallGrade(double percentage, List<Grade> grades) {
    if (grades.isEmpty) return 'N/A';
    
    grades.sort((a, b) => b.minPercentage.compareTo(a.minPercentage));

    for (var grade in grades) {
      if (percentage >= grade.minPercentage && percentage <= grade.maxPercentage) {
        return grade.gradeName ?? 'N/A';
      }
    }
    return 'F';
  }

  String getRemarks(String grade) {
    switch (grade) {
      case 'A':
      case 'A+':
        return 'Excellent';
      case 'B':
      case 'B+':
        return 'Very Good';
      case 'C':
      case 'C+':
        return 'Good';
      case 'D':
        return 'Satisfactory';
      case 'F':
        return 'Needs Improvement';
      default:
        return '';
    }
  }
}
