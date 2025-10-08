import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/school_class.dart';

class ClassService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<SchoolClass>> getClassesBySchoolId(int schoolId) async {
    final response = await _supabaseClient
        .from('classes')
        .select()
        .eq('school_id', schoolId)
        .order('name', ascending: true);
    return (response as List).map((e) => SchoolClass.fromMap(e)).toList();
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
    final response = await _supabaseClient
        .from('classes')
        .select()
        .eq('id', id)
        .single();
    if (response.isEmpty) {
      return null;
    }
    return SchoolClass.fromMap(response);
  }

  Future<List<SchoolClass>> getClasses(int schoolId) async {
    return getClassesBySchoolId(schoolId);
  }
}
