class SalaryPayment {
  final String id;
  final String staffId;
  final int schoolId;
  final double amount;
  final DateTime paymentDate;
  final String paymentMonth;
  final String paymentMethod;
  final String? transactionId;
  final String status;
  final String? notes;
  final String? paidBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  SalaryPayment({
    required this.id,
    required this.staffId,
    required this.schoolId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMonth,
    required this.paymentMethod,
    this.transactionId,
    required this.status,
    this.notes,
    this.paidBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SalaryPayment.fromJson(Map<String, dynamic> json) {
    return SalaryPayment(
      id: json['id'],
      staffId: json['staff_id'],
      schoolId: json['school_id'],
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date']),
      paymentMonth: json['payment_month'],
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      status: json['status'],
      notes: json['notes'],
      paidBy: json['paid_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'school_id': schoolId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String().split('T')[0],
      'payment_month': paymentMonth,
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'status': status,
      'notes': notes,
      'paid_by': paidBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
