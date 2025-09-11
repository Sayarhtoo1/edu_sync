// Required for ForeignKey
// Assuming studentId links to public.students
// Assuming parentId links to public.users

class FormResponse {
  final String id; // uuid
  final String formId; // uuid
  final int studentId; // INTEGER, referencing public.students(id)
  final String parentId; // uuid of the parent (user)
  final DateTime submittedAt;

  FormResponse({
    required this.id,
    required this.formId,
    required this.studentId,
    required this.parentId,
    required this.submittedAt,
  });

  factory FormResponse.fromMap(Map<String, dynamic> map) {
    return FormResponse(
      id: map['id'] ?? '',
      formId: map['form_id'] ?? '',
      studentId: map['student_id'] ?? 0,
      parentId: map['parent_id'] ?? '',
      submittedAt: DateTime.tryParse(map['submitted_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'form_id': formId,
      'student_id': studentId,
      'parent_id': parentId,
      'submitted_at': submittedAt.toIso8601String(),
    };
  }
}
