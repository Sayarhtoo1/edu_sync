import 'package:edu_sync/screens/admin/admin_panel_components/admin_panel_models.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/summary_card.dart';
import 'package:flutter/material.dart';

class SummaryGrid extends StatelessWidget {
  final List<SummaryItemData> summaryData;

  const SummaryGrid({
    super.key,
    required this.summaryData,
  });

  @override
  Widget build(BuildContext context) {
    if (summaryData.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      // Determine number of columns based on available width
      int crossAxisCount;
      if (constraints.maxWidth >= 800) { // Large screen, 4 items
        crossAxisCount = 4;
      } else if (constraints.maxWidth >= 500) { // Medium screen, 2 items
        crossAxisCount = 2;
      } else { // Small screen, 2 items (or 1 if very small, but 2 is common)
        crossAxisCount = 2;
      }

      // Calculate item width based on crossAxisCount and spacing
      double availableWidth = constraints.maxWidth;
      double totalSpacing = 16.0 * (crossAxisCount - 1);
      // Ensure totalSpacing is not greater than availableWidth before division
      double itemWidth = (totalSpacing < availableWidth)
          ? ((availableWidth - totalSpacing) / crossAxisCount).floorToDouble() // Floor to avoid sub-pixel issues contributing to wrap
          : (availableWidth / crossAxisCount).floorToDouble(); // Fallback if spacing is too much for items (e.g. very narrow screen)

      itemWidth = itemWidth > 0 ? itemWidth : 50.0; // Min width safeguard, reduced from 100

      return Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: summaryData.map((item) {
          return SizedBox(
            width: itemWidth,
            child: SummaryCard(
              title: item.title,
              count: item.count,
              icon: item.icon,
              backgroundColor: item.backgroundColor,
              iconBackgroundColor: item.iconBackgroundColor,
              iconColor: item.iconColor,
              onTap: item.onTap,
            ),
          );
        }).toList(),
      );
    });
  }
}