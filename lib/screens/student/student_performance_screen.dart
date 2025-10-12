import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../providers/exam_provider.dart';

class StudentPerformanceScreen extends StatefulWidget {
  final int studentId;
  final int classId;

  const StudentPerformanceScreen({
    super.key,
    required this.studentId,
    required this.classId,
  });

  @override
  State<StudentPerformanceScreen> createState() => _StudentPerformanceScreenState();
}

class _StudentPerformanceScreenState extends State<StudentPerformanceScreen> {
  Map<String, dynamic>? _trendData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPerformance();
  }

  Future<void> _loadPerformance() async {
    setState(() => _isLoading = true);
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final trendData = await examProvider.getStudentPerformanceTrend(
        studentId: widget.studentId,
        classId: widget.classId,
      );
      setState(() => _trendData = trendData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading performance: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Performance')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _trendData == null
              ? const Center(child: Text('No data available'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildTrendChart(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildTrendChart() {
    final trends = List<Map<String, dynamic>>.from(_trendData!['trends'] ?? []);
    if (trends.isEmpty) return const Text('No performance data');

    final data = trends.map((t) => _ChartData(
      t['exam_name'],
      t['percentage'].toDouble(),
    )).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Performance Timeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                primaryYAxis: const NumericAxis(minimum: 0, maximum: 100),
                series: <CartesianSeries>[
                  LineSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (data, _) => data.examName,
                    yValueMapper: (data, _) => data.percentage,
                    markerSettings: const MarkerSettings(isVisible: true),
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String examName;
  final double percentage;
  _ChartData(this.examName, this.percentage);
}
