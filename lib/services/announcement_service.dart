import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/utils/logger.dart';
import '../models/announcement.dart';
import 'api_service.dart';
import 'cache_service.dart';

class AnnouncementService {
  final SupabaseClient _supabaseClient;
  final CacheService _cacheService;
  final ApiService _apiService = ApiService();
  
  AnnouncementService(this._supabaseClient, this._cacheService);

  Future<List<Announcement>> getAnnouncements(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('announcements')
          .select()
          .eq('school_id', schoolId)
          .order('created_at', ascending: false);
      final announcements = response.map((data) => Announcement.fromMap(data)).toList();
      
      await _cacheService.cacheAnnouncements(announcements);
      return announcements;
    } catch (e) {
      logger.w('Supabase failed, using cache: $e');
      return await _cacheService.getCachedAnnouncements(schoolId);
    }
  }

  // For Admins: Create a new announcement
  Future<Announcement?> createAnnouncement(Announcement announcement) async {
    try {
      final response = await _supabaseClient
          .from('announcements')
          .insert(announcement.toMap()..remove('id'))
          .select()
          .single();
      
      final createdAnnouncement = Announcement.fromMap(response);
      logger.i('Announcement created successfully: ${createdAnnouncement.id}');
      
      // Realtime subscription will handle notifications automatically
      // No need to manually trigger notifications here
      
      return createdAnnouncement;
    } catch (e) {
      logger.e('Error creating announcement: $e');
      return null;
    }
  }

  // For Admins: Update an announcement
  Future<bool> updateAnnouncement(Announcement announcement) async {
    try {
      await _supabaseClient
          .from('announcements')
          .update(announcement.toMap()..remove('id'))
          .eq('id', announcement.id);
      return true;
    } catch (e) {
      logger.e('Error updating announcement: $e');
      return false;
    }
  }

  // For Admins: Delete an announcement
  Future<bool> deleteAnnouncement(int announcementId) async {
    try {
      await _supabaseClient
          .from('announcements')
          .delete()
          .eq('id', announcementId);
      return true;
    } catch (e) {
      logger.e('Error deleting announcement: $e');
      return false;
    }
  }
}
