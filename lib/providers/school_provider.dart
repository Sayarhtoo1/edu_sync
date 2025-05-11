import 'package:flutter/material.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/services/school_service.dart';
import 'package:edu_sync/services/auth_service.dart';

class SchoolProvider with ChangeNotifier {
  School? _currentSchool;
  bool _isLoading = false;
  final SchoolService _schoolService = SchoolService();
  final AuthService _authService = AuthService();

  School? get currentSchool => _currentSchool;
  bool get isLoading => _isLoading;

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
          print("Error fetching school from metadata: $e");
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
}
