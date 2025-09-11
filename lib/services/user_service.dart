import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user; // Alias to avoid conflict

class UserService {
  final SupabaseClient _supabaseClient;

  UserService(this._supabaseClient);

  Future<List<app_user.User>> getTeachers() async {
    try {
      final List<Map<String, dynamic>> response = await _supabaseClient
          .from('users') // Assuming 'users' is your table name
          .select()
          .eq('role', 'teacher') // Assuming 'role' column and 'teacher' role
          .order('full_name', ascending: true); // Order by full_name

      return response.map((json) => app_user.User.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error fetching teachers: $e');
    }
  }
}