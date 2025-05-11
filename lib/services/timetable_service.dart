import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/timetable.dart'; // Assuming Timetable model is defined

class TimetableService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  // Fetch timetable for a specific class
  Future<List<Timetable>> getTimetableForClass(int classId) async { // Corrected to int
    try {
      final response = await _supabaseClient
          .from('timetables')
          .select()
          .eq('class_id', classId)
          .order('day_of_week', ascending: true) // You might need a way to order days correctly
          .order('start_time', ascending: true);
      return response.map((data) => Timetable.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching timetable for class $classId: $e');
      return [];
    }
  }

  // Fetch timetable for a specific teacher
  Future<List<Timetable>> getTimetableForTeacher(String teacherId) async {
    try {
      final response = await _supabaseClient
          .from('timetables')
          .select('*, classes!inner(school_id)') // Assuming you need school context
          .eq('teacher_id', teacherId)
          .order('day_of_week', ascending: true)
          .order('start_time', ascending: true);
      return response.map((data) => Timetable.fromMap(data)).toList();
    } catch (e) {
      print('Error fetching timetable for teacher $teacherId: $e');
      return [];
    }
  }
  
  // Add a new timetable entry
  Future<Timetable?> createTimetableEntry(Timetable entry) async {
    try {
      final response = await _supabaseClient
          .from('timetables')
          .insert(entry.toMap()..remove('id')) // Remove id for insert
          .select()
          .single();
      return Timetable.fromMap(response);
    } catch (e) {
      print('Error creating timetable entry: $e');
      return null;
    }
  }

  // Update timetable entry
  Future<bool> updateTimetableEntry(Timetable entry) async {
    try {
      await _supabaseClient
          .from('timetables')
          .update(entry.toMap()..remove('id'))
          .eq('id', entry.id);
      return true;
    } catch (e) {
      print('Error updating timetable entry: $e');
      return false;
    }
  }

  // Delete a timetable entry
  Future<bool> deleteTimetableEntry(int entryId) async {
    try {
      await _supabaseClient
          .from('timetables')
          .delete()
          .eq('id', entryId);
      return true;
    } catch (e) {
      print('Error deleting timetable entry: $e');
      return false;
    }
  }
}
