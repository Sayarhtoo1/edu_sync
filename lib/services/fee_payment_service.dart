import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fee_payment.dart';
import '../models/income.dart';
import '../utils/logger.dart';

class FeePaymentService {
  final SupabaseClient _supabase;

  FeePaymentService(this._supabase);

  Future<List<FeePayment>> getPaymentsByStudent(int studentId) async {
    try {
      final response = await _supabase
          .from('fee_payments')
          .select()
          .eq('student_id', studentId)
          .order('payment_date', ascending: false);
      return (response as List).map((e) => FeePayment.fromJson(e)).toList();
    } catch (e) {
      logger.e('Error fetching payments: $e');
      return [];
    }
  }

  Future<FeePayment?> createPayment(FeePayment payment, {String? feeType}) async {
    try {
      final response = await _supabase
          .from('fee_payments')
          .insert(payment.toJson())
          .select('*, students!inner(school_id, full_name)')
          .single();
      
      final createdPayment = FeePayment.fromJson(response);
      
      // Create income entry for paid fee payments
      if (payment.status == 'Paid') {
        await _createIncomeEntry(response, payment, feeType);
      }
      
      return createdPayment;
    } catch (e) {
      logger.e('Error creating payment: $e');
      return null;
    }
  }

  Future<void> _createIncomeEntry(Map<String, dynamic> paymentData, FeePayment payment, String? feeType) async {
    try {
      final studentName = paymentData['students']['full_name'] ?? 'Student';
      final schoolId = paymentData['students']['school_id'];
      final category = feeType != null ? '$feeType Fee' : 'Tuition Fees';
      
      final income = Income(
        schoolId: schoolId,
        description: 'Fee payment from $studentName',
        amount: payment.amountPaid,
        date: payment.paymentDate,
        category: category,
        createdByUserId: payment.collectedBy,
      );
      
      await _supabase.from('finance_entries').insert({
        ...income.toMap(),
        'entry_type': 'Income',
      });
    } catch (e) {
      logger.e('Error creating income entry: $e');
    }
  }

  Future<Map<String, dynamic>> getOutstandingFees(int studentId) async {
    try {
      final response = await _supabase
          .from('outstanding_fees')
          .select()
          .eq('student_id', studentId);
      
      double total = 0;
      for (var fee in response) {
        total += (fee['outstanding_amount'] as num).toDouble();
      }
      
      return {
        'fees': response,
        'total_outstanding': total,
      };
    } catch (e) {
      logger.e('Error fetching outstanding fees: $e');
      return {'fees': [], 'total_outstanding': 0.0};
    }
  }

  Future<List<FeePayment>> getAllPayments(int schoolId) async {
    try {
      final response = await _supabase
          .from('fee_payments')
          .select('*, students!inner(school_id, full_name, class_id)')
          .eq('students.school_id', schoolId)
          .order('payment_date', ascending: false);
      return (response as List).map((e) => FeePayment.fromJson(e)).toList();
    } catch (e) {
      logger.e('Error fetching all payments: $e');
      return [];
    }
  }

  Future<List<FeePayment>> getPaymentsByClass(int classId) async {
    try {
      final response = await _supabase
          .from('fee_payments')
          .select('*, students!inner(class_id)')
          .eq('students.class_id', classId)
          .order('payment_date', ascending: false);
      return (response as List).map((e) => FeePayment.fromJson(e)).toList();
    } catch (e) {
      logger.e('Error fetching payments by class: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getOutstandingFeesSummary(int schoolId) async {
    try {
      final response = await _supabase.rpc('get_outstanding_fees_summary', params: {'p_school_id': schoolId});
      return response ?? {'total_outstanding': 0, 'students_with_dues': 0};
    } catch (e) {
      logger.e('Error fetching outstanding fees summary: $e');
      return {'total_outstanding': 0, 'students_with_dues': 0};
    }
  }

  Future<FeePayment?> updatePayment(String paymentId, Map<String, dynamic> updates) async {
    try {
      final response = await _supabase
          .from('fee_payments')
          .update(updates)
          .eq('id', paymentId)
          .select()
          .single();
      return FeePayment.fromJson(response);
    } catch (e) {
      logger.e('Error updating payment: $e');
      return null;
    }
  }

  Future<bool> deletePayment(String paymentId) async {
    try {
      final payment = await _supabase.from('fee_payments').select('*, students!inner(school_id, full_name)').eq('id', paymentId).single();
      
      await _supabase.from('fee_payments').delete().eq('id', paymentId);
      
      if (payment['status'] == 'Paid' && payment['amount_paid'] > 0) {
        await _deleteIncomeEntry(payment);
      }
      
      return true;
    } catch (e) {
      logger.e('Error deleting payment: $e');
      return false;
    }
  }

  Future<void> _deleteIncomeEntry(Map<String, dynamic> paymentData) async {
    try {
      final studentName = paymentData['students']['full_name'] ?? 'Student';
      final amount = (paymentData['amount_paid'] as num).toDouble();
      final date = paymentData['payment_date'];
      final schoolId = paymentData['students']['school_id'];
      
      final entries = await _supabase.from('finance_entries').select()
          .eq('entry_type', 'Income')
          .eq('school_id', schoolId)
          .eq('amount', amount)
          .eq('date', date);
      
      for (var entry in entries) {
        final description = entry['description'] as String? ?? '';
        if (description.contains(studentName)) {
          await _supabase.from('finance_entries').delete().eq('id', entry['id']);
          logger.i('Deleted income entry for $studentName');
          break;
        }
      }
    } catch (e) {
      logger.e('Error deleting income entry: $e');
    }
  }
}
