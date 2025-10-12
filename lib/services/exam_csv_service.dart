import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/logger.dart';
import 'exam_marks_service.dart';

class ExamCsvService {
  final ExamMarksService _marksService;

  ExamCsvService({required ExamMarksService marksService})
      : _marksService = marksService;

  Future<void> exportMarksTemplate({
    required String examId,
    required String subjectId,
  }) async {
    try {
      final students = await _marksService.getStudentsForMarksEntry(
        examId: examId,
        subjectId: subjectId,
      );

      final rows = [
        ['Student ID', 'Student Name', 'Marks Obtained', 'Total Marks'],
        ...students.map((s) => [
          s['id'].toString(),
          s['full_name'],
          s['marks_obtained']?.toString() ?? '',
          s['total_marks'].toString(),
        ]),
      ];

      await _saveCsv(rows, 'marks_template_${DateTime.now().millisecondsSinceEpoch}.csv');
    } catch (e) {
      logger.e('Error exporting template: $e');
      rethrow;
    }
  }

  Future<void> exportMarksData({
    required String examId,
    required String subjectId,
  }) async {
    try {
      final students = await _marksService.getStudentsForMarksEntry(
        examId: examId,
        subjectId: subjectId,
      );

      final rows = [
        ['Student ID', 'Student Name', 'Marks Obtained', 'Total Marks', 'Grade', 'Status'],
        ...students.map((s) {
          final marks = s['marks_obtained'];
          final total = s['total_marks'];
          final passingMarks = s['passing_marks'] ?? (total * 0.4).round();
          final grade = marks != null ? _calculateSimpleGrade(marks, total) : '';
          final status = marks != null ? (_marksService.isPassed(marks, passingMarks) ? 'PASS' : 'FAIL') : '';
          return [
            s['id'].toString(),
            s['full_name'],
            marks?.toString() ?? '',
            total.toString(),
            grade,
            status,
          ];
        }),
      ];

      await _saveCsv(rows, 'marks_export_${DateTime.now().millisecondsSinceEpoch}.csv');
    } catch (e) {
      logger.e('Error exporting marks: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> importMarksFromCsv(String filePath) async {
    try {
      final file = File(filePath);
      final csvString = await file.readAsString();
      final rows = const CsvToListConverter().convert(csvString);

      if (rows.length < 2) throw Exception('CSV file is empty or invalid');

      final marks = <Map<String, dynamic>>[];
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 3) continue;

        final studentId = int.tryParse(row[0].toString());
        final marksObtained = int.tryParse(row[2].toString());

        if (studentId != null && marksObtained != null) {
          marks.add({
            'student_id': studentId,
            'marks_obtained': marksObtained,
          });
        }
      }

      return marks;
    } catch (e) {
      logger.e('Error importing CSV: $e');
      rethrow;
    }
  }

  String _calculateSimpleGrade(int marks, int total) {
    final percentage = (marks / total) * 100;
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  Future<void> _saveCsv(List<List<dynamic>> rows, String filename) async {
    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(file.path)], text: 'Exam Marks CSV');
  }
}
