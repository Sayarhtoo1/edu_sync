import 'package:flutter/material.dart';
import '../../../../theme/app_theme.dart';

class MarksSummaryWidget extends StatelessWidget {
  final Map<String, dynamic> progress;

  const MarksSummaryWidget({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final totalStudents = progress['totalStudents'] as int;
    final marksEntered = progress['marksEntered'] as int;
    final average = progress['average'] as double;
    final passPercentage = progress['passPercentage'] as double;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            defaultAccentColor.withOpacity(0.8),
            defaultAccentColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStat(
                'Entered',
                '$marksEntered/$totalStudents',
                Icons.edit_note,
              ),
              _buildStat(
                'Average',
                average.toStringAsFixed(1),
                Icons.analytics,
              ),
              _buildStat(
                'Pass Rate',
                '${passPercentage.toStringAsFixed(1)}%',
                Icons.check_circle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: totalStudents > 0 ? marksEntered / totalStudents : 0,
              minHeight: 8,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
