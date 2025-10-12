import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/salary_payment.dart';
import '../utils/logger.dart';

class SalaryService {
  final SupabaseClient _supabase;

  SalaryService(this._supabase);

  Future<List<Map<String, dynamic>>> getStaffWithSalary(int schoolId) async {
    try {
      final response = await _supabase
          .from('users')
          .select('id, full_name, role, email, salary')
          .eq('school_id', schoolId)
          .inFilter('role', ['Admin', 'Teacher', 'Staff', 'Manager'])
          .order('full_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      logger.e('Error fetching staff with salary: $e');
      return [];
    }
  }

  Future<List<SalaryPayment>> getSalaryPayments(int schoolId, {String? month}) async {
    try {
      var query = _supabase
          .from('salary_payments')
          .select()
          .eq('school_id', schoolId);
      
      if (month != null) {
        query = query.eq('payment_month', month);
      }
      
      final response = await query.order('payment_date', ascending: false);
      return (response as List).map((e) => SalaryPayment.fromJson(e)).toList();
    } catch (e) {
      logger.e('Error fetching salary payments: $e');
      return [];
    }
  }

  Future<SalaryPayment?> createSalaryPayment(SalaryPayment payment) async {
    try {
      final response = await _supabase
          .from('salary_payments')
          .insert(payment.toJson())
          .select()
          .single();
      return SalaryPayment.fromJson(response);
    } catch (e) {
      logger.e('Error creating salary payment: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getSalarySummary(int schoolId, String month) async {
    try {
      final payments = await _supabase
          .from('salary_payments')
          .select()
          .eq('school_id', schoolId)
          .eq('payment_month', month)
          .eq('status', 'Paid');
      
      double totalPaid = 0;
      int staffCount = 0;
      for (var payment in payments) {
        totalPaid += (payment['amount'] as num).toDouble();
        staffCount++;
      }
      
      return {
        'total_paid': totalPaid,
        'staff_count': staffCount,
        'payments': payments,
      };
    } catch (e) {
      logger.e('Error fetching salary summary: $e');
      return {'total_paid': 0.0, 'staff_count': 0, 'payments': []};
    }
  }

  Future<bool> updateStaffSalary(String staffId, double salary) async {
    try {
      await _supabase
          .from('users')
          .update({'salary': salary})
          .eq('id', staffId);
      return true;
    } catch (e) {
      logger.e('Error updating staff salary: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUnpaidStaff(int schoolId, String month) async {
    try {
      final allStaff = await getStaffWithSalary(schoolId);
      final paidStaff = await _supabase
          .from('salary_payments')
          .select('staff_id')
          .eq('school_id', schoolId)
          .eq('payment_month', month)
          .eq('status', 'Paid');
      
      final paidIds = paidStaff.map((e) => e['staff_id']).toSet();
      return allStaff.where((staff) => !paidIds.contains(staff['id'])).toList();
    } catch (e) {
      logger.e('Error fetching unpaid staff: $e');
      return [];
    }
  }

  Future<bool> deleteSalaryPayment(String paymentId) async {
    try {
      await _supabase
          .from('salary_payments')
          .delete()
          .eq('id', paymentId);
      return true;
    } catch (e) {
      logger.e('Error deleting salary payment: $e');
      return false;
    }
  }
}
