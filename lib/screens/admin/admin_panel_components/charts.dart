import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edu_sync/l10n/app_localizations.dart';

class ChartsRow extends StatelessWidget {
  final Map<String, int> studentCountsByClass;

  const ChartsRow({super.key, required this.studentCountsByClass});

  List<Color> _getSectionColors() {
    return [
      Colors.purple.shade300,
      Colors.blue.shade300,
      Colors.orange.shade300,
      Colors.green.shade300,
      Colors.red.shade300,
      Colors.teal.shade300,
      Colors.pink.shade300,
      Colors.amber.shade300,
    ];
  }

  List<PieChartSectionData> _generatePieChartSections(BuildContext context, Map<String, int> data) {
    final List<Color> sectionColors = _getSectionColors();
    int colorIndex = 0;

    if (data.isEmpty) return [];

    return data.entries.map((entry) {
      final sectionColor = sectionColors[colorIndex % sectionColors.length];
      colorIndex++;

      return PieChartSectionData(
        color: sectionColor,
        value: entry.value.toDouble(),
        title: entry.value.toInt().toString(),
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
        ),
      );
    }).toList();
  }

  Widget _buildChartLegend(BuildContext context, TextTheme textTheme, Map<String, int> data) {
    final List<Color> sectionColors = _getSectionColors();
    int colorIndex = 0;

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: data.entries.map((entry) {
        final color = sectionColors[colorIndex % sectionColors.length];
        colorIndex++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, color: color),
            const SizedBox(width: 4),
            Text("${entry.key} (${entry.value})", style: textTheme.bodySmall?.copyWith(color: Colors.black87)),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 650;
      return Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: isMobile ? 0 : 1,
            child: Container(
              height: isMobile ? 300 : 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.studentsDistributionByClassTitle, style: textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: studentCountsByClass.isEmpty
                        ? Center(child: Text(l10n.noDataAvailable, style: textTheme.bodySmall?.copyWith(color: Colors.grey)))
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: _generatePieChartSections(context, studentCountsByClass),
                              pieTouchData: PieTouchData(
                                touchCallback: (event, response) {},
                              ),
                            ),
                          ),
                  ),
                  if (studentCountsByClass.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildChartLegend(context, textTheme, studentCountsByClass),
                  ]
                ],
              ),
            ),
          ),
          SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
          Flexible(
            flex: isMobile ? 0 : 2,
            child: Container(
              height: isMobile ? 250 : 300,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("All Exam Results", style: textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Center(child: Text("Line Chart Placeholder", style: textTheme.bodySmall?.copyWith(color: Colors.grey))),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
