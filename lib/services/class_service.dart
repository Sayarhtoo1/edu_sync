import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/school_class.dart';
import 'cache_service.dart';
import '../utils/logger.dart';

class ClassService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cache;

  ClassService(this._cache);

  Future<List<SchoolClass>> getClassesBySchoolId(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('classes')
          .select()
          .eq('school_id', schoolId)
          .order('name', ascending: true);
      final classes = (response as List).map((e) => SchoolClass.fromMap(e)).toList();
      await _cache.cacheClasses(classes);
      return classes;
    } catch (e) {
      logger.w('Error fetching classes, using cache: $e');
      return await _cache.getCachedClasses(schoolId);
    }
  }

  Future<void> createClass(String name, int schoolId, String? teacherId) async {
    await _supabaseClient.from('classes').insert({
      'name': name,
      'school_id': schoolId,
      'teacher_id': teacherId,
    });
  }

  Future<void> updateClass(int id, String name, String? teacherId) async {
    await _supabaseClient.from('classes').update({
      'name': name,
      'teacher_id': teacherId,
    }).eq('id', id);
  }

  Future<void> deleteClass(int id) async {
    await _supabaseClient.from('classes').delete().eq('id', id);
  }

  Future<SchoolClass?> getClassById(int id) async {
    try {
      final response = await _supabaseClient
          .from('classes')
          .select()
          .eq('id', id)
          .single();
      if (response.isEmpty) {
        return null;
      }
      return SchoolClass.fromMap(response);
    } catch (e) {
      logger.w('Error fetching class by id, using cache: $e');
      return await _cache.getCachedClassById(id);
    }
  }

  Future<List<SchoolClass>> getClasses(int schoolId) async {
    return getClassesBySchoolId(schoolId);
  }
}
