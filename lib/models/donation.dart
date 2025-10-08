class Donation {
  final String id;
  final int schoolId;
  final String? donatorId;
  final String donatorName;
  final String? donatorEmail;
  final String? donatorPhone;
  final double amount;
  final DateTime donationDate;
  final String paymentMethod;
  final String? transactionId;
  final String? purpose;
  final bool isAnonymous;
  final String? receiptNumber;
  final String? receiptUrl;
  final String status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Donation({
    required this.id,
    required this.schoolId,
    this.donatorId,
    required this.donatorName,
    this.donatorEmail,
    this.donatorPhone,
    required this.amount,
    required this.donationDate,
    required this.paymentMethod,
    this.transactionId,
    this.purpose,
    this.isAnonymous = false,
    this.receiptNumber,
    this.receiptUrl,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      schoolId: json['school_id'],
      donatorId: json['donator_id'],
      donatorName: json['donator_name'],
      donatorEmail: json['donator_email'],
      donatorPhone: json['donator_phone'],
      amount: (json['amount'] as num).toDouble(),
      donationDate: DateTime.parse(json['donation_date']),
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      purpose: json['purpose'],
      isAnonymous: json['is_anonymous'] ?? false,
      receiptNumber: json['receipt_number'],
      receiptUrl: json['receipt_url'],
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'donator_id': donatorId,
      'donator_name': donatorName,
      'donator_email': donatorEmail,
      'donator_phone': donatorPhone,
      'amount': amount,
      'donation_date': donationDate.toIso8601String().split('T')[0],
      'payment_method': paymentMethod,
      'transaction_id': transactionId,
      'purpose': purpose,
      'is_anonymous': isAnonymous,
      'receipt_number': receiptNumber,
      'receipt_url': receiptUrl,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
