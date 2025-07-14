import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement.dart';
import 'cache_service.dart';

class AnnouncementService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cacheService = CacheService();

  Future<List<Announcement>> getAnnouncements(int schoolId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      // Offline: Fetch from cache
      return await _cacheService.getAnnouncements(schoolId);
    } else {
      // Online: Fetch from Supabase and update cache
      try {
        final response = await _supabaseClient
            .from('announcements')
            .select()
            .eq('school_id', schoolId)
            .order('created_at', ascending: false);

        final announcements = response.map((data) => Announcement.fromMap(data)).toList();
        await _cacheService.saveAnnouncements(schoolId, announcements);
        return announcements;
      } catch (e) {
        print('Error fetching announcements: $e');
        // If fetching from Supabase fails, try to get from cache
        return await _cacheService.getAnnouncements(schoolId);
      }
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
      return Announcement.fromMap(response);
    } catch (e) {
      print('Error creating announcement: $e');
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
      print('Error updating announcement: $e');
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
      print('Error deleting announcement: $e');
      return false;
    }
  }
}
