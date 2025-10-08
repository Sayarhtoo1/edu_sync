import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../providers/school_provider.dart'; // Import SchoolProvider
// Import Grade model

class ReportCardScreen extends StatefulWidget {
  final String studentId;
  final String examId;

  const ReportCardScreen({super.key, required this.studentId, required this.examId});

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> {
  late Future<void> _fetchReportCardFuture;

  @override
  void initState() {
    super.initState();
    _fetchReportCardFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id;

    if (schoolId != null) {
      await examProvider.getDetailedStudentReportCard(
        studentId: widget.studentId,
        examId: widget.examId,
        schoolId: schoolId,
      );
      await examProvider.fetchGrades(schoolId.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);
    // No need to listen to ExamProvider at the top level, as it's consumed by a Consumer below
    // final examProvider = Provider.of<ExamProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.reportCardTitle ?? 'Report Card'),
      ),
      body: FutureBuilder(
        future: _fetchReportCardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Consumer<ExamProvider>(
              builder: (context, examProvider, child) {
                if (examProvider.detailedReportCard.isEmpty) {
                  return Center(child: Text(localizations?.noReportCardData ?? 'No report card data available.'));
                }

                final studentName = examProvider.detailedReportCard.first['student_name'];
                final examName = examProvider.detailedReportCard.first['exam_name'];
                final grades = examProvider.grades;

                List<Map<String, dynamic>> subjectResults = [];

                for (var report in examProvider.detailedReportCard) {
                  final marksObtained = report['marks_obtained'] as int;
                  final maxMarks = report['max_marks'] as int;
                  final passingMarks = report['passing_marks'] as int;

                  final subjectGradeAndStatus = examProvider.examService.getSubjectGradeAndStatus(
                    marksObtained: marksObtained,
                    maxMarks: maxMarks,
                    passingMarks: passingMarks,
                    grades: grades,
                  );

                  subjectResults.add({
                    ...report,
                    'percentage': subjectGradeAndStatus['percentage'],
                    'grade': subjectGradeAndStatus['grade'],
                    'passed': subjectGradeAndStatus['passed'],
                  });
                }

                final overallResult = examProvider.examService.getOverallExamResult(
                  subjectResults: subjectResults.map((e) => {
                    'marksObtained': e['marks_obtained'],
                    'maxMarks': e['max_marks'],
                    'passed': e['passed'],
                  }).toList(),
                  grades: grades,
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${localizations?.studentNameLabel ?? 'Student Name'}: $studentName',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '${localizations?.examNameLabel ?? 'Exam Name'}: $examName',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Text(
                        localizations?.subjectWisePerformance ?? 'Subject-wise Performance',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      DataTable(
                        columns: [
                          DataColumn(label: Text(localizations?.subjectLabel ?? 'Subject')),
                          DataColumn(label: Text(localizations?.maxMarksLabel ?? 'Max Marks')),
                          DataColumn(label: Text(localizations?.passingMarksLabel ?? 'Passing Marks')),
                          DataColumn(label: Text(localizations?.marksObtainedLabel ?? 'Marks Obtained')),
                          DataColumn(label: Text(localizations?.percentageLabel ?? 'Percentage')),
                          DataColumn(label: Text(localizations?.gradeLabel ?? 'Grade')),
                          DataColumn(label: Text(localizations?.statusLabel ?? 'Status')),
                        ],
                        rows: subjectResults.map<DataRow>((report) {
                          final subjectName = report['subject_name'];
                          final maxMarks = report['max_marks'] as int;
                          final passingMarks = report['passing_marks'] as int;
                          final marksObtained = report['marks_obtained'] as int;
                          final double percentage = report['percentage'] as double;
                          final String grade = report['grade'] as String;
                          final bool passed = report['passed'] as bool;
                          final String status = passed ? (localizations?.passStatus ?? 'Pass') : (localizations?.failStatus ?? 'Fail');

                          return DataRow(cells: [
                            DataCell(Text(subjectName)),
                            DataCell(Text(maxMarks.toString())),
                            DataCell(Text(passingMarks.toString())),
                            DataCell(Text(marksObtained.toString())),
                            DataCell(Text('${percentage.toStringAsFixed(2)}%')),
                            DataCell(Text(grade)),
                            DataCell(Text(status)),
                          ]);
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      Text(
                        localizations?.overallSummary ?? 'Overall Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${localizations?.totalMaxMarksLabel ?? 'Total Max Marks'}: ${overallResult['totalMaxMarks']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${localizations?.totalMarksObtainedLabel ?? 'Total Marks Obtained'}: ${overallResult['totalMarksObtained']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${localizations?.percentageLabel ?? 'Percentage'}: ${(overallResult['overallPercentage'] as double).toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${localizations?.overallGradeLabel ?? 'Overall Grade'}: ${overallResult['overallGrade']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      Text(
                        '${localizations?.overallStatusLabel ?? 'Overall Status'}: ${(overallResult['overallPassed'] as bool) ? (localizations?.passStatus ?? 'Pass') : (localizations?.failStatus ?? 'Fail')}',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
