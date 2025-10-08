import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/staff.dart';

class StaffService {
  final SupabaseClient _supabaseClient;

  StaffService(this._supabaseClient);

  Future<List<Staff>> getStaff() async {
    try {
      final List<Map<String, dynamic>> response = await _supabaseClient
          .from('users')
          .select()
          .filter('role', 'in', '("Admin","Teacher")');

      return response.map((json) => Staff.fromMap(json)).toList();
    } catch (e) {
      throw Exception('Error fetching staff: $e');
    }
  }
}
