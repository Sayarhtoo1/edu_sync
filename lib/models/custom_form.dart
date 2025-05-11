import 'package:floor/floor.dart';
import 'package:intl/intl.dart';
import 'dart:convert'; // Import for jsonEncode/Decode

@Entity(tableName: 'custom_forms')
class CustomForm {
  @PrimaryKey()
  final String id; // uuid
  @ColumnInfo(name: 'school_id')
  final int schoolId; 
  final String title;
  @ColumnInfo(name: 'created_by') 
  final String createdBy; // uuid
  
  @ColumnInfo(name: 'assigned_class_ids_json') 
  final String? assignedClassIdsJson; // JSON string of List<int>
  
  @ColumnInfo(name: 'assigned_student_ids_json')
  final String? assignedStudentIdsJson; // JSON string of List<int>

  @ColumnInfo(name: 'assigned_section_details_json') 
  final String? assignedSectionDetailsJson;

  @ColumnInfo(name: 'assign_to_whole_school')
  final bool assignToWholeSchool;

  @ColumnInfo(name: 'active_from')
  final DateTime activeFrom;
  @ColumnInfo(name: 'active_to')
  final DateTime activeTo;
  @ColumnInfo(name: 'is_daily')
  final bool isDaily; 

  @ColumnInfo(name: 'created_at')
  final DateTime createdAt;
  @ColumnInfo(name: 'updated_at') 
  final DateTime? updatedAt; 

  @ignore
  List<int> get assignedClassIds => CustomForm.sFromJsonListInt(assignedClassIdsJson); // Corrected to List<int>
  @ignore
  List<int> get assignedStudentIds => CustomForm.sFromJsonListInt(assignedStudentIdsJson); // Corrected to List<int>
  @ignore
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
      print("Error decoding assignedSectionDetailsJson: $e");
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
    // Supabase returns INTEGER[] as List<dynamic> (of int)
    List<dynamic>? rawClassIds = map['assigned_class_ids'] as List<dynamic>?;
    List<dynamic>? rawStudentIds = map['assigned_student_ids'] as List<dynamic>?;

    List<int>? classIdsFromDb = rawClassIds?.map((e) => e as int).toList();
    List<int>? studentIdsFromDb = rawStudentIds?.map((e) => e as int).toList();
    
    return CustomForm(
      id: map['id'] as String, // Form ID itself is UUID String
      schoolId: map['school_id'] as int,
      title: map['title'] as String,
      createdBy: map['created_by'] as String, 
      assignedClassIdsJson: classIdsFromDb != null ? jsonEncode(classIdsFromDb) : null, // Store List<int> as JSON
      assignedStudentIdsJson: studentIdsFromDb != null ? jsonEncode(studentIdsFromDb) : null, // Store List<int> as JSON
      assignedSectionDetailsJson: map['assigned_section_details'] != null
          ? jsonEncode(map['assigned_section_details']) 
          : null,
      assignToWholeSchool: map['assign_to_whole_school'] as bool? ?? false,
      activeFrom: DateTime.parse(map['active_from'] as String),
      activeTo: DateTime.parse(map['active_to'] as String),
      isDaily: map['is_daily'] as bool? ?? true,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at'] as String) : null,
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
      print("Error encoding List<String> to JSON string for Floor: $e");
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
      print("Error decoding JSON string to List<int> from Floor: $e");
      return []; 
    }
  }
}
