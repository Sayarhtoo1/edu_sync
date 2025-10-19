import 'package:flutter/material.dart';
import 'package:edu_sync/models/timetable.dart';
import 'package:edu_sync/services/timetable_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/services/class_service.dart';
import 'add_edit_timetable_entry_screen.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart';
import 'package:provider/provider.dart';

class TimetableManagementScreen extends StatefulWidget {
  const TimetableManagementScreen({super.key});

  @override
  State<TimetableManagementScreen> createState() => _TimetableManagementScreenState();
}

class _TimetableManagementScreenState extends State<TimetableManagementScreen> {
  TimetableService? _timetableService;
  AuthService? _authService;
  ClassService? _classService;

  List<Timetable> _timetableEntries = [];
  List<app_class.SchoolClass> _availableClasses = [];
  app_class.SchoolClass? _selectedClass;
  bool _isLoading = true;
  int? _currentSchoolId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _timetableService = Provider.of<TimetableService>(context, listen: false);
      _authService = Provider.of<AuthService>(context, listen: false);
      _classService = Provider.of<ClassService>(context, listen: false);
      _initialized = true;
      _fetchInitialData();
    }
  }

  Future<void> _fetchInitialData() async {
    if (_authService == null || _classService == null) return;
    setState(() => _isLoading = true);
    _currentSchoolId = await _authService!.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      _availableClasses = await _classService!.getClasses(_currentSchoolId!);
      if (_availableClasses.isNotEmpty) {
        _selectedClass = _availableClasses.first;
        await _loadTimetableForSelectedClass();
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTimetableForSelectedClass() async {
    if (_selectedClass == null || _selectedClass!.id == null || _timetableService == null) return;
    setState(() => _isLoading = true);
    _timetableEntries = await _timetableService!.getTimetableForClass(_selectedClass!.id!);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _groupTimetableEntries() {
    final Map<String, Map<String, dynamic>> grouped = {};
    
    for (final entry in _timetableEntries) {
      final key = '${entry.subjectName}_${entry.startTimeString}_${entry.endTimeString}_${entry.teacherId ?? ""}';
      
      if (grouped.containsKey(key)) {
        (grouped[key]!['days'] as List<String>).add(entry.dayOfWeek);
        (grouped[key]!['ids'] as List<int>).add(entry.id);
      } else {
        grouped[key] = {
          'entry': entry,
          'days': [entry.dayOfWeek],
          'ids': [entry.id],
        };
      }
    }
    
    return grouped.values.toList();
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
    if (_timetableService == null) return;
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(l10n?.confirmDeleteTitle ?? 'Confirm Delete'),
        content: Text(l10n?.confirmDeleteTimetableEntryText ?? 'Are you sure you want to delete this timetable entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n?.cancel ?? 'Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true), 
            child: Text(l10n?.delete ?? 'Delete')
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _timetableService!.deleteTimetableEntry(entryId);
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
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(l10n?.manageTimetablesTitle ?? 'Manage Timetables'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEditEntry(),
        backgroundColor: contextualAccentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n?.addEntryButton ?? 'Add Entry', style: const TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : Column(
              children: [
                if (_availableClasses.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                    child: DropdownButtonFormField<app_class.SchoolClass>(
                      value: _selectedClass,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.class_, color: contextualAccentColor),
                        hintText: l10n?.selectClassToViewTimetableHint ?? 'Select Class',
                      ),
                      isExpanded: true,
                      items: _availableClasses.map((app_class.SchoolClass cls) {
                        return DropdownMenuItem<app_class.SchoolClass>(
                          value: cls,
                          child: Text(cls.name, style: theme.textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (app_class.SchoolClass? newValue) {
                        setState(() => _selectedClass = newValue);
                        if (newValue != null) _loadTimetableForSelectedClass();
                      },
                    ),
                  ),
                Expanded(
                  child: _selectedClass == null
                      ? _buildEmptyState(l10n?.pleaseSelectClassToViewTimetableText ?? 'Please select a class', Icons.class_, contextualAccentColor)
                      : _timetableEntries.isEmpty
                          ? _buildEmptyState('${l10n?.noTimetableEntriesForText ?? 'No entries for'} ${_selectedClass!.name}', Icons.event_busy, contextualAccentColor)
                          : RefreshIndicator(
                              onRefresh: _loadTimetableForSelectedClass,
                              color: contextualAccentColor,
                              child: Builder(
                                builder: (context) {
                                  final groupedEntries = _groupTimetableEntries();
                                  return ListView.builder(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                                    itemCount: groupedEntries.length,
                                    itemBuilder: (context, index) => _buildGroupedTimetableCard(context, groupedEntries[index], l10n, theme, contextualAccentColor),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: textDarkGrey.withOpacity(0.6)), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  String _getDaySymbol(String day) {
    switch (day) {
      case 'Monday': return 'Mon';
      case 'Tuesday': return 'Tue';
      case 'Wednesday': return 'Wed';
      case 'Thursday': return 'Thu';
      case 'Friday': return 'Fri';
      case 'Saturday': return 'Sat';
      case 'Sunday': return 'Sun';
      default: return day.substring(0, 3);
    }
  }

  Widget _buildGroupedTimetableCard(BuildContext context, Map<String, dynamic> groupedData, AppLocalizations? l10n, ThemeData theme, Color accentColor) {
    final Timetable entry = groupedData['entry'];
    final List<String> days = groupedData['days'];
    final List<int> ids = groupedData['ids'];
    
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.book, color: accentColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.subjectName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        children: days.map((day) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(_getDaySymbol(day), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: accentColor)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: accentColor),
                  onPressed: () => _navigateToAddEditEntry(entry: entry),
                ),
                PopupMenuButton<int>(
                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  onSelected: (id) => _deleteEntry(id),
                  itemBuilder: (context) => ids.map((id) {
                    final dayIndex = ids.indexOf(id);
                    return PopupMenuItem<int>(
                      value: id,
                      child: Text('Delete ${days[dayIndex]}'),
                    );
                  }).toList()..add(PopupMenuItem<int>(
                    value: -1,
                    child: Text('Delete All', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
                    onTap: () {
                      Future.delayed(Duration.zero, () {
                        for (final id in ids) {
                          _deleteEntry(id);
                        }
                      });
                    },
                  )),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: appBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, size: 18, color: accentColor),
                  const SizedBox(width: 8),
                  Text('${entry.startTimeString} - ${entry.endTimeString}', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
