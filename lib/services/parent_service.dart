import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/utils/logger.dart';
import 'package:edu_sync/services/cache_service.dart';

class ParentService {
  final SupabaseClient _supabaseClient;
  final CacheService _cache;

  ParentService(this._supabaseClient, this._cache);

  // Get all parents for a school
  Future<List<app_user.User>> getParentsBySchool(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('users')
          .select()
          .eq('role', UserRole.Parent.name)
          .eq('school_id', schoolId)
          .order('full_name', ascending: true);

      final parents = response.map((data) => app_user.User.fromJson(data)).toList();
      await _cache.cacheUsers(parents);
      return parents;
    } catch (e) {
      logger.e('Error fetching parents: $e');
      return await _cache.getCachedUsersByRole(UserRole.Parent.name);
    }
  }

  // Get students linked to a parent
  Future<List<int>> getStudentIdsForParent(String parentId) async {
    try {
      final response = await _supabaseClient
          .from('parent_student_relations')
          .select('student_id')
          .eq('parent_id', parentId);
      return response.map((data) => data['student_id'] as int).toList();
    } catch (e) {
      logger.e('Error fetching student IDs for parent: $e');
      return [];
    }
  }

  // Create parent via edge function
  Future<String> createParent({
    required String email,
    required String password,
    required int schoolId,
    required String fullName,
    String? profilePhotoUrl,
    String? phoneNumber1,
    String? phoneNumber2,
  }) async {
    try {
      // Use create-staff-by-admin edge function which handles all user types
      final response = await _supabaseClient.functions.invoke(
        'create-staff-by-admin',
        body: {
          'email': email,
          'password': password,
          'role': UserRole.Parent.name,
          'school_id': schoolId,
          'full_name': fullName,
          'profile_photo_url': profilePhotoUrl,
          'phone_number': phoneNumber1, // Edge function expects phone_number (singular)
          // Note: phoneNumber2 will need to be updated separately after user creation
        },
      );

      if (response.data == null) {
        throw Exception('Failed to create parent: Edge function returned no data.');
      }

      final responseData = response.data as Map<String, dynamic>;
      if (responseData.containsKey('error')) {
        throw Exception('Failed to create parent: ${responseData['error']}');
      }

      // create-staff-by-admin returns {"user": {...}}
      final user = app_user.User.fromJson(responseData['user']);
      return user.id;
    } catch (e) {
      logger.e('Error creating parent: $e');
      rethrow;
    }
  }

  // Update parent
  Future<bool> updateParent(app_user.User parent) async {
    try {
      await _supabaseClient.from('users').update({
        'full_name': parent.fullName,
        'profile_photo_url': parent.profilePhotoUrl,
        'phone_number_1': parent.phoneNumber1,
        'phone_number_2': parent.phoneNumber2,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', parent.id);
      return true;
    } catch (e) {
      logger.e('Error updating parent: $e');
      return false;
    }
  }

  // Delete parent
  Future<bool> deleteParent(String parentId) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'delete-user-by-admin',
        body: {'user_id': parentId},
      );

      if (response.data == null) {
        return false;
      }

      final responseData = response.data as Map<String, dynamic>;
      if (responseData.containsKey('error')) {
        logger.e('Error deleting parent: ${responseData['error']}');
        return false;
      }

      return true;
    } catch (e) {
      logger.e('Error deleting parent: $e');
      return false;
    }
  }
}
