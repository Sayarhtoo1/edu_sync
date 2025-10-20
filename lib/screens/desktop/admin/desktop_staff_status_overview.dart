import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class StaffAttendanceData {
  final app_user.User user;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? status;

  StaffAttendanceData({required this.user, this.checkInTime, this.checkOutTime, this.status});
}

class DesktopStaffStatusOverview extends StatefulWidget {
  const DesktopStaffStatusOverview({super.key});

  @override
  State<DesktopStaffStatusOverview> createState() => _DesktopStaffStatusOverviewState();
}

class _DesktopStaffStatusOverviewState extends State<DesktopStaffStatusOverview> {
  List<StaffAttendanceData> _staffList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  Future<void> _loadStaffData() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    
    if (schoolId != null) {
      final staff = await authService.getStaffBySchool(schoolId);
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final List<StaffAttendanceData> staffWithAttendance = [];
      
      for (var user in staff) {
        try {
          final attendanceData = await Supabase.instance.client
              .from('staff_attendance')
              .select()
              .eq('staff_id', user.id)
              .eq('school_id', schoolId)
              .gte('check_in_timestamp', startOfDay.toIso8601String())
              .maybeSingle();
          
          staffWithAttendance.add(StaffAttendanceData(
            user: user,
            checkInTime: attendanceData?['check_in_timestamp'] != null ? DateTime.parse(attendanceData!['check_in_timestamp']) : null,
            checkOutTime: attendanceData?['check_out_timestamp'] != null ? DateTime.parse(attendanceData!['check_out_timestamp']) : null,
            status: attendanceData?['status'],
          ));
        } catch (e) {
          staffWithAttendance.add(StaffAttendanceData(user: user));
        }
      }
      
      if (mounted) setState(() { _staffList = staffWithAttendance; _isLoading = false; });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaff = _staffList.where((s) => (s.user.fullName?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase())).toList();
    final presentCount = filteredStaff.where((s) => s.checkInTime != null && s.checkOutTime == null).length;
    final absentCount = filteredStaff.where((s) => s.checkInTime == null).length;
    final leftCount = filteredStaff.where((s) => s.checkOutTime != null).length;

    return DesktopScaffold(
      title: 'Staff Status Overview',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Present', presentCount, const Color(0xFF2ECC71), Icons.check_circle)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Absent', absentCount, const Color(0xFFE74C3C), Icons.cancel)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Left', leftCount, const Color(0xFFF39C12), Icons.logout)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search staff...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: filteredStaff.isEmpty
                        ? Center(child: Text('No staff found', style: TextStyle(color: Colors.grey[600])))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: filteredStaff.length,
                            itemBuilder: (context, index) => _buildStaffCard(filteredStaff[index]),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('$count', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStaffCard(StaffAttendanceData staffData) {
    final staff = staffData.user;
    final bool isClockedIn = staffData.checkInTime != null && staffData.checkOutTime == null;
    final bool hasClockedOut = staffData.checkOutTime != null;

    Color statusColor;
    String statusText;

    if (hasClockedOut) {
      statusColor = const Color(0xFFF39C12);
      statusText = 'Left';
    } else if (isClockedIn) {
      statusColor = const Color(0xFF2ECC71);
      statusText = 'Present';
    } else {
      statusColor = const Color(0xFFE74C3C);
      statusText = 'Absent';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundImage: staff.profilePhotoUrl != null ? NetworkImage(staff.profilePhotoUrl!) : null,
            child: staff.profilePhotoUrl == null ? const Icon(Icons.person, size: 32) : null,
          ),
          const SizedBox(height: 12),
          Text(staff.fullName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          if (staffData.checkInTime != null) ...[
            const SizedBox(height: 8),
            Text('In: ${DateFormat('hh:mm a').format(staffData.checkInTime!)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
