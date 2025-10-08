import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartsSection extends StatelessWidget {
  final Map<String, int> studentCountsByClass;

  const ChartsSection({
    super.key,
    required this.studentCountsByClass,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const SizedBox.shrink(); // Or a placeholder widget
    }
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.studentsDistributionByClassTitle,
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2C2C2C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: studentCountsByClass.isEmpty
                        ? Center(
                            child: Text(
                              l10n.noDataAvailable,
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF8C8C8C),
                              ),
                            ),
                          )
                        : SfCircularChart(
                            series: <CircularSeries>[
                              PieSeries<MapEntry<String, int>, String>(
                                dataSource: studentCountsByClass.entries.toList(),
                                xValueMapper: (MapEntry<String, int> data, _) => data.key,
                                yValueMapper: (MapEntry<String, int> data, _) => data.value,
                                dataLabelSettings: const DataLabelSettings(isVisible: true),
                                enableTooltip: true,
                              )
                            ],
                            title: ChartTitle(text: l10n.studentsDistributionByClassTitle),
                            legend: const Legend(isVisible: true),
                          ),
                  ),
                  if (studentCountsByClass.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _buildChartLegend(context, textTheme, l10n),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "All Exam Results",
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2C2C2C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      "Line Chart Placeholder",
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8C8C8C),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChartLegend(BuildContext context, TextTheme textTheme, AppLocalizations l10n) {
    final List<Color> sectionColors = _getSectionColors();
    int colorIndex = 0;

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: studentCountsByClass.entries.map((entry) {
        final color = sectionColors[colorIndex % sectionColors.length];
        colorIndex++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, color: color),
            const SizedBox(width: 4),
            Text(
              "${entry.key} (${entry.value})",
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFF2C2C2C),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

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
}
