import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/services/school_service.dart';
import 'package:edu_sync/screens/admin/school_settings_screen.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  late final SchoolService _schoolService;
  final _dayAdjustmentController = TextEditingController();
  School? _currentSchool;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('AdminSettingsScreen: didChangeDependencies called');
    _schoolService = Provider.of<SchoolService>(context, listen: false);
  }

  @override
  void initState() {
    super.initState();
    debugPrint('AdminSettingsScreen: initState called'); // Added debug print
    _loadSchoolSettings();
  }

  Future<void> _loadSchoolSettings() async {
    debugPrint('AdminSettingsScreen: _loadSchoolSettings started'); // Added debug print
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      _currentSchool = schoolProvider.currentSchool;
      if (_currentSchool != null) {
        _dayAdjustmentController.text = (_currentSchool!.hijriDayAdjustment ?? 0).toString();
      } else {
        _errorMessage = AppLocalizations.of(context)?.error_school_not_found ?? 'Error: School not found';
      }
    } catch (e) {
    _errorMessage = "${AppLocalizations.of(context)?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}";
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
    debugPrint('AdminSettingsScreen: _loadSchoolSettings finished'); // Added debug print
  }

  Future<void> _saveSettings() async {
    if (!mounted || _currentSchool == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final int? adjustment = int.tryParse(_dayAdjustmentController.text);
      if (adjustment == null) {
      _errorMessage = AppLocalizations.of(context)?.error_invalid_number ?? 'Error: Invalid number';
        return;
      }

      final updatedSchool = _currentSchool!.copyWith(hijriDayAdjustment: adjustment);
      await _schoolService.updateSchool(updatedSchool); // Need to implement updateSchool in SchoolService

      // Update the provider with the new school data
      Provider.of<SchoolProvider>(context, listen: false).refreshSchoolData(updatedSchool.id);


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.settingsSavedSuccessfully ?? 'Settings saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        _errorMessage = "${AppLocalizations.of(context)?.errorSavingSettings ?? 'Error saving settings'}: ${e.toString()}";
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _dayAdjustmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(l10n.adminSettingsTitle ?? 'Admin Settings', style: const TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Color(0xFFE57373)),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF757575))),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildSectionHeader('Calendar Settings'),
                    const SizedBox(height: 8),
                    _buildSettingsCard([
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF9C27B0).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.calendar_today, color: Color(0xFF9C27B0), size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    l10n.hijriCalendarSettingsTitle ?? 'Hijri Calendar Settings',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _dayAdjustmentController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n.dayAdjustmentLabel,
                                hintText: l10n.dayAdjustmentHint,
                                filled: true,
                                fillColor: const Color(0xFFF5F7FA),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide.none,
                                ),
                                prefixIcon: const Icon(Icons.edit_calendar, color: Color(0xFF9C27B0)),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _saveSettings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9C27B0),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                                child: Text(l10n.saveSettingsButton ?? 'Save Settings', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildSectionHeader('School Management'),
                    const SizedBox(height: 8),
                    _buildSettingsCard([
                      _buildSettingsTile(
                        icon: Icons.location_on,
                        iconColor: const Color(0xFF2196F3),
                        title: l10n.schoolLocationSettingsTitle,
                        subtitle: 'Configure school location',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SchoolSettingsScreen()),
                          );
                        },
                      ),
                      const Divider(height: 1, indent: 56),
                      _buildSettingsTile(
                        icon: Icons.how_to_reg,
                        iconColor: const Color(0xFF4CAF50),
                        title: l10n.markAttendanceTitle,
                        subtitle: 'Attendance settings',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const SchoolSettingsScreen()),
                          );
                        },
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
}
