import 'package:flutter/material.dart';

import '../../../../providers/exam_provider.dart';
import '../../../../theme/app_theme.dart';

class PerformanceOverviewWidget extends StatelessWidget {
  final ExamProvider examProvider;

  const PerformanceOverviewWidget({
    super.key,
    required this.examProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance Overview',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              // Mobile layout - vertical stack
              return Column(
                children: [
                  _buildPerformanceChart(),
                  const SizedBox(height: 16),
                  _buildGradeDistribution(),
                ],
              );
            } else {
              // Desktop layout - horizontal
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPerformanceChart(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildGradeDistribution(),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildPerformanceChart() {
    // Calculate performance metrics
    final totalExams = examProvider.exams.length;
    final upcomingExams = examProvider.exams.where((exam) => exam.examDate.isAfter(DateTime.now())).length;
    final completedExams = examProvider.exams.where((exam) => exam.examDate.isBefore(DateTime.now())).length;

    final completionRate = totalExams > 0 ? (completedExams / totalExams) * 100 : 0.0;
    final upcomingRate = totalExams > 0 ? (upcomingExams / totalExams) * 100 : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textLightGrey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exam Completion Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressIndicator(
                  'Completed',
                  completionRate,
                  accentEarnings,
                  '${completionRate.toStringAsFixed(0)}%',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressIndicator(
                  'Upcoming',
                  upcomingRate,
                  accentTeachers,
                  '${upcomingRate.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatusSummary(totalExams, completedExams, upcomingExams),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double percentage, Color color, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: textLightGrey,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildStatusSummary(int total, int completed, int upcoming) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            'Total',
            total.toString(),
            accentStudents,
          ),
        ),
        Container(
          height: 40,
          width: 1,
          color: textLightGrey.withOpacity(0.3),
        ),
        Expanded(
          child: _buildSummaryItem(
            'Completed',
            completed.toString(),
            accentEarnings,
          ),
        ),
        Container(
          height: 40,
          width: 1,
          color: textLightGrey.withOpacity(0.3),
        ),
        Expanded(
          child: _buildSummaryItem(
            'Upcoming',
            upcoming.toString(),
            accentTeachers,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: textLightGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeDistribution() {
    final grades = examProvider.grades;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textLightGrey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Grade Levels',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          grades.isEmpty
              ? const Text(
                  'No grade levels configured',
                  style: TextStyle(
                    color: textLightGrey,
                    fontSize: 12,
                  ),
                )
              : Column(
                  children: grades.map((grade) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              grade.gradeName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: textDarkGrey,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentParents.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 10,
                                color: accentParents,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }
}