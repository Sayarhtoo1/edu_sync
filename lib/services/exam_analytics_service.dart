import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grade.dart';
import 'package:collection/collection.dart';

class ExamAnalyticsService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  String calculateGrade(double percentage, List<Grade> grades) {
    if (grades.isEmpty) {
      return 'N/A';
    }
    grades.sort((a, b) => b.minPercentage.compareTo(a.minPercentage));

    final grade = grades.firstWhereOrNull(
      (g) => percentage >= g.minPercentage && percentage <= g.maxPercentage,
    );

    return grade?.gradeName ?? 'F';
  }

  Map<String, dynamic> getOverallExamResult({
    required List<Map<String, dynamic>> subjectResults,
    required List<Grade> grades,
    double minOverallPercentage = 40.0,
  }) {
    if (subjectResults.isEmpty) {
      return {
        'overallPercentage': 0.0,
        'overallGrade': 'N/A',
        'overallPassed': false,
        'passedAllSubjects': false,
      };
    }

    int totalMarksObtained = 0;
    int totalMaxMarks = 0;
    bool passedAllSubjects = true;

    for (var result in subjectResults) {
      totalMarksObtained += result['marksObtained'] as int;
      totalMaxMarks += result['maxMarks'] as int;
      if (!(result['passed'] as bool)) {
        passedAllSubjects = false;
      }
    }

    final double overallPercentage = totalMaxMarks == 0 ? 0.0 : (totalMarksObtained / totalMaxMarks) * 100;
    final String overallGrade = calculateGrade(overallPercentage, grades);
    final bool overallPassed = passedAllSubjects && (overallPercentage >= minOverallPercentage);

    return {
      'overallPercentage': overallPercentage,
      'overallGrade': overallGrade,
      'overallPassed': overallPassed,
      'passedAllSubjects': passedAllSubjects,
    };
  }

  Map<String, dynamic> getSubjectGradeAndStatus({
    required int marksObtained,
    required int maxMarks,
    required int passingMarks,
    required List<Grade> grades,
  }) {
    if (maxMarks == 0) {
      return {
        'percentage': 0.0,
        'grade': 'N/A',
        'passed': false,
      };
    }
    final double percentage = (marksObtained / maxMarks) * 100;
    final String grade = calculateGrade(percentage, grades);
    final bool passed = marksObtained >= passingMarks;

    return {
      'percentage': percentage,
      'grade': grade,
      'passed': passed,
    };
  }

  Future<List<dynamic>> getStudentReportCard({
    required String studentId,
    required String examId,
  }) async {
    return await _supabaseClient.rpc('get_student_report_card', params: {
      'p_student_id': studentId,
      'p_exam_id': examId,
    });
  }

  Future<List<dynamic>> getDetailedStudentReportCard({
    required String studentId,
    required String examId,
    required int schoolId,
  }) async {
    final response = await _supabaseClient.rpc('get_detailed_student_report_card', params: {
      'p_student_id': studentId,
      'p_exam_id': examId,
      'p_school_id': schoolId,
    });
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getClassExamResults({
    required int classId,
    required String examId,
  }) async {
    return await _supabaseClient.rpc('get_class_exam_results', params: {
      'p_class_id': classId,
      'p_exam_id': examId,
    });
  }

  Future<Map<String, dynamic>> getSchoolPerformanceOverview(int schoolId) async {
    final response = await _supabaseClient.rpc('get_school_performance_overview', params: {
      'p_school_id': schoolId,
    });
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getClassPerformanceOverview(int classId) async {
    final response = await _supabaseClient.rpc('get_class_performance_overview', params: {
      'p_class_id': classId,
    });
    return response as Map<String, dynamic>;
  }

  Future<List<dynamic>> getSubjectPerformance({int? schoolId, int? classId}) async {
    final response = await _supabaseClient.rpc('get_subject_performance', params: {
      'p_school_id': schoolId,
      'p_class_id': classId,
    });
    return response as List<dynamic>;
  }

  Future<Map<String, dynamic>> getStudentPerformance(int studentId) async {
    final response = await _supabaseClient.rpc('get_student_performance', params: {
      'p_student_id': studentId,
    });
    return response as Map<String, dynamic>;
  }
}
