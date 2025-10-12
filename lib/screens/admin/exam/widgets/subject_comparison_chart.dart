import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class SubjectComparisonChart extends StatelessWidget {
  final List<Map<String, dynamic>> subjects;

  const SubjectComparisonChart({super.key, required this.subjects});

  @override
  Widget build(BuildContext context) {
    final data = subjects.map((s) => _ChartData(
      s['subject_name'],
      s['average_percentage'].toDouble(),
    )).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Subject-wise Performance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                primaryYAxis: const NumericAxis(minimum: 0, maximum: 100),
                series: <CartesianSeries>[
                  ColumnSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (data, _) => data.subjectName,
                    yValueMapper: (data, _) => data.average,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                    color: Colors.blue,
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
  final String subjectName;
  final double average;
  _ChartData(this.subjectName, this.average);
}
