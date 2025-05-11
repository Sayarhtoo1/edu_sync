import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement.dart';
// For user role and class info

class AnnouncementService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Fetch announcements relevant to the current user (school_id, role, class_id if applicable)
  // RLS policies on the 'announcements' table will handle filtering.
  Future<List<Announcement>> getAnnouncements(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('announcements')
          .select()
          .eq('school_id', schoolId) // Basic filter, RLS will do the rest
          .order('created_at', ascending: false);
      
      return response.map((data) => Announcement.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching announcements: $e');
      return [];
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
