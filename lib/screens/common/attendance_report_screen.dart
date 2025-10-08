import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/attendance_report.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../services/class_service.dart';
import '../../services/student_service.dart';
import '../../models/school_class.dart' as app_class;
import '../../models/student.dart';
import 'attendance_report_components/date_range_selector.dart';
import 'attendance_report_components/report_display.dart';
import 'attendance_report_components/export_button.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  late final AttendanceService _attendanceService;
  late final AuthService _authService;
  late final ClassService _classService;
  late final StudentService _studentService;

  List<AttendanceReport> _reportData = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole;
  int? _schoolId;
  String? _userId;

  DateTimeRange? _selectedDateRange;
  ReportType _reportType = ReportType.Monthly;

  List<app_class.SchoolClass> _classes = [];
  app_class.SchoolClass? _selectedClass;
  List<Student> _students = [];
  List<Student> _selectedStudents = [];

  @override
  void initState() {
    super.initState();
    _attendanceService = Provider.of<AttendanceService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _classService = Provider.of<ClassService>(context, listen: false);
    _studentService = Provider.of<StudentService>(context, listen: false);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      _userId = currentUser.id;
      _userRole = await _authService.getUserRole();
      _schoolId = await _authService.getCurrentUserSchoolId();
      if (_schoolId != null) {
        _loadClasses();
      }
      setState(() {});
    }
  }

  Future<void> _loadClasses() async {
    if (_schoolId == null) return;
    final classes = await _classService.getClasses(_schoolId!);
    if (_userRole == 'Admin') {
      classes.insert(0, app_class.SchoolClass(id: -1, name: 'Whole School', schoolId: _schoolId!));
    }
    setState(() {
      _classes = classes;
    });
  }

  Future<void> _loadStudents() async {
    if (_selectedClass == null) return;
    if (_selectedClass!.id == -1) {
      final students = await _studentService.getStudentsBySchool(_schoolId!);
      setState(() {
        _students = students;
      });
    } else {
      final students = await _studentService.getStudentsByClass(_selectedClass!.id!);
      setState(() {
        _students = students;
      });
    }
  }

  void _onDateRangeChanged(DateTimeRange? range) {
    setState(() {
      _selectedDateRange = range;
    });
  }

  void _onReportTypeChanged(ReportType type) {
    setState(() {
      _reportType = type;
    });
  }

  Future<void> _generateReport() async {
    if (_selectedDateRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date range.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<AttendanceReport> data = [];
      if (_userRole == 'Admin' && _schoolId != null) {
        data = await _attendanceService.getAttendanceForAdmin(
          _schoolId!,
          _selectedDateRange!.start,
          _selectedDateRange!.end,
          classId: _selectedClass?.id == -1 ? null : _selectedClass?.id,
          studentIds: (_selectedStudents.isNotEmpty ? _selectedStudents : _students).map((s) => s.id).toList(),
        );
      } else if (_userRole == 'Teacher' && _userId != null) {
        data = await _attendanceService.getAttendanceForTeacher(
          _userId!,
          _selectedDateRange!.start,
          _selectedDateRange!.end,
          classId: _selectedClass?.id,
          studentIds: (_selectedStudents.isNotEmpty ? _selectedStudents : _students).map((s) => s.id).toList(),
        );
      } else if (_userRole == 'Parent' && _userId != null) {
        data = await _attendanceService.getAttendanceForParent(_userId!, _selectedDateRange!.start, _selectedDateRange!.end);
      }
      setState(() {
        _reportData = data;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate report: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_userRole == 'Admin' || _userRole == 'Teacher') ...[
              DropdownButtonFormField<app_class.SchoolClass>(
                value: _selectedClass,
                hint: const Text('Select Class'),
                items: _classes.map((app_class.SchoolClass schoolClass) {
                  return DropdownMenuItem<app_class.SchoolClass>(
                    value: schoolClass,
                    child: Text(schoolClass.name),
                  );
                }).toList(),
                onChanged: (app_class.SchoolClass? newValue) {
                  setState(() {
                    _selectedClass = newValue;
                    _students = [];
                    _selectedStudents = [];
                  });
                  if (newValue != null) {
                    _loadStudents();
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_students.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedStudents.isEmpty
                      ? 'all'
                      : _selectedStudents.length == 1
                          ? _selectedStudents.first.id.toString()
                          : null, // Set to null if multiple students are selected
                  hint: const Text('Select Students'),
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: const Text('All Students'),
                      onTap: () {
                        setState(() {
                          _selectedStudents = List.from(_students);
                        });
                      },
                    ),
                    ..._students.map((Student student) {
                      return DropdownMenuItem<String>(
                        value: student.id.toString(),
                        child: Text(student.fullName),
                        onTap: () {
                          setState(() {
                            _selectedStudents = [student];
                          });
                        },
                      );
                    }),
                  ],
                  onChanged: (String? newValue) {
                    // The actual state change is handled by onTap
                  },
                ),
              const SizedBox(height: 16),
            ],
            DateRangeSelector(
              onDateRangeChanged: _onDateRangeChanged,
              onReportTypeChanged: _onReportTypeChanged,
              reportType: _reportType,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _generateReport,
              child: const Text('Generate Report'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
            else if (_reportData.isNotEmpty)
              Expanded(
                child: ReportDisplay(
                  reportData: _reportData,
                  dateRange: _selectedDateRange!,
                  students: _selectedStudents.isNotEmpty ? _selectedStudents : _students,
                ),
              )
            else
              const Center(child: Text('No data to display.')),
          ],
        ),
      ),
      floatingActionButton: _reportData.isNotEmpty
          ? ExportButton(reportData: _reportData)
          : null,
    );
  }
}
