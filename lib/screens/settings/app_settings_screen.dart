import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/providers/locale_provider.dart'; 
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart';
import 'package:edu_sync/services/update_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final UpdateService _updateService = UpdateService();
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  void _showLanguagePicker(BuildContext context, LocaleProvider localeProvider) {
    final theme = Theme.of(context); // Get theme for dialog elements
    final Color contextualAccentColor = defaultAccentColor; // General accent

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog( // DialogTheme applied globally
          title: Text(AppLocalizations.of(context)?.language ?? 'Select Language', style: theme.dialogTheme.titleTextStyle),
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
    if (l10n == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(l10n.settings ?? 'Settings', style: const TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          _buildSectionHeader('General'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.language,
              iconColor: const Color(0xFF2196F3),
              title: l10n.language ?? 'Language',
              subtitle: localeProvider.locale.languageCode == 'en' ? 'English' : 'မြန်မာ',
              onTap: () => _showLanguagePicker(context, localeProvider),
            ),
            const Divider(height: 1, indent: 56),
            _buildSwitchTile(
              icon: Icons.notifications_active,
              iconColor: const Color(0xFFFF9800),
              title: l10n.enableNotifications ?? 'Enable Notifications',
              value: true,
              onChanged: (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notification settings: $value')),
                );
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('App Information'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingsTile(
              icon: Icons.info_outline,
              iconColor: const Color(0xFF9C27B0),
              title: l10n.aboutAppTitle ?? 'About App',
              subtitle: '${l10n.versionLabel ?? 'Version'} $_appVersion',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: l10n.appTitle ?? 'EduSync',
                  applicationVersion: '${l10n.versionLabel ?? 'Version'} $_appVersion',
                  applicationLegalese: '© 2024 EduSync Team',
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(l10n.appTagline ?? 'Your School, Simplified')
                    )
                  ],
                );
              },
            ),
            const Divider(height: 1, indent: 56),
            _buildSettingsTile(
              icon: Icons.system_update,
              iconColor: const Color(0xFF4CAF50),
              title: 'Check for Updates',
              onTap: () => _updateService.checkForUpdate(context),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF757575),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF757575))) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF9E9E9E)),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      secondary: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      value: value,
      onChanged: onChanged,
      activeColor: iconColor,
    );
  }
}
