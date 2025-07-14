import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/timetable.dart'; // Assuming Timetable model is defined
import 'cache_service.dart';

class TimetableService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cacheService = CacheService();

  // Fetch timetable for a specific class
  Future<List<Timetable>> getTimetableForClass(int classId) async { // Corrected to int
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return await _cacheService.getTimetableForClass(classId);
    } else {
      try {
        final response = await _supabaseClient
            .from('timetables')
            .select()
            .eq('class_id', classId)
            .order('day_of_week', ascending: true) // You might need a way to order days correctly
            .order('start_time', ascending: true);
        final timetable = response.map((data) => Timetable.fromMap(data)).toList();
        await _cacheService.saveTimetableForClass(classId, timetable);
        return timetable;
      } catch (e) {
        print('Error fetching timetable for class $classId: $e');
        return await _cacheService.getTimetableForClass(classId);
      }
    }
  }

  // Fetch timetable for a specific teacher
  Future<List<Timetable>> getTimetableForTeacher(String teacherId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return await _cacheService.getTimetableForTeacher(teacherId);
    } else {
      try {
        final response = await _supabaseClient
            .from('timetables')
            .select('*, classes!inner(school_id)') // Assuming you need school context
            .eq('teacher_id', teacherId)
            .order('day_of_week', ascending: true)
            .order('start_time', ascending: true);
        final timetable = response.map((data) => Timetable.fromMap(data)).toList();
        await _cacheService.saveTimetableForTeacher(teacherId, timetable);
        return timetable;
      } catch (e) {
        print('Error fetching timetable for teacher $teacherId: $e');
        return await _cacheService.getTimetableForTeacher(teacherId);
      }
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
