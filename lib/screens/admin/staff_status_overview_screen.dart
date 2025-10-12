import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../providers/school_provider.dart';
import '../../models/user.dart' as app_user;

class StaffAttendanceData {
  final app_user.User user;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String? status;

  StaffAttendanceData({
    required this.user,
    this.checkInTime,
    this.checkOutTime,
    this.status,
  });
}

class StaffStatusOverviewScreen extends StatefulWidget {
  const StaffStatusOverviewScreen({super.key});

  @override
  State<StaffStatusOverviewScreen> createState() => _StaffStatusOverviewScreenState();
}

class _StaffStatusOverviewScreenState extends State<StaffStatusOverviewScreen> {
  List<StaffAttendanceData> _staffList = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

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
            checkInTime: attendanceData?['check_in_timestamp'] != null
                ? DateTime.parse(attendanceData!['check_in_timestamp'])
                : null,
            checkOutTime: attendanceData?['check_out_timestamp'] != null
                ? DateTime.parse(attendanceData!['check_out_timestamp'])
                : null,
            status: attendanceData?['status'],
          ));
        } catch (e) {
          staffWithAttendance.add(StaffAttendanceData(user: user));
        }
      }
      
      if (mounted) {
        setState(() {
          _staffList = staffWithAttendance;
          _isLoading = false;
        });
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStaff = _staffList.where((staffData) {
      final name = staffData.user.fullName?.toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    final presentCount = filteredStaff.where((s) => s.checkInTime != null && s.checkOutTime == null).length;
    final absentCount = filteredStaff.where((s) => s.checkInTime == null).length;
    final leftCount = filteredStaff.where((s) => s.checkOutTime != null).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Staff Status Overview', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStaffData,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _buildStatCard('Present', presentCount, const Color(0xFF4CAF50), Icons.check_circle)),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        Expanded(child: _buildStatCard('Absent', absentCount, const Color(0xFFF44336), Icons.cancel)),
                        Container(width: 1, height: 40, color: Colors.grey[300]),
                        Expanded(child: _buildStatCard('Left', leftCount, const Color(0xFFFF9800), Icons.logout)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search staff...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: filteredStaff.isEmpty
                        ? Center(child: Text('No staff found', style: TextStyle(color: Colors.grey[600])))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredStaff.length,
                            itemBuilder: (context, index) {
                              final staffData = filteredStaff[index];
                              return _buildStaffCard(staffData);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text('$count', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStaffCard(StaffAttendanceData staffData) {
    final staff = staffData.user;
    final bool isClockedIn = staffData.checkInTime != null && staffData.checkOutTime == null;
    final bool hasClockedOut = staffData.checkOutTime != null;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (hasClockedOut) {
      statusColor = const Color(0xFFFF9800);
      statusText = 'Left';
      statusIcon = Icons.logout;
    } else if (isClockedIn) {
      statusColor = const Color(0xFF4CAF50);
      statusText = 'Present';
      statusIcon = Icons.check_circle;
    } else {
      statusColor = const Color(0xFFF44336);
      statusText = 'Absent';
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: staff.profilePhotoUrl != null ? NetworkImage(staff.profilePhotoUrl!) : null,
              child: staff.profilePhotoUrl == null ? const Icon(Icons.person, size: 28) : null,
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(staff.fullName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 4),
                Text(statusText, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
              ],
            ),
            if (staffData.checkInTime != null) ...[
              const SizedBox(height: 4),
              Text('In: ${DateFormat('hh:mm a').format(staffData.checkInTime!)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
            if (staffData.checkOutTime != null) ...[
              const SizedBox(height: 2),
              Text('Out: ${DateFormat('hh:mm a').format(staffData.checkOutTime!)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ],
        ),
        trailing: Text(staff.role, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
