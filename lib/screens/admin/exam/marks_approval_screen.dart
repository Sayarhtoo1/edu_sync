import 'package:flutter/material.dart';
import '../../../services/marks_approval_service.dart';
import '../../../models/marks_approval.dart';

class MarksApprovalScreen extends StatefulWidget {
  final int schoolId;

  const MarksApprovalScreen({super.key, required this.schoolId});

  @override
  State<MarksApprovalScreen> createState() => _MarksApprovalScreenState();
}

class _MarksApprovalScreenState extends State<MarksApprovalScreen> {
  final _approvalService = MarksApprovalService();
  List<MarksApproval> _approvals = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadApprovals();
  }

  Future<void> _loadApprovals() async {
    setState(() => _isLoading = true);
    try {
      final approvals = await _approvalService.getPendingApprovals(widget.schoolId);
      setState(() => _approvals = approvals);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading approvals: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(String id) async {
    try {
      await _approvalService.approveMarks(approvalId: id);
      await _loadApprovals();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marks approved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _reject(String id) async {
    final controller = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Marks'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Comments (required)'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result == true && controller.text.isNotEmpty) {
      try {
        await _approvalService.rejectMarks(approvalId: id, comments: controller.text);
        await _loadApprovals();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marks rejected')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Marks Approvals')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _approvals.isEmpty
              ? const Center(child: Text('No pending approvals'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _approvals.length,
                  itemBuilder: (context, index) {
                    final approval = _approvals[index];
                    return Card(
                      child: ListTile(
                        title: Text('Exam: ${approval.examId}'),
                        subtitle: Text('Subject: ${approval.subjectId}\nSubmitted: ${approval.submittedAt}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _approve(approval.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _reject(approval.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
