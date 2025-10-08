import 'package:flutter/material.dart';
import '../services/exam_service.dart';
import '../models/exam.dart';
import '../models/subject.dart';
import '../models/grade.dart';
import '../models/student.dart'; // Import Student model
import '../models/exam_subject.dart';
import '../services/cache_service.dart';

class ExamProvider with ChangeNotifier {
  final ExamService _examService = ExamService();
  final CacheService _cacheService = CacheService();

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
  List<Student> get students => _students; // Getter for students
  List<ExamSubject> get examSubjects => _examSubjects;
  List<dynamic> get reportCard => _reportCard;
  List<dynamic> get detailedReportCard => _detailedReportCard; // Getter for detailed report card
  List<dynamic> get classResults => _classResults;
  ExamService get examService => _examService; // Expose ExamService

  Future<void> createExam({
    required int classId,
    required int schoolId,
    required String name,
    required DateTime examDate,
    required String examinerName,
    String? description,
    int? maxMarks,
  }) async {
    try {
      await _examService.addExam(
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
      // Handle error
    }
  }

  Future<void> addSubject({
    required String name,
    required int classId,
    required int schoolId,
  }) async {
    try {
      await _examService.addSubject(
        name: name,
        classId: classId,
        schoolId: schoolId,
      );
      await fetchSubjects(schoolId.toString());
    } catch (e) {
      // Handle error
    }
  }

  Future<void> updateSubject({
    required String id,
    required String name,
    required int classId,
    required int schoolId,
  }) async {
    try {
      await _examService.updateSubject(
        id: id,
        name: name,
        classId: classId,
        schoolId: schoolId,
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
    required String studentId,
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
    required String studentId,
    required String examId,
  }) async {
    _reportCard = await _examService.getStudentReportCard(
      studentId: studentId,
      examId: examId,
    );
    notifyListeners();
  }

  Future<void> getDetailedStudentReportCard({
    required String studentId,
    required String examId,
    required int schoolId,
  }) async {
    try {
      _detailedReportCard = await _examService.getDetailedStudentReportCard(
        studentId: studentId,
        examId: examId,
        schoolId: schoolId,
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
}
