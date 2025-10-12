import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import '../models/student.dart';
import '../models/grade.dart';
import '../models/exam_subject.dart'; // Import ExamSubject model
// Import SchoolClass model
import 'package:collection/collection.dart'; // Import for `firstWhereOrNull`

class ExamService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  String calculateGrade(double percentage, List<Grade> grades) {
    if (grades.isEmpty) {
      return 'N/A';
    }
    grades.sort((a, b) => b.minPercentage.compareTo(a.minPercentage)); // Sort descending by minPercentage

    final grade = grades.firstWhereOrNull(
      (g) => percentage >= g.minPercentage && percentage <= g.maxPercentage,
    );

    return grade?.gradeName ?? 'F'; // Default to 'F' if no grade matches
  }

  Map<String, dynamic> getOverallExamResult({
    required List<Map<String, dynamic>> subjectResults,
    required List<Grade> grades,
    double minOverallPercentage = 40.0, // Default minimum overall percentage to pass
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

  Future<Exam> addExam({
    required int classId,
    required int schoolId,
    required String name,
    required DateTime examDate,
    required String examinerName,
    String? description,
    int? maxMarks,
  }) async {
    final response = await _supabaseClient.rpc('add_exam', params: {
      'p_class_id': classId,
      'p_school_id': schoolId,
      'p_name': name,
      'p_exam_date': examDate.toIso8601String(),
      'p_examiner_name': examinerName,
      'p_description': description,
      'p_max_marks': maxMarks,
    });
    
    // If response is a string (exam ID), create Exam object manually
    if (response is String) {
      return Exam(
        id: response,
        classId: classId,
        schoolId: schoolId,
        name: name,
        examDate: examDate,
        examinerName: examinerName,
        description: description,
        maxMarks: maxMarks,
        createdAt: DateTime.now(),
      );
    }
    
    return Exam.fromMap(response as Map<String, dynamic>);
  }

  Future<void> addSubject({
    required String name,
    required int schoolId,
    int? classId,
    String? code,
  }) async {
    await _supabaseClient.rpc('add_subject', params: {
      'p_name': name,
      'p_school_id': schoolId,
      'p_class_id': classId,
      'p_code': code,
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

  Future<void> updateSubject({
    required String id,
    required String name,
    required int schoolId,
    int? classId,
    String? code,
  }) async {
    await _supabaseClient.rpc('update_subject', params: {
      'p_subject_id': id,
      'p_name': name,
      'p_school_id': schoolId,
      'p_class_id': classId,
      'p_code': code,
    });
  }

  Future<void> deleteSubject(String id) async {
    await _supabaseClient.rpc('delete_subject', params: {
      'p_subject_id': id,
    });
  }

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

  Future<void> upsertStudentExamMark({
    required String examId,
    required int studentId,
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

  Future<void> upsertExamSubject({
    String? id,
    required String examId,
    required String subjectId,
    required int maxMarks,
    required int passingMarks,
  }) async {
    await _supabaseClient.rpc('upsert_exam_subject', params: {
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

  Future<List<Student>> getStudentsByClassId(int classId) async {
    final response = await _supabaseClient
        .from('students')
        .select()
        .eq('class_id', classId)
        .order('full_name', ascending: true);
    return (response as List).map((e) => Student.fromMap(e)).toList();
  }

  Future<List<dynamic>> getStudentReportCard({
    required int studentId,
    required String examId,
  }) async {
    return await _supabaseClient.rpc('get_student_report_card', params: {
      'p_student_id': studentId,
      'p_exam_id': examId,
    });
  }

  Future<List<dynamic>> getDetailedStudentReportCard({
    required int studentId,
    required String examId,
  }) async {
    final response = await _supabaseClient.rpc('get_detailed_student_report_card', params: {
      'p_student_id': studentId,
      'p_exam_id': examId,
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

  Future<List<Exam>> getExamsBySchoolId(int schoolId) async {
    final response = await _supabaseClient
        .from('exams')
        .select('id, class_id, school_id, name, exam_date, examiner_name, description, max_marks, created_at')
        .eq('school_id', schoolId)
        .order('exam_date', ascending: false);
    return (response as List).map((e) => Exam.fromMap(e)).toList();
  }

  Future<List<Subject>> getSubjectsBySchoolId(int schoolId) async {
    final response = await _supabaseClient
        .from('subjects')
        .select('id, name, class_id, school_id, created_at')
        .eq('school_id', schoolId)
        .order('name', ascending: true);
    return (response as List).map((e) => Subject.fromMap(e)).toList();
  }

  Future<List<Subject>> getSubjectsByClassId(int classId) async {
    final response = await _supabaseClient
        .from('subjects')
        .select('id, name, class_id, school_id, created_at')
        .eq('class_id', classId)
        .order('name', ascending: true);
    return (response as List).map((e) => Subject.fromMap(e)).toList();
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

  Future<Map<String, dynamic>?> getStudentPerformance(int studentId) async {
    final response = await _supabaseClient.rpc('get_student_performance', params: {
      'p_student_id': studentId,
    });
    return response as Map<String, dynamic>?;
  }
}
