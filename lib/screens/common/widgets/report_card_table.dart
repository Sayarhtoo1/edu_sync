import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';

class ReportCardTable extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;

  const ReportCardTable({
    super.key,
    required this.subjects,
  });

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Subject-wise Performance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(2),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade100),
                  children: const [
                    _TableHeader('Subject'),
                    _TableHeader('Marks'),
                    _TableHeader('Grade'),
                    _TableHeader('Remarks'),
                  ],
                ),
                ...subjects.map((subject) {
                  final percentage = subject['percentage'] as double;
                  final grade = examProvider.calculateOverallGrade(percentage);
                  final remarks = examProvider.getRemarks(grade);
                  final passed = subject['passed'] as bool;

                  return TableRow(
                    children: [
                      _TableCell(subject['subjectName']),
                      _TableCell(
                        '${subject['marksObtained']}/${subject['totalMarks']}',
                      ),
                      _TableCell(
                        grade,
                        color: passed ? Colors.green : Colors.red,
                      ),
                      _TableCell(remarks),
                    ],
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final Color? color;

  const _TableCell(this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          color: color,
          fontWeight: color != null ? FontWeight.bold : null,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
