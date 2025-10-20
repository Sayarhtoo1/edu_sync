import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/timetable.dart';
import 'package:edu_sync/services/timetable_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_add_edit_timetable_entry.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';
import 'package:edu_sync/utils/logger.dart';

class DesktopTimetableManagement extends StatefulWidget {
  const DesktopTimetableManagement({super.key});

  @override
  State<DesktopTimetableManagement> createState() => _DesktopTimetableManagementState();
}

class _DesktopTimetableManagementState extends State<DesktopTimetableManagement> {
  late final TimetableService _timetableService;
  late final AuthService _authService;
  late final ClassService _classService;

  List<Timetable> _timetableEntries = [];
  List<app_class.SchoolClass> _availableClasses = [];
  app_class.SchoolClass? _selectedClass;
  bool _isLoading = true;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _timetableService = Provider.of<TimetableService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _classService = Provider.of<ClassService>(context, listen: false);
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    _currentSchoolId = await _authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      _availableClasses = await _classService.getClasses(_currentSchoolId!);
      if (_availableClasses.isNotEmpty) {
        _selectedClass = _availableClasses.first;
        await _loadTimetableForSelectedClass();
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadTimetableForSelectedClass() async {
    if (_selectedClass?.id == null) return;
    setState(() => _isLoading = true);
    _timetableEntries = await _timetableService.getTimetableForClass(_selectedClass!.id!);
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> _groupTimetableEntries() {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final entry in _timetableEntries) {
      final key = '${entry.subjectName}_${entry.startTimeString}_${entry.endTimeString}_${entry.teacherId ?? ""}';
      if (grouped.containsKey(key)) {
        (grouped[key]!['days'] as List<String>).add(entry.dayOfWeek);
        (grouped[key]!['ids'] as List<int>).add(entry.id);
      } else {
        grouped[key] = {'entry': entry, 'days': [entry.dayOfWeek], 'ids': [entry.id]};
      }
    }
    return grouped.values.toList();
  }

  void _navigateToAddEditEntry({Timetable? entry}) async {
    if (_currentSchoolId == null) return;
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DesktopAddEditTimetableEntry(
          timetableEntry: entry,
          schoolId: _currentSchoolId!,
          classIdForNewEntry: _selectedClass?.id,
        ),
      ),
    );
    if (result == true) _loadTimetableForSelectedClass();
  }

  Future<void> _deleteEntry(int entryId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Delete this timetable entry?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      await _timetableService.deleteTimetableEntry(entryId);
      _loadTimetableForSelectedClass();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Timetable Management',
      actions: [
        ElevatedButton.icon(
          onPressed: () => _navigateToAddEditEntry(),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Entry'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildClassSelector(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _selectedClass == null
                        ? _buildEmptyState('Select a class')
                        : _timetableEntries.isEmpty
                            ? _buildEmptyState('No entries for ${_selectedClass!.name}')
                            : _buildTimetableList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildClassSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: DropdownButtonFormField<app_class.SchoolClass>(
        value: _selectedClass,
        decoration: const InputDecoration(border: InputBorder.none, prefixIcon: Icon(Icons.class_, color: Color(0xFF3498DB))),
        hint: const Text('Select Class'),
        items: _availableClasses.map((cls) => DropdownMenuItem(value: cls, child: Text(cls.name))).toList(),
        onChanged: (value) {
          setState(() => _selectedClass = value);
          if (value != null) _loadTimetableForSelectedClass();
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildTimetableList() {
    final groupedEntries = _groupTimetableEntries();
    return ListView.builder(
      itemCount: groupedEntries.length,
      itemBuilder: (context, index) => _buildTimetableCard(groupedEntries[index]),
    );
  }

  Widget _buildTimetableCard(Map<String, dynamic> groupedData) {
    final Timetable entry = groupedData['entry'];
    final List<String> days = groupedData['days'];
    final List<int> ids = groupedData['ids'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.book, color: Color(0xFF3498DB), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.subjectName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${entry.startTimeString} - ${entry.endTimeString}', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  children: days.map((day) => Chip(
                    label: Text(day.substring(0, 3), style: const TextStyle(fontSize: 11)),
                    backgroundColor: const Color(0xFF3498DB).withOpacity(0.1),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF2ECC71)),
            onPressed: () => _navigateToAddEditEntry(entry: entry),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteEntry(ids.first),
          ),
        ],
      ),
    );
  }
}
