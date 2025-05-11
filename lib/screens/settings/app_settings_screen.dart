import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/providers/locale_provider.dart'; 
import 'package:edu_sync/l10n/app_localizations.dart'; 
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  // Example: bool _notificationsEnabled = true;
  // Example: String _selectedLanguage = 'English'; // or from a LocaleProvider

  void _showLanguagePicker(BuildContext context, LocaleProvider localeProvider) {
    final theme = Theme.of(context); // Get theme for dialog elements
    final Color contextualAccentColor = defaultAccentColor; // General accent

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog( // DialogTheme applied globally
          title: Text(AppLocalizations.of(context).language ?? 'Select Language', style: theme.dialogTheme.titleTextStyle),
          content: SizedBox(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: L10n.all.length,
              itemBuilder: (BuildContext context, int index) {
                final locale = L10n.all[index];
                return ListTile(
                  title: Text(locale.languageCode == 'en' ? 'English' : 'မြန်မာ', style: theme.textTheme.bodyLarge),
                  trailing: localeProvider.locale == locale ? Icon(Icons.check, color: contextualAccentColor) : null,
                  onTap: () {
                    localeProvider.setLocale(locale);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = defaultAccentColor;


    return Scaffold(
      appBar: AppBar( 
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.language, color: theme.iconTheme.color),
            title: Text(l10n.language, style: theme.textTheme.titleMedium),
            subtitle: Text(localeProvider.locale.languageCode == 'en' ? 'English' : 'မြန်မာ', style: theme.textTheme.bodySmall),
            trailing: Icon(Icons.arrow_forward_ios, color: theme.iconTheme.color),
            onTap: () {
              _showLanguagePicker(context, localeProvider);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: Text(l10n.enableNotifications, style: theme.textTheme.titleMedium), 
            value: true, 
            onChanged: (bool value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Notification settings UI not yet fully implemented. Value: $value')),
              );
            },
            activeColor: contextualAccentColor,
            secondary: Icon(Icons.notifications_active, color: theme.iconTheme.color),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.aboutAppTitle, style: theme.textTheme.titleMedium), 
            subtitle: Text('${l10n.versionLabel} 1.0.0 (Placeholder)', style: theme.textTheme.bodySmall), 
            leading: Icon(Icons.info_outline, color: theme.iconTheme.color),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: l10n.appTitle, // Use appTitle instead of appName
                applicationVersion: '${l10n.versionLabel} 1.0.0 (Placeholder)', 
                applicationLegalese: '© 2024 EduSync Team', 
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: Text(l10n.appTagline, style: theme.textTheme.bodyMedium) 
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
