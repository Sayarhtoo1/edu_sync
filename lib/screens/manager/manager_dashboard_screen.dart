import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/widgets/app_drawer.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final School? currentSchool = schoolProvider.currentSchool;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        title: Text(currentSchool?.name ?? l10n.managerDashboardTitle),
        backgroundColor: iconColorTeachers, // You might want to define a specific color for managers
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.managerDashboardWelcomeMessage,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: textDarkGrey),
              ),
              const SizedBox(height: 20),
              _buildQuickActionsGrid(context),
              const SizedBox(height: 20),
              Text(
                l10n.recentActivity,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textLightGrey),
              ),
              const SizedBox(height: 10),
              _buildRecentActivitiesList(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildActionCard(
          context,
          title: l10n.manageTeachersAction,
          icon: Icons.school,
          onTap: () {
            // Navigate to manage teachers screen
          },
        ),
        _buildActionCard(
          context,
          title: l10n.manageParentsAction,
          icon: Icons.people,
          onTap: () {
            // Navigate to manage parents screen
          },
        ),
        _buildActionCard(
          context,
          title: l10n.manageStudentsTitle,
          icon: Icons.person_outline,
          onTap: () {
            // Navigate to manage students screen
          },
        ),
        _buildActionCard(
          context,
          title: l10n.manageClassesTitle,
          icon: Icons.class_,
          onTap: () {
            // Navigate to manage classes screen
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: iconColorTeachers),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5, // Show last 5 activities
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: iconColorTeachers.withOpacity(0.2),
            child: Icon(Icons.event_note, color: iconColorTeachers),
          ),
          title: Text('Activity ${index + 1}'),
          subtitle: Text('Activity details ${index + 1}'),
        );
      },
    );
  }
}
