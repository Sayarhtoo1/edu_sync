import 'package:flutter/material.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/admin_panel_models.dart';
import 'package:edu_sync/l10n/app_localizations.dart';

class BottomSectionsRow extends StatelessWidget {
  final List<StarStudentItem> starStudents;
  final List<ActivityLogItem> activityLogs;

  const BottomSectionsRow({
    super.key,
    required this.starStudents,
    required this.activityLogs,
  });

  Widget _buildStarStudentListItem(BuildContext context, StarStudentItem student, TextTheme textTheme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundImage: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
            ? NetworkImage(student.avatarUrl!)
            : null,
        child: (student.avatarUrl == null || student.avatarUrl!.isEmpty)
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(student.name, style: textTheme.bodyMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w500)),
      subtitle: Text(student.id, style: textTheme.bodySmall?.copyWith(color: Colors.grey)),
      trailing: Text(student.marks.toString(), style: textTheme.bodyMedium?.copyWith(color: Colors.purple, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildActivityLogListItem(BuildContext context, ActivityLogItem item, TextTheme textTheme) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.green.withAlpha((0.2 * 255).round()),
        child: Icon(item.icon, size: 18, color: Colors.green),
      ),
      title: Text(item.message, style: textTheme.bodyMedium?.copyWith(color: Colors.black87), maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(item.timestamp, style: textTheme.bodySmall?.copyWith(color: Colors.grey)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 700;
      return Flex(
        direction: isMobile ? Axis.vertical : Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: isMobile ? 0 : 3,
            child: Container(
              constraints: BoxConstraints(minHeight: isMobile ? 300 : 350),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Star Students", style: textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  starStudents.isEmpty
                      ? Center(child: Text("No star students to display.", style: textTheme.bodySmall?.copyWith(color: Colors.grey)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: starStudents.length,
                          itemBuilder: (ctx, i) => _buildStarStudentListItem(context, starStudents[i], textTheme),
                        ),
                ],
              ),
            ),
          ),
          SizedBox(width: isMobile ? 0 : 16, height: isMobile ? 16 : 0),
          Flexible(
            flex: isMobile ? 0 : 2,
            child: Container(
              constraints: BoxConstraints(minHeight: isMobile ? 250 : 350),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 10, offset: const Offset(0, 2))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Recent Activity", style: textTheme.titleMedium?.copyWith(color: Colors.black87, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  activityLogs.isEmpty
                      ? Center(child: Text(l10n.noRecentActivity, style: textTheme.bodySmall?.copyWith(color: Colors.grey)))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: activityLogs.length,
                          itemBuilder: (ctx, i) => _buildActivityLogListItem(context, activityLogs[i], textTheme),
                        ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
