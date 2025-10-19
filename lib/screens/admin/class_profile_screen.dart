import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:edu_sync/models/school_class.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/attendance_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:intl/intl.dart';

class ClassProfileScreen extends StatefulWidget {
  final SchoolClass schoolClass;

  const ClassProfileScreen({super.key, required this.schoolClass});

  @override
  State<ClassProfileScreen> createState() => _ClassProfileScreenState();
}

class _ClassProfileScreenState extends State<ClassProfileScreen> {
  bool _isLoading = true;
  int _totalStudents = 0;
  int _maleStudents = 0;
  int _femaleStudents = 0;
  app_user.User? _teacher;
  
  // Yesterday attendance
  int _yesterdayPresent = 0;
  int _yesterdayAbsent = 0;
  int _yesterdayLate = 0;
  List<String> _yesterdayAbsentStudents = [];
  
  // Today attendance
  int _todayPresent = 0;
  int _todayAbsent = 0;
  int _todayLate = 0;
  List<String> _todayAbsentStudents = [];
  bool _todayRecorded = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final studentService = context.read<StudentService>();
    final authService = context.read<AuthService>();
    final attendanceService = context.read<AttendanceService>();
    
    // Get students
    final students = await studentService.getStudentsByClass(widget.schoolClass.id!);
    _totalStudents = students.length;
    _maleStudents = students.where((s) => s.gender?.toLowerCase() == 'male').length;
    _femaleStudents = students.where((s) => s.gender?.toLowerCase() == 'female').length;
    
    // Get teacher
    if (widget.schoolClass.teacherId != null) {
      _teacher = await authService.getUserById(widget.schoolClass.teacherId!);
    }
    
    // Get yesterday attendance
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayAttendance = await attendanceService.getAttendanceForClassByDate(widget.schoolClass.id!, yesterday);
    _yesterdayPresent = yesterdayAttendance.where((a) => a.status.toLowerCase() == 'present').length;
    _yesterdayAbsent = yesterdayAttendance.where((a) => a.status.toLowerCase() == 'absent').length;
    _yesterdayLate = yesterdayAttendance.where((a) => a.status.toLowerCase() == 'late').length;
    
    // Get absent student names for yesterday
    final yesterdayAbsentIds = yesterdayAttendance.where((a) => a.status.toLowerCase() == 'absent' || a.status.toLowerCase() == 'leave').map((a) => a.studentId).toList();
    _yesterdayAbsentStudents = students.where((s) => yesterdayAbsentIds.contains(s.id)).map((s) => s.fullName).toList();
    
    // Get today attendance
    final today = DateTime.now();
    final todayAttendance = await attendanceService.getAttendanceForClassByDate(widget.schoolClass.id!, today);
    _todayRecorded = todayAttendance.isNotEmpty;
    _todayPresent = todayAttendance.where((a) => a.status.toLowerCase() == 'present').length;
    _todayAbsent = todayAttendance.where((a) => a.status.toLowerCase() == 'absent').length;
    _todayLate = todayAttendance.where((a) => a.status.toLowerCase() == 'late').length;
    
    // Get absent student names for today
    final todayAbsentIds = todayAttendance.where((a) => a.status.toLowerCase() == 'absent' || a.status.toLowerCase() == 'leave').map((a) => a.studentId).toList();
    _todayAbsentStudents = students.where((s) => todayAbsentIds.contains(s.id)).map((s) => s.fullName).toList();
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF9C27B0),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.schoolClass.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF9C27B0), const Color(0xFF9C27B0).withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(Icons.class_rounded, size: 80, color: Colors.white.withOpacity(0.3)),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator()))
                : Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoCard(),
                        const SizedBox(height: 16),
                        _buildStatsCards(),
                        const SizedBox(height: 16),
                        _buildAttendanceSection(),
                        const SizedBox(height: 16),
                        _buildGenderChart(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.info_outline, color: Color(0xFF9C27B0), size: 24),
              ),
              const SizedBox(width: 12),
              const Text('Class Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(Icons.class_rounded, 'Class Name', widget.schoolClass.name),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.person_outline, 'Class Teacher', _teacher?.fullName ?? 'Not Assigned', 
            color: _teacher != null ? Colors.green : Colors.orange),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.groups_rounded, 'Total Students', '$_totalStudents Students'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 2),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total', _totalStudents, const Color(0xFF2196F3), Icons.groups)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Male', _maleStudents, const Color(0xFF4CAF50), Icons.male)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Female', _femaleStudents, const Color(0xFFE91E63), Icons.female)),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(value.toString(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text('Attendance Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Row(
          children: [
            Expanded(child: _buildAttendanceCard('Yesterday', _yesterdayPresent, _yesterdayAbsent, _yesterdayLate, _yesterdayAbsentStudents, const Color(0xFFFF9800), true)),
            const SizedBox(width: 12),
            Expanded(child: _buildAttendanceCard('Today', _todayPresent, _todayAbsent, _todayLate, _todayAbsentStudents, const Color(0xFF2196F3), _todayRecorded)),
          ],
        ),
        const SizedBox(height: 16),
        if (_todayRecorded) _buildAttendanceChart(),
      ],
    );
  }
  
  Widget _buildAttendanceCard(String label, int present, int absent, int late, List<String> absentStudents, Color color, bool recorded) {
    if (!recorded) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, color: Colors.grey[600], size: 48),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Not Recorded Yet', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }
    
    final total = present + absent + late;
    final percentage = total > 0 ? (present / total * 100).toStringAsFixed(1) : '0.0';
    
    return InkWell(
      onTap: absentStudents.isNotEmpty ? () => _showAbsentStudents(label, absentStudents) : null,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 8),
                Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 16),
            Text('$percentage%', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            const Text('Attendance Rate', style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAttendanceStat(Icons.check_circle, present, 'Present'),
                _buildAttendanceStat(Icons.cancel, absent, 'Absent'),
                _buildAttendanceStat(Icons.access_time, late, 'Late'),
              ],
            ),
            if (absentStudents.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Tap to see absent',
                        style: TextStyle(color: Colors.white, fontSize: 9),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  void _showAbsentStudents(String day, List<String> students) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person_off, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Text('Absent Students - $day', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ...students.map((name) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.red),
                  const SizedBox(width: 12),
                  Text(name, style: const TextStyle(fontSize: 15)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAttendanceStat(IconData icon, int value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
  
  Widget _buildAttendanceChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Attendance Comparison', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              primaryYAxis: NumericAxis(minimum: 0, interval: _totalStudents > 10 ? 5 : 2),
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              series: <CartesianSeries>[
                ColumnSeries<_AttendanceData, String>(
                  name: 'Present',
                  dataSource: [
                    _AttendanceData('Yesterday', _yesterdayPresent),
                    _AttendanceData('Today', _todayPresent),
                  ],
                  xValueMapper: (_AttendanceData data, _) => data.day,
                  yValueMapper: (_AttendanceData data, _) => data.value,
                  color: const Color(0xFF4CAF50),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                ColumnSeries<_AttendanceData, String>(
                  name: 'Absent',
                  dataSource: [
                    _AttendanceData('Yesterday', _yesterdayAbsent),
                    _AttendanceData('Today', _todayAbsent),
                  ],
                  xValueMapper: (_AttendanceData data, _) => data.day,
                  yValueMapper: (_AttendanceData data, _) => data.value,
                  color: const Color(0xFFF44336),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                ColumnSeries<_AttendanceData, String>(
                  name: 'Late',
                  dataSource: [
                    _AttendanceData('Yesterday', _yesterdayLate),
                    _AttendanceData('Today', _todayLate),
                  ],
                  xValueMapper: (_AttendanceData data, _) => data.day,
                  yValueMapper: (_AttendanceData data, _) => data.value,
                  color: const Color(0xFFFF9800),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderChart() {
    if (_totalStudents == 0) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Gender Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          SizedBox(
            height: 250,
            child: SfCircularChart(
              legend: Legend(isVisible: true, position: LegendPosition.bottom),
              series: <CircularSeries>[
                PieSeries<_ChartData, String>(
                  dataSource: [
                    _ChartData('Male', _maleStudents, const Color(0xFF4CAF50)),
                    _ChartData('Female', _femaleStudents, const Color(0xFFE91E63)),
                  ],
                  xValueMapper: (_ChartData data, _) => data.label,
                  yValueMapper: (_ChartData data, _) => data.value,
                  pointColorMapper: (_ChartData data, _) => data.color,
                  dataLabelSettings: const DataLabelSettings(isVisible: true, textStyle: TextStyle(fontWeight: FontWeight.bold)),
                  explode: true,
                  explodeIndex: 0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  final String label;
  final int value;
  final Color color;

  _ChartData(this.label, this.value, this.color);
}

class _AttendanceData {
  final String day;
  final int value;

  _AttendanceData(this.day, this.value);
}
