import 'package:flutter/material.dart';
import '../services/class_service.dart';
import '../models/school_class.dart';

class ClassProvider with ChangeNotifier {
  final ClassService _classService;
  List<SchoolClass> _classes = [];

  ClassProvider(this._classService);

  List<SchoolClass> get classes => _classes;

  Future<void> fetchClasses(String schoolId) async {
    try {
      _classes = await _classService.getClassesBySchoolId(int.parse(schoolId));
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
