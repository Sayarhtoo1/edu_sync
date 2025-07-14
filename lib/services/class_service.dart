import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'cache_service.dart';

class ClassService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cacheService = CacheService();

  // Fetch all classes for a school
  Future<List<app_class.SchoolClass>> getClasses(int schoolId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Offline: Fetch from cache
      return await _cacheService.getClasses(schoolId);
    } else {
      // Online: Fetch from Supabase and update cache
      try {
        final List<dynamic> responseData = await _supabaseClient
            .from('classes')
            .select()
            .eq('school_id', schoolId);
        final classes = responseData.map((data) => app_class.SchoolClass.fromMap(data as Map<String, dynamic>)).toList();
        await _cacheService.saveClasses(schoolId, classes);
        return classes;
      } catch (e) {
        print('Error fetching classes by school: $e');
        return await _cacheService.getClasses(schoolId);
      }
    }
  }

  // Add a new class
  Future<app_class.SchoolClass?> createClass(app_class.SchoolClass newClass) async {
    try {
      final response = await _supabaseClient
          .from('classes')
          .insert(newClass.toMap()..remove('id')) // Remove id for insert
          .select()
          .single();
      return app_class.SchoolClass.fromMap(response);
    } catch (e) {
      print('Error creating class: $e');
      return null;
    }
  }

  // Update class details
  Future<bool> updateClass(app_class.SchoolClass classToUpdate) async {
    try {
      if (classToUpdate.id == null) {
        print('Error: Class ID is null, cannot update.');
        return false;
      }
      await _supabaseClient
          .from('classes')
          .update(classToUpdate.toMap()..remove('id')) // Do not update id
          .eq('id', classToUpdate.id!); // Use null-check operator
      return true;
    } catch (e) {
      print('Error updating class: $e');
      return false;
    }
  }

  // Delete a class
  Future<bool> deleteClass(int classId) async { // Corrected to int
    try {
      await _supabaseClient
          .from('classes')
          .delete()
          .eq('id', classId);
      return true;
    } catch (e) {
      print('Error deleting class: $e');
      return false;
    }
  }
}
