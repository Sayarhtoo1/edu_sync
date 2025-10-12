import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../theme/app_theme.dart';

class ReportCardSummary extends StatelessWidget {
  final int totalMarksObtained;
  final int totalMaxMarks;
  final double overallPercentage;
  final String result;
  final int rank;
  final double classAverage;

  const ReportCardSummary({
    super.key,
    required this.totalMarksObtained,
    required this.totalMaxMarks,
    required this.overallPercentage,
    required this.result,
    required this.rank,
    required this.classAverage,
  });

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final overallGrade = examProvider.calculateOverallGrade(overallPercentage);
    final isPassed = result == 'PASSED';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Overall Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat(
                  'Total Marks',
                  '$totalMarksObtained/$totalMaxMarks',
                  Icons.assignment,
                ),
                _buildStat(
                  'Percentage',
                  '${overallPercentage.toStringAsFixed(1)}%',
                  Icons.percent,
                ),
                _buildStat(
                  'Grade',
                  overallGrade,
                  Icons.grade,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPassed ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPassed ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isPassed ? Icons.check_circle : Icons.cancel,
                    color: isPassed ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Result: $result',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip('Class Rank: $rank', Icons.emoji_events),
                _buildInfoChip(
                  'Class Avg: ${classAverage.toStringAsFixed(1)}%',
                  Icons.people,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: defaultAccentColor, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: defaultAccentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: defaultAccentColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: defaultAccentColor,
            ),
          ),
        ],
      ),
    );
  }
}
