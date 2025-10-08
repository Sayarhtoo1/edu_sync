import 'package:flutter/material.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/services/school_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/utils/logger.dart';
import 'package:edu_sync/models/school_class.dart'; // Import SchoolClass model
import 'package:edu_sync/models/student.dart'; // Import Student model
 
 class SchoolProvider with ChangeNotifier {
   School? _currentSchool;
   bool _isLoading = false;
   final SchoolService _schoolService;
   final AuthService _authService;
   List<SchoolClass> _schoolClasses = []; // Add list for school classes
   List<Student> _students = []; // Add list for students
 
   SchoolProvider(this._schoolService, this._authService);
 
   School? get currentSchool => _currentSchool;
   bool get isLoading => _isLoading;
   List<SchoolClass> get schoolClasses => _schoolClasses; // Getter for school classes
   List<Student> get students => _students; // Getter for students
 
   Future<void> fetchCurrentSchool() async {
     _isLoading = true;
     notifyListeners();

    final user = _authService.getCurrentUser();
    if (user != null) {
      // Attempt to get school_id from user's public profile first
      final schoolIdFromProfile = await _authService.getCurrentUserSchoolId();
      if (schoolIdFromProfile != null) {
        _currentSchool = await _schoolService.getSchoolById(schoolIdFromProfile);
      } else if (user.userMetadata?['school_id'] != null) {
        // Fallback to userMetadata if profile fetch fails or school_id not in public.users yet
        try {
          final schoolIdFromMeta = user.userMetadata!['school_id'] as int;
          _currentSchool = await _schoolService.getSchoolById(schoolIdFromMeta);
        } catch (e) {
          logger.e("Error fetching school from metadata: $e");
          _currentSchool = null;
        }
      } else {
        _currentSchool = null;
      }
    } else {
      _currentSchool = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearSchool() {
    _currentSchool = null;
    notifyListeners();
  }

  // Call this after admin registers a new school or updates school info
  Future<void> refreshSchoolData(int schoolId) async {
     _isLoading = true;
    notifyListeners();
    _currentSchool = await _schoolService.getSchoolById(schoolId);
     _isLoading = false;
    notifyListeners();
  }
 
   Future<void> fetchClasses(int schoolId) async {
     _isLoading = true;
     notifyListeners();
     _schoolClasses = await _schoolService.getClassesBySchoolId(schoolId);
     _isLoading = false;
     notifyListeners();
   }

  Future<void> fetchStudents(int schoolId) async {
    _isLoading = true;
    notifyListeners();
    _students = await _schoolService.getStudentsBySchoolId(schoolId); // Assuming this service method exists
    _isLoading = false;
    notifyListeners();
  }
 }
