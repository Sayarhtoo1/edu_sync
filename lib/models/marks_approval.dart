class MarksApproval {
  final String id;
  final String examId;
  final String subjectId;
  final String? submittedBy;
  final String? approvedBy;
  final String status;
  final String? comments;
  final DateTime submittedAt;
  final DateTime? reviewedAt;

  MarksApproval({
    required this.id,
    required this.examId,
    required this.subjectId,
    this.submittedBy,
    this.approvedBy,
    required this.status,
    this.comments,
    required this.submittedAt,
    this.reviewedAt,
  });

  factory MarksApproval.fromMap(Map<String, dynamic> map) {
    return MarksApproval(
      id: map['id'],
      examId: map['exam_id'],
      subjectId: map['subject_id'],
      submittedBy: map['submitted_by'],
      approvedBy: map['approved_by'],
      status: map['status'],
      comments: map['comments'],
      submittedAt: DateTime.parse(map['submitted_at']),
      reviewedAt: map['reviewed_at'] != null ? DateTime.parse(map['reviewed_at']) : null,
    );
  }
}
