import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/logger.dart';

class ExamAnalyticsEnhancedService {
  final SupabaseClient _supabaseClient;

  ExamAnalyticsEnhancedService({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  Future<Map<String, dynamic>> getStudentPerformanceTrend({
    required int studentId,
    required int classId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('student_exam_marks')
          .select('marks_obtained, exam_subjects!inner(total_marks, exams!inner(name, exam_date))')
          .eq('student_id', studentId)
          .eq('exam_subjects.exams.class_id', classId)
          .order('exam_subjects.exams.exam_date');

      final trends = <Map<String, dynamic>>[];
      for (var mark in response) {
        final examSubject = mark['exam_subjects'];
        final exam = examSubject['exams'];
        final percentage = (mark['marks_obtained'] / examSubject['total_marks']) * 100;
        trends.add({
          'exam_name': exam['name'],
          'exam_date': exam['exam_date'],
          'percentage': percentage,
        });
      }

      return {'trends': trends};
    } catch (e) {
      logger.e('Error fetching performance trend: $e');
      return {'trends': []};
    }
  }

  Future<Map<String, dynamic>> getSubjectWiseAnalysis({
    required String examId,
    required int classId,
  }) async {
    try {
      final response = await _supabaseClient.rpc('get_subject_wise_analysis', params: {
        'p_exam_id': examId,
        'p_class_id': classId,
      });

      return {'subjects': response ?? []};
    } catch (e) {
      logger.e('Error fetching subject analysis: $e');
      return {'subjects': []};
    }
  }

  Future<Map<String, dynamic>> getClassPerformanceDistribution({
    required String examId,
  }) async {
    try {
      final response = await _supabaseClient
          .from('student_exam_marks')
          .select('marks_obtained, exam_subjects!inner(total_marks)')
          .eq('exam_subjects.exam_id', examId);

      final distribution = {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0};
      for (var mark in response) {
        final percentage = (mark['marks_obtained'] / mark['exam_subjects']['total_marks']) * 100;
        if (percentage >= 80) {
          distribution['A'] = (distribution['A'] ?? 0) + 1;
        } else if (percentage >= 70) {
          distribution['B'] = (distribution['B'] ?? 0) + 1;
        } else if (percentage >= 60) {
          distribution['C'] = (distribution['C'] ?? 0) + 1;
        } else if (percentage >= 50) {
          distribution['D'] = (distribution['D'] ?? 0) + 1;
        } else {
          distribution['F'] = (distribution['F'] ?? 0) + 1;
        }
      }

      return distribution;
    } catch (e) {
      logger.e('Error fetching distribution: $e');
      return {'A': 0, 'B': 0, 'C': 0, 'D': 0, 'F': 0};
    }
  }

  Future<List<Map<String, dynamic>>> getTopPerformersDetailed({
    required String examId,
    int limit = 10,
  }) async {
    try {
      final response = await _supabaseClient.rpc('get_top_performers_detailed', params: {
        'p_exam_id': examId,
        'p_limit': limit,
      });

      return List<Map<String, dynamic>>.from(response ?? []);
    } catch (e) {
      logger.e('Error fetching top performers: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getExamComparison({
    required List<String> examIds,
    required int classId,
  }) async {
    try {
      final comparisons = <Map<String, dynamic>>[];
      
      for (var examId in examIds) {
        final avg = await _supabaseClient.rpc('get_class_average', params: {'p_exam_id': examId});
        final exam = await _supabaseClient.from('exams').select('name, exam_date').eq('id', examId).single();
        
        comparisons.add({
          'exam_name': exam['name'],
          'exam_date': exam['exam_date'],
          'average': avg['percentage'] ?? 0.0,
        });
      }

      return {'comparisons': comparisons};
    } catch (e) {
      logger.e('Error comparing exams: $e');
      return {'comparisons': []};
    }
  }
}
