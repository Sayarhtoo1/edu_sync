import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/timetable.dart'; // Assuming Timetable model is defined
import 'package:edu_sync/utils/logger.dart';
import 'api_service.dart';
import 'cache_service.dart';

class TimetableService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cacheService = CacheService();
  final ApiService _apiService = ApiService();

  // Fetch timetable for a specific class
  Future<List<Timetable>> getTimetableForClass(int classId) async { // Corrected to int
    return await _apiService.fetchData<List<Timetable>>(
      onlineRequest: () async {
        final response = await _supabaseClient
            .from('timetables')
            .select()
            .eq('class_id', classId)
            .order('day_of_week', ascending: true)
            .order('start_time', ascending: true);
        return response.map((data) => Timetable.fromMap(data)).toList();
      },
      offlineRequest: () => _cacheService.getTimetableForClass(classId),
      cacheData: (data) => _cacheService.saveTimetableForClass(classId, data),
    );
  }

  // Fetch timetable for a specific teacher
  Future<List<Timetable>> getTimetableForTeacher(String teacherId) async {
    return await _apiService.fetchData<List<Timetable>>(
      onlineRequest: () async {
        final response = await _supabaseClient
            .from('timetables')
            .select('*, classes!inner(name)') // Select class name
            .eq('teacher_id', teacherId)
            .order('day_of_week', ascending: true)
            .order('start_time', ascending: true);
        return response.map((data) {
          final classData = data['classes'] as Map<String, dynamic>;
          return Timetable.fromMap({
            ...data,
            'class_name': classData['name'], // Extract class name from nested data
          });
        }).toList();
      },
      offlineRequest: () => _cacheService.getTimetableForTeacher(teacherId),
      cacheData: (data) => _cacheService.saveTimetableForTeacher(teacherId, data),
    );
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
      logger.e('Error creating timetable entry: $e');
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
      logger.e('Error updating timetable entry: $e');
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
      logger.e('Error deleting timetable entry: $e');
      return false;
    }
  }

  // Fetch all timetable entries for the entire school
  Future<List<Timetable>> getAllTimetables(int schoolId) async {
    return await _apiService.fetchData<List<Timetable>>(
      onlineRequest: () async {
        final response = await _supabaseClient
            .from('timetables')
            .select('*, classes!inner(school_id, name)')
            .eq('classes.school_id', schoolId)
            .order('day_of_week', ascending: true)
            .order('start_time', ascending: true);
        return response.map((data) {
          final classData = data['classes'] as Map<String, dynamic>;
          return Timetable.fromMap({
            ...data,
            'class_name': classData['name'],
          });
        }).toList();
      },
      offlineRequest: () => _cacheService.getAllTimetables(schoolId), // Pass schoolId to cache
      cacheData: (data) => _cacheService.saveAllTimetables(schoolId, data), // Pass schoolId to cache
    );
  }
}
