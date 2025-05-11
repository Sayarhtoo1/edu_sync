import 'package:floor/floor.dart';
import 'custom_form.dart'; // Required for ForeignKey
// Assuming studentId links to public.students
import 'package:edu_sync/models/user.dart';   // Assuming parentId links to public.users

@Entity(
  tableName: 'form_responses',
  foreignKeys: [
    ForeignKey(
      childColumns: ['form_id'],
      parentColumns: ['id'],
      entity: CustomForm,
      onDelete: ForeignKeyAction.cascade,
    ),
    // Assuming student_id refers to your app's Student model/table if students are not users
    // If student_id refers to a user with role 'Student', then entity would be User
    // For now, let's assume a separate Student model/table as per typical school apps.
    // ForeignKey( 
    //   childColumns: ['student_id'],
    //   parentColumns: ['id'], // Assuming Student model has 'id' as String (uuid)
    //   entity: Student, // This requires Student model to be a Floor entity
    //   onDelete: ForeignKeyAction.cascade,
    // ),
    ForeignKey(
      childColumns: ['parent_id'],
      parentColumns: ['id'],
      entity: User, // Assuming User model is a Floor entity
      onDelete: ForeignKeyAction.cascade,
    )
  ],
  indices: [
    Index(value: ['form_id']),
    Index(value: ['student_id']),
    Index(value: ['parent_id']),
    Index(value: ['form_id', 'student_id', 'submitted_at']) // Removed unique = true for Floor compatibility here
    // Uniqueness for form_id, student_id, date(submitted_at) should be handled by app logic or a DB constraint
  ]
)
class FormResponse {
  @PrimaryKey()
  final String id; // uuid

  @ColumnInfo(name: 'form_id')
  final String formId; // uuid
  @ColumnInfo(name: 'student_id')
  final int studentId; // INTEGER, referencing public.students(id)
  @ColumnInfo(name: 'parent_id')
  final String parentId; // uuid of the parent (user)

  @ColumnInfo(name: 'submitted_at')
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
      id: map['id'] as String,
      formId: map['form_id'] as String,
      studentId: map['student_id'] as int, // Changed to int
      parentId: map['parent_id'] as String,
      submittedAt: DateTime.parse(map['submitted_at'] as String),
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
