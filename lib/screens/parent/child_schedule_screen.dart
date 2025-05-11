import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/models/timetable.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/timetable_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class ChildScheduleScreen extends StatefulWidget {
  const ChildScheduleScreen({super.key});

  @override
  State<ChildScheduleScreen> createState() => _ChildScheduleScreenState();
}

class _ChildScheduleScreenState extends State<ChildScheduleScreen> {
  final StudentService _studentService = StudentService();
  final TimetableService _timetableService = TimetableService();
  final AuthService _authService = AuthService();

  List<Student> _linkedStudents = [];
  Student? _selectedStudent;
  List<Timetable> _timetableEntries = [];
  
  bool _isLoadingStudents = true;
  bool _isLoadingSchedule = false;
  String? _errorMessage;
  int? _schoolId;
  String? _parentId;

  @override
  void initState() {
    super.initState();
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    _schoolId = schoolProvider.currentSchool?.id;
    _parentId = _authService.getCurrentUser()?.id;

    if (_parentId != null && _schoolId != null) {
      _loadLinkedStudents();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isLoadingStudents = false;
            _errorMessage = AppLocalizations.of(context).error_user_not_found;
          });
        }
      });
    }
  }

  Future<void> _loadLinkedStudents() async {
    if (_parentId == null || _schoolId == null) return;
    setState(() => _isLoadingStudents = true);
    try {
      _linkedStudents = await _studentService.getStudentsByParent(_parentId!, _schoolId!);
      if (_linkedStudents.isNotEmpty) {
        _selectedStudent = _linkedStudents.first;
        _loadScheduleForStudent();
      } else {
        if (mounted) setState(() => _isLoadingStudents = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
          _errorMessage = "${AppLocalizations.of(context).errorOccurredPrefix}: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _loadScheduleForStudent() async {
    if (_selectedStudent == null || _selectedStudent!.classId == null) {
      if (mounted) setState(() => _timetableEntries = []);
      return; 
    }
    setState(() => _isLoadingSchedule = true);
    try {
      _timetableEntries = await _timetableService.getTimetableForClass(_selectedStudent!.classId!);
    } catch (e) {
       if (mounted) {
        setState(() => _errorMessage = "${AppLocalizations.of(context).errorOccurredPrefix}: ${e.toString()}");
      }
    }
    if (mounted) {
      setState(() => _isLoadingSchedule = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students');

    return Scaffold(
      appBar: AppBar( // Theme applied globally
        title: Text(l10n.childScheduleTitle), 
      ),
      body: _isLoadingStudents
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : _errorMessage != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error))))
              : _linkedStudents.isEmpty
                  ? Center(child: Text(l10n.noChildrenLinked, style: theme.textTheme.bodyLarge)) 
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0), // Increased padding
                          child: DropdownButtonFormField<Student>(
                            value: _selectedStudent,
                            hint: Text(l10n.selectChildHint, style: theme.textTheme.bodyLarge), 
                            items: _linkedStudents.map((Student student) {
                              return DropdownMenuItem<Student>(
                                value: student,
                                child: Text(student.fullName, style: theme.textTheme.bodyLarge),
                              );
                            }).toList(),
                            onChanged: (Student? newValue) {
                              setState(() {
                                _selectedStudent = newValue;
                                _timetableEntries = []; 
                              });
                              if (newValue != null) {
                                _loadScheduleForStudent();
                              }
                            },
                            // decoration will be picked from global theme's inputDecorationTheme
                          ),
                        ),
                        Expanded(
                          child: _isLoadingSchedule
                              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                              : _selectedStudent == null || _selectedStudent!.classId == null
                                  ? Center(child: Text(l10n.childNotAssignedToClass, style: theme.textTheme.bodyLarge)) 
                                  : _timetableEntries.isEmpty
                                      ? Center(child: Text(l10n.noScheduleFound, style: theme.textTheme.bodyLarge)) 
                                      : _buildTimetableDisplay(l10n),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildTimetableDisplay(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students');
    Map<String, List<Timetable>> groupedEntries = {};
    for (var entry in _timetableEntries) {
      groupedEntries.putIfAbsent(entry.dayOfWeek, () => []).add(entry);
    }
    groupedEntries.forEach((day, entries) {
      entries.sort((a, b) => a.startTimeOfDay.hour * 60 + a.startTimeOfDay.minute
          .compareTo(b.startTimeOfDay.hour * 60 + b.startTimeOfDay.minute));
    });

    final dayOrder = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    List<String> sortedDays = groupedEntries.keys.toList()
      ..sort((a, b) => dayOrder.indexOf(a).compareTo(dayOrder.indexOf(b)));
    
    String getLocalizedDayName(String dayKey) {
        switch (dayKey.toLowerCase()) {
            case 'monday': return l10n.monday;
            case 'tuesday': return l10n.tuesday;
            case 'wednesday': return l10n.wednesday;
            case 'thursday': return l10n.thursday;
            case 'friday': return l10n.friday;
            case 'saturday': return l10n.saturday;
            case 'sunday': return l10n.sunday;
            default: return dayKey;
        }
    }


    return ListView.builder(
      itemCount: sortedDays.length,
      itemBuilder: (context, index) {
        String day = sortedDays[index];
        List<Timetable> dayEntries = groupedEntries[day]!;
        
        return Card( // CardTheme applied globally
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjusted margin
          child: ExpansionTile(
            iconColor: contextualAccentColor,
            collapsedIconColor: textLightGrey, // Use top-level constant
            title: Text(getLocalizedDayName(day), style: theme.textTheme.titleLarge?.copyWith(color: contextualAccentColor)),
            children: dayEntries.map((entry) {
              return ListTile(
                title: Text(entry.subjectName, style: theme.textTheme.titleMedium),
                subtitle: Text(
                  '${l10n.time}: ${entry.startTimeOfDay.format(context)} - ${entry.endTimeOfDay.format(context)}'
                  '${entry.teacherId != null ? '\n${l10n.teacherLabel} ID: ${entry.teacherId}' : ''}',
                  style: theme.textTheme.bodySmall,
                ),
                isThreeLine: entry.teacherId != null,
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
