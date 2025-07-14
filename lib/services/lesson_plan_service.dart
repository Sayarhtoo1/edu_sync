import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lesson_plan.dart';
import 'cache_service.dart';

class LessonPlanService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cacheService = CacheService();

  // Fetch lesson plans for a specific class and teacher
  Future<List<LessonPlan>> getLessonPlans({required int classId, String? teacherId, String? subjectName}) async { // Corrected to int
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return await _cacheService.getLessonPlans(classId);
    } else {
      try {
        // Chain order directly. If conditional filters were needed between select and order,
        // query would need to be of a more generic PostgrestBuilder type or dynamic.
        final response = await _supabaseClient
            .from('lesson_plans') // Assuming table name is 'lesson_plans'
            .select()
            .eq('class_id', classId)
            // Example of how conditional filters would be added if teacherId/subjectName were in this table:
            // .if(teacherId != null, (q) => q.eq('teacher_id', teacherId))
            // .if(subjectName != null, (q) => q.eq('subject_name', subjectName))
            .order('date', ascending: false);

        final lessonPlans = response.map((data) => LessonPlan.fromMap(data)).toList();
        await _cacheService.saveLessonPlans(classId, lessonPlans);
        return lessonPlans;
      } catch (e) {
        print('Error fetching lesson plans: $e');
        return await _cacheService.getLessonPlans(classId);
      }
    }
  }

  Future<LessonPlan?> createLessonPlan(LessonPlan lessonPlan) async {
    try {
      final response = await _supabaseClient
          .from('lesson_plans')
          .insert(lessonPlan.toMap()..remove('id')) // Remove id for insert
          .select()
          .single();
      return LessonPlan.fromMap(response);
    } catch (e) {
      print('Error creating lesson plan: $e');
      return null;
    }
  }

  Future<bool> updateLessonPlan(LessonPlan lessonPlan) async {
    try {
      if (lessonPlan.id == null) {
        print('Error: LessonPlan ID is null, cannot update.');
        return false;
      }
      await _supabaseClient
          .from('lesson_plans')
          .update(lessonPlan.toMap()..remove('id'))
          .eq('id', lessonPlan.id!); // Use null-check operator
      return true;
    } catch (e) {
      print('Error updating lesson plan: $e');
      return false;
    }
  }

  Future<bool> deleteLessonPlan(int lessonPlanId) async {
    try {
      await _supabaseClient
          .from('lesson_plans')
          .delete()
          .eq('id', lessonPlanId); // lessonPlanId is int, so it's fine
      return true;
    } catch (e) {
      print('Error deleting lesson plan: $e');
      return false;
    }
  }
}
// Removed LessonPlanExtension as fromMap/toMap are now in the model file.
