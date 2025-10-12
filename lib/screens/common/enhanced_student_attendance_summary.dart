import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../services/class_service.dart';
import '../../services/student_service.dart';
import '../../providers/school_provider.dart';
import '../../models/school_class.dart' as app_class;
import '../../models/student.dart';

class EnhancedStudentAttendanceSummary extends StatefulWidget {
  const EnhancedStudentAttendanceSummary({super.key});

  @override
  State<EnhancedStudentAttendanceSummary> createState() => _EnhancedStudentAttendanceSummaryState();
}

class _EnhancedStudentAttendanceSummaryState extends State<EnhancedStudentAttendanceSummary> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  List<Map<String, dynamic>> _attendanceData = [];
  Map<String, dynamic>? _summary;
  
  app_class.SchoolClass? _selectedClass;
  List<app_class.SchoolClass> _classes = [];
  Student? _selectedStudent;
  List<Student> _students = [];

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final schoolProvider = context.read<SchoolProvider>();
    final classService = context.read<ClassService>();
    final schoolId = schoolProvider.currentSchool?.id;
    
    if (schoolId == null) return;

    final classes = await classService.getClasses(schoolId);
    setState(() {
      _classes = classes;
    });
  }

  Future<void> _loadStudents() async {
    if (_selectedClass == null) return;
    
    final studentService = context.read<StudentService>();
    final students = await studentService.getStudentsByClass(_selectedClass!.id!);
    
    setState(() {
      _students = students;
      _selectedStudent = null;
    });
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    try {
      final attendanceService = context.read<AttendanceService>();
      final authService = context.read<AuthService>();
      final schoolProvider = context.read<SchoolProvider>();
      
      final schoolId = schoolProvider.currentSchool?.id;
      final userRole = await authService.getUserRole();
      
      if (schoolId == null) return;

      List<Map<String, dynamic>> data = [];
      
      if (_selectedStudent != null) {
        // Load for specific student
        final attendance = await attendanceService.getAttendanceForStudent(_selectedStudent!.id);
        data = _processStudentAttendance(attendance);
      } else if (_selectedClass != null) {
        // Load for class
        final reportData = await attendanceService.getAttendanceForAdmin(
          schoolId,
          _startDate,
          _endDate,
          classId: _selectedClass!.id,
        );
        data = _processReportData(reportData);
      }

      setState(() {
        _attendanceData = data;
        _summary = _calculateSummary(data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _processStudentAttendance(List attendance) {
    final Map<String, Map<String, dynamic>> studentMap = {};
    
    for (var record in attendance) {
      final date = record.date;
      if (date.isBefore(_startDate) || date.isAfter(_endDate)) continue;
      
      final key = 'student_${record.studentId}';
      if (!studentMap.containsKey(key)) {
        studentMap[key] = {
          'student_name': _selectedStudent?.fullName ?? 'Unknown',
          'present': 0,
          'absent': 0,
          'late': 0,
          'excused': 0,
        };
      }
      
      final status = record.status.toLowerCase();
      if (status == 'present') {
        studentMap[key]!['present'] = (studentMap[key]!['present'] as int) + 1;
      } else if (status == 'absent') {
        studentMap[key]!['absent'] = (studentMap[key]!['absent'] as int) + 1;
      } else if (status == 'late') {
        studentMap[key]!['late'] = (studentMap[key]!['late'] as int) + 1;
      } else if (status == 'excused') {
        studentMap[key]!['excused'] = (studentMap[key]!['excused'] as int) + 1;
      }
    }
    
    return studentMap.values.toList();
  }

  List<Map<String, dynamic>> _processReportData(List reportData) {
    final Map<String, Map<String, dynamic>> studentMap = {};
    
    for (var record in reportData) {
      final key = record.studentName;
      if (!studentMap.containsKey(key)) {
        studentMap[key] = {
          'student_name': record.studentName,
          'present': 0,
          'absent': 0,
          'late': 0,
          'excused': 0,
        };
      }
      
      final status = record.status.toLowerCase();
      if (status == 'present') {
        studentMap[key]!['present'] = (studentMap[key]!['present'] as int) + 1;
      } else if (status == 'absent') {
        studentMap[key]!['absent'] = (studentMap[key]!['absent'] as int) + 1;
      } else if (status == 'late') {
        studentMap[key]!['late'] = (studentMap[key]!['late'] as int) + 1;
      } else if (status == 'excused') {
        studentMap[key]!['excused'] = (studentMap[key]!['excused'] as int) + 1;
      }
    }
    
    return studentMap.values.toList();
  }

  Map<String, dynamic> _calculateSummary(List<Map<String, dynamic>> data) {
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLate = 0;
    int totalExcused = 0;
    
    for (var student in data) {
      totalPresent += (student['present'] as int?) ?? 0;
      totalAbsent += (student['absent'] as int?) ?? 0;
      totalLate += (student['late'] as int?) ?? 0;
      totalExcused += (student['excused'] as int?) ?? 0;
    }

    final totalDays = totalPresent + totalAbsent + totalLate + totalExcused;
    
    return {
      'total_students': data.length,
      'total_present': totalPresent,
      'total_absent': totalAbsent,
      'total_late': totalLate,
      'total_excused': totalExcused,
      'attendance_rate': totalDays > 0 ? (totalPresent / totalDays * 100) : 0.0,
    };
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      if (_selectedClass != null) {
        _loadAttendance();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Student Attendance Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _selectedClass != null ? _loadAttendance : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
            const SizedBox(height: 16),
            _buildDateRangeCard(),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_summary != null) ...[
              _buildSummaryCards(),
              const SizedBox(height: 16),
              _buildChart(),
              const SizedBox(height: 16),
              _buildStudentList(),
            ] else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: Text('Select class and generate report')),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            DropdownButtonFormField<app_class.SchoolClass>(
              value: _selectedClass,
              decoration: const InputDecoration(
                labelText: 'Select Class',
                border: OutlineInputBorder(),
              ),
              items: _classes.map((c) {
                return DropdownMenuItem(value: c, child: Text(c.name));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedClass = value;
                  _selectedStudent = null;
                  _students = [];
                });
                if (value != null) {
                  _loadStudents();
                  _loadAttendance();
                }
              },
            ),
            if (_students.isNotEmpty) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<Student>(
                value: _selectedStudent,
                decoration: const InputDecoration(
                  labelText: 'Select Student (Optional)',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Students')),
                  ..._students.map((s) {
                    return DropdownMenuItem(value: s, child: Text(s.fullName));
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStudent = value;
                  });
                  _loadAttendance();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateRangeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF1976D2)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        '${DateFormat('MMM dd, yyyy').format(_startDate)} - ${DateFormat('MMM dd, yyyy').format(_endDate)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: _selectDateRange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _startDate.month,
                    decoration: const InputDecoration(
                      labelText: 'Month',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(12, (index) {
                      final month = index + 1;
                      return DropdownMenuItem(
                        value: month,
                        child: Text(DateFormat('MMMM').format(DateTime(2024, month))),
                      );
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _startDate = DateTime(_startDate.year, value, 1);
                          _endDate = DateTime(_startDate.year, value + 1, 0);
                        });
                        _loadAttendance();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _startDate.year,
                    decoration: const InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: List.generate(5, (index) {
                      final year = DateTime.now().year - index;
                      return DropdownMenuItem(value: year, child: Text(year.toString()));
                    }),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _startDate = DateTime(value, _startDate.month, 1);
                          _endDate = DateTime(value, _startDate.month + 1, 0);
                        });
                        _loadAttendance();
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Column(
      children: [
        _buildSummaryCard(
          'Total Students',
          _summary!['total_students'].toString(),
          Icons.people,
          const Color(0xFF2196F3),
        ),
        const SizedBox(height: 12),
        _buildSummaryCard(
          'Attendance Rate',
          '${_summary!['attendance_rate'].toStringAsFixed(1)}%',
          Icons.check_circle,
          const Color(0xFF4CAF50),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                'Present',
                _summary!['total_present'].toString(),
                Icons.check,
                const Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                'Absent',
                _summary!['total_absent'].toString(),
                Icons.close,
                const Color(0xFFF44336),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    if (_summary == null) return const SizedBox();

    final chartData = [
      _ChartData('Present', _summary!['total_present'].toDouble(), const Color(0xFF4CAF50)),
      _ChartData('Absent', _summary!['total_absent'].toDouble(), const Color(0xFFF44336)),
      _ChartData('Late', _summary!['total_late'].toDouble(), const Color(0xFFFF9800)),
      _ChartData('Excused', _summary!['total_excused'].toDouble(), const Color(0xFF2196F3)),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Attendance Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCircularChart(
                legend: Legend(isVisible: true, position: LegendPosition.bottom),
                series: <CircularSeries>[
                  DoughnutSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (data, _) => data.category,
                    yValueMapper: (data, _) => data.value,
                    pointColorMapper: (data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList() {
    if (_attendanceData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No attendance data available')),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Student Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attendanceData.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final student = _attendanceData[index];
              return _buildStudentTile(student);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStudentTile(Map<String, dynamic> student) {
    final present = student['present'] ?? 0;
    final absent = student['absent'] ?? 0;
    final late = student['late'] ?? 0;
    final totalDays = present + absent + late;
    final attendanceRate = totalDays > 0 ? (present / totalDays * 100) : 0.0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: attendanceRate >= 80 ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
        child: Text(
          '${attendanceRate.toStringAsFixed(0)}%',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(student['student_name'] ?? 'Unknown'),
      subtitle: Text('P: $present | A: $absent | L: $late'),
      trailing: Icon(
        attendanceRate >= 80 ? Icons.check_circle : Icons.warning,
        color: attendanceRate >= 80 ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
      ),
    );
  }
}

class _ChartData {
  final String category;
  final double value;
  final Color color;

  _ChartData(this.category, this.value, this.color);
}
