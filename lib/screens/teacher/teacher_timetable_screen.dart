import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import '../../l10n/app_localizations.dart';
import '../../models/timetable.dart' as timetable_model; // Aliasing to avoid conflict if any
import '../../models/school_class.dart' as app_class; // Import SchoolClass
import '../../services/timetable_service.dart';
import '../../services/class_service.dart'; // Import ClassService
import '../../providers/school_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart'; // Import AppTheme
import '../../models/timetable_status.dart';
import 'teacher_timetable_components/timetable_helpers.dart';
import 'teacher_timetable_components/timetable_entry_card.dart';

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
        _errorMessage = '${AppLocalizations.of(context).error_fetching_timetable}: ${e.toString()}';
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.my_timetable_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
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
                        onSurface: Colors.black, // Adjust as needed
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: contextualAccentColor,
                        ),
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => _changeSelectedDate(_selectedDate.subtract(const Duration(days: 1))),
                ),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                  style: theme.textTheme.titleMedium?.copyWith(color: contextualAccentColor),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios),
                  onPressed: () => _changeSelectedDate(_selectedDate.add(const Duration(days: 1))),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final theme = Theme.of(context);
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

    return ListView.builder(
      itemCount: _timetableEntries.length,
      itemBuilder: (context, index) {
        final entry = _timetableEntries[index];
        return TimetableEntryCard(
          entry: entry,
          classMap: _classMap,
          l10n: l10n,
          selectedDate: _selectedDate,
        );
      },
    );
  }


  Color _getColorForStatus(TimetableStatus status) {
    switch (status) {
      case TimetableStatus.upcoming:
        return Colors.blue;
      case TimetableStatus.inProcess:
        return Colors.green;
      case TimetableStatus.done:
        return Colors.grey;
      }
    
    }
}
