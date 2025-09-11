
/// Represents an announcement within the school management system.
///
/// Announcements can be targeted to all users, specific roles (Teachers, Parents),
/// or a specific class.
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

  /// Creates an [Announcement] instance.
  ///
  /// [id] The unique identifier for the announcement.
  /// [schoolId] The ID of the school this announcement belongs to.
  /// [title] The title of the announcement.
  /// [content] The main content/body of the announcement.
  /// [createdByUserId] The UUID of the user who created the announcement (optional).
  /// [createdAt] The timestamp when the announcement was created.
  /// [updatedAt] The timestamp when the announcement was last updated.
  /// [targetRole] Specifies the target audience ('All', 'Teachers', 'Parents', 'SpecificClass') (optional).
  /// [targetClassId] The ID of the target class if [targetRole] is 'SpecificClass' (optional).
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

  /// Creates an [Announcement] instance from a map (e.g., from a JSON response).
  ///
  /// @param map A map containing the announcement data.
  /// @returns An [Announcement] instance.
  factory Announcement.fromMap(Map<String, dynamic> map) {
    return Announcement(
      id: map['id'] ?? 0,
      schoolId: map['school_id'] ?? 0,
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      createdByUserId: map['created_by_user_id'],
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
      targetRole: map['target_role'],
      targetClassId: map['target_class_id'],
    );
  }

  /// Converts this [Announcement] instance into a map.
  ///
  /// This is typically used for sending data to a database or API.
  /// The 'id', 'created_at', and 'updated_at' fields are typically handled by the database
  /// and are commented out for insert operations.
  ///
  /// @returns A map representation of the announcement.
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
