import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../../../providers/exam_provider.dart';
import '../../../../widgets/common/desktop_scaffold.dart';

class DesktopExamAnalytics extends StatefulWidget {
  final String examId;
  final String examName;

  const DesktopExamAnalytics({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<DesktopExamAnalytics> createState() => _DesktopExamAnalyticsState();
}

class _DesktopExamAnalyticsState extends State<DesktopExamAnalytics> {
  Map<String, dynamic>? _distribution;
  List<Map<String, dynamic>> _topPerformers = [];
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
      final topPerformers = await examProvider.getTopPerformersDetailed(examId: widget.examId, limit: 10);

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
    return DesktopScaffold(
      title: widget.examName,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_distribution != null) _buildStatisticsCards(),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            if (_distribution != null) _buildDistributionChart(),
                            const SizedBox(height: 24),
                            if (_distribution != null) _buildGradeBreakdown(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          children: [
                            if (_topPerformers.isNotEmpty) _buildTopPerformersCard(),
                            const SizedBox(height: 24),
                            if (_distribution != null) _buildInsightsCard(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatisticsCards() {
    final totalStudents = _distribution!.values.fold<int>(0, (sum, count) => sum + (count as int));
    final passRate = _calculatePassRate();
    final avgGrade = _calculateAverageGrade();
    final highestGrade = _distribution!.keys.isNotEmpty ? _distribution!.keys.first : 'N/A';
    
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total Students', totalStudents.toString(), Icons.people, const Color(0xFF3498DB))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Pass Rate', '${passRate.toStringAsFixed(1)}%', Icons.check_circle, const Color(0xFF2ECC71))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Average Grade', avgGrade, Icons.grade, const Color(0xFFF39C12))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Top Grade', highestGrade, Icons.star, const Color(0xFF9B59B6))),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 4),
                  Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionChart() {
    final data = _distribution!.entries.map((e) => _ChartData(e.key, e.value as int)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pie_chart, color: Color(0xFF3498DB)),
                const SizedBox(width: 12),
                const Text('Grade Distribution', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: SfCircularChart(
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.right,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CircularSeries>[
                  DoughnutSeries<_ChartData, String>(
                    dataSource: data,
                    xValueMapper: (data, _) => data.grade,
                    yValueMapper: (data, _) => data.count,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    explode: true,
                    explodeIndex: 0,
                    explodeOffset: '10%',
                    innerRadius: '60%',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeBreakdown() {
    final sortedGrades = _distribution!.entries.toList()
      ..sort((a, b) => (b.value as int).compareTo(a.value as int));
    final total = _distribution!.values.fold<int>(0, (sum, count) => sum + (count as int));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Color(0xFF3498DB)),
                const SizedBox(width: 12),
                const Text('Grade Breakdown', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            ...sortedGrades.map((entry) {
              final count = entry.value as int;
              final percentage = (count / total * 100);
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Grade ${entry.key}', style: const TextStyle(fontWeight: FontWeight.w600)),
                        Text('$count students (${percentage.toStringAsFixed(1)}%)', 
                          style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(_getGradeColor(entry.key)),
                      minHeight: 8,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformersCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emoji_events, color: Color(0xFFF39C12)),
                const SizedBox(width: 12),
                const Text('Top Performers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            ..._topPerformers.asMap().entries.map((entry) {
              final index = entry.key;
              final performer = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: index < 3 ? _getRankColor(index).withOpacity(0.1) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: index < 3 ? _getRankColor(index) : Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: index < 3 ? _getRankColor(index) : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            performer['student_name'] ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Class: ${performer['class_name'] ?? 'N/A'}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${performer['percentage']?.toStringAsFixed(1) ?? '0'}%',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: index < 3 ? _getRankColor(index) : Colors.grey[700],
                          ),
                        ),
                        Text(
                          'Grade ${performer['grade'] ?? 'N/A'}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard() {
    final passRate = _calculatePassRate();
    final totalStudents = _distribution!.values.fold<int>(0, (sum, count) => sum + (count as int));
    final insights = <Map<String, dynamic>>[
      {
        'icon': Icons.trending_up,
        'color': const Color(0xFF2ECC71),
        'title': 'Pass Rate',
        'value': '${passRate.toStringAsFixed(1)}%',
        'subtitle': passRate >= 75 ? 'Excellent performance' : passRate >= 50 ? 'Good performance' : 'Needs improvement',
      },
      {
        'icon': Icons.people_outline,
        'color': const Color(0xFF3498DB),
        'title': 'Participation',
        'value': '$totalStudents students',
        'subtitle': 'Completed the exam',
      },
      {
        'icon': Icons.analytics,
        'color': const Color(0xFF9B59B6),
        'title': 'Grade Spread',
        'value': '${_distribution!.keys.length} grades',
        'subtitle': 'Distribution across grades',
      },
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFFF39C12)),
                const SizedBox(width: 12),
                const Text('Insights', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),
            ...insights.map((insight) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (insight['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(insight['icon'] as IconData, color: insight['color'] as Color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(insight['title'] as String, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(insight['value'] as String, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(insight['subtitle'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A': return const Color(0xFF2ECC71);
      case 'B': return const Color(0xFF3498DB);
      case 'C': return const Color(0xFFF39C12);
      case 'D': return const Color(0xFFE67E22);
      default: return const Color(0xFFE74C3C);
    }
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0: return const Color(0xFFF39C12);
      case 1: return const Color(0xFF95A5A6);
      case 2: return const Color(0xFFCD7F32);
      default: return Colors.grey;
    }
  }

  double _calculatePassRate() {
    if (_distribution == null || _distribution!.isEmpty) return 0.0;
    
    final totalStudents = _distribution!.values.fold<int>(0, (sum, count) => sum + (count as int));
    if (totalStudents == 0) return 0.0;
    
    final passGrades = ['A', 'B', 'C', 'D'];
    final passCount = _distribution!.entries
        .where((e) => passGrades.contains(e.key))
        .fold<int>(0, (sum, e) => sum + (e.value as int));
    
    return (passCount / totalStudents) * 100;
  }

  String _calculateAverageGrade() {
    if (_distribution == null || _distribution!.isEmpty) return 'N/A';
    
    final gradePoints = {'A': 4, 'B': 3, 'C': 2, 'D': 1, 'F': 0};
    int totalPoints = 0;
    int totalStudents = 0;
    
    _distribution!.forEach((grade, count) {
      totalPoints += (gradePoints[grade] ?? 0) * (count as int);
      totalStudents += count as int;
    });
    
    if (totalStudents == 0) return 'N/A';
    
    final avgPoints = totalPoints / totalStudents;
    if (avgPoints >= 3.5) return 'A';
    if (avgPoints >= 2.5) return 'B';
    if (avgPoints >= 1.5) return 'C';
    if (avgPoints >= 0.5) return 'D';
    return 'F';
  }
}

class _ChartData {
  final String grade;
  final int count;
  _ChartData(this.grade, this.count);
}
