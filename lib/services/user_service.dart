import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart' as app_user;
import 'cache_service.dart';
import '../utils/logger.dart';

class UserService {
  final SupabaseClient _supabaseClient;
  final CacheService _cache;

  UserService(this._supabaseClient, this._cache);

  Future<List<app_user.User>> getTeachers() async {
    try {
      final List<Map<String, dynamic>> response = await _supabaseClient
          .from('users')
          .select()
          .eq('role', 'teacher')
          .order('full_name', ascending: true);

      final teachers = response.map((json) => app_user.User.fromJson(json)).toList();
      
      // Cache teachers
      await _cache.cacheUsers(teachers);
      
      return teachers;
    } catch (e) {
      logger.w('Error fetching teachers, using cache: $e');
      // Return cached teachers filtered by role
      final allCached = await _cache.getCachedUsersByRole('teacher');
      return allCached;
    }
  }
}