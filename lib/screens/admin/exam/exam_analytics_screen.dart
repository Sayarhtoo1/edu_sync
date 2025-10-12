import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../providers/exam_provider.dart';
import '../../../theme/app_theme.dart';
import 'widgets/exam_trends_chart.dart';
import 'widgets/subject_comparison_chart.dart';
import 'widgets/top_performers_widget.dart';

class ExamAnalyticsScreen extends StatefulWidget {
  final String examId;
  final String examName;

  const ExamAnalyticsScreen({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<ExamAnalyticsScreen> createState() => _ExamAnalyticsScreenState();
}

class _ExamAnalyticsScreenState extends State<ExamAnalyticsScreen> {
  Map<String, dynamic>? _distribution;
  List<Map<String, dynamic>> _topPerformers = [];
  final List<Map<String, dynamic>> _trends = [];
  final List<Map<String, dynamic>> _subjectAnalysis = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final distribution = await examProvider.getClassPerformanceDistribution(examId: widget.examId);
      final topPerformers = await examProvider.getTopPerformersDetailed(examId: widget.examId, limit: 5);

      setState(() {
        _distribution = distribution;
        _topPerformers = topPerformers;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analytics: ${widget.examName}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_distribution != null) _buildDistributionChart(),
                  const SizedBox(height: 24),
                  if (_topPerformers.isNotEmpty) TopPerformersWidget(performers: _topPerformers),
                ],
              ),
            ),
    );
  }

  Widget _buildDistributionChart() {
    final data = _distribution!.entries.map((e) => _ChartData(e.key, e.value)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grade Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SfCircularChart(
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              series: <CircularSeries>[
                PieSeries<_ChartData, String>(
                  dataSource: data,
                  xValueMapper: (data, _) => data.grade,
                  yValueMapper: (data, _) => data.count,
                  dataLabelSettings: const DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

class _ChartData {
  final String grade;
  final int count;
  _ChartData(this.grade, this.count);
}
