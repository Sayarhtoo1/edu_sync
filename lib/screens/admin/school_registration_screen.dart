import 'package:flutter/material.dart';
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class SchoolRegistrationScreen extends StatefulWidget {
  const SchoolRegistrationScreen({super.key});

  @override
  State<SchoolRegistrationScreen> createState() => _SchoolRegistrationScreenState();
}

class _SchoolRegistrationScreenState extends State<SchoolRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // final theme = Theme.of(context); // Unused
    final Color contextualAccentColor = defaultAccentColor;

    return Scaffold(
      appBar: AppBar( 
        title: Text(l10n.schoolRegistrationTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: l10n.schoolNameLabel),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.schoolNameValidator;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.logoUrlLabel),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.academicYearLabel, hintText: l10n.academicYearHint),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.themeLabel, hintText: l10n.themeHint),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.contactInfoLabel),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: contextualAccentColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // TODO: Implement school registration logic
                  }
                },
                child: Text(l10n.registerSchoolButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
