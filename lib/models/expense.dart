import 'package:flutter/foundation.dart';
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
    // Add this block for logging
    if (kDebugMode) {
      print('--- Deserializing Expense ---');
      print('Raw data: $map');
      if (map['description'] == null) {
        print('WARNING: Expense "description" is null.');
      }
      if (map['date'] == null) {
        print('WARNING: Expense "date" is null.');
      }
      if (map['category'] == null) {
        print('WARNING: Expense "category" is null.');
      }
      print('---------------------------');
    }
    // End of logging block

    return Expense(
      id: map['id'] as int?,
      schoolId: map['school_id'] as int,
      description: map['description'] as String,
      amount: double.parse(map['amount'].toString()),
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String?,
      createdByUserId: map['created_by_user_id'] as String?,
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
