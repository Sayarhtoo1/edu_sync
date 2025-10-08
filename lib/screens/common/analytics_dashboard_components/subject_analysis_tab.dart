import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../providers/analytics_provider.dart';

class SubjectAnalysisTab extends StatelessWidget {
  const SubjectAnalysisTab({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);

    if (analyticsProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final subjectPerformance = analyticsProvider.subjectPerformance;

    if (subjectPerformance.isEmpty) {
      return Center(child: Text(localizations!.noDataAvailable));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations!.averageMarksPerSubject,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Average Marks per Subject Bar Chart
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <CartesianSeries>[
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: subjectPerformance.cast<Map<String, dynamic>>(),
                  xValueMapper: (Map<String, dynamic> data, _) => data['subject_name'] as String,
                  yValueMapper: (Map<String, dynamic> data, _) => data['average_marks'],
                  name: localizations.averageMarks,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                )
              ],
              title: ChartTitle(text: localizations.averageMarksPerSubject),
              legend: const Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            localizations.passFailRatePerSubject,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Pass/Fail Rate Pie Chart for each subject or a selected one
          SizedBox(
            height: 300,
            child: SfCircularChart(
              series: <CircularSeries>[
                PieSeries<Map<String, dynamic>, String>(
                  dataSource: subjectPerformance.cast<Map<String, dynamic>>(),
                  xValueMapper: (Map<String, dynamic> data, _) => data['subject_name'] as String,
                  yValueMapper: (Map<String, dynamic> data, _) => data['pass_rate'],
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                  name: localizations.passRate,
                )
              ],
              title: ChartTitle(text: localizations.passFailRatePerSubject),
              legend: const Legend(isVisible: true),
              tooltipBehavior: TooltipBehavior(enable: true),
            ),
          ),
        ],
      ),
    );
  }
}