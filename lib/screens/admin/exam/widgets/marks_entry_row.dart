import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../providers/exam_provider.dart';
import '../../../../theme/app_theme.dart';

class MarksEntryRow extends StatelessWidget {
  final int index;
  final Map<String, dynamic> student;
  final TextEditingController controller;
  final Function(String) onChanged;

  const MarksEntryRow({
    super.key,
    required this.index,
    required this.student,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final maxMarks = student['maxMarks'] as int;
    final passingMarks = student['passingMarks'] as int;
    final marksObtained = controller.text.isEmpty ? null : int.tryParse(controller.text);
    
    String grade = 'N/A';
    bool? isPassed;
    
    if (marksObtained != null) {
      grade = examProvider.calculateGrade(marksObtained, maxMarks);
      isPassed = examProvider.isPassed(marksObtained, passingMarks);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: defaultAccentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: defaultAccentColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Text(
                student['studentName'],
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: '/$maxMarks',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    final marks = int.tryParse(value);
                    if (marks != null && marks > maxMarks) {
                      controller.text = maxMarks.toString();
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }
                  }
                  onChanged(value);
                },
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getGradeColor(grade).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _getGradeColor(grade)),
              ),
              child: Center(
                child: Text(
                  grade,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getGradeColor(grade),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isPassed == null
                  ? Icons.remove
                  : isPassed
                      ? Icons.check_circle
                      : Icons.cancel,
              color: isPassed == null
                  ? Colors.grey
                  : isPassed
                      ? Colors.green
                      : Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A':
      case 'A+':
        return Colors.green;
      case 'B':
      case 'B+':
        return Colors.blue;
      case 'C':
      case 'C+':
        return Colors.orange;
      case 'D':
        return Colors.deepOrange;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
