import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/models/attendance.dart' as app_attendance;
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/attendance_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class ChildAttendanceScreen extends StatefulWidget {
  const ChildAttendanceScreen({super.key});

  @override
  State<ChildAttendanceScreen> createState() => _ChildAttendanceScreenState();
}

class _ChildAttendanceScreenState extends State<ChildAttendanceScreen> {
  final StudentService _studentService = StudentService();
  final AttendanceService _attendanceService = AttendanceService();
  final AuthService _authService = AuthService();

  List<Student> _linkedStudents = [];
  Student? _selectedStudent;
  List<app_attendance.Attendance> _attendanceRecords = [];
  
  bool _isLoadingStudents = true;
  bool _isLoadingAttendance = false;
  String? _errorMessage;
  int? _schoolId;
  String? _parentId;

  // For date range or month selection
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);


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
            _errorMessage = AppLocalizations.of(context).error_user_not_found ?? "User or school context not found.";
          });
        }
      });
    }
  }

  Future<void> _loadLinkedStudents() async {
    if (_parentId == null || _schoolId == null) return;
    setState(() => _isLoadingStudents = true);
    try {
      // Assumes StudentService has a method to get students linked to a parent.
      // This would query through parent_student_relations.
      _linkedStudents = await _studentService.getStudentsByParent(_parentId!, _schoolId!);
      if (_linkedStudents.isNotEmpty) {
        _selectedStudent = _linkedStudents.first;
        _loadAttendanceForStudent();
      } else {
         if (mounted) setState(() => _isLoadingStudents = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
          _errorMessage = AppLocalizations.of(context).errorOccurredPrefix ?? "Error" ": ${e.toString()}";
        });
      }
    }
  }

  Future<void> _loadAttendanceForStudent() async {
    if (_selectedStudent == null) {
      if (mounted) setState(() => _attendanceRecords = []);
      return;
    }
    setState(() => _isLoadingAttendance = true);
    try {
      // Fetch attendance for the selected student for the selected month.
      // AttendanceService might need a new method like getAttendanceForStudentInMonth.
      // For now, let's assume we fetch all and filter, or adapt existing service.
      // This is a placeholder; a more specific query is better.
      // RLS on attendance table should ensure parent can only see their child's attendance.
      List<app_attendance.Attendance> allStudentAttendance = await _attendanceService.getAttendanceForStudent(_selectedStudent!.id);
      _attendanceRecords = allStudentAttendance.where((att) => 
          att.date.year == _selectedMonth.year && att.date.month == _selectedMonth.month
      ).toList();
      _attendanceRecords.sort((a,b) => a.date.compareTo(b.date)); // Sort by date

    } catch (e) {
       if (mounted) {
        setState(() => _errorMessage = AppLocalizations.of(context).errorOccurredPrefix ?? "Error" ": ${e.toString()}");
      }
    }
    if (mounted) {
      setState(() => _isLoadingAttendance = false);
    }
  }
  
  void _changeMonth(int monthIncrement) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + monthIncrement);
      _loadAttendanceForStudent();
    });
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students'); // Student-centric screen

    return Scaffold(
      appBar: AppBar( // Theme applied globally
        title: Text(l10n.childAttendanceTitle), 
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
                                _attendanceRecords = []; 
                              });
                              if (newValue != null) {
                                _loadAttendanceForStudent();
                              }
                            },
                            // decoration will be picked from global theme's inputDecorationTheme
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Adjusted padding
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(icon: Icon(Icons.chevron_left, color: theme.iconTheme.color), onPressed: () => _changeMonth(-1)),
                              Text(DateFormat.yMMMM(l10n.localeName).format(_selectedMonth), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                              IconButton(icon: Icon(Icons.chevron_right, color: theme.iconTheme.color), onPressed: () => _changeMonth(1)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _isLoadingAttendance
                              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                              : _selectedStudent == null
                                  ? Center(child: Text(l10n.pleaseSelectChild, style: theme.textTheme.bodyLarge)) 
                                  : _attendanceRecords.isEmpty
                                      ? Center(child: Text(l10n.noAttendanceRecordsFound, style: theme.textTheme.bodyLarge)) 
                                      : ListView.builder(
                                          itemCount: _attendanceRecords.length,
                                          itemBuilder: (context, index) {
                                            final record = _attendanceRecords[index];
                                            String statusText;
                                            Color statusColor;
                                            // Using theme colors for consistency where appropriate, but keeping specific status colors
                                            switch(record.status) {
                                              case 'Present':
                                                statusText = l10n.attendanceStatusPresent;
                                                statusColor = iconColorEarnings; // Greenish from theme
                                                break;
                                              case 'Absent':
                                                statusText = l10n.attendanceStatusAbsent;
                                                statusColor = theme.colorScheme.error; // Red from theme
                                                break;
                                              case 'Late':
                                                statusText = l10n.attendanceStatusLate;
                                                statusColor = iconColorParents; // Orangeish from theme
                                                break;
                                              default:
                                                statusText = record.status ?? l10n.not_specified; 
                                                statusColor = textLightGrey; // Grey from theme
                                            }

                                            return Card( // CardTheme applied globally
                                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Adjusted margin
                                              child: ListTile(
                                                title: Text(DateFormat.yMMMd(l10n.localeName).format(record.date), style: theme.textTheme.titleMedium),
                                                trailing: Text(statusText, style: theme.textTheme.bodyLarge?.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
                                              ),
                                            );
                                          },
                                        ),
                        ),
                      ],
                    ),
    );
  }
}
