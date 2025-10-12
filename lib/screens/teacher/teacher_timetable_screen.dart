import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Corrected import
import '../../models/timetable.dart' as timetable_model; // Aliasing to avoid conflict if any
import '../../models/school_class.dart' as app_class; // Import SchoolClass
import '../../services/timetable_service.dart';
import '../../services/class_service.dart'; // Import ClassService
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
  late final ClassService _classService; // Initialize ClassService
  late final AuthService _authService;
  late final String _currentUserId;
  int? _currentSchoolId; // School ID is int as per School model

  bool _isLoading = true;
  String? _errorMessage;
  List<timetable_model.Timetable> _timetableEntries = [];
  Map<int, app_class.SchoolClass> _classMap = {}; // Map to store classes for quick lookup
  DateTime _selectedDate = DateTime.now(); // Default to present day

  @override
  void initState() {
    super.initState();
    _timetableService = Provider.of<TimetableService>(context, listen: false);
    _classService = Provider.of<ClassService>(context, listen: false); // Initialize ClassService
    _authService = Provider.of<AuthService>(context, listen: false);
    _currentUserId = _authService.getCurrentUser()?.id ?? '';

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
        _errorMessage = AppLocalizations.of(context)!.error_user_not_found; // Assert non-null
      });
      return;
    }

    if (_currentSchoolId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.error_school_not_selected_or_found; // Assert non-null
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
      // Fetch all classes to build the class map
      if (_currentSchoolId != null) {
        final allClasses = await _classService.getClasses(_currentSchoolId!);
        _classMap = {for (var cls in allClasses) cls.id!: cls};
      }

      // Fetch all timetable entries for the teacher
      final allEntries = await _timetableService.getTimetableForTeacher(_currentUserId);

      // Filter entries for the selected day
      final selectedDayName = DateFormat('EEEE').format(_selectedDate); // e.g., "Monday"
      final entriesForSelectedDay = allEntries
          .where((entry) => entry.dayOfWeek == selectedDayName)
          .toList();

      // Sort entries by start time
      entriesForSelectedDay.sort((a, b) => a.startTimeString.compareTo(b.startTimeString));

      setState(() {
        _timetableEntries = entriesForSelectedDay;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${AppLocalizations.of(context)!.error_fetching_timetable}: ${e.toString()}'; // Assert non-null
      });
    }
  }

  void _changeSelectedDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
    });
    _fetchTimetable();
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(l10n.my_timetable_title),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month, color: contextualAccentColor),
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                builder: (context, child) {
                  return Theme(
                    data: theme.copyWith(
                      colorScheme: theme.colorScheme.copyWith(
                        primary: contextualAccentColor,
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(foregroundColor: contextualAccentColor),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null && picked != _selectedDate) {
                _changeSelectedDate(picked);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateNavigator(contextualAccentColor, theme),
          Expanded(child: _buildBody(l10n, contextualAccentColor)),
        ],
      ),
    );
  }

  Widget _buildDateNavigator(Color accentColor, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, color: accentColor),
            onPressed: () => _changeSelectedDate(_selectedDate.subtract(const Duration(days: 1))),
          ),
          Column(
            children: [
              Text(
                DateFormat('EEEE').format(_selectedDate),
                style: theme.textTheme.titleMedium?.copyWith(color: accentColor, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM d, yyyy').format(_selectedDate),
                style: theme.textTheme.bodySmall?.copyWith(color: textDarkGrey.withOpacity(0.6)),
              ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.chevron_right, color: accentColor),
            onPressed: () => _changeSelectedDate(_selectedDate.add(const Duration(days: 1))),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, Color accentColor) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor)));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_timetableEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: accentColor.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text(l10n.no_timetable_entries_found, style: TextStyle(fontSize: 16, color: textDarkGrey.withOpacity(0.6))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: _timetableEntries.length,
      itemBuilder: (context, index) {
        final entry = _timetableEntries[index];
        return _buildEnhancedTimetableCard(entry, accentColor, theme, index);
      },
    );
  }

  Widget _buildEnhancedTimetableCard(timetable_model.Timetable entry, Color accentColor, ThemeData theme, int index) {
    final className = _classMap[entry.classId]?.name ?? 'Unknown Class';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(20),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${entry.startTimeString} - ${entry.endTimeString}',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: accentColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.subjectName,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.class_, size: 16, color: textDarkGrey.withOpacity(0.6)),
                      const SizedBox(width: 4),
                      Text(
                        className,
                        style: theme.textTheme.bodySmall?.copyWith(color: textDarkGrey.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.book, color: accentColor, size: 24),
            ),
          ],
        ),
      ),
    );
  }


}
