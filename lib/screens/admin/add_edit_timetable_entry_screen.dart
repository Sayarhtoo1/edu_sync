import 'package:flutter/material.dart';
import 'package:edu_sync/models/timetable.dart';
import 'package:edu_sync/services/timetable_service.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
import 'package:provider/provider.dart';
import 'package:edu_sync/utils/logger.dart';

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
  late final TimetableService _timetableService;
  late final ClassService _classService;
  late final AuthService _authService;

  late TextEditingController _subjectNameController;
  
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  Set<String> _selectedDaysOfWeek = {};
  int? _selectedClassId;
  String? _selectedTeacherId;

  List<app_class.SchoolClass> _availableClasses = [];
  List<app_user.User> _availableTeachers = [];

  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.timetableEntry != null;

  final List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    debugPrint('AddEditTimetableEntryScreen: initState called'); // Added debug print
    _timetableService = Provider.of<TimetableService>(context, listen: false);
    _classService = Provider.of<ClassService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _subjectNameController = TextEditingController(text: widget.timetableEntry?.subjectName ?? '');
    if (_isEditing && widget.timetableEntry != null) {
      _selectedStartTime = widget.timetableEntry!.startTimeOfDay;
      _selectedEndTime = widget.timetableEntry!.endTimeOfDay;
      _selectedDaysOfWeek = {widget.timetableEntry!.dayOfWeek};
      _selectedClassId = widget.timetableEntry!.classId;
      _selectedTeacherId = widget.timetableEntry!.teacherId;
    } else if (widget.classIdForNewEntry != null) {
      _selectedClassId = widget.classIdForNewEntry; // classIdForNewEntry is int?
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    debugPrint('AddEditTimetableEntryScreen: _loadInitialData started'); // Added debug print
    setState(() => _isLoading = true);
    try {
      _availableClasses = await _classService.getClasses(widget.schoolId);
      _availableTeachers = await _authService.getUsersByRole(UserRole.Teacher, widget.schoolId);
      
      if (_availableClasses.length == 1 && _selectedClassId == null && widget.classIdForNewEntry == null && !_isEditing) {
        _selectedClassId = _availableClasses.first.id; // Class.id is int?
      }
    } catch (e) {
      logger.e("Error loading initial data for timetable entry: $e");
      if (mounted) {
        setState(() => _errorMessage = AppLocalizations.of(context)?.failedToLoadTimetableDataError ?? 'Failed to load timetable data');
      }
    }
    if(mounted) setState(() => _isLoading = false);
    debugPrint('AddEditTimetableEntryScreen: _loadInitialData finished'); // Added debug print
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
    if (_selectedStartTime == null || _selectedEndTime == null || _selectedDaysOfWeek.isEmpty || _selectedClassId == null) {
      setState(() => _errorMessage = l10n?.fillAllFieldsError ?? 'Please fill all required fields');
      return;
    }
    if (_selectedEndTime!.hour < _selectedStartTime!.hour || (_selectedEndTime!.hour == _selectedStartTime!.hour && _selectedEndTime!.minute <= _selectedStartTime!.minute)) {
      setState(() => _errorMessage = l10n?.endTimeAfterStartTimeError ?? 'End time must be after start time');
      return;
    }
    _formKey.currentState!.save();
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final selectedClass = _availableClasses.firstWhere((cls) => cls.id == _selectedClassId);
      
      if (_isEditing) {
        final entry = Timetable(
          id: widget.timetableEntry!.id,
          classId: _selectedClassId!,
          className: selectedClass.name,
          startTimeOfDay: _selectedStartTime!,
          endTimeOfDay: _selectedEndTime!,
          dayOfWeek: _selectedDaysOfWeek.first,
          subjectName: _subjectNameController.text,
          teacherId: _selectedTeacherId,
        );
        final success = await _timetableService.updateTimetableEntry(entry);
        if (!success) throw Exception('Failed to update');
      } else {
        for (final day in _selectedDaysOfWeek) {
          final entry = Timetable(
            id: 0,
            classId: _selectedClassId!,
            className: selectedClass.name,
            startTimeOfDay: _selectedStartTime!,
            endTimeOfDay: _selectedEndTime!,
            dayOfWeek: day,
            subjectName: _subjectNameController.text,
            teacherId: _selectedTeacherId,
          );
          final newEntry = await _timetableService.createTimetableEntry(entry);
          if (newEntry == null) throw Exception('Failed to create entry for $day');
        }
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '${l10n?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}';
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
        case 'monday': return l10n?.monday ?? 'Monday';
        case 'tuesday': return l10n?.tuesday ?? 'Tuesday';
        case 'wednesday': return l10n?.wednesday ?? 'Wednesday';
        case 'thursday': return l10n?.thursday ?? 'Thursday';
        case 'friday': return l10n?.friday ?? 'Friday';
        case 'saturday': return l10n?.saturday ?? 'Saturday';
        case 'sunday': return l10n?.sunday ?? 'Sunday';
        default: return dayKey;
      }
    }

    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(_isEditing ? (l10n?.editTimetableEntryTitle ?? 'Edit Entry') : (l10n?.addTimetableEntryTitle ?? 'Add Entry')),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionCard(
                    'Basic Information',
                    [
                      _buildDropdownField(
                        value: _selectedClassId,
                        hint: l10n?.selectClassHint ?? 'Select Class',
                        icon: Icons.class_,
                        items: _availableClasses.map((cls) => DropdownMenuItem<int>(value: cls.id, child: Text(cls.name))).toList(),
                        onChanged: (value) => setState(() => _selectedClassId = value),
                        validator: (value) => value == null ? (l10n?.pleaseSelectClass ?? 'Required') : null,
                        accentColor: contextualAccentColor,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _subjectNameController,
                        label: l10n?.subjectNameLabel ?? 'Subject Name',
                        icon: Icons.book,
                        validator: (value) => (value == null || value.isEmpty) ? (l10n?.subjectNameValidator ?? 'Required') : null,
                        accentColor: contextualAccentColor,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdownField<String>(
                        value: _selectedTeacherId,
                        hint: l10n?.selectClassTeacherHint ?? 'Select Teacher',
                        icon: Icons.person,
                        items: _availableTeachers.map((teacher) => DropdownMenuItem<String>(value: teacher.id, child: Text(teacher.fullName ?? 'Unnamed'))).toList(),
                        onChanged: (value) => setState(() => _selectedTeacherId = value),
                        accentColor: contextualAccentColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionCard(
                    'Schedule',
                    [
                      _buildDaySelector(getLocalizedDayName, contextualAccentColor),
                      const SizedBox(height: 16),
                      _buildTimeSelector(
                        label: l10n?.startTimeLabelPrefix ?? 'Start Time',
                        time: _selectedStartTime,
                        icon: Icons.access_time,
                        onTap: () => _selectTime(context, true),
                        accentColor: contextualAccentColor,
                        context: context,
                      ),
                      const SizedBox(height: 12),
                      _buildTimeSelector(
                        label: l10n?.endTimeLabelPrefix ?? 'End Time',
                        time: _selectedEndTime,
                        icon: Icons.access_time_filled,
                        onTap: () => _selectTime(context, false),
                        accentColor: contextualAccentColor,
                        context: context,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: contextualAccentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: _saveTimetableEntry,
                    child: Text(_isEditing ? (l10n?.updateEntryButton ?? 'Update') : (l10n?.addEntryButton ?? 'Add Entry'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_errorMessage, style: TextStyle(color: theme.colorScheme.error))),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textDarkGrey)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, String? Function(String?)? validator, required Color accentColor}) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: accentColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor, width: 2)),
      ),
      validator: validator,
    );
  }

  Widget _buildDropdownField<T>({required T? value, required String hint, required IconData icon, required List<DropdownMenuItem<T>> items, required void Function(T?) onChanged, String? Function(T?)? validator, required Color accentColor}) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: accentColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: accentColor, width: 2)),
      ),
      items: items,
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildTimeSelector({required String label, required TimeOfDay? time, required IconData icon, required VoidCallback onTap, required Color accentColor, required BuildContext context}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 12, color: textDarkGrey.withOpacity(0.6))),
                  const SizedBox(height: 4),
                  Text(time?.format(context) ?? 'Not Set', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: textDarkGrey.withOpacity(0.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector(String Function(String) getLocalizedDayName, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: accentColor, size: 20),
            const SizedBox(width: 8),
            Text('Select Days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textDarkGrey)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _daysOfWeek.map((day) {
            final isSelected = _selectedDaysOfWeek.contains(day);
            return FilterChip(
              label: Text(getLocalizedDayName(day)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedDaysOfWeek.add(day);
                  } else {
                    _selectedDaysOfWeek.remove(day);
                  }
                });
              },
              selectedColor: accentColor.withOpacity(0.2),
              checkmarkColor: accentColor,
              labelStyle: TextStyle(
                color: isSelected ? accentColor : textDarkGrey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(color: isSelected ? accentColor : Colors.grey.withOpacity(0.3)),
            );
          }).toList(),
        ),
        if (_selectedDaysOfWeek.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Please select at least one day', style: TextStyle(fontSize: 12, color: Colors.red.withOpacity(0.7))),
          ),
      ],
    );
  }
}
