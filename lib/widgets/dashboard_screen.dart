import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/widgets/app_drawer.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/theme/app_theme.dart';

// Ensure this is imported for textDarkGrey

class DashboardScreen extends StatelessWidget {
  final String title;
  final String welcomeMessage;
  final Widget? headerWidget; // New parameter for widgets at the top
  final Widget? quickActionsSection; // New parameter

  const DashboardScreen({
    super.key,
    required this.title,
    required this.welcomeMessage,
    this.headerWidget, // Initialize new parameter
    this.quickActionsSection, // Initialize new parameter
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Consumer<SchoolProvider>(
          builder: (context, schoolProvider, child) {
            return Text(schoolProvider.currentSchool?.name ?? title);
          },
        ),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView( // Changed to SingleChildScrollView to accommodate more content
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (headerWidget != null) ...[
                headerWidget!,
                const SizedBox(height: 24), // Spacing after the header widget
              ],
              Text(
                welcomeMessage,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(color: textDarkGrey),
              ),
              if (quickActionsSection != null) ...[
                const SizedBox(height: 24),
                quickActionsSection!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
