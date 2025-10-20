import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class TeacherAttendanceData {
  final app_user.User user;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  TeacherAttendanceData({required this.user, this.checkInTime, this.checkOutTime});
}

class DesktopTeacherStatusOverview extends StatefulWidget {
  const DesktopTeacherStatusOverview({super.key});

  @override
  State<DesktopTeacherStatusOverview> createState() => _DesktopTeacherStatusOverviewState();
}

class _DesktopTeacherStatusOverviewState extends State<DesktopTeacherStatusOverview> {
  List<TeacherAttendanceData> _teacherList = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTeacherData();
  }

  Future<void> _loadTeacherData() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    
    if (schoolId != null) {
      final teachers = await authService.getUsersByRole(UserRole.Teacher, schoolId);
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      
      final List<TeacherAttendanceData> teachersWithAttendance = [];
      
      for (var user in teachers) {
        try {
          final attendanceData = await Supabase.instance.client
              .from('staff_attendance')
              .select()
              .eq('staff_id', user.id)
              .eq('school_id', schoolId)
              .gte('check_in_timestamp', startOfDay.toIso8601String())
              .maybeSingle();
          
          teachersWithAttendance.add(TeacherAttendanceData(
            user: user,
            checkInTime: attendanceData?['check_in_timestamp'] != null ? DateTime.parse(attendanceData!['check_in_timestamp']) : null,
            checkOutTime: attendanceData?['check_out_timestamp'] != null ? DateTime.parse(attendanceData!['check_out_timestamp']) : null,
          ));
        } catch (e) {
          teachersWithAttendance.add(TeacherAttendanceData(user: user));
        }
      }
      
      if (mounted) setState(() { _teacherList = teachersWithAttendance; _isLoading = false; });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTeachers = _teacherList.where((t) => (t.user.fullName?.toLowerCase() ?? '').contains(_searchQuery.toLowerCase())).toList();
    final presentCount = filteredTeachers.where((t) => t.checkInTime != null && t.checkOutTime == null).length;
    final absentCount = filteredTeachers.where((t) => t.checkInTime == null).length;
    final leftCount = filteredTeachers.where((t) => t.checkOutTime != null).length;

    return DesktopScaffold(
      title: 'Teacher Status Overview',
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
                      hintText: 'Search teachers...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: filteredTeachers.isEmpty
                        ? Center(child: Text('No teachers found', style: TextStyle(color: Colors.grey[600])))
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 1.5,
                            ),
                            itemCount: filteredTeachers.length,
                            itemBuilder: (context, index) => _buildTeacherCard(filteredTeachers[index]),
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

  Widget _buildTeacherCard(TeacherAttendanceData teacherData) {
    final teacher = teacherData.user;
    final bool isClockedIn = teacherData.checkInTime != null && teacherData.checkOutTime == null;
    final bool hasClockedOut = teacherData.checkOutTime != null;

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
            backgroundImage: teacher.profilePhotoUrl != null ? NetworkImage(teacher.profilePhotoUrl!) : null,
            child: teacher.profilePhotoUrl == null ? const Icon(Icons.person, size: 32) : null,
          ),
          const SizedBox(height: 12),
          Text(teacher.fullName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          if (teacherData.checkInTime != null) ...[
            const SizedBox(height: 8),
            Text('In: ${DateFormat('hh:mm a').format(teacherData.checkInTime!)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
