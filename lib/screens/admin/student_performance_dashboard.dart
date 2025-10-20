import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/attendance_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/exam_service.dart';

class StudentPerformanceDashboard extends StatefulWidget {
  const StudentPerformanceDashboard({super.key});

  @override
  State<StudentPerformanceDashboard> createState() => _StudentPerformanceDashboardState();
}

class _StudentPerformanceDashboardState extends State<StudentPerformanceDashboard> {
  bool _isLoading = true;
  int _totalStudents = 0;
  double _attendanceRate = 0.0;
  Map<String, int> _studentsByClass = {};
  Map<String, double> _subjectAverages = {};
  int _totalExams = 0;
  double _overallAverage = 0.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final studentService = context.read<StudentService>();
    final attendanceService = context.read<AttendanceService>();
    final classService = context.read<ClassService>();
    final examService = context.read<ExamService>();
    
    final schoolId = await authService.getCurrentUserSchoolId();
    if (schoolId != null) {
      // Get students
      final students = await studentService.getStudentsBySchool(schoolId);
      _totalStudents = students.length;
      
      // Calculate attendance
      final today = DateTime.now();
      final reports = await attendanceService.getAttendanceForAdmin(schoolId, today, today);
      final present = reports.where((r) => r.status == 'Present').length;
      _attendanceRate = _totalStudents > 0 ? (present / _totalStudents * 100) : 0;
      
      // Group students by class
      final classes = await classService.getClassesBySchoolId(schoolId);
      final classMap = {for (var c in classes) c.id: c.name};
      final classGroups = <String, int>{};
      for (final student in students) {
        final className = student.classId != null ? classMap[student.classId] ?? 'Unknown' : 'Unassigned';
        classGroups[className] = (classGroups[className] ?? 0) + 1;
      }
      _studentsByClass = classGroups;
      
      // Get exam data
      final exams = await examService.getExamsBySchoolId(schoolId);
      _totalExams = exams.length;
      
      // Calculate subject averages from exam marks
      final subjectPerformance = await examService.getSubjectPerformance(schoolId: schoolId);
      final subjectAverages = <String, double>{};
      
      for (final item in subjectPerformance.take(6)) {
        final subjectName = item['subject_name'] as String?;
        final avgPercentage = item['average_percentage'] as num?;
        if (subjectName != null && avgPercentage != null) {
          subjectAverages[subjectName] = avgPercentage.toDouble();
        }
      }
      _subjectAverages = subjectAverages;
      
      // Calculate overall average
      if (subjectAverages.isNotEmpty) {
        _overallAverage = subjectAverages.values.reduce((a, b) => a + b) / subjectAverages.length;
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Student Performance Dashboard'),
        backgroundColor: const Color(0xFF5B4FC4),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopStats(),
                  const SizedBox(height: 24),
                  if (_studentsByClass.isNotEmpty) _buildStudentDistribution(),
                  const SizedBox(height: 24),
                  if (_subjectAverages.isNotEmpty) _buildSubjectPerformance(),
                  const SizedBox(height: 24),
                  _buildExamStats(),
                ],
              ),
            ),
    );
  }

  Widget _buildTopStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.people_outline,
            _totalStudents.toString(),
            'Total Students',
            const Color(0xFF5B4FC4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.check_circle_outline,
            '${_attendanceRate.toStringAsFixed(1)}%',
            'Attendance Today',
            const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.assignment_outlined,
            _totalExams.toString(),
            'Total Exams',
            const Color(0xFF2196F3),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildStudentDistribution() {
    final chartData = _studentsByClass.entries.map((e) {
      return _ChartData(e.key, e.value, _getClassColor(e.key));
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Distribution by Class', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: SfCircularChart(
              legend: Legend(isVisible: true, position: LegendPosition.bottom, overflowMode: LegendItemOverflowMode.wrap),
              series: <CircularSeries>[
                DoughnutSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_ChartData data, _) => data.label,
                  yValueMapper: (_ChartData data, _) => data.value,
                  pointColorMapper: (_ChartData data, _) => data.color,
                  innerRadius: '60%',
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.outside,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPerformance() {
    final chartData = _subjectAverages.entries.map((e) {
      return _SubjectData(e.key, e.value);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Average Performance by Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(minimum: 0, maximum: 100, interval: 20),
              series: <CartesianSeries>[
                ColumnSeries<_SubjectData, String>(
                  dataSource: chartData,
                  xValueMapper: (_SubjectData data, _) => data.subject,
                  yValueMapper: (_SubjectData data, _) => data.average,
                  color: const Color(0xFF5B4FC4),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  dataLabelSettings: const DataLabelSettings(
                    isVisible: true,
                    textStyle: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Exam Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem('Total Exams', _totalExams.toString(), Icons.assignment, const Color(0xFF2196F3)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem('Overall Average', '${_overallAverage.toStringAsFixed(1)}%', Icons.trending_up, const Color(0xFF4CAF50)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
            ],
          ),
        ],
      ),
    );
  }

  Color _getClassColor(String className) {
    final colors = [
      const Color(0xFF5B4FC4),
      const Color(0xFF4FC4E9),
      const Color(0xFFE94FC4),
      const Color(0xFF4FE9C4),
      const Color(0xFFE9C44F),
      const Color(0xFFFF6B6B),
    ];
    return colors[className.hashCode % colors.length];
  }
}

class _ChartData {
  final String label;
  final int value;
  final Color color;
  _ChartData(this.label, this.value, this.color);
}

class _SubjectData {
  final String subject;
  final double average;
  _SubjectData(this.subject, this.average);
}
