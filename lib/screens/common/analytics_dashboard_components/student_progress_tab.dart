import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Import for Syncfusion charts
import '../../../l10n/gen/app_localizations.dart';
import '../../../providers/analytics_provider.dart';
import '../../../providers/school_provider.dart'; // To get students
import '../../../models/student.dart'; // Import Student model

class StudentProgressTab extends StatefulWidget {
  const StudentProgressTab({super.key});

  @override
  State<StudentProgressTab> createState() => _StudentProgressTabState();
}

class _StudentProgressTabState extends State<StudentProgressTab> {
  Student? _selectedStudent;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    // Ensure students are fetched before trying to access them
    if (schoolProvider.currentSchool != null) {
      await schoolProvider.fetchStudents(schoolProvider.currentSchool!.id);
    }
    if (schoolProvider.students.isNotEmpty) {
      setState(() {
        _selectedStudent = schoolProvider.students.first; // Select first student by default
      });
      _fetchStudentProgress();
    }
  }

  Future<void> _fetchStudentProgress() async {
    if (_selectedStudent != null) {
      final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);
      await analyticsProvider.fetchStudentPerformance(_selectedStudent!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);

    if (analyticsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final studentPerformance = analyticsProvider.studentPerformance;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations!.studentProgress,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Student>(
            decoration: InputDecoration(
              labelText: localizations.selectStudent,
              border: const OutlineInputBorder(),
            ),
            value: _selectedStudent,
            items: schoolProvider.students.map((student) => DropdownMenuItem<Student>(
              value: student,
              child: Text(student.fullName), // Use fullName
            )).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStudent = value;
                _fetchStudentProgress();
              });
            },
          ),
          const SizedBox(height: 16),
          if (_selectedStudent == null)
            Center(child: Text(localizations.selectStudentForProgress))
          else if (studentPerformance == null || studentPerformance.isEmpty)
            Center(child: Text(localizations.noDataAvailable))
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${localizations.overallAverage}: ${studentPerformance['overall_average']?.toStringAsFixed(2) ?? 'N/A'}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.marksPerSubject,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 300,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        series: <CartesianSeries>[
                          ColumnSeries<Map<String, dynamic>, String>(
                            dataSource: (studentPerformance['subject_marks'] as List).cast<Map<String, dynamic>>(),
                            xValueMapper: (Map<String, dynamic> data, _) => data['subject_name'] as String,
                            yValueMapper: (Map<String, dynamic> data, _) => data['marks'],
                            name: localizations.marks,
                            dataLabelSettings: const DataLabelSettings(isVisible: true),
                          )
                        ],
                        title: ChartTitle(text: localizations.marksPerSubject),
                        legend: const Legend(isVisible: true),
                        tooltipBehavior: TooltipBehavior(enable: true),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}