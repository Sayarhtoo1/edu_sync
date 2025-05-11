import 'dart:io'; // Moved import to the top
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/school.dart'; // Assuming School model is defined

class SchoolService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Create a new school profile
  Future<School?> createSchool({
    required String name,
    String? logoUrl,
    String? academicYear,
    String? theme,
    String? contactInfo,
    required String adminUserId, // To link the school to the admin who created it
  }) async {
    try {
      final response = await _supabaseClient.from('schools').insert({
        'name': name,
        'logo_url': logoUrl,
        'academic_year': academicYear,
        'theme': theme,
        'contact_info': contactInfo,
        // 'created_by': adminUserId, // If you have a created_by field linking to users.id
      }).select().single(); // Use .select().single() to get the created record back

      // After creating the school, update the admin user's school_id
      await _supabaseClient.from('users').update({'school_id': response['id']}).eq('id', adminUserId);
      
      // Assuming your School model can be created from a Map
      return School(
        id: response['id'],
        name: response['name'],
        logoUrl: response['logo_url'] ?? '',
        academicYear: response['academic_year'] ?? '',
        theme: response['theme'] ?? '',
        contact: response['contact_info'] ?? '',
      );
    } catch (e) {
      print('Error creating school: ${e.toString()}');
      return null;
    }
  }

  // Fetch school details
  Future<School?> getSchoolById(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('schools')
          .select()
          .eq('id', schoolId)
          .single();
      return School(
        id: response['id'],
        name: response['name'],
        logoUrl: response['logo_url'] ?? '',
        academicYear: response['academic_year'] ?? '',
        theme: response['theme'] ?? '',
        contact: response['contact_info'] ?? '',
      );
    } catch (e) {
      print('Error fetching school: ${e.toString()}');
      return null;
    }
  }

  // Update school profile
  Future<bool> updateSchool(School school) async {
    try {
      await _supabaseClient.from('schools').update({
        'name': school.name,
        'logo_url': school.logoUrl,
        'academic_year': school.academicYear,
        'theme': school.theme,
        'contact_info': school.contact,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', school.id);
      return true;
    } catch (e) {
      print('Error updating school: ${e.toString()}');
      return false;
    }
  }

  // Upload school logo
  Future<String?> uploadSchoolLogo(int schoolId, String filePath, String fileName) async {
    try {
      final file = File(filePath); // Requires dart:io
      final storageResponse = await _supabaseClient.storage
          .from('edusync') // Bucket name
          .upload('schools/$schoolId/$fileName', file, fileOptions: const FileOptions(cacheControl: '3600', upsert: false));
      
      if (storageResponse.isNotEmpty) {
        final publicUrl = _supabaseClient.storage.from('edusync').getPublicUrl('schools/$schoolId/$fileName');
        return publicUrl;
      }
    } catch (e) {
      print('Error uploading school logo: ${e.toString()}');
    }
    return null;
  }
}

// You'll need to import dart:io for File operations if you use filePath directly
// For Flutter, consider using a package like file_picker to get the file path/bytes.
