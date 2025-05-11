import 'package:floor/floor.dart';
import 'package:intl/intl.dart'; // Import DateFormat

@entity
class Income {
  @PrimaryKey() // id is nullable, DB handles auto-generation
  final int? id;
  final int schoolId;
  final String description;
  final double amount;
  final DateTime date;
  final String? createdByUserId; // Added

  Income({
    this.id,
    required this.schoolId,
    required this.description,
    required this.amount,
    required this.date,
    this.createdByUserId, // Added
  });

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] as int?,
      schoolId: map['school_id'] as int,
      description: map['description'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      createdByUserId: map['created_by_user_id'] as String?, // Added
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'school_id': schoolId,
      'description': description,
      'amount': amount,
      'date': DateFormat('yyyy-MM-dd').format(date),
      'created_by_user_id': createdByUserId, // Added
    };
  }
}
