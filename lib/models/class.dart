import 'package:floor/floor.dart';

@Entity(tableName: 'classes')
class Class {
  @PrimaryKey(autoGenerate: true) // Allow Floor to auto-generate for local cache if needed
  final int? id; // Changed to int?
  final String name;
  @ColumnInfo(name: 'teacher_id')
  final String? teacherId; // Assuming teacher_id is UUID (String)
  @ColumnInfo(name: 'school_id')
  final int schoolId;
  final String? section; 

  Class({
    required this.id, // Now int
    required this.name,
    this.teacherId,
    required this.schoolId,
    this.section,
  });

  factory Class.fromMap(Map<String, dynamic> map) {
    return Class(
      id: map['id'] as int, // Corrected to int
      name: map['name'] as String,
      teacherId: map['teacher_id'] as String?,
      schoolId: map['school_id'] as int,
      section: map['section'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'teacher_id': teacherId,
      'school_id': schoolId,
      'section': section,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Class copyWith({
    int? id, 
    String? name,
    String? teacherId,
    int? schoolId,
    String? section,
  }) {
    return Class(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      schoolId: schoolId ?? this.schoolId,
      section: section ?? this.section,
    );
  }
}
