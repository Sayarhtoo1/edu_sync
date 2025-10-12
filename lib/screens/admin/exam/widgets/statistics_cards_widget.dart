import 'package:flutter/material.dart';
import '../../../../providers/exam_provider.dart';
import '../../../../theme/app_theme.dart';

class StatisticsCardsWidget extends StatelessWidget {
  final ExamProvider examProvider;

  const StatisticsCardsWidget({
    super.key,
    required this.examProvider,
  });

  @override
  Widget build(BuildContext context) {
    final totalExams = examProvider.exams.length;
    final upcomingExams = examProvider.exams.where((exam) => exam.examDate.isAfter(DateTime.now())).length;
    final completedExams = examProvider.exams.where((exam) => exam.examDate.isBefore(DateTime.now())).length;
    final subjectsCount = examProvider.subjects.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exam Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            // Responsive layout: 2 columns on mobile, 4 on larger screens
            final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;
            return GridView.count(
              crossAxisCount: crossAxisCount,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: constraints.maxWidth < 600 ? 1.2 : 1.1,
              children: [
                _buildStatCard(
                  'Total Exams',
                  totalExams.toString(),
                  Icons.assignment,
                  accentStudents,
                  'All created exams',
                ),
                _buildStatCard(
                  'Upcoming',
                  upcomingExams.toString(),
                  Icons.schedule,
                  accentTeachers,
                  'Scheduled for future',
                ),
                _buildStatCard(
                  'Completed',
                  completedExams.toString(),
                  Icons.check_circle,
                  accentEarnings,
                  'Already conducted',
                ),
                _buildStatCard(
                  'Subjects',
                  subjectsCount.toString(),
                  Icons.subject,
                  accentParents,
                  'Available subjects',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String description) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C2C2C),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C2C2C),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}