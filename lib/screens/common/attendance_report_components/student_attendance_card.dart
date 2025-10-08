import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/attendance_report.dart';
import '../../../theme/app_theme.dart';
import '../../../models/student.dart'; // Assuming you have a Student model

class StudentAttendanceCard extends StatelessWidget {
  final Student student; // Changed to take a Student object
  final List<AttendanceReport> attendanceRecords;
  final DateTimeRange dateRange;

  const StudentAttendanceCard({
    super.key,
    required this.student,
    required this.attendanceRecords,
    required this.dateRange,
  });

  @override
  Widget build(BuildContext context) {
    final summary = _calculateSummary();
    final days = dateRange.end.difference(dateRange.start).inDays + 1;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.getAccentColorForContext('students').withOpacity(0.2),
                  backgroundImage: student.profilePhotoUrl != null && student.profilePhotoUrl!.isNotEmpty
                      ? CachedNetworkImageProvider(student.profilePhotoUrl!)
                      : null,
                  child: (student.profilePhotoUrl == null || student.profilePhotoUrl!.isEmpty)
                      ? Text(
                          student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : '?',
                          style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.getAccentColorForContext('students')),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Text(student.fullName, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 20,
                child: Row(
                  children: List.generate(days, (index) {
                    final date = dateRange.start.add(Duration(days: index));
                    final record = attendanceRecords.firstWhere(
                      (r) => r.date.year == date.year && r.date.month == date.month && r.date.day == date.day,
                      orElse: () => AttendanceReport(
                        studentName: student.fullName,
                        date: date,
                        status: 'No Record', // Changed from 'Holiday'
                        className: attendanceRecords.isNotEmpty ? attendanceRecords.first.className : 'N/A',
                      ),
                    );
                    return Expanded(
                      child: Container(
                        color: _getColorForStatus(record.status),
                        margin: const EdgeInsets.symmetric(horizontal: 0.5), // Small gap between days
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem(context, 'Present', summary['Present'] ?? 0, iconColorEarnings),
                _buildSummaryItem(context, 'Absent', summary['Absent'] ?? 0, theme.colorScheme.error),
                _buildSummaryItem(context, 'Late', summary['Late'] ?? 0, iconColorParents),
                _buildSummaryItem(context, 'Leave', summary['Leave'] ?? 0, Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _calculateSummary() {
    final summary = <String, int>{};
    for (var record in attendanceRecords) {
      summary[record.status] = (summary[record.status] ?? 0) + 1;
    }
    return summary;
  }

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'Present':
        return iconColorEarnings;
      case 'Absent':
        return Colors.red.shade700;
      case 'Late':
        return iconColorParents;
      case 'Leave':
        return Colors.amber.shade700;
      case 'Holiday':
        return Colors.grey.shade400;
      case 'No Record': // Added new status
        return Colors.blueGrey.shade100; // A very light grey/blue to indicate no record
      default:
        return Colors.grey;
    }
  }

  Widget _buildSummaryItem(BuildContext context, String title, int count, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(title, style: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold)),
        Text(count.toString(), style: theme.textTheme.titleMedium?.copyWith(color: color)),
      ],
    );
  }
}
