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
    debugPrint('AdminSettingsScreen: didChangeDependencies called'); // Added debug print
    _schoolService = SchoolService();
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
    debugPrint('AdminSettingsScreen: build called'); // Added debug print
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const SizedBox.shrink(); // Or a placeholder widget
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.adminSettingsTitle ?? 'Admin Settings'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.hijriCalendarSettingsTitle ?? 'Hijri Calendar Settings',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _dayAdjustmentController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: l10n.dayAdjustmentLabel ?? 'Day Adjustment',
                          hintText: l10n.dayAdjustmentHint ?? 'Enter day adjustment (e.g., -1, 0, 1)',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: _saveSettings,
                          child: Text(l10n.saveSettingsButton ?? 'Save Settings'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        title: Text(l10n.schoolLocationSettingsTitle ?? 'School Location Settings'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SchoolSettingsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      ListTile(
                        title: Text(l10n.markAttendanceTitle ?? 'Mark Attendance'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SchoolSettingsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
    );
  }
}
