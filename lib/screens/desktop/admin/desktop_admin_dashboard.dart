import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/attendance_service.dart';
import 'package:edu_sync/services/announcement_service.dart';
import 'package:edu_sync/services/finance_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/screens/admin/admin_panel_state.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/staff/staff_attendance_screen.dart';
import 'package:edu_sync/screens/admin/finance/finance_overview_screen.dart';
import 'package:edu_sync/models/announcement.dart';
import 'dart:async';

class DesktopAdminDashboard extends StatefulWidget {
  const DesktopAdminDashboard({super.key});

  @override
  State<DesktopAdminDashboard> createState() => _DesktopAdminDashboardState();
}

class _DesktopAdminDashboardState extends State<DesktopAdminDashboard>
    with AdminPanelStateMixin<DesktopAdminDashboard> {
  Timer? _refreshTimer;
  String? _adminName;
  String? _schoolName;
  List<Announcement> _recentAnnouncements = [];
  Map<String, int> _studentAttendance = {};
  List<Map<String, dynamic>> _staffAttendance = [];
  List<FinancialDataPoint> _financeData = [];
  bool _loadingAnnouncements = false;
  bool _loadingStudentAttendance = false;
  bool _loadingStaffAttendance = false;
  bool _loadingFinance = false;

  @override
  void initState() {
    super.initState();
    initializeServices(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      startScheduleTimer();
      _startRefreshTimer();
    });
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (mounted) _loadData();
    });
  }

  void _loadData() async {
    await loadDashboardData(context);
    if (mounted) {
      final authService = context.read<AuthService>();
      final schoolProvider = context.read<SchoolProvider>();
      final user = authService.getCurrentUser();
      final userDetails = user != null ? await authService.getUserById(user.id) : null;
      setState(() {
        _adminName = userDetails?.fullName ?? user?.email?.split('@')[0] ?? 'Admin';
        _schoolName = schoolProvider.currentSchool?.name;
      });
      _loadAnnouncements();
      _loadStudentAttendance();
      _loadStaffAttendance();
      _loadFinanceData();
    }
  }

  void _loadAnnouncements() async {
    if (!mounted) return;
    setState(() => _loadingAnnouncements = true);
    try {
      final announcementService = context.read<AnnouncementService>();
      final schoolProvider = context.read<SchoolProvider>();
      final schoolId = schoolProvider.currentSchool?.id;
      if (schoolId != null) {
        final announcements = await announcementService.getAnnouncements(schoolId);
        if (mounted) {
          setState(() {
            _recentAnnouncements = announcements.take(4).toList();
            _loadingAnnouncements = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loadingAnnouncements = false);
    }
  }

  void _loadStudentAttendance() async {
    if (!mounted) return;
    setState(() => _loadingStudentAttendance = true);
    try {
      final attendanceService = context.read<AttendanceService>();
      final schoolProvider = context.read<SchoolProvider>();
      final schoolId = schoolProvider.currentSchool?.id;
      if (schoolId != null) {
        final today = DateTime.now();
        final reports = await attendanceService.getAttendanceForAdmin(schoolId, today, today);
        final present = reports.where((r) => r.status == 'Present').length;
        final absent = reports.where((r) => r.status == 'Absent').length;
        final late = reports.where((r) => r.status == 'Late').length;
        
        if (mounted) {
          setState(() {
            _studentAttendance = {'Present': present, 'Absent': absent, 'Late': late};
            _loadingStudentAttendance = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loadingStudentAttendance = false);
    }
  }

  void _loadStaffAttendance() async {
    if (!mounted) return;
    setState(() => _loadingStaffAttendance = true);
    try {
      final attendanceService = context.read<AttendanceService>();
      final schoolProvider = context.read<SchoolProvider>();
      final schoolId = schoolProvider.currentSchool?.id;
      if (schoolId != null) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final summary = await attendanceService.getStaffAttendanceSummary(
          schoolId: schoolId,
          startDate: startOfMonth,
          endDate: now,
        );
        if (mounted) {
          setState(() {
            _staffAttendance = summary.take(5).toList();
            _loadingStaffAttendance = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loadingStaffAttendance = false);
    }
  }

  void _loadFinanceData() async {
    if (!mounted) return;
    setState(() => _loadingFinance = true);
    try {
      final financeService = context.read<FinanceService>();
      final schoolProvider = context.read<SchoolProvider>();
      final schoolId = schoolProvider.currentSchool?.id;
      if (schoolId != null) {
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final data = await financeService.getFinancialChartData(schoolId, startOfMonth, now);
        if (mounted) {
          setState(() {
            _financeData = data;
            _loadingFinance = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _loadingFinance = false);
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    cancelScheduleTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          _buildSidebar(currentRoute),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWelcomeSection(),
                              const SizedBox(height: 32),
                              _buildMetricsGrid(),
                              const SizedBox(height: 32),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      children: [
                                        _buildStudentAttendanceOverview(),
                                        const SizedBox(height: 24),
                                        _buildFinanceChart(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  Expanded(
                                    child: Column(
                                      children: [
                                        _buildStaffAttendance(),
                                        const SizedBox(height: 24),
                                        _buildRecentAnnouncements(),
                                        const SizedBox(height: 24),
                                        _buildQuickActionsGrid(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(String currentRoute) {
    return Container(
      width: 260,
      color: const Color(0xFF2C3E50),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Consumer<SchoolProvider>(
                  builder: (context, schoolProvider, _) {
                    final schoolLogo = schoolProvider.currentSchool?.logoUrl;
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: schoolLogo != null && schoolLogo.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(schoolLogo, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.school, color: Color(0xFF2C3E50), size: 20),
                    );
                  },
                ),
                const SizedBox(width: 12),
                const Text('EduSync', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
          const Divider(color: Color(0xFF34495E), height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildNavItem(Icons.dashboard_outlined, 'Dashboard', '/admin', currentRoute),
                _buildNavItem(Icons.school_outlined, 'Students', '/admin/student-management', currentRoute),
                _buildNavItem(Icons.people_outline, 'Staff', '/admin/staff-management', currentRoute),
                _buildNavItem(Icons.class_outlined, 'Classes', '/admin/class-management', currentRoute),
                _buildNavItem(Icons.schedule_outlined, 'Timetable', '/admin/timetable-management', currentRoute),
                _buildNavItem(Icons.assignment_outlined, 'Exams', '/admin/exam-overview', currentRoute),
                _buildNavItem(Icons.account_balance_wallet_outlined, 'Finance', '/admin/finance-management', currentRoute),
                _buildNavItem(Icons.campaign_outlined, 'Announcements', '/admin/announcements', currentRoute),
              ],
            ),
          ),
          const Divider(color: Color(0xFF34495E), height: 1),
          _buildNavItem(Icons.settings_outlined, 'Settings', '/admin/settings', currentRoute),
          _buildNavItem(Icons.logout_outlined, 'Logout', null, currentRoute, onTap: _logout),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, String? route, String currentRoute, {VoidCallback? onTap}) {
    final isActive = route != null && currentRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3498DB) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(label, style: const TextStyle(fontSize: 13, color: Colors.white)),
        onTap: onTap ?? (route != null ? () => context.go(route) : null),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          const Text('Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
          const Spacer(),
          IconButton(icon: const Icon(Icons.search, size: 22), onPressed: () {}),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.notifications_outlined, size: 22), onPressed: () {}),
          const SizedBox(width: 16),
          Consumer<AuthService>(
            builder: (context, authService, _) {
              final user = authService.getCurrentUser();
              return Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_adminName ?? 'Admin', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('Administrator', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF3498DB),
                    child: Text(
                      (user?.email?.substring(0, 1) ?? 'A').toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good ${_getGreeting()}! 👋',
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  _adminName ?? 'Admin',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  _schoolName ?? 'School Management',
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, size: 48, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildMetricsGrid() {
    int studentCount = summaryData.isNotEmpty ? (int.tryParse(summaryData[0].count) ?? 0) : 0;
    int teacherCount = summaryData.length > 1 ? (int.tryParse(summaryData[1].count) ?? 0) : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overview', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildMetricCard('Total Students', studentCount.toString(), Icons.school_outlined, const Color(0xFF3498DB), () => context.push('/admin/student-management'))),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('Total Teachers', teacherCount.toString(), Icons.people_outline, const Color(0xFF2ECC71), () => context.push('/admin/staff-management'))),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('Total Classes', studentCountsByClass.length.toString(), Icons.class_outlined, const Color(0xFF9B59B6), () => context.push('/admin/class-management'))),
            const SizedBox(width: 16),
            Expanded(child: _buildMetricCard('Net Balance', '${netBalance.round()}', Icons.account_balance_wallet_outlined, const Color(0xFFF39C12), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinanceOverviewScreen())))),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
              ],
            ),
            const SizedBox(height: 16),
            Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentAttendanceOverview() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Student Attendance Today', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(icon: const Icon(Icons.refresh, size: 20), onPressed: _loadStudentAttendance),
            ],
          ),
          const SizedBox(height: 24),
          _loadingStudentAttendance
              ? const Center(child: CircularProgressIndicator())
              : _studentAttendance.isEmpty
                  ? const Center(child: Text('No data'))
                  : Row(
                      children: [
                        Expanded(child: _buildAttendanceCard('Present', _studentAttendance['Present'] ?? 0, const Color(0xFF2ECC71), Icons.check_circle)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildAttendanceCard('Absent', _studentAttendance['Absent'] ?? 0, const Color(0xFFE74C3C), Icons.cancel)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildAttendanceCard('Late', _studentAttendance['Late'] ?? 0, const Color(0xFFF39C12), Icons.access_time)),
                      ],
                    ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(count.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildStaffAttendance() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Staff Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _loadingStaffAttendance
              ? const Center(child: CircularProgressIndicator())
              : _staffAttendance.isEmpty
                  ? const Center(child: Text('No data'))
                  : Column(
                      children: _staffAttendance.map((staff) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: const Color(0xFF3498DB),
                                child: Text(
                                  staff['full_name'].toString().substring(0, 1).toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(staff['full_name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                    Text('${staff['present_days']} days', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2ECC71).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('${staff['present_days']}', style: const TextStyle(fontSize: 12, color: Color(0xFF2ECC71), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildFinanceChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Finance Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('This Month', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 20),
          _loadingFinance
              ? const SizedBox(height: 150, child: Center(child: CircularProgressIndicator()))
              : _financeData.isEmpty
                  ? const SizedBox(height: 150, child: Center(child: Text('No data')))
                  : SizedBox(
                      height: 150,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _financeData.take(10).map((data) {
                          final maxAmount = _financeData.map((d) => d.totalIncome > d.totalOutcome ? d.totalIncome : d.totalOutcome).reduce((a, b) => a > b ? a : b);
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (data.totalIncome > 0)
                                    Container(
                                      height: (data.totalIncome / maxAmount) * 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2ECC71),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  const SizedBox(height: 2),
                                  if (data.totalOutcome > 0)
                                    Container(
                                      height: (data.totalOutcome / maxAmount) * 60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE74C3C),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF2ECC71), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Income', style: TextStyle(fontSize: 11)),
                ],
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFE74C3C), shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  const Text('Expense', style: TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentAnnouncements() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Recent Announcements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton(
                onPressed: () => context.push('/admin/announcements'),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _loadingAnnouncements
              ? const Center(child: CircularProgressIndicator())
              : _recentAnnouncements.isEmpty
                  ? const Center(child: Text('No announcements'))
                  : Column(
                      children: _recentAnnouncements.map((announcement) {
                        return _buildAnnouncementItem(announcement);
                      }).toList(),
                    ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(Announcement announcement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.campaign_outlined, color: Color(0xFF3498DB), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(announcement.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(announcement.content, style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildActionButton('Mark Attendance', Icons.how_to_reg_outlined, const Color(0xFF2ECC71), () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceMarkingScreen()))),
          const SizedBox(height: 8),
          _buildActionButton('Staff Status', Icons.people_alt_outlined, const Color(0xFF3498DB), () => context.push('/admin/staff-status')),
          const SizedBox(height: 8),
          _buildActionButton('Manage Exams', Icons.assignment_outlined, const Color(0xFFE74C3C), () => context.pushNamed('exam-overview')),
          const SizedBox(height: 8),
          _buildActionButton('View Finance', Icons.account_balance_outlined, const Color(0xFFF39C12), () => context.push('/admin/finance-management')),
          const SizedBox(height: 8),
          _buildActionButton('Timetable', Icons.schedule_outlined, const Color(0xFF9B59B6), () => context.push('/admin/timetable-management')),
          const SizedBox(height: 8),
          _buildActionButton('School Schedule', Icons.calendar_view_week, const Color(0xFF16A085), () => context.push('/admin/whole-school-schedule')),
          const SizedBox(height: 8),
          _buildActionButton('Teacher Status', Icons.person_outline, const Color(0xFFE67E22), () => context.push('/admin/teacher-status')),
          const SizedBox(height: 8),
          _buildActionButton('Staff Attendance', Icons.fact_check_outlined, const Color(0xFF8E44AD), () => context.push('/admin/staff-attendance-summary')),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _logout() async {
    final authService = context.read<AuthService>();
    await authService.signOut();
    if (mounted) context.go('/login');
  }
}
