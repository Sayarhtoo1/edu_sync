import 'package:flutter/material.dart';
import '../services/exam_service.dart';
// Assuming SchoolClass model is needed for filtering
import '../services/cache_service.dart';
import '../models/subject.dart';

class AnalyticsProvider with ChangeNotifier {
  final ExamService _examService;
  final CacheService _cacheService = CacheService();

  Map<String, dynamic>? _schoolPerformanceOverview;
  Map<String, dynamic>? _classPerformanceOverview;
  List<dynamic> _subjectPerformance = [];
  Map<String, dynamic>? _studentPerformance; // Changed to Map
  bool _isLoading = false;

  AnalyticsProvider(this._examService);

  Map<String, dynamic>? get schoolPerformanceOverview => _schoolPerformanceOverview;
  Map<String, dynamic>? get classPerformanceOverview => _classPerformanceOverview;
  List<dynamic> get subjectPerformance => _subjectPerformance;
  Map<String, dynamic>? get studentPerformance => _studentPerformance; // Changed getter
  bool get isLoading => _isLoading;

  Future<void> fetchSchoolPerformanceOverview(int schoolId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _schoolPerformanceOverview = await _examService.getSchoolPerformanceOverview(schoolId);
    } catch (e) {
      // Handle error
      _schoolPerformanceOverview = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchClassPerformanceOverview(int classId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _classPerformanceOverview = await _examService.getClassPerformanceOverview(classId);
    } catch (e) {
      // Handle error
      _classPerformanceOverview = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSubjectPerformance({int? schoolId, int? classId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (schoolId != null) {
        List<Subject> cachedSubjects = await _cacheService.getSubjects(schoolId);
        if (cachedSubjects.isNotEmpty) {
          // Potentially use cached data for initial display if available
          // For now, we'll just fetch fresh data and update cache
        }
      }
      _subjectPerformance = await _examService.getSubjectPerformance(schoolId: schoolId, classId: classId);
      if (schoolId != null && _subjectPerformance.isNotEmpty) {
        // Assuming subjectPerformance contains enough info to reconstruct Subject objects
        // This might need adjustment based on the actual structure of _subjectPerformance
        List<Subject> subjectsToCache = _subjectPerformance.map((e) => Subject.fromMap(e)).toList();
        await _cacheService.saveSubjects(schoolId, subjectsToCache);
      }
    } catch (e) {
      // Handle error
      _subjectPerformance = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchStudentPerformance(int studentId) async { // Renamed method
    _isLoading = true;
    notifyListeners();
    try {
      _studentPerformance = await _examService.getStudentPerformance(studentId); // Changed to Map
    } catch (e) {
      // Handle error
      _studentPerformance = null; // Changed to null
    }
    _isLoading = false;
    notifyListeners();
  }

  void clearAnalyticsData() {
    _schoolPerformanceOverview = null;
    _classPerformanceOverview = null;
    _subjectPerformance = [];
    _studentPerformance = null; // Changed to null
    notifyListeners();
  }
}