import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class DesktopStaffAttendanceSummary extends StatefulWidget {
  const DesktopStaffAttendanceSummary({super.key});

  @override
  State<DesktopStaffAttendanceSummary> createState() => _DesktopStaffAttendanceSummaryState();
}

class _DesktopStaffAttendanceSummaryState extends State<DesktopStaffAttendanceSummary> {
  List<Map<String, dynamic>> _attendanceData = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAttendanceData();
  }

  Future<void> _loadAttendanceData() async {
    setState(() => _isLoading = true);
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    
    if (schoolId != null) {
      final startOfDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      try {
        final data = await Supabase.instance.client
            .from('staff_attendance')
            .select('*, users!staff_id(full_name, profile_photo_url)')
            .eq('school_id', schoolId)
            .gte('check_in_timestamp', startOfDay.toIso8601String())
            .lt('check_in_timestamp', endOfDay.toIso8601String())
            .order('check_in_timestamp');
        
        if (mounted) setState(() { _attendanceData = List<Map<String, dynamic>>.from(data); _isLoading = false; });
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _loadAttendanceData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _attendanceData.where((a) => a['check_out_timestamp'] == null).length;
    final leftCount = _attendanceData.where((a) => a['check_out_timestamp'] != null).length;

    return DesktopScaffold(
      title: 'Staff Attendance Summary',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Color(0xFF3498DB)),
                                const SizedBox(width: 12),
                                Text(DateFormat('MMMM dd, yyyy').format(_selectedDate), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      _buildStatCard('Present', presentCount, const Color(0xFF2ECC71)),
                      const SizedBox(width: 16),
                      _buildStatCard('Left', leftCount, const Color(0xFFF39C12)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _attendanceData.isEmpty
                        ? Center(child: Text('No attendance records', style: TextStyle(color: Colors.grey[600])))
                        : _buildAttendanceTable(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAttendanceTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Staff Name', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Check In', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Check Out', style: TextStyle(fontWeight: FontWeight.bold))),
                Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _attendanceData.length,
              itemBuilder: (context, index) {
                final record = _attendanceData[index];
                final user = record['users'];
                final checkIn = record['check_in_timestamp'] != null ? DateTime.parse(record['check_in_timestamp']) : null;
                final checkOut = record['check_out_timestamp'] != null ? DateTime.parse(record['check_out_timestamp']) : null;
                final status = checkOut != null ? 'Left' : 'Present';
                final statusColor = checkOut != null ? const Color(0xFFF39C12) : const Color(0xFF2ECC71);

                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: user?['profile_photo_url'] != null ? NetworkImage(user['profile_photo_url']) : null,
                              child: user?['profile_photo_url'] == null ? const Icon(Icons.person, size: 20) : null,
                            ),
                            const SizedBox(width: 12),
                            Text(user?['full_name'] ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(child: Text(checkIn != null ? DateFormat('hh:mm a').format(checkIn) : '-')),
                      Expanded(child: Text(checkOut != null ? DateFormat('hh:mm a').format(checkOut) : '-')),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
                        ),
                      ),
                    ],
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
