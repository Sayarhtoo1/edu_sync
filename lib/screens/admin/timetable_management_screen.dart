import 'package:flutter/material.dart';
import 'package:edu_sync/models/timetable.dart';
import 'package:edu_sync/services/timetable_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/class.dart' as app_class;
import 'package:edu_sync/services/class_service.dart';
import 'add_edit_timetable_entry_screen.dart';
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class TimetableManagementScreen extends StatefulWidget {
  const TimetableManagementScreen({super.key});

  @override
  State<TimetableManagementScreen> createState() => _TimetableManagementScreenState();
}

class _TimetableManagementScreenState extends State<TimetableManagementScreen> {
  final TimetableService _timetableService = TimetableService();
  final AuthService _authService = AuthService();
  final ClassService _classService = ClassService();

  List<Timetable> _timetableEntries = [];
  List<app_class.Class> _availableClasses = [];
  app_class.Class? _selectedClass;
  bool _isLoading = true;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    _currentSchoolId = await _authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      _availableClasses = await _classService.getClassesBySchool(_currentSchoolId!);
      if (_availableClasses.isNotEmpty) {
        _selectedClass = _availableClasses.first; // Default to first class
        await _loadTimetableForSelectedClass();
      } else {
         if (mounted) setState(() => _isLoading = false);
      }
    } else {
      // print("School ID not found. Cannot load timetables."); // Removed print
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTimetableForSelectedClass() async {
    if (_selectedClass == null || _selectedClass!.id == null) return; // Add null check for id
    setState(() => _isLoading = true);
    // _selectedClass.id is int?, getTimetableForClass expects int
    _timetableEntries = await _timetableService.getTimetableForClass(_selectedClass!.id!); 
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddEditEntry({Timetable? entry}) async {
    if (_currentSchoolId == null) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('School context not found.')));
       return;
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTimetableEntryScreen(
          timetableEntry: entry,
          schoolId: _currentSchoolId!,
          classIdForNewEntry: _selectedClass?.id,
        ),
      ),
    );
    if (result == true) {
      _loadTimetableForSelectedClass();
    }
  }

  Future<void> _deleteEntry(int entryId) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteTimetableEntryText), 
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true), 
            child: Text(l10n.delete)
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _timetableService.deleteTimetableEntry(entryId);
      if (success) {
        _loadTimetableForSelectedClass();
      } else {
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete entry.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students');

    return Scaffold(
      appBar: AppBar( 
        title: Text(l10n.manageTimetablesTitle), 
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: contextualAccentColor),
            tooltip: l10n.addEntryButton,
            onPressed: () => _navigateToAddEditEntry(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : Column(
              children: [
                if (_availableClasses.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0), 
                    child: DropdownButtonFormField<app_class.Class>(
                      value: _selectedClass,
                      hint: Text(l10n.selectClassToViewTimetableHint, style: theme.textTheme.bodyLarge), 
                      items: _availableClasses.map((app_class.Class cls) {
                        return DropdownMenuItem<app_class.Class>(
                          value: cls,
                          child: Text(cls.name, style: theme.textTheme.bodyLarge),
                        );
                      }).toList(),
                      onChanged: (app_class.Class? newValue) {
                        setState(() {
                          _selectedClass = newValue;
                        });
                        if (newValue != null) {
                          _loadTimetableForSelectedClass();
                        }
                      },
                    ),
                  ),
                Expanded(
                  child: _selectedClass == null
                      ? Center(child: Text(l10n.pleaseSelectClassToViewTimetableText, style: theme.textTheme.bodyLarge))
                      : _timetableEntries.isEmpty
                          ? Center(child: Text('${l10n.noTimetableEntriesForText} ${_selectedClass!.name}. ${l10n.addOneText}', style: theme.textTheme.bodyLarge))
                          : RefreshIndicator(
                              onRefresh: _loadTimetableForSelectedClass,
                              color: contextualAccentColor,
                              child: ListView.builder(
                                itemCount: _timetableEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = _timetableEntries[index];
                                  return Card( 
                                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: ListTile(
                                      title: Text('${entry.subjectName} (${entry.dayOfWeek})', style: theme.textTheme.titleMedium),
                                      subtitle: Text('${entry.startTimeString} - ${entry.endTimeString} (${l10n.teacherLabel} ID: ${entry.teacherId ?? l10n.not_specified})', style: theme.textTheme.bodySmall), 
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.edit, color: theme.iconTheme.color ?? textDarkGrey), 
                                            tooltip: l10n.editButton, 
                                            onPressed: () => _navigateToAddEditEntry(entry: entry),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                            tooltip: l10n.deleteButton, 
                                            onPressed: () => _deleteEntry(entry.id),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
    );
  }
}
