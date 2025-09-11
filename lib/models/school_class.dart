import 'package:drift/drift.dart' show Value;
import 'package:edu_sync/database/app_database.dart' as db; // Alias app_database

class SchoolClass {
  final int? id; // Changed to int?
  final String name;
  final String? teacherId; // Assuming teacher_id is UUID (String)
  final int schoolId;
  final String? section;
  final DateTime? updatedAt;

  SchoolClass({
    required this.id, // Now int
    required this.name,
    this.teacherId,
    required this.schoolId,
    this.section,
    this.updatedAt,
  });

  factory SchoolClass.fromMap(Map<String, dynamic> map) {
    return SchoolClass(
      id: map['id'],
      name: map['name'] ?? '',
      teacherId: map['teacher_id'],
      schoolId: map['school_id'] ?? 0,
      section: map['section'],
      updatedAt: map['updated_at'] != null ? DateTime.parse(map['updated_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'teacher_id': teacherId,
      'school_id': schoolId,
      'section': section,
      'updated_at': updatedAt?.toIso8601String(),
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  // Convert SchoolClass to ClassesCompanion for drift
  db.ClassesCompanion toCompanion() {
    return db.ClassesCompanion(
      id: id != null ? Value(id!) : const Value.absent(),
      name: Value(name),
      teacherId: Value(teacherId),
      schoolId: Value(schoolId),
      section: Value(section),
      updatedAt: Value(updatedAt),
    );
  }

  // Convert ClassData from drift to SchoolClass
  factory SchoolClass.fromData(db.ClassesData data) {
    return SchoolClass(
      id: data.id,
      name: data.name,
      teacherId: data.teacherId,
      schoolId: data.schoolId,
      section: data.section,
      updatedAt: data.updatedAt,
    );
  }

  SchoolClass copyWith({
    int? id,
    String? name,
    String? teacherId,
    int? schoolId,
    String? section,
    DateTime? updatedAt,
  }) {
    return SchoolClass(
      id: id ?? this.id,
      name: name ?? this.name,
      teacherId: teacherId ?? this.teacherId,
      schoolId: schoolId ?? this.schoolId,
      section: section ?? this.section,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
