import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/timetable.dart' as timetable_model; // Aliasing to avoid conflict if any
import '../../services/timetable_service.dart';
import '../../providers/school_provider.dart';
import '../../services/auth_service.dart'; 
import '../../theme/app_theme.dart'; // Import AppTheme

class TeacherTimetableScreen extends StatefulWidget {
  const TeacherTimetableScreen({super.key});

  @override
  State<TeacherTimetableScreen> createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  late final TimetableService _timetableService;
  late final String _currentUserId;
  int? _currentSchoolId; // School ID is int as per School model

  bool _isLoading = true;
  String? _errorMessage;
  List<timetable_model.Timetable> _timetableEntries = [];

  @override
  void initState() {
    super.initState();
    _timetableService = TimetableService(); // Corrected instantiation
    final authService = AuthService(); // Corrected instantiation
    _currentUserId = authService.getCurrentUser()?.id ?? ''; // Corrected method call

    // It's better to fetch schoolId once SchoolProvider is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSchoolIdAndFetchTimetable();
    });
  }

  Future<void> _loadSchoolIdAndFetchTimetable() async {
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    // Ensure school data is loaded if not already
    if (schoolProvider.currentSchool == null) {
      // Assuming SchoolProvider has a method to load school data if not present
      // This might involve fetching based on user's association or a default
      // For now, let's assume it might be null and handle it.
      // Or, we can try to load it.
      // await schoolProvider.fetchSchoolForUser(_currentUserId); // Example
    }
    _currentSchoolId = schoolProvider.currentSchool?.id;

    if (_currentUserId.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context).error_user_not_found;
      });
      return;
    }

    if (_currentSchoolId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context).error_school_not_selected_or_found;
      });
      return;
    }
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Assuming TimetableService has a method like getTimetableForTeacher
      // We need to ensure TimetableService can filter by teacher ID.
      // For now, let's assume it fetches all for the school and we filter client-side,
      // or ideally, the service method handles it.
      // Let's assume getTimetableForSchool is available and we need to adapt it or add a new method.
    // For this example, let's say we need a method `getTimetableForTeacher(schoolId, teacherId)`
      // Ensure _currentSchoolId is not null before calling. The check is done in _loadSchoolIdAndFetchTimetable
      // Corrected service call: getTimetableForTeacher only needs userId.
      // _currentSchoolId check in _loadSchoolIdAndFetchTimetable ensures school context is loaded.
      final entries = await _timetableService.getTimetableForTeacher(_currentUserId);
      setState(() {
        _timetableEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${AppLocalizations.of(context).error_fetching_timetable}: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // final theme = Theme.of(context); // Not explicitly used here, but good practice if needed
    // final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    return Scaffold( // Scaffold theme applied globally
      appBar: AppBar( // AppBar theme applied globally
        title: Text(l10n.my_timetable_title),
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final theme = Theme.of(context); // Get theme for styling
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)),
        ),
      );
    }

    if (_timetableEntries.isEmpty) {
      return Center(
        child: Text(l10n.no_timetable_entries_found, style: theme.textTheme.bodyLarge),
      );
    }

    // Group entries by day of the week for better display
    Map<String, List<timetable_model.Timetable>> groupedEntries = {};
    for (var entry in _timetableEntries) {
      // Assuming dayOfWeek is a non-nullable string in Timetable model
      groupedEntries.putIfAbsent(entry.dayOfWeek, () => []).add(entry);
    }
    // Sort entries within each day by start time
    groupedEntries.forEach((day, entries) {
      // Assuming startTimeString is a non-nullable string in Timetable model
      entries.sort((a, b) => a.startTimeString.compareTo(b.startTimeString));
    });

    // Define order of days
    final dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    List<String> sortedDays = groupedEntries.keys.toList()
      ..sort((a, b) => dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b)));


    return ListView.builder(
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        String day = sortedDays[index];
        List<timetable_model.Timetable> dayEntries = groupedEntries[day]!;
        
        String localizedDay;
        switch (day.toLowerCase()) {
          case 'monday':
            localizedDay = l10n.monday;
            break;
          case 'tuesday':
            localizedDay = l10n.tuesday;
            break;
          case 'wednesday':
            localizedDay = l10n.wednesday;
            break;
          case 'thursday':
            localizedDay = l10n.thursday;
            break;
          case 'friday':
            localizedDay = l10n.friday;
            break;
          case 'saturday':
            localizedDay = l10n.saturday;
            break;
          case 'sunday':
            localizedDay = l10n.sunday;
            break;
          default:
            localizedDay = day; 
        }
        
        return Card( // CardTheme applied globally
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjusted margin
          child: ExpansionTile(
            iconColor: contextualAccentColor,
            collapsedIconColor: textLightGrey,
            title: Text(localizedDay, style: theme.textTheme.titleLarge?.copyWith(color: contextualAccentColor)),
            children: dayEntries.map((entry) {
              return ListTile(
                leading: Icon(Icons.schedule, color: contextualAccentColor.withOpacity(0.7)),
                title: Text(entry.subjectName, style: theme.textTheme.titleMedium), 
                subtitle: Text(
                  '${l10n.time}: ${entry.startTimeString} - ${entry.endTimeString}',
                  style: theme.textTheme.bodySmall,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
