import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/subject.dart';

class SubjectCrudService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> addSubject({
    required String name,
    required int classId,
    required int schoolId,
  }) async {
    await _supabaseClient.rpc('add_subject', params: {
      'p_name': name,
      'p_class_id': classId,
      'p_school_id': schoolId,
    });
  }

  Future<void> updateSubject({
    required String id,
    required String name,
    required int classId,
    required int schoolId,
  }) async {
    await _supabaseClient.rpc('update_subject', params: {
      'p_subject_id': id,
      'p_name': name,
      'p_class_id': classId,
      'p_school_id': schoolId,
    });
  }

  Future<void> deleteSubject(String id) async {
    await _supabaseClient.rpc('delete_subject', params: {
      'p_subject_id': id,
    });
  }

  Future<List<Subject>> getSubjectsBySchoolId(int schoolId) async {
    final response = await _supabaseClient
        .from('subjects')
        .select('id, name, class_id, school_id, created_at')
        .eq('school_id', schoolId)
        .order('name', ascending: true);
    return (response as List).map((e) => Subject.fromMap(e)).toList();
  }

  Future<List<Subject>> getSubjectsByClassId(int classId) async {
    final response = await _supabaseClient
        .from('subjects')
        .select('id, name, class_id, school_id, created_at')
        .eq('class_id', classId)
        .order('name', ascending: true);
    return (response as List).map((e) => Subject.fromMap(e)).toList();
  }
}
