import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/models/attendance.dart' as app_attendance;
import 'package:edu_sync/services/attendance_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/student_service.dart';

class AttendanceMarkingScreen extends StatefulWidget {
  const AttendanceMarkingScreen({super.key});

  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  final ClassService _classService = ClassService();
  final StudentService _studentService = StudentService();
  final AttendanceService _attendanceService = AttendanceService();
  final AuthService _authService = AuthService();

  List<app_class.SchoolClass> _teacherClasses = [];
  app_class.SchoolClass? _selectedClass;
  DateTime _selectedDate = DateTime.now();
  List<Student> _studentsInClass = [];
  Map<int, String> _attendanceStatus = {}; 
  bool _isLoading = true;
  String? _currentUserId; 
  String? _currentUserRole;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final currentUser = _authService.getCurrentUser();
    _currentUserRole = await _authService.getUserRole();

    if (currentUser == null || _currentUserRole == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    _currentUserId = currentUser.id;
    // Ensure context is available for AppLocalizations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _currentSchoolId = await _authService.getCurrentUserSchoolId();

      if (_currentSchoolId != null && _currentUserId != null) {
        List<app_class.SchoolClass> allClassesInSchool = await _classService.getClasses(_currentSchoolId!);
        
        if (_currentUserRole == 'Teacher') {
          _teacherClasses = allClassesInSchool.where((c) => c.teacherId == _currentUserId).toList();
        } else if (_currentUserRole == 'Admin') {
          _teacherClasses = allClassesInSchool; 
        } else {
          _teacherClasses = []; 
        }

        if (_teacherClasses.isNotEmpty) {
          _selectedClass = _teacherClasses.first;
          await _loadStudentsForClass();
        }
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _loadStudentsForClass() async {
    if (_selectedClass == null || _selectedClass!.id == null) return; // Added null check for id
    if (!mounted) return;
    setState(() => _isLoading = true);
    // _selectedClass.id is int?
    _studentsInClass = await _studentService.getStudentsByClass(_selectedClass!.id!);
    
    // _selectedClass.id is int?
    final attendance = await _attendanceService.getAttendanceForClassByDate(_selectedClass!.id!, _selectedDate);
    _attendanceStatus = {for (var a in attendance) a.studentId: a.status};
    
    for (var student in _studentsInClass) {
      _attendanceStatus.putIfAbsent(student.id, () => 'Present'); 
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 7)), 
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: contextualAccentColor,
              onPrimary: Colors.white,
              onSurface: textDarkGrey,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: contextualAccentColor,
              ),
            ), dialogTheme: DialogThemeData(backgroundColor: cardBackgroundColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadStudentsForClass(); 
    }
  }
  
  void _setAttendanceStatus(int studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
    });
  }

  Future<void> _saveAttendance() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    if (_selectedClass == null || _currentUserId == null) { 
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.classOrUserMissingError))); 
      return;
    }
    setState(() => _isLoading = true);
    
    List<app_attendance.Attendance> attendanceBatch = [];
    _attendanceStatus.forEach((studentId, status) {
      attendanceBatch.add(app_attendance.Attendance(
        studentId: studentId,
        classId: _selectedClass!.id!, // _selectedClass.id is int?
        date: _selectedDate,
        // isPresent is removed, status is now the source of truth
        status: status, 
        markedByTeacherId: _currentUserId!, 
      ));
    });
    
    bool success = await _attendanceService.saveAttendanceBatch(attendanceBatch);

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.attendanceSavedSuccess)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.attendanceSaveFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    return Scaffold(
      appBar: AppBar( // Theme applied globally
        title: Text(l10n.markAttendanceTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<app_class.SchoolClass>(
                          value: _selectedClass,
                          hint: Text(l10n.selectClassHint, style: theme.textTheme.bodyLarge),
                          items: _teacherClasses.map((app_class.SchoolClass cls) {
                            return DropdownMenuItem<app_class.SchoolClass>(
                              value: cls,
                              child: Text(cls.name, style: theme.textTheme.bodyLarge), 
                            );
                          }).toList(),
                          onChanged: (app_class.SchoolClass? newValue) {
                            setState(() {
                              _selectedClass = newValue;
                            });
                            if (newValue != null) {
                              _loadStudentsForClass();
                            }
                          },
                          // decoration will use global theme
                        ),
                      ),
                      const SizedBox(width: 16),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: contextualAccentColor),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                        onPressed: () => _selectDate(context),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: _selectedClass == null
                      ? Center(child: Text(l10n.pleaseSelectClass, style: theme.textTheme.bodyLarge))
                      : _studentsInClass.isEmpty
                          ? Center(child: Text(l10n.noStudentsInClass, style: theme.textTheme.bodyLarge))
                          : ListView.builder(
                              itemCount: _studentsInClass.length,
                              itemBuilder: (context, index) {
                                final student = _studentsInClass[index];
                                final currentStatus = _attendanceStatus[student.id] ?? 'Present';
                                
                                return Card( // CardTheme applied globally
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Adjusted margin
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: contextualAccentColor.withOpacity(0.2),
                                      backgroundImage: student.profilePhotoUrl != null && student.profilePhotoUrl!.isNotEmpty
                                          ? NetworkImage(student.profilePhotoUrl!)
                                          : null,
                                      child: student.profilePhotoUrl == null || student.profilePhotoUrl!.isEmpty
                                          ? Text(student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : '?', style: TextStyle(color: contextualAccentColor, fontWeight: FontWeight.bold))
                                          : null,
                                    ),
                                    title: Text(student.fullName, style: theme.textTheme.titleMedium), 
                                    trailing: AttendanceStatusButtons(
                                      currentStatus: currentStatus,
                                      studentId: student.id,
                                      onStatusChanged: _setAttendanceStatus,
                                      l10n: l10n,
                                      theme: theme, // Pass theme
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
                if (_studentsInClass.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: contextualAccentColor,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50)
                      ),
                      onPressed: _saveAttendance,
                      child: Text(l10n.saveAttendanceButton),
                    ),
                  )
              ],
            ),
    );
  }
}

// New Widget for Attendance Status Buttons
class AttendanceStatusButtons extends StatelessWidget {
  final String currentStatus;
  final int studentId;
  final Function(int, String) onStatusChanged;
  final AppLocalizations l10n;
  final ThemeData theme; // Added theme parameter

  const AttendanceStatusButtons({
    super.key,
    required this.currentStatus,
    required this.studentId,
    required this.onStatusChanged,
    required this.l10n,
    required this.theme, // Added theme parameter
  });

  @override
  Widget build(BuildContext context) {
    // Use theme colors for statuses
    final Map<String, Color> statusColors = {
      'Present': iconColorEarnings, // Greenish from theme
      'Absent': theme.colorScheme.error,   // Red from theme
      'Late': iconColorParents,  // Orangeish from theme
    };

    final Map<String, String> statusLabels = {
      'Present': l10n.attendanceStatusPresent,
      'Absent': l10n.attendanceStatusAbsent,
      'Late': l10n.attendanceStatusLate,
    };
    
    final List<String> statuses = ['Present', 'Absent', 'Late'];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: statuses.map((status) {
        bool isSelected = currentStatus == status;
        Color activeColor = statusColors[status] ?? textLightGrey; // Fallback to a theme grey
        Color inactiveColor = theme.colorScheme.surfaceContainerHighest; // Lighter grey for unselected
        Color textColor = isSelected ? Colors.white : activeColor; // Text color contrast

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: ElevatedButton(
            onPressed: () => onStatusChanged(studentId, status),
            style: ElevatedButton.styleFrom(
              backgroundColor: isSelected ? activeColor : inactiveColor, 
              foregroundColor: textColor, 
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              textStyle: theme.textTheme.labelSmall?.copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: BorderSide(
                  color: isSelected ? activeColor : (theme.dividerColor), 
                  width: isSelected ? 1.5 : 1,
                )
              ),
              elevation: isSelected ? 2 : 0,
            ),
            child: Text(statusLabels[status]!),
          ),
        );
      }).toList(),
    );
  }
}
