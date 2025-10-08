import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../providers/analytics_provider.dart';
import '../../../models/user_role.dart';
import '../../../models/school_class.dart';

class OverallPerformanceTab extends StatelessWidget {
  final UserRole? currentUserRole;
  final SchoolClass? selectedClass;

  const OverallPerformanceTab({
    super.key,
    required this.currentUserRole,
    required this.selectedClass,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);

    if (analyticsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = currentUserRole == UserRole.Admin && selectedClass == null
        ? analyticsProvider.schoolPerformanceOverview
        : analyticsProvider.classPerformanceOverview;

    if (data == null || data.isEmpty) {
      return Center(child: Text(localizations!.noDataAvailable));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations!.overallSummary,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${localizations.totalStudents}: ${data['total_students'] ?? 'N/A'}'),
                  Text('${localizations.averageMarks}: ${data['average_marks']?.toStringAsFixed(2) ?? 'N/A'}%'),
                  Text('${localizations.passRate}: ${data['pass_rate']?.toStringAsFixed(2) ?? 'N/A'}%'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.gradeDistribution,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Grade Distribution Bar Chart
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <CartesianSeries>[
                ColumnSeries<MapEntry<String, dynamic>, String>(
                  dataSource: (data['grade_distribution'] as Map<String, dynamic>).entries.toList(),
                  xValueMapper: (MapEntry<String, dynamic> data, _) => data.key,
                  yValueMapper: (MapEntry<String, dynamic> data, _) => data.value as num,
                  name: localizations.grades,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                )
              ],
              title: ChartTitle(text: localizations.gradeDistribution),
              legend: const Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.topPerformingStudents,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Top Performing Students Table
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.topPerformingStudents,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (data['top_students'] != null && (data['top_students'] as List).isNotEmpty)
                    ... (data['top_students'] as List).map((student) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text('${student['name']}: ${student['marks']?.toStringAsFixed(2) ?? 'N/A'}%'),
                    ))
                  else
                    Text(localizations.noTopStudents),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}