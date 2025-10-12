import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/attendance_service.dart';
import '../../services/auth_service.dart';
import '../../providers/school_provider.dart';

class StaffAttendanceSummaryScreen extends StatefulWidget {
  const StaffAttendanceSummaryScreen({super.key});

  @override
  State<StaffAttendanceSummaryScreen> createState() => _StaffAttendanceSummaryScreenState();
}

class _StaffAttendanceSummaryScreenState extends State<StaffAttendanceSummaryScreen> {
  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _endDate = DateTime.now();
  bool _isLoading = false;
  List<Map<String, dynamic>> _attendanceData = [];
  Map<String, dynamic>? _summary;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _isLoading = true);
    try {
      final schoolProvider = context.read<SchoolProvider>();
      final attendanceService = context.read<AttendanceService>();
      
      final schoolId = schoolProvider.currentSchool?.id;
      if (schoolId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('School not found')),
          );
        }
        return;
      }

      final data = await attendanceService.getStaffAttendanceSummary(
        schoolId: schoolId,
        startDate: _startDate,
        endDate: _endDate,
      );

      setState(() {
        _attendanceData = data;
        _summary = _calculateSummary(data);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic> _calculateSummary(List<Map<String, dynamic>> data) {
    int totalPresent = 0;
    int totalAbsent = 0;
    int totalLate = 0;
    
    for (var staff in data) {
      totalPresent += (staff['present_days'] as int?) ?? 0;
      totalAbsent += (staff['absent_days'] as int?) ?? 0;
      totalLate += (staff['late_days'] as int?) ?? 0;
    }

    return {
      'total_staff': data.length,
      'total_present': totalPresent,
      'total_absent': totalAbsent,
      'total_late': totalLate,
      'attendance_rate': data.isEmpty ? 0.0 : (totalPresent / (totalPresent + totalAbsent) * 100),
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
      _loadAttendance();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Staff Attendance Summary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendance,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAttendance,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateRangeCard(),
                    const SizedBox(height: 16),
                    if (_summary != null) _buildSummaryCards(),
                    const SizedBox(height: 16),
                    _buildStaffList(),
                  ],
                ),
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
          'Total Staff',
          _summary!['total_staff'].toString(),
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

  Widget _buildStaffList() {
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
            child: Text(
              'Staff Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _attendanceData.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final staff = _attendanceData[index];
              return _buildStaffTile(staff);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStaffTile(Map<String, dynamic> staff) {
    final presentDays = staff['present_days'] ?? 0;
    final absentDays = staff['absent_days'] ?? 0;
    final lateDays = staff['late_days'] ?? 0;
    final totalDays = presentDays + absentDays;
    final attendanceRate = totalDays > 0 ? (presentDays / totalDays * 100) : 0.0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: attendanceRate >= 80 ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
        child: Text(
          '${attendanceRate.toStringAsFixed(0)}%',
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(staff['full_name'] ?? 'Unknown'),
      subtitle: Text('Role: ${staff['role'] ?? 'N/A'}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('P: $presentDays', style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
          Text('A: $absentDays', style: const TextStyle(color: Color(0xFFF44336))),
        ],
      ),
    );
  }
}
