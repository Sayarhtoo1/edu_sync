import 'package:intl/intl.dart'; // Import DateFormat

class Expense {
  final int? id;
  final int schoolId;
  final String description;
  final double amount;
  final DateTime date;
  final String? category;
  final String? createdByUserId;

  Expense({
    this.id,
    required this.schoolId,
    required this.description,
    required this.amount,
    required this.date,
    this.category,
    this.createdByUserId,
  });

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      schoolId: map['school_id'] ?? 0,
      description: map['description'] ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0.0') ?? 0.0,
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
      category: map['category'],
      createdByUserId: map['created_by_user_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school_id': schoolId,
      'description': description,
      'amount': amount,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'category': category,
      'created_by_user_id': createdByUserId,
    };
  }
}
