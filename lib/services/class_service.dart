import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/class.dart' as app_class;

class ClassService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Fetch all classes for a school
  Future<List<app_class.Class>> getClassesBySchool(int schoolId) async {
    try {
      final List<dynamic> responseData = await _supabaseClient
          .from('classes')
          .select()
          .eq('school_id', schoolId);
      return responseData.map((data) => app_class.Class.fromMap(data as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error fetching classes by school: $e');
      return [];
    }
  }

  // Add a new class
  Future<app_class.Class?> createClass(app_class.Class newClass) async {
    try {
      final response = await _supabaseClient
          .from('classes')
          .insert(newClass.toMap()..remove('id')) // Remove id for insert
          .select()
          .single();
      return app_class.Class.fromMap(response);
    } catch (e) {
      print('Error creating class: $e');
      return null;
    }
  }

  // Update class details
  Future<bool> updateClass(app_class.Class classToUpdate) async {
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
