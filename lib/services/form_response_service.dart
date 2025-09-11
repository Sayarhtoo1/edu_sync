import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/models/form_response.dart';
import 'package:edu_sync/models/form_response_answer.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/utils/logger.dart';
import 'cache_service.dart';

class FormResponseService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final CacheService _cacheService = CacheService();

  Future<bool> submitResponse(FormResponse response, List<FormResponseAnswer> answers) async {
    try {
      final List<Map<String, dynamic>> answersJson = answers.map((a) => a.toRpcJson()).toList();
      
      final newResponseId = await _supabaseClient.rpc(
        'submit_form_with_answers',
        params: {
          'p_form_id': response.formId,
          'p_student_id': response.studentId,
          'p_parent_id': response.parentId,
          'p_submitted_by_id': response.parentId,
          'p_answers': answersJson,
        },
      );

      // If the RPC returns a non-null value, the submission was successful.
      return newResponseId != null;
    } catch (e) {
      logger.e('Error submitting form response via RPC: $e');
      return false;
    }
  }

  Future<List<FormResponse>> getResponsesForForm(String formId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return await _cacheService.getFormResponses(formId);
    } else {
      try {
        final response = await _supabaseClient
            .from('form_responses')
            .select()
            .eq('form_id', formId)
            .order('submitted_at', ascending: false);
        final responses = response.map((data) => FormResponse.fromMap(data)).toList();
        await _cacheService.saveFormResponses(formId, responses);
        return responses;
      } catch (e) {
        logger.e('Error fetching responses for form $formId: $e');
        return await _cacheService.getFormResponses(formId);
      }
    }
  }

  Future<List<FormResponseAnswer>> getAnswersForResponse(String responseId) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return await _cacheService.getFormResponseAnswers(responseId);
    } else {
      try {
        final response = await _supabaseClient
            .from('form_response_answers')
            .select()
            .eq('response_id', responseId);
        final answers = response.map((data) => FormResponseAnswer.fromMap(data)).toList();
        await _cacheService.saveFormResponseAnswers(responseId, answers);
        return answers;
      } catch (e) {
        logger.e('Error fetching answers for response $responseId: $e');
        return await _cacheService.getFormResponseAnswers(responseId);
      }
    }
  }

  Future<bool> checkIfResponseSubmitted(String formId, int studentId, String parentId, DateTime date) async {
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final response = await _supabaseClient
          .from('form_responses')
          .select('id')
          .eq('form_id', formId)
          .eq('student_id', studentId)
          .eq('parent_id', parentId)
          .eq('date(submitted_at)', dateString) // Compare only the date part
          .limit(1);
      
      return response.isNotEmpty;
    } catch (e) {
      logger.e('Error checking if response submitted: $e');
      return false; // Assume not submitted on error
    }
  }

  Future<List<FormResponse>> getRecentResponses(int schoolId, {int limit = 5}) async {
    try {
      // 1. Get all form_ids for the given schoolId
      final formsInSchoolResponse = await _supabaseClient
          .from('custom_forms')
          .select('id')
          .eq('school_id', schoolId);

      if (formsInSchoolResponse.isEmpty) {
        return []; // No forms in this school, so no responses
      }
      final List<String> formIdsInSchool = formsInSchoolResponse.map((form) => form['id'] as String).toList();

      // 2. Get recent responses for those form_ids
      final responseData = await _supabaseClient
          .from('form_responses')
          .select() // Select all columns from form_responses first
          .filter('form_id', 'in', formIdsInSchool) // Using .filter() instead of .in_()
          .order('submitted_at', ascending: false)
          .limit(limit);
      
      // Note: FormResponse.fromMap will need to handle the case where related data 
      // (like custom_forms(title) or students(full_name)) is not directly in the map.
      // For the AdminPanelScreen's recent activity, we fetch student details separately.
      // The FormResponse model itself doesn't store student_name or form_title.
      return responseData.map((data) => FormResponse.fromMap(data)).toList();
    } catch (e) {
      logger.e('Error fetching recent responses: $e');
      return [];
    }
  }
}
