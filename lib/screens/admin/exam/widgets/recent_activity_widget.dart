import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../../providers/exam_provider.dart';
import '../../../../theme/app_theme.dart';
import '../../../common/empty_state.dart';

class RecentActivityWidget extends StatelessWidget {
  final ExamProvider examProvider;

  const RecentActivityWidget({
    super.key,
    required this.examProvider,
  });

  @override
  Widget build(BuildContext context) {
    final recentExams = _getRecentExams();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/exam-management'),
              style: TextButton.styleFrom(
                foregroundColor: defaultAccentColor,
              ),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        recentExams.isEmpty
            ? SizedBox(
                height: 200,
                child: EmptyState(
                  icon: Icons.assignment_outlined,
                  message: 'No recent exams',
                  description: 'Create your first exam to see activity here',
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentExams.length > 5 ? 5 : recentExams.length,
                itemBuilder: (context, index) {
                  final exam = recentExams[index];
                  return _buildExamCard(context, exam);
                },
              ),
      ],
    );
  }

  List<dynamic> _getRecentExams() {
    // Get exams sorted by date (newest first)
    final sortedExams = [...examProvider.exams];
    sortedExams.sort((a, b) => b.examDate.compareTo(a.examDate));
    return sortedExams;
  }

  Widget _buildExamCard(BuildContext context, dynamic exam) {
    final isUpcoming = exam.examDate.isAfter(DateTime.now());
    final daysUntil = exam.examDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => context.push('/exam-management/edit/${exam.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUpcoming
                      ? accentTeachers.withOpacity(0.2)
                      : accentStudents.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isUpcoming ? Icons.schedule : Icons.check_circle,
                  color: isUpcoming ? accentTeachers : accentStudents,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exam.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Examiner: ${exam.examinerName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: textLightGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: textLightGrey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, yyyy').format(exam.examDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: textDarkGrey,
                          ),
                        ),
                        if (isUpcoming) ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentTeachers.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              daysUntil == 0
                                  ? 'Today'
                                  : daysUntil == 1
                                      ? 'Tomorrow'
                                      : 'In $daysUntil days',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentTeachers,
                              ),
                            ),
                          ),
                        ] else ...[
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentStudents.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: accentStudents,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      context.push('/exam-management/edit/${exam.id}');
                      break;
                    case 'marks':
                      context.push('/input-marks/${exam.id}');
                      break;
                    case 'delete':
                      _showDeleteDialog(context, exam);
                      break;
                  }
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Edit'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'marks',
                    child: ListTile(
                      leading: Icon(Icons.grade),
                      title: Text('Input Marks'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete', style: TextStyle(color: Colors.red)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, dynamic exam) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Exam'),
          content: Text('Are you sure you want to delete "${exam.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement delete functionality
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}