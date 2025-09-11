import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/utils/logger.dart';
import '../models/announcement.dart';
import 'api_service.dart';
import 'cache_service.dart';

class AnnouncementService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cacheService = CacheService();
  final ApiService _apiService = ApiService();

  Future<List<Announcement>> getAnnouncements(int schoolId) async {
    return await _apiService.fetchData<List<Announcement>>(
      onlineRequest: () async {
        final response = await _supabaseClient
            .from('announcements')
            .select()
            .eq('school_id', schoolId)
            .order('created_at', ascending: false);
        return response.map((data) => Announcement.fromMap(data)).toList();
      },
      offlineRequest: () => _cacheService.getAnnouncements(schoolId),
      cacheData: (data) => _cacheService.saveAnnouncements(schoolId, data),
    );
  }

  // For Admins: Create a new announcement
  Future<Announcement?> createAnnouncement(Announcement announcement) async {
    try {
      final response = await _supabaseClient
          .from('announcements')
          .insert(announcement.toMap()..remove('id'))
          .select()
          .single();
      return Announcement.fromMap(response);
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
