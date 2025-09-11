import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import '../../../models/attendance_report.dart';

class ExportButton extends StatelessWidget {
  final List<AttendanceReport> reportData;

  const ExportButton({super.key, required this.reportData});

  Future<void> _exportToCsv(BuildContext context) async {
    List<List<dynamic>> rows = [];
    rows.add(['Student Name', 'Class Name', 'Date', 'Status']);
    for (var report in reportData) {
      rows.add([
        report.studentName,
        report.className,
        report.date.toIso8601String(),
        report.status,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    try {
      final directory = await getExternalStorageDirectory();
      if (directory != null) {
        final path = '${directory.path}/attendance_report.csv';
        final file = File(path);
        await file.writeAsString(csv);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report exported to $path')),
        );
        OpenFile.open(path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _exportToCsv(context),
      child: const Icon(Icons.download),
    );
  }
}
