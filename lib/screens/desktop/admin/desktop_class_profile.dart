import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:edu_sync/models/school_class.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/attendance_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;

class DesktopClassProfile extends StatefulWidget {
  final SchoolClass schoolClass;

  const DesktopClassProfile({super.key, required this.schoolClass});

  @override
  State<DesktopClassProfile> createState() => _DesktopClassProfileState();
}

class _DesktopClassProfileState extends State<DesktopClassProfile> {
  bool _isLoading = true;
  int _totalStudents = 0;
  int _maleStudents = 0;
  int _femaleStudents = 0;
  app_user.User? _teacher;
  
  int _yesterdayPresent = 0, _yesterdayAbsent = 0, _yesterdayLate = 0;
  int _todayPresent = 0, _todayAbsent = 0, _todayLate = 0;
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
    
    final students = await studentService.getStudentsByClass(widget.schoolClass.id!);
    _totalStudents = students.length;
    _maleStudents = students.where((s) => s.gender?.toLowerCase() == 'male').length;
    _femaleStudents = students.where((s) => s.gender?.toLowerCase() == 'female').length;
    
    if (widget.schoolClass.teacherId != null) {
      _teacher = await authService.getUserById(widget.schoolClass.teacherId!);
    }
    
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayAttendance = await attendanceService.getAttendanceForClassByDate(widget.schoolClass.id!, yesterday);
    _yesterdayPresent = yesterdayAttendance.where((a) => a.status.toLowerCase() == 'present').length;
    _yesterdayAbsent = yesterdayAttendance.where((a) => a.status.toLowerCase() == 'absent').length;
    _yesterdayLate = yesterdayAttendance.where((a) => a.status.toLowerCase() == 'late').length;
    
    final today = DateTime.now();
    final todayAttendance = await attendanceService.getAttendanceForClassByDate(widget.schoolClass.id!, today);
    _todayRecorded = todayAttendance.isNotEmpty;
    _todayPresent = todayAttendance.where((a) => a.status.toLowerCase() == 'present').length;
    _todayAbsent = todayAttendance.where((a) => a.status.toLowerCase() == 'absent').length;
    _todayLate = todayAttendance.where((a) => a.status.toLowerCase() == 'late').length;
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.schoolClass.name),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column - Class Info & Stats
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildInfoCard(),
                          const SizedBox(height: 20),
                          _buildStatsCards(),
                          const SizedBox(height: 20),
                          _buildGenderChart(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right Column - Attendance
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildAttendanceCard('Yesterday', _yesterdayPresent, _yesterdayAbsent, _yesterdayLate, const Color(0xFFF39C12), true),
                          const SizedBox(height: 20),
                          _buildAttendanceCard('Today', _todayPresent, _todayAbsent, _todayLate, const Color(0xFF3498DB), _todayRecorded),
                          if (_todayRecorded) ...[
                            const SizedBox(height: 20),
                            _buildAttendanceChart(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.class_rounded, color: Color(0xFF9B59B6), size: 24),
              SizedBox(width: 8),
              Text('Class Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Class Name', widget.schoolClass.name, Icons.class_rounded),
          _buildInfoRow('Class Teacher', _teacher?.fullName ?? 'Not Assigned', Icons.person_outline),
          _buildInfoRow('Total Students', '$_totalStudents Students', Icons.groups_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Total', _totalStudents, const Color(0xFF3498DB), Icons.groups)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Male', _maleStudents, const Color(0xFF2ECC71), Icons.male)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Female', _femaleStudents, const Color(0xFFE74C3C), Icons.female)),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(value.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(String label, int present, int absent, int late, Color color, bool recorded) {
    if (!recorded) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(Icons.event_busy, color: Colors.grey[600], size: 48),
            const SizedBox(height: 12),
            Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text('Not Recorded Yet', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }

    final total = present + absent + late;
    final percentage = total > 0 ? (present / total * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 20),
          Text('$percentage%', style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
          const Text('Attendance Rate', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAttendanceStat(Icons.check_circle, present, 'Present'),
              _buildAttendanceStat(Icons.cancel, absent, 'Absent'),
              _buildAttendanceStat(Icons.access_time, late, 'Late'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(IconData icon, int value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(value.toString(), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildAttendanceChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
              primaryYAxis: NumericAxis(minimum: 0),
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
                  color: const Color(0xFF2ECC71),
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
                  color: const Color(0xFFE74C3C),
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
                  color: const Color(0xFFF39C12),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
                    _ChartData('Male', _maleStudents, const Color(0xFF2ECC71)),
                    _ChartData('Female', _femaleStudents, const Color(0xFFE74C3C)),
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
