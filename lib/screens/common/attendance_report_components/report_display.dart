import 'package:flutter/material.dart';
import '../../../models/attendance_report.dart';
import '../../../models/student.dart';
import 'student_attendance_card.dart';

class ReportDisplay extends StatelessWidget {
  final List<AttendanceReport> reportData;
  final DateTimeRange dateRange;
  final List<Student> students; // Add students list

  const ReportDisplay({
    super.key,
    required this.reportData,
    required this.dateRange,
    required this.students, // Require students list
  });

  @override
  Widget build(BuildContext context) {
    final groupedData = _groupDataByStudent();

    return ListView.builder(
      itemCount: students.length, // Iterate through students
      itemBuilder: (context, index) {
        final student = students[index];
        final records = groupedData[student.fullName] ?? []; // Get records for this student
        return StudentAttendanceCard(
          student: student,
          attendanceRecords: records,
          dateRange: dateRange,
        );
      },
    );
  }

  Map<String, List<AttendanceReport>> _groupDataByStudent() {
    final groupedData = <String, List<AttendanceReport>>{};
    for (var record in reportData) {
      if (groupedData.containsKey(record.studentName)) {
        groupedData[record.studentName]!.add(record);
      } else {
        groupedData[record.studentName] = [record];
      }
    }
    return groupedData;
  }
}
