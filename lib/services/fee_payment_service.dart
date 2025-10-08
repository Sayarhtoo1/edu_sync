import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fee_payment.dart';
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

  Future<FeePayment?> createPayment(FeePayment payment) async {
    try {
      final response = await _supabase
          .from('fee_payments')
          .insert(payment.toJson())
          .select()
          .single();
      return FeePayment.fromJson(response);
    } catch (e) {
      logger.e('Error creating payment: $e');
      return null;
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
}
