import 'package:flutter/material.dart';
import 'package:edu_sync/models/timetable.dart';
import 'package:edu_sync/services/timetable_service.dart';
import 'package:edu_sync/models/class.dart' as app_class;
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class AddEditTimetableEntryScreen extends StatefulWidget {
  final Timetable? timetableEntry;
  final int schoolId; 
  final int? classIdForNewEntry; // Corrected to int?

  const AddEditTimetableEntryScreen({
    super.key,
    this.timetableEntry,
    required this.schoolId,
    this.classIdForNewEntry,
  });

  @override
  State<AddEditTimetableEntryScreen> createState() => _AddEditTimetableEntryScreenState();
}

class _AddEditTimetableEntryScreenState extends State<AddEditTimetableEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TimetableService _timetableService = TimetableService();
  final ClassService _classService = ClassService();
  final AuthService _authService = AuthService();

  late TextEditingController _subjectNameController;
  
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _selectedDayOfWeek;
  int? _selectedClassId; // Corrected to int?
  String? _selectedTeacherId;

  List<app_class.Class> _availableClasses = [];
  List<app_user.User> _availableTeachers = [];

  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.timetableEntry != null;

  final List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    _subjectNameController = TextEditingController(text: widget.timetableEntry?.subjectName ?? '');
    if (_isEditing && widget.timetableEntry != null) {
      _selectedStartTime = widget.timetableEntry!.startTimeOfDay;
      _selectedEndTime = widget.timetableEntry!.endTimeOfDay;
      _selectedDayOfWeek = widget.timetableEntry!.dayOfWeek;
      _selectedClassId = widget.timetableEntry!.classId; // Timetable.classId is int
      _selectedTeacherId = widget.timetableEntry!.teacherId;
    } else if (widget.classIdForNewEntry != null) {
      _selectedClassId = widget.classIdForNewEntry; // classIdForNewEntry is int?
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      _availableClasses = await _classService.getClassesBySchool(widget.schoolId);
      _availableTeachers = await _authService.getUsersByRole('Teacher', widget.schoolId);
      
      if (_availableClasses.length == 1 && _selectedClassId == null && widget.classIdForNewEntry == null && !_isEditing) {
        _selectedClassId = _availableClasses.first.id; // Class.id is int?
      }
      // Auto-select teacher if only one is available and not editing
      // if (_availableTeachers.length == 1 && _selectedTeacherId == null && !_isEditing) {
      //    _selectedTeacherId = _availableTeachers.first.id; 
      // }

    } catch (e) {
      print("Error loading initial data for timetable entry: $e");
      if (mounted) {
        setState(() => _errorMessage = AppLocalizations.of(context).failedToLoadTimetableDataError);
      }
    }
    if(mounted) setState(() => _isLoading = false);
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students');

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (isStartTime ? _selectedStartTime : _selectedEndTime) ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: contextualAccentColor, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: textDarkGrey, // dial text color
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: cardBackgroundColor,
              dialHandColor: contextualAccentColor,
              dialBackgroundColor: appBackgroundColor, // background of the dial itself
              hourMinuteTextColor: textDarkGrey, // Color for hour/minute text inputs
              dayPeriodTextColor: textDarkGrey, // Color for AM/PM text
              // Other properties as needed
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: contextualAccentColor, // OK/Cancel button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _selectedStartTime = picked;
        } else {
          _selectedEndTime = picked;
        }
      });
    }
  }

  Future<void> _saveTimetableEntry() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStartTime == null || _selectedEndTime == null || _selectedDayOfWeek == null || _selectedClassId == null /* Teacher can be optional || _selectedTeacherId == null */) {
      setState(() => _errorMessage = l10n.fillAllFieldsError); // Adjusted validation message if teacher is optional
      return;
    }
    if (_selectedEndTime!.hour < _selectedStartTime!.hour || (_selectedEndTime!.hour == _selectedStartTime!.hour && _selectedEndTime!.minute <= _selectedStartTime!.minute)) {
      setState(() => _errorMessage = l10n.endTimeAfterStartTimeError);
      return;
    }
    _formKey.currentState!.save();
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final entry = Timetable(
        id: _isEditing ? widget.timetableEntry!.id : 0, 
        classId: _selectedClassId!, // Now int
        startTimeOfDay: _selectedStartTime!,
        endTimeOfDay: _selectedEndTime!,
        dayOfWeek: _selectedDayOfWeek!,
        subjectName: _subjectNameController.text,
        teacherId: _selectedTeacherId,
      );

      bool success;
      if (_isEditing) {
        success = await _timetableService.updateTimetableEntry(entry);
      } else {
        final newEntry = await _timetableService.createTimetableEntry(entry);
        success = newEntry != null;
      }

      if (success) {
        if(mounted) Navigator.of(context).pop(true); 
      } else {
        throw Exception(l10n.failedToSaveTimetableEntryError);
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '${l10n.errorOccurredPrefix}: ${e.toString()}';
        });
      }
    }
  }
  
  @override
  void dispose(){
    _subjectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students');

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

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editTimetableEntryTitle : l10n.addTimetableEntryTitle)), // Theme applied globally
      body: _isLoading 
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    DropdownButtonFormField<int>( // Corrected to int
                      value: _selectedClassId,
                      hint: Text(l10n.selectClassHint),
                      items: _availableClasses.map((app_class.Class cls) {
                        return DropdownMenuItem<int>(value: cls.id, child: Text(cls.name)); // cls.id is int?
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedClassId = value),
                      validator: (value) => value == null ? l10n.pleaseSelectClass : null, 
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _subjectNameController,
                      decoration: InputDecoration(labelText: l10n.subjectNameLabel),
                      validator: (value) => (value == null || value.isEmpty) ? l10n.subjectNameValidator : null,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTeacherId,
                      hint: Text(l10n.selectClassTeacherHint), 
                      items: _availableTeachers.map((app_user.User teacher) {
                        return DropdownMenuItem<String>(value: teacher.id, child: Text(teacher.fullName ?? l10n.unnamedTeacher));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedTeacherId = value),
                      // validator: (value) => value == null ? l10n.classTeacherValidator : null, // Teacher can be optional
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedDayOfWeek,
                      hint: Text(l10n.selectDayOfWeekHint),
                      items: _daysOfWeek.map((String day) {
                        return DropdownMenuItem<String>(value: day, child: Text(getLocalizedDayName(day)));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedDayOfWeek = value),
                      validator: (value) => value == null ? l10n.dayValidator : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text('${l10n.startTimeLabelPrefix}${_selectedStartTime?.format(context) ?? l10n.timeNotSet}', style: theme.textTheme.bodyLarge),
                      trailing: Icon(Icons.access_time, color: theme.iconTheme.color),
                      onTap: () => _selectTime(context, true),
                    ),
                    ListTile(
                      title: Text('${l10n.endTimeLabelPrefix}${_selectedEndTime?.format(context) ?? l10n.timeNotSet}', style: theme.textTheme.bodyLarge),
                      trailing: Icon(Icons.access_time, color: theme.iconTheme.color),
                      onTap: () => _selectTime(context, false),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: contextualAccentColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _saveTimetableEntry,
                      child: Text(_isEditing ? l10n.updateEntryButton : l10n.addEntryButton),
                    ),
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(_errorMessage, style: TextStyle(color: theme.colorScheme.error)),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}
