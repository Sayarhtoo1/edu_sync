class ExamTemplate {
  final String id;
  final int schoolId;
  final String name;
  final String? description;
  final List<Map<String, dynamic>> subjects;
  final String? createdBy;
  final DateTime createdAt;

  ExamTemplate({
    required this.id,
    required this.schoolId,
    required this.name,
    this.description,
    required this.subjects,
    this.createdBy,
    required this.createdAt,
  });

  factory ExamTemplate.fromMap(Map<String, dynamic> map) {
    return ExamTemplate(
      id: map['id'],
      schoolId: map['school_id'],
      name: map['name'],
      description: map['description'],
      subjects: List<Map<String, dynamic>>.from(map['subjects'] ?? []),
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school_id': schoolId,
      'name': name,
      'description': description,
      'subjects': subjects,
      'created_by': createdBy,
    };
  }
}
