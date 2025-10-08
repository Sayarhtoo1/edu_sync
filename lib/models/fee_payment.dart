class FeePayment {
  final String id;
  final int studentId;
  final String? feeStructureId;
  final double amountPaid;
  final DateTime paymentDate;
  final String paymentMethod;
  final String? transactionId;
  final String status;
  final String? receiptNumber;
  final String? receiptUrl;
  final String? notes;
  final String? collectedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  FeePayment({
    required this.id,
    required this.studentId,
    this.feeStructureId,
    required this.amountPaid,
    required this.paymentDate,
    required this.paymentMethod,
    this.transactionId,
    required this.status,
    this.receiptNumber,
    this.receiptUrl,
    this.notes,
    this.collectedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FeePayment.fromJson(Map<String, dynamic> json) {
    return FeePayment(
      id: json['id'],
      studentId: json['student_id'],
      feeStructureId: json['fee_structure_id'],
      amountPaid: (json['amount_paid'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date']),
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      status: json['status'],
      receiptNumber: json['receipt_number'],
      receiptUrl: json['receipt_url'],
      notes: json['notes'],
      collectedBy: json['collected_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'fee_structure_id': feeStructureId,
      'amount_paid': amountPaid,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'status': status,
      'receipt_number': receiptNumber,
      'receipt_url': receiptUrl,
      'notes': notes,
      'collected_by': collectedBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
