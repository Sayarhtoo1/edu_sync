
class Announcement {
  final int id;
  final int schoolId;
  final String title;
  final String content;
  final String? createdByUserId; // UUID
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? targetRole; // 'All', 'Teachers', 'Parents', 'SpecificClass'
  final int? targetClassId; // Corrected to int?

  Announcement({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.content,
    this.createdByUserId,
    required this.createdAt,
    required this.updatedAt,
    this.targetRole,
    this.targetClassId,
  });

  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'] as int,
      schoolId: map['school_id'] as int,
      title: map['title'] as String,
      content: map['content'] as String,
      createdByUserId: map['created_by_user_id'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      targetRole: map['target_role'] as String?,
      targetClassId: map['target_class_id'] as int?, // Corrected to int?
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // 'id': id, // Not sent for insert
      'school_id': schoolId,
      'title': title,
      'content': content,
      'created_by_user_id': createdByUserId,
      // 'created_at': createdAt.toIso8601String(), // Handled by DB
      // 'updated_at': updatedAt.toIso8601String(), // Handled by DB
      'target_role': targetRole,
      'target_class_id': targetClassId,
    };
  }
}
