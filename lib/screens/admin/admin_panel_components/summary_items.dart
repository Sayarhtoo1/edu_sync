import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/screens/admin/student_management_screen.dart';
import 'package:edu_sync/screens/admin/user_management_screen.dart';
import 'package:edu_sync/screens/admin/view_form_responses_screen.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/admin_panel_models.dart';

class SummaryItemsGrid extends StatelessWidget {
  final List<SummaryItemData> summaryData;

  const SummaryItemsGrid({super.key, required this.summaryData});

  Widget _buildSummaryItemDisplay(BuildContext context, SummaryItemData item, TextTheme textTheme) {
    return InkWell(
      onTap: () {
        final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
        final currentSchool = schoolProvider.currentSchool;
        if (currentSchool == null) return;

        switch (item.title.toLowerCase()) {
          case 'students':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudentManagementScreen()));
            break;
          case 'teachers':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementScreen(initialTabIndex: 0)));
            break;
          case 'parents':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementScreen(initialTabIndex: 1)));
            break;
          case 'forms today':
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewFormResponsesScreen(schoolId: currentSchool.id)));
            break;
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    item.title,
                    style: textTheme.bodySmall?.copyWith(color: Colors.black87.withAlpha((0.7 * 255).round())),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.count,
                    style: textTheme.titleLarge?.copyWith(color: Colors.black87, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: item.iconBackgroundColor,
              child: Icon(item.icon, color: item.iconColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (summaryData.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(builder: (context, constraints) {
      int crossAxisCount;
      if (constraints.maxWidth >= 800) {
        crossAxisCount = 4;
      } else if (constraints.maxWidth >= 500) {
        crossAxisCount = 2;
      } else {
        crossAxisCount = 2;
      }

      double availableWidth = constraints.maxWidth;
      double totalSpacing = 16.0 * (crossAxisCount - 1);
      double itemWidth = (totalSpacing < availableWidth)
          ? ((availableWidth - totalSpacing) / crossAxisCount).floorToDouble()
          : (availableWidth / crossAxisCount).floorToDouble();

      itemWidth = itemWidth > 0 ? itemWidth : 50.0;

      return Wrap(
        spacing: 16.0,
        runSpacing: 16.0,
        children: summaryData.map((item) {
          return SizedBox(
            width: itemWidth,
            child: _buildSummaryItemDisplay(context, item, textTheme),
          );
        }).toList(),
      );
    });
  }
}
