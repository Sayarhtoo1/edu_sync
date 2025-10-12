import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ExamTrendsChart extends StatelessWidget {
  final List<Map<String, dynamic>> trends;

  const ExamTrendsChart({super.key, required this.trends});

  @override
  Widget build(BuildContext context) {
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
            const Text('Performance Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
