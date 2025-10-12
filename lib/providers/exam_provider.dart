import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/exam_service.dart';
import '../services/exam_marks_service.dart';
import '../services/exam_report_service.dart';
import '../services/exam_analytics_enhanced_service.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import '../models/grade.dart';
import '../models/student.dart';
import '../models/exam_subject.dart';
import '../services/cache_service.dart';

class ExamProvider with ChangeNotifier {
  final ExamService _examService = ExamService();
  final ExamMarksService _marksService = ExamMarksService();
  final ExamReportService _reportService = ExamReportService();
  final ExamAnalyticsEnhancedService _analyticsService = ExamAnalyticsEnhancedService(supabaseClient: Supabase.instance.client);
  final CacheService _cacheService = CacheService();

  SupabaseClient get supabaseClient => Supabase.instance.client;
  ExamMarksService get marksService => _marksService;

  List<Exam> _exams = [];
  List<Subject> _subjects = [];
  List<Grade> _grades = [];
  List<Student> _students = []; // Add students list
  List<ExamSubject> _examSubjects = [];
  List<dynamic> _reportCard = [];
  List<dynamic> _detailedReportCard = []; // Add detailed report card list
  List<dynamic> _classResults = [];

  List<Exam> get exams => _exams;
  List<Subject> get subjects => _subjects;
  List<Grade> get grades => _grades;
  List<Student> get students => _students;
  List<ExamSubject> get examSubjects => _examSubjects;
  List<dynamic> get reportCard => _reportCard;
  List<dynamic> get detailedReportCard => _detailedReportCard;
  List<dynamic> get classResults => _classResults;
  ExamService get examService => _examService;
  ExamReportService get reportService => _reportService;

  Future<Exam> createExam({
    required int classId,
    required int schoolId,
    required String name,
    required DateTime examDate,
    required String examinerName,
    String? description,
    int? maxMarks,
  }) async {
    try {
      final exam = await _examService.addExam(
        classId: classId,
        schoolId: schoolId,
        name: name,
        examDate: examDate,
        examinerName: examinerName,
        description: description,
        maxMarks: maxMarks,
      );
      await fetchExams(schoolId.toString());
      return exam;
    } catch (e) {
      rethrow;
    }
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
    try {
      await _examService.updateExam(
        id: id,
        classId: classId,
        schoolId: schoolId,
        name: name,
        examDate: examDate,
        examinerName: examinerName,
        description: description,
        maxMarks: maxMarks,
      );
      await fetchExams(schoolId.toString());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteExam(String id, String schoolId) async {
    try {
      await _examService.deleteExam(id);
      _exams.removeWhere((exam) => exam.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addSubject({
    required String name,
    required int schoolId,
    int? classId,
    String? code,
  }) async {
    try {
      await _examService.addSubject(
        name: name,
        schoolId: schoolId,
        classId: classId,
        code: code,
      );
      await fetchSubjects(schoolId.toString());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateSubject({
    required String id,
    required String name,
    required int schoolId,
    int? classId,
    String? code,
  }) async {
    try {
      await _examService.updateSubject(
        id: id,
        name: name,
        schoolId: schoolId,
        classId: classId,
        code: code,
      );
      await fetchSubjects(schoolId.toString());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateGrade({
    required String id,
    required String gradeName,
    required int minPercentage,
    required int maxPercentage,
    required int schoolId,
    String? remarks,
  }) async {
    try {
      await _examService.updateGrade(
        id: id,
        schoolId: schoolId,
        gradeName: gradeName,
        minPercentage: minPercentage,
        maxPercentage: maxPercentage,
        remarks: remarks ?? '',
      );
      await fetchGrades(schoolId.toString());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteGrade(String id, String schoolId) async {
    try {
      await _examService.deleteGrade(id);
      _grades.removeWhere((grade) => grade.id == id);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchGrades(String schoolId) async {
    try {
      final int schoolIdInt = int.parse(schoolId);
      List<Grade> cachedGrades = await _cacheService.getGrades(schoolIdInt);
      if (cachedGrades.isNotEmpty) {
        _grades = cachedGrades;
        notifyListeners();
      }

      _grades = await _examService.getGradesBySchoolId(schoolIdInt);
      await _cacheService.saveGrades(schoolIdInt, _grades);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> deleteSubject(String id, String schoolId) async {
    try {
      await _examService.deleteSubject(id);
      _subjects.removeWhere((subject) => subject.id == id);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> addGrade({
    required int schoolId,
    required String gradeName,
    required int minPercentage,
    required int maxPercentage,
    required String remarks,
  }) async {
    try {
      await _examService.addGrade(
        schoolId: schoolId,
        gradeName: gradeName,
        minPercentage: minPercentage,
        maxPercentage: maxPercentage,
        remarks: remarks,
      );
      await fetchGrades(schoolId.toString());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> upsertStudentExamMark({
    required String examId,
    required int studentId,
    required String subjectId,
    required int marksObtained,
  }) async {
    await _examService.upsertStudentExamMark(
      examId: examId,
      studentId: studentId,
      subjectId: subjectId,
      marksObtained: marksObtained,
    );
    notifyListeners();
  }

  Future<void> upsertExamSubject(ExamSubject examSubject) async {
    try {
      await _examService.upsertExamSubject(
        id: examSubject.id,
        examId: examSubject.examId,
        subjectId: examSubject.subjectId,
        maxMarks: examSubject.maxMarks,
        passingMarks: examSubject.passingMarks,
      );
      await fetchExamSubjectsForExam(examSubject.examId);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchExamSubjectsForExam(String examId) async {
    try {
      _examSubjects = await _examService.getExamSubjectsForExam(examId);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> getStudentReportCard({
    required int studentId,
    required String examId,
  }) async {
    _reportCard = await _examService.getStudentReportCard(
      studentId: studentId,
      examId: examId,
    );
    notifyListeners();
  }

  Future<void> getDetailedStudentReportCard({
    required int studentId,
    required String examId,
  }) async {
    try {
      _detailedReportCard = await _examService.getDetailedStudentReportCard(
        studentId: studentId,
        examId: examId,
      );
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> getClassExamResults({
    required int classId,
    required String examId,
  }) async {
    try {
      _classResults = await _examService.getClassExamResults(
        classId: classId,
        examId: examId,
      );
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchExams(String schoolId) async {
    try {
      _exams = await _examService.getExamsBySchoolId(int.parse(schoolId));
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchSubjects(String schoolId) async {
    try {
      final int schoolIdInt = int.parse(schoolId);
      List<Subject> cachedSubjects = await _cacheService.getSubjects(schoolIdInt);
      if (cachedSubjects.isNotEmpty) {
        _subjects = cachedSubjects;
        notifyListeners();
      }

      _subjects = await _examService.getSubjectsBySchoolId(schoolIdInt);
      await _cacheService.saveSubjects(schoolIdInt, _subjects);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchStudentsByClassId(String classId) async {
    try {
      _students = await _examService.getStudentsByClassId(int.parse(classId));
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchSubjectsByClassId(String classId) async {
    try {
      _subjects = await _examService.getSubjectsByClassId(int.parse(classId));
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> saveExamSubjects(String examId, List<Subject> subjects) async {
    try {
      for (final subject in subjects) {
        await _examService.upsertExamSubject(
          examId: examId,
          subjectId: subject.id,
          maxMarks: subject.maxMarks ?? 100,
          passingMarks: subject.passingMarks ?? 40,
        );
      }
      await fetchExamSubjectsForExam(examId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getStudentsForMarksEntry({
    required String examId,
    required String subjectId,
  }) async {
    return await _marksService.getStudentsForMarksEntry(
      examId: examId,
      subjectId: subjectId,
    );
  }

  Future<void> saveStudentMark({
    required String examId,
    required int studentId,
    required String subjectId,
    required int marksObtained,
  }) async {
    await _marksService.saveStudentMark(
      examId: examId,
      studentId: studentId,
      subjectId: subjectId,
      marksObtained: marksObtained,
    );
    notifyListeners();
  }

  Future<void> bulkSaveMarks({
    required String examId,
    required String subjectId,
    required List<Map<String, dynamic>> marks,
  }) async {
    await _marksService.bulkSaveMarks(
      examId: examId,
      subjectId: subjectId,
      marks: marks,
    );
    notifyListeners();
  }

  Future<Map<String, dynamic>> getMarksEntryProgress({
    required String examId,
    required String subjectId,
  }) async {
    return await _marksService.getMarksEntryProgress(
      examId: examId,
      subjectId: subjectId,
    );
  }

  String calculateGrade(int marksObtained, int totalMarks) {
    return _marksService.calculateGrade(marksObtained, totalMarks, _grades);
  }

  bool isPassed(int marksObtained, int passingMarks) {
    return _marksService.isPassed(marksObtained, passingMarks);
  }

  Future<Map<String, dynamic>> getReportCard({
    required int studentId,
    required String examId,
  }) async {
    return await _reportService.getStudentReportCard(
      studentId: studentId,
      examId: examId,
    );
  }

  Future<int> getStudentRank({
    required int studentId,
    required String examId,
  }) async {
    return await _reportService.getStudentRank(
      studentId: studentId,
      examId: examId,
    );
  }

  Future<Map<String, dynamic>> getClassAverage(String examId) async {
    return await _reportService.getClassAverage(examId);
  }

  Future<List<Map<String, dynamic>>> getTopPerformers({
    required String examId,
    int limit = 10,
  }) async {
    return await _reportService.getTopPerformers(
      examId: examId,
      limit: limit,
    );
  }

  String calculateOverallGrade(double percentage) {
    return _reportService.calculateOverallGrade(percentage, _grades);
  }

  String getRemarks(String grade) {
    return _reportService.getRemarks(grade);
  }

  Future<Map<String, dynamic>> getStudentPerformanceTrend({
    required int studentId,
    required int classId,
  }) async {
    return await _analyticsService.getStudentPerformanceTrend(
      studentId: studentId,
      classId: classId,
    );
  }

  Future<Map<String, dynamic>> getSubjectWiseAnalysis({
    required String examId,
    required int classId,
  }) async {
    return await _analyticsService.getSubjectWiseAnalysis(
      examId: examId,
      classId: classId,
    );
  }

  Future<Map<String, dynamic>> getClassPerformanceDistribution({
    required String examId,
  }) async {
    return await _analyticsService.getClassPerformanceDistribution(examId: examId);
  }

  Future<List<Map<String, dynamic>>> getTopPerformersDetailed({
    required String examId,
    int limit = 10,
  }) async {
    return await _analyticsService.getTopPerformersDetailed(
      examId: examId,
      limit: limit,
    );
  }

  Future<Map<String, dynamic>> getExamComparison({
    required List<String> examIds,
    required int classId,
  }) async {
    return await _analyticsService.getExamComparison(
      examIds: examIds,
      classId: classId,
    );
  }
}
