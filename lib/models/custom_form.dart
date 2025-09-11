import 'package:intl/intl.dart';
import 'dart:convert'; // Import for jsonEncode/Decode
import 'package:edu_sync/utils/logger.dart';

class CustomForm {
  final String id; // uuid
  final int schoolId; 
  final String title;
  final String createdBy; // uuid
  
  final String? assignedClassIdsJson; // JSON string of List<int>
  
  final String? assignedStudentIdsJson; // JSON string of List<int>

  final String? assignedSectionDetailsJson;

  final bool assignToWholeSchool;

  final DateTime activeFrom;
  final DateTime activeTo;
  final bool isDaily; 

  final DateTime createdAt;
  final DateTime? updatedAt; 

  List<int> get assignedClassIds => CustomForm.sFromJsonListInt(assignedClassIdsJson); // Corrected to List<int>
  List<int> get assignedStudentIds => CustomForm.sFromJsonListInt(assignedStudentIdsJson); // Corrected to List<int>
  List<Map<String, String>> get assignedSectionDetails { 
    if (assignedSectionDetailsJson == null || assignedSectionDetailsJson!.isEmpty) return [];
    try {
      final decoded = jsonDecode(assignedSectionDetailsJson!);
      if (decoded is List) {
        return List<Map<String, String>>.from(decoded.map((item) {
          if (item is Map) {
            return Map<String, String>.from(item.map((key, value) => MapEntry(key.toString(), value.toString())));
          }
          return <String, String>{}; 
        }).where((item) => item.isNotEmpty));
      }
      return [];
    } catch (e) {
      logger.e("Error decoding assignedSectionDetailsJson: $e");
      return [];
    }
  }

  CustomForm({
    required this.id,
    required this.schoolId, 
    required this.title,
    required this.createdBy, 
    this.assignedClassIdsJson,
    this.assignedStudentIdsJson,
    this.assignedSectionDetailsJson, 
    required this.assignToWholeSchool,
    required this.activeFrom,
    required this.activeTo,
    required this.isDaily,
    required this.createdAt,
    this.updatedAt,
  });

  factory CustomForm.fromMap(Map<String, dynamic> map) {
    List<dynamic>? rawClassIds = map['assigned_class_ids'];
    List<dynamic>? rawStudentIds = map['assigned_student_ids'];

    List<int>? classIdsFromDb = rawClassIds?.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    List<int>? studentIdsFromDb = rawStudentIds?.map((e) => int.tryParse(e.toString()) ?? 0).toList();

    return CustomForm(
      id: map['id'] ?? '',
      schoolId: map['school_id'] ?? 0,
      title: map['title'] ?? '',
      createdBy: map['created_by'] ?? '',
      assignedClassIdsJson: classIdsFromDb != null ? jsonEncode(classIdsFromDb) : null,
      assignedStudentIdsJson: studentIdsFromDb != null ? jsonEncode(studentIdsFromDb) : null,
      assignedSectionDetailsJson: map['assigned_section_details'] != null
          ? jsonEncode(map['assigned_section_details'])
          : null,
      assignToWholeSchool: map['assign_to_whole_school'] ?? false,
      activeFrom: DateTime.tryParse(map['active_from'] ?? '') ?? DateTime.now(),
      activeTo: DateTime.tryParse(map['active_to'] ?? '') ?? DateTime.now(),
      isDaily: map['is_daily'] ?? true,
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'school_id': schoolId, 
      'title': title,
      'created_by': createdBy, 
      'assigned_class_ids': assignedClassIds, // Getter returns List<int>
      'assigned_student_ids': assignedStudentIds, // Getter returns List<int>
      'assigned_section_details': assignedSectionDetails, 
      'assign_to_whole_school': assignToWholeSchool,
      'active_from': DateFormat('yyyy-MM-dd').format(activeFrom),
      'active_to': DateFormat('yyyy-MM-dd').format(activeTo),
      'is_daily': isDaily,
    };
  }
  
  // Helper methods for JSON string conversion for Floor
  static String? sToJsonListString(List<String>? list) { // Added back
    if (list == null || list.isEmpty) return null;
    try {
      return jsonEncode(list);
    } catch (e) {
      logger.e("Error encoding List<String> to JSON string for Floor: $e");
      return null;
    }
  }

  static String? sToJsonListInt(List<int>? list) { 
    if (list == null || list.isEmpty) return null;
    try {
      return jsonEncode(list); 
    } catch (e) { 
      print("Error encoding List<int> to JSON string for Floor: $e");
      return null;
    }
  }

  static List<int> sFromJsonListInt(String? jsonString) { // Changed from sFromJsonListString
    if (jsonString == null || jsonString.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is List) {
        return List<int>.from(decoded.map((e) => int.tryParse(e.toString()) ?? 0).where((e) => e != 0 || (e == 0 && decoded.contains(0)))); // Handle potential parse errors
        }
        return [];
      } catch (e) {
        logger.e("Error decoding JSON string to List<int> from Floor: $e");
        return [];
      }
    }
  }
