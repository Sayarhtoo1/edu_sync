class FeeStructure {
  final String id;
  final int schoolId;
  final int? classId;
  final String feeType;
  final double amount;
  final String frequency;
  final String? academicYear;
  final String? description;
  final bool isMandatory;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeeStructure({
    required this.id,
    required this.schoolId,
    this.classId,
    required this.feeType,
    required this.amount,
    required this.frequency,
    this.academicYear,
    this.description,
    this.isMandatory = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) {
    return FeeStructure(
      id: json['id'],
      schoolId: json['school_id'],
      classId: json['class_id'],
      feeType: json['fee_type'],
      amount: (json['amount'] as num).toDouble(),
      frequency: json['frequency'],
      academicYear: json['academic_year'],
      description: json['description'],
      isMandatory: json['is_mandatory'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'class_id': classId,
      'fee_type': feeType,
      'amount': amount,
      'frequency': frequency,
      'academic_year': academicYear,
      'description': description,
      'is_mandatory': isMandatory,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
