import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/models/attendance.dart' as app_attendance;
import 'package:edu_sync/services/attendance_service.dart';
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/utils/logger.dart'; // Import logger
import 'package:provider/provider.dart'; // Import provider
import 'package:cached_network_image/cached_network_image.dart'; // Import cached_network_image

class AttendanceMarkingScreen extends StatefulWidget {
  const AttendanceMarkingScreen({super.key});

  @override
  State<AttendanceMarkingScreen> createState() => _AttendanceMarkingScreenState();
}

class _AttendanceMarkingScreenState extends State<AttendanceMarkingScreen> {
  late final ClassService _classService;
  late final StudentService _studentService;
  late final AttendanceService _attendanceService;
  late final AuthService _authService;

  List<app_class.SchoolClass> _teacherClasses = [];
  app_class.SchoolClass? _selectedClass;
  DateTime _selectedDate = DateTime.now();
  List<Student> _studentsInClass = [];
  Map<int, app_attendance.Attendance> _attendanceStatus = {};
  bool _isLoading = true;
  String? _currentUserId;
  String? _currentUserRole;
  int? _currentSchoolId;

  int _presentCount = 0;
  int _absentCount = 0;
  int _leaveCount = 0;

  @override
  void initState() {
    super.initState();
    _classService = Provider.of<ClassService>(context, listen: false);
    _studentService = Provider.of<StudentService>(context, listen: false);
    _attendanceService = Provider.of<AttendanceService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    final currentUser = _authService.getCurrentUser();
    _currentUserRole = await _authService.getUserRole();
    logger.i('AttendanceMarkingScreen: Fetched user role: $_currentUserRole');

    if (currentUser == null || _currentUserRole == null) {
      logger.i('AttendanceMarkingScreen: Current user or role is null. User: $currentUser, Role: $_currentUserRole');
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    _currentUserId = currentUser.id;
    logger.i('AttendanceMarkingScreen: Current User ID: $_currentUserId, Role: $_currentUserRole');

    // Ensure context is available for AppLocalizations
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _currentSchoolId = await _authService.getCurrentUserSchoolId();
      logger.i('AttendanceMarkingScreen: Current School ID: $_currentSchoolId');

      if (_currentSchoolId != null && _currentUserId != null) {
        List<app_class.SchoolClass> allClassesInSchool = await _classService.getClasses(_currentSchoolId!);
        logger.i('AttendanceMarkingScreen: Fetched ${allClassesInSchool.length} classes for school ID $_currentSchoolId.');
        
        logger.i('AttendanceMarkingScreen: Comparing roles: _currentUserRole: "$_currentUserRole", UserRole.Teacher.name: "${UserRole.Teacher.name}", UserRole.Admin.name: "${UserRole.Admin.name}"');

        if (_currentUserRole == UserRole.Teacher.name) {
          _teacherClasses = allClassesInSchool.where((c) => c.teacherId == _currentUserId).toList();
          logger.i('AttendanceMarkingScreen: Filtered to ${_teacherClasses.length} classes for teacher.');
        } else if (_currentUserRole == UserRole.Admin.name) {
          _teacherClasses = allClassesInSchool;
          logger.i('AttendanceMarkingScreen: Admin user, using all ${allClassesInSchool.length} classes.');
        } else {
          _teacherClasses = []; 
          logger.i('AttendanceMarkingScreen: Unknown role, no classes assigned.');
        }

        if (_teacherClasses.isNotEmpty) {
          _selectedClass = _teacherClasses.first;
          logger.i('AttendanceMarkingScreen: Selected first class: ${_selectedClass?.name} (ID: ${_selectedClass?.id})');
          await _loadStudentsForClass();
        } else {
          logger.i('AttendanceMarkingScreen: No classes found for the current user/role in this school.');
        }
      } else {
        logger.i('AttendanceMarkingScreen: Current School ID or User ID is null after fetch. School ID: $_currentSchoolId, User ID: $_currentUserId');
      }
      if (mounted) {
        setState(() => _isLoading = false);
        logger.i('AttendanceMarkingScreen: _isLoading set to false.');
      }
    });
  }

  Future<void> _loadStudentsForClass() async {
    if (_selectedClass == null || _selectedClass!.id == null) {
      logger.i('AttendanceMarkingScreen: _loadStudentsForClass called with null _selectedClass or ID.');
      return; // Added null check for id
    }
    if (!mounted) return;
    setState(() => _isLoading = true);
    logger.i('AttendanceMarkingScreen: Loading students for class ID: ${_selectedClass!.id!}');
    
    _studentsInClass = await _studentService.getStudentsByClass(_selectedClass!.id!);
    logger.i('AttendanceMarkingScreen: Fetched ${_studentsInClass.length} students for class ID: ${_selectedClass!.id!}');
    
    final attendance = await _attendanceService.getAttendanceForClassByDate(_selectedClass!.id!, _selectedDate);
    logger.i('AttendanceMarkingScreen: Fetched ${attendance.length} attendance records for class ID: ${_selectedClass!.id!} on $_selectedDate');
    _attendanceStatus = {for (var a in attendance) a.studentId: a};
    
    for (var student in _studentsInClass) {
      _attendanceStatus.putIfAbsent(
        student.id,
        () => app_attendance.Attendance(
          studentId: student.id,
          classId: _selectedClass!.id!,
          date: _selectedDate,
          status: 'Present',
          markedByTeacherId: _currentUserId,
        ),
      );
    }

    _updateAttendanceCounts(); // Update counts after loading attendance

    if (mounted) {
      setState(() => _isLoading = false);
      logger.i('AttendanceMarkingScreen: _loadStudentsForClass finished, _isLoading set to false.');
    }
  }

  void _updateAttendanceCounts() {
    _presentCount = _attendanceStatus.values.where((att) => att.status == 'Present').length;
    _absentCount = _attendanceStatus.values.where((att) => att.status == 'Absent').length;
    _leaveCount = _attendanceStatus.values.where((att) => att.status == 'Leave').length;
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
      final existingAttendance = _attendanceStatus[studentId];
      if (existingAttendance != null) {
        _attendanceStatus[studentId] = app_attendance.Attendance(
          id: existingAttendance.id,
          studentId: existingAttendance.studentId,
          classId: existingAttendance.classId,
          date: existingAttendance.date,
          status: status,
          markedByTeacherId: existingAttendance.markedByTeacherId,
          updatedAt: DateTime.now(),
        );
      } else {
        // This case should ideally not happen if _loadStudentsForClass populates correctly
        _attendanceStatus[studentId] = app_attendance.Attendance(
          studentId: studentId,
          classId: _selectedClass!.id!,
          date: _selectedDate,
          status: status,
          markedByTeacherId: _currentUserId,
          updatedAt: DateTime.now(),
        );
      }
      _updateAttendanceCounts(); // Update counts when a student's status changes
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
    
    List<app_attendance.Attendance> attendanceBatch = _attendanceStatus.values.toList();
    
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
                // Display attendance summary
                if (_selectedClass != null && _studentsInClass.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildAttendanceSummaryCard(l10n.attendanceStatusPresent, _presentCount, Colors.green),
                        _buildAttendanceSummaryCard(l10n.attendanceStatusAbsent, _absentCount, theme.colorScheme.error),
                        _buildAttendanceSummaryCard(l10n.attendanceStatusLeave, _leaveCount, Colors.orange),
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
                                final app_attendance.Attendance? attendanceRecord = _attendanceStatus[student.id];
                                final String currentStatus = attendanceRecord?.status ?? 'Present';
                                
                                return Card( // CardTheme applied globally
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), // Adjusted margin
                                  child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: contextualAccentColor.withAlpha((255 * 0.2).round()), // Fix deprecated withOpacity
                                  child: student.profilePhotoUrl != null && student.profilePhotoUrl!.isNotEmpty
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: student.profilePhotoUrl!,
                                            placeholder: (context, url) => CircularProgressIndicator(
                                              valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor),
                                            ),
                                            errorWidget: (context, url, error) => Icon(Icons.person_outline, color: contextualAccentColor), // Changed to person icon
                                            fit: BoxFit.cover,
                                            width: 50,
                                            height: 50,
                                          ),
                                        )
                                      : Text(student.fullName.isNotEmpty ? student.fullName[0].toUpperCase() : '?', style: TextStyle(color: contextualAccentColor, fontWeight: FontWeight.bold)),
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

  Widget _buildAttendanceSummaryCard(String title, int count, Color color) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                count.toString(),
                style: theme.textTheme.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
      'Leave': iconColorParents,  // Orangeish from theme (using for Leave)
    };

    final Map<String, String> statusLabels = {
      'Present': l10n.attendanceStatusPresent,
      'Absent': l10n.attendanceStatusAbsent,
      'Leave': l10n.attendanceStatusLeave, // Changed from Late to Leave
    };
    
    final List<String> statuses = ['Present', 'Absent', 'Leave']; // Changed from Late to Leave

    // Determine the next status in the cycle
    String getNextStatus(String current) {
      int currentIndex = statuses.indexOf(current);
      return statuses[(currentIndex + 1) % statuses.length];
    }

    // Get the current status's color and label
    Color activeColor = statusColors[currentStatus] ?? textLightGrey;
    String activeLabel = statusLabels[currentStatus] ?? currentStatus;

    return GestureDetector(
      onTap: () {
        final nextStatus = getNextStatus(currentStatus);
        onStatusChanged(studentId, nextStatus);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: activeColor,
          borderRadius: BorderRadius.circular(20.0), // Pill shape
          border: Border.all(color: activeColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          activeLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
