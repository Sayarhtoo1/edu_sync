import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/widgets/app_drawer.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme


class TeacherDashboardScreen extends StatelessWidget { 
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final School? currentSchool = schoolProvider.currentSchool;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers'); // For future dashboard items

    return Scaffold(
      appBar: AppBar( 
        title: Text(currentSchool?.name ?? l10n.teacherDashboardTitle), 
      ),
      drawer: const AppDrawer(), 
      body: Center( 
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            l10n.teacherDashboardWelcomeMessage, 
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(color: textDarkGrey), 
          ),
        ),
      ),
    );
  }
}
