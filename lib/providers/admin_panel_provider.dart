import 'package:flutter/material.dart';
import 'package:edu_sync/services/timetable_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/models/timetable.dart' as timetable_model;
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/models/user_role.dart'; // Import UserRole
import 'package:edu_sync/utils/logger.dart'; // Assuming logger exists

class AdminPanelProvider with ChangeNotifier {
  final TimetableService _timetableService;
  final AuthService _authService;
  final ClassService _classService;

  bool _isLoading = false;
  List<timetable_model.Timetable> _timetableEntries = [];
  List<app_user.User> _teachers = []; // Teachers are users with a 'Teacher' role
  List<app_class.SchoolClass> _schoolClasses = [];
  int? _currentSchoolId; // Add currentSchoolId

  AdminPanelProvider({
    required TimetableService timetableService,
    required AuthService authService,
    required ClassService classService,
  })  : _timetableService = timetableService,
        _authService = authService,
        _classService = classService;

  void setCurrentSchoolId(int schoolId) {
    if (_currentSchoolId != schoolId) {
      _currentSchoolId = schoolId;
      // Optionally, re-fetch data if school changes
      // fetchTimetableEntries();
      // fetchTeachers();
      // fetchSchoolClasses();
    }
  }

  bool get isLoading => _isLoading;
  List<timetable_model.Timetable> get timetableEntries => _timetableEntries;
  List<app_user.User> get teachers => _teachers;
  List<app_class.SchoolClass> get schoolClasses => _schoolClasses;

  Future<void> fetchTimetableEntries() async {
    logger.d("AdminPanelProvider: Entering fetchTimetableEntries."); // Added entry log
    _isLoading = true;
    notifyListeners();
    try {
      if (_currentSchoolId == null) {
        logger.e("AdminPanelProvider: School ID is null, cannot fetch timetable entries.");
        return;
      }
      logger.d("AdminPanelProvider: Attempting to fetch timetable entries for school ID: $_currentSchoolId");
      final fetchedEntries = await _timetableService.getAllTimetables(_currentSchoolId!);
      logger.d("AdminPanelProvider: Raw fetched timetable entries count: ${fetchedEntries.length}"); // Log raw count
      _timetableEntries = fetchedEntries;
      logger.d("AdminPanelProvider: Fetched timetable entries: ${_timetableEntries.length}");
    } catch (e, stack) { // Catch stack trace as well
      logger.e("AdminPanelProvider: Error fetching timetable entries: $e\nStack: $stack");
      print("AdminPanelProvider: Error fetching timetable entries: $e"); // Added print for visibility
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTeachers() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_currentSchoolId == null) {
        logger.e("AdminPanelProvider: School ID is null, cannot fetch teachers.");
        return;
      }
      _teachers = await _authService.getUsersByRole(UserRole.Teacher, _currentSchoolId!);
      logger.d("AdminPanelProvider: Fetched teachers: ${_teachers.length}");
    } catch (e) {
      logger.e("AdminPanelProvider: Error fetching teachers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSchoolClasses() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_currentSchoolId == null) {
        logger.e("AdminPanelProvider: School ID is null, cannot fetch school classes.");
        return;
      }
      _schoolClasses = await _classService.getClasses(_currentSchoolId!);
      logger.d("AdminPanelProvider: Fetched school classes: ${_schoolClasses.length}");
    } catch (e) {
      logger.e("AdminPanelProvider: Error fetching school classes: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
