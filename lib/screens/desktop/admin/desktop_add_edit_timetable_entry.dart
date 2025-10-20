import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/timetable.dart';
import 'package:edu_sync/services/timetable_service.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';
import 'package:edu_sync/utils/logger.dart';

class DesktopAddEditTimetableEntry extends StatefulWidget {
  final Timetable? timetableEntry;
  final int schoolId;
  final int? classIdForNewEntry;

  const DesktopAddEditTimetableEntry({super.key, this.timetableEntry, required this.schoolId, this.classIdForNewEntry});

  @override
  State<DesktopAddEditTimetableEntry> createState() => _DesktopAddEditTimetableEntryState();
}

class _DesktopAddEditTimetableEntryState extends State<DesktopAddEditTimetableEntry> {
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
      _selectedClassId = widget.classIdForNewEntry;
    }
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      _availableClasses = await _classService.getClasses(widget.schoolId);
      _availableTeachers = await _authService.getUsersByRole(UserRole.Teacher, widget.schoolId);
    } catch (e) {
      logger.e("Error loading timetable data: $e");
      if (mounted) setState(() => _errorMessage = 'Failed to load data');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: (isStartTime ? _selectedStartTime : _selectedEndTime) ?? TimeOfDay.now(),
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
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStartTime == null || _selectedEndTime == null || _selectedDaysOfWeek.isEmpty || _selectedClassId == null) {
      setState(() => _errorMessage = 'Please fill all required fields');
      return;
    }
    if (_selectedEndTime!.hour < _selectedStartTime!.hour || (_selectedEndTime!.hour == _selectedStartTime!.hour && _selectedEndTime!.minute <= _selectedStartTime!.minute)) {
      setState(() => _errorMessage = 'End time must be after start time');
      return;
    }
    
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
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _subjectNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: _isEditing ? 'Edit Timetable Entry' : 'Add Timetable Entry',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildBasicInfoCard()),
                        const SizedBox(width: 24),
                        Expanded(child: _buildScheduleCard()),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 24),
          DropdownButtonFormField<int>(
            value: _selectedClassId,
            decoration: const InputDecoration(labelText: 'Class *', border: OutlineInputBorder()),
            hint: const Text('Select Class'),
            items: _availableClasses.map((cls) => DropdownMenuItem<int>(value: cls.id, child: Text(cls.name))).toList(),
            onChanged: (value) => setState(() => _selectedClassId = value),
            validator: (value) => value == null ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _subjectNameController,
            decoration: const InputDecoration(labelText: 'Subject Name *', border: OutlineInputBorder()),
            validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTeacherId,
            decoration: const InputDecoration(labelText: 'Teacher', border: OutlineInputBorder()),
            hint: const Text('Select Teacher'),
            items: _availableTeachers.map((teacher) => DropdownMenuItem<String>(value: teacher.id, child: Text(teacher.fullName ?? 'Unnamed'))).toList(),
            onChanged: (value) => setState(() => _selectedTeacherId = value),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 24),
          const Text('Days of Week *', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _daysOfWeek.map((day) {
              final isSelected = _selectedDaysOfWeek.contains(day);
              return FilterChip(
                label: Text(day.substring(0, 3)),
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
                selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
                checkmarkColor: const Color(0xFF3498DB),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: () => _selectTime(context, true),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Start Time *', border: OutlineInputBorder()),
              child: Text(_selectedStartTime?.format(context) ?? 'Select Time'),
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => _selectTime(context, false),
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'End Time *', border: OutlineInputBorder()),
              child: Text(_selectedEndTime?.format(context) ?? 'Select Time'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveTimetableEntry,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isEditing ? 'Update Entry' : 'Create Entry'),
          ),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(width: 16),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}
