import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/marks_approval.dart';
import '../utils/logger.dart';

class MarksApprovalService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<void> submitForApproval({
    required String examId,
    required String subjectId,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      await _supabaseClient.from('marks_approvals').insert({
        'exam_id': examId,
        'subject_id': subjectId,
        'submitted_by': userId,
        'status': 'pending',
      });
    } catch (e) {
      logger.e('Error submitting for approval: $e');
      rethrow;
    }
  }

  Future<List<MarksApproval>> getPendingApprovals(int schoolId) async {
    try {
      final response = await _supabaseClient
          .from('marks_approvals')
          .select('*, exams!inner(school_id)')
          .eq('status', 'pending')
          .eq('exams.school_id', schoolId);

      return (response as List).map((a) => MarksApproval.fromMap(a)).toList();
    } catch (e) {
      logger.e('Error fetching pending approvals: $e');
      return [];
    }
  }

  Future<void> approveMarks({
    required String approvalId,
    String? comments,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      await _supabaseClient.from('marks_approvals').update({
        'status': 'approved',
        'approved_by': userId,
        'comments': comments,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', approvalId);
    } catch (e) {
      logger.e('Error approving marks: $e');
      rethrow;
    }
  }

  Future<void> rejectMarks({
    required String approvalId,
    required String comments,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      await _supabaseClient.from('marks_approvals').update({
        'status': 'rejected',
        'approved_by': userId,
        'comments': comments,
        'reviewed_at': DateTime.now().toIso8601String(),
      }).eq('id', approvalId);
    } catch (e) {
      logger.e('Error rejecting marks: $e');
      rethrow;
    }
  }
}
