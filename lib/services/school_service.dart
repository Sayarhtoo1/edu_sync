import 'dart:io'; // Moved import to the top
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/school.dart'; // Assuming School model is defined
import 'package:edu_sync/utils/logger.dart';
import 'cache_service.dart';

class SchoolService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cacheService = CacheService();

  // Create a new school profile using an RPC function for atomicity
  Future<School?> createSchool({
    required String name,
    String? logoUrl,
    String? academicYear,
    String? theme,
    String? contactInfo,
    required String adminUserId,
  }) async {
    try {
      final newSchoolId = await _supabaseClient.rpc(
        'create_school_and_assign_admin',
        params: {
          'school_name': name,
          'admin_user_id': adminUserId,
          'logo_url': logoUrl,
          'academic_year': academicYear,
          'theme': theme,
          'contact_info': contactInfo,
        },
      );

      if (newSchoolId != null) {
        // The RPC returns the new school's ID. We can construct the School object
        // with the data we already have, since the RPC was successful.
        return School(
          id: newSchoolId as int,
          name: name,
          logoUrl: logoUrl ?? '',
          academicYear: academicYear ?? '',
          theme: theme ?? '',
          contact: contactInfo ?? '',
        );
      }
      return null;
    } catch (e) {
      logger.e('Error creating school via RPC: ${e.toString()}');
      return null;
    }
  }

  // Fetch school details
  Future<School?> getSchoolById(int schoolId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return await _cacheService.getSchool(schoolId);
    } else {
      try {
        final response = await _supabaseClient
            .from('schools')
            .select()
            .eq('id', schoolId)
            .single();
        final school = School(
          id: response['id'],
          name: response['name'],
          logoUrl: response['logo_url'] ?? '',
          academicYear: response['academic_year'] ?? '',
          theme: response['theme'] ?? '',
          contact: response['contact_info'] ?? '',
          hijriDayAdjustment: response['hijri_day_adjustment'], // Correctly retrieve from DB
        );
        await _cacheService.saveSchool(school);
        return school;
      } catch (e) {
        logger.e('Error fetching school: ${e.toString()}');
        return await _cacheService.getSchool(schoolId);
      }
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
        'hijri_day_adjustment': school.hijriDayAdjustment, // Added Hijri day adjustment
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', school.id);
      return true;
    } catch (e) {
      logger.e('Error updating school: ${e.toString()}');
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
      logger.e('Error uploading school logo: ${e.toString()}');
    }
    return null;
  }
}

// You'll need to import dart:io for File operations if you use filePath directly
// For Flutter, consider using a package like file_picker to get the file path/bytes.
