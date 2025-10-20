import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/widgets/admin/animated_metric_card.dart';
import 'package:edu_sync/widgets/admin/hero_welcome_card.dart';
import 'package:edu_sync/widgets/admin/category_action_section.dart';
import 'package:edu_sync/screens/admin/admin_announcements_screen.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/screens/teacher/teacher_timetable_screen.dart';
import 'package:edu_sync/screens/admin/fee/fee_structure_management_screen.dart';
import 'package:edu_sync/screens/admin/finance/finance_overview_screen.dart';
import 'package:edu_sync/widgets/admin/modern_admin_drawer.dart';
import 'package:edu_sync/screens/admin/admin_panel_state.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/screens/staff/staff_attendance_screen.dart';
import 'package:edu_sync/services/notification_service.dart';
import 'package:edu_sync/widgets/announcement_popup_dialog.dart';
import 'package:edu_sync/widgets/common/notification_bell_icon.dart';
import 'package:edu_sync/utils/responsive.dart';
import 'dart:async';

class ModernAdminDashboard extends StatefulWidget {
  final bool isDesktopWrapper;
  
  const ModernAdminDashboard({super.key, this.isDesktopWrapper = false});

  @override
  State<ModernAdminDashboard> createState() => _ModernAdminDashboardState();
}

class _ModernAdminDashboardState extends State<ModernAdminDashboard>
    with AdminPanelStateMixin<ModernAdminDashboard>, TickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  StreamSubscription? _announcementSubscription;
  Timer? _refreshTimer;
  String? _adminName;
  String? _schoolName;
  final Map<String, int> _summaryMetrics = {};
  late NotificationService _notificationService;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    
    initializeServices(context);
    _notificationService = Provider.of<NotificationService>(context, listen: false);
    
    // Listen for new announcements
    _announcementSubscription = _notificationService.inAppAnnouncements.listen((announcement) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AnnouncementPopupDialog(
            announcement: announcement,
            onDismiss: () => Navigator.of(context).pop(),
          ),
        );
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      startScheduleTimer();
      _startRefreshTimer();
      _fadeController.forward();
    });
  }

  void _startRefreshTimer() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadData();
    }
  }

  @override
  void didPopNext() {
    if (mounted) {
      _loadData();
    }
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
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeController.dispose();
    _announcementSubscription?.cancel();
    _refreshTimer?.cancel();
    cancelScheduleTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDesktopWrapper) {
      return _buildBody();
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Consumer<SchoolProvider>(
              builder: (context, schoolProvider, _) {
                final schoolLogo = schoolProvider.currentSchool?.logoUrl;
                return Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                  ),
                  child: schoolLogo != null && schoolLogo.isNotEmpty
                      ? Image.network(schoolLogo, fit: BoxFit.contain)
                      : const Icon(Icons.school, size: 20, color: Colors.grey),
                );
              },
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Admin Dashboard',
                style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          const NotificationBellIcon(),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const ModernAdminDrawer(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen()),
          );
        },
        tooltip: 'New Announcement',
        backgroundColor: const Color(0xFF1976D2),
        child: const Icon(Icons.campaign_outlined),
      ),
    );
  }

  Widget _buildBody() {
    return isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await loadDashboardData(context);
                _loadData();
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = Responsive.isDesktop(context);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: isDesktop ? 7 : 1,
                        child: SingleChildScrollView(
                          padding: Responsive.padding(context),
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                HeroWelcomeCard(
                                  adminName: _adminName ?? 'Admin',
                                  schoolName: _schoolName,
                                ),
                                const SizedBox(height: 24),
                                _buildMetricsSection(),
                                const SizedBox(height: 24),
                                if (!isDesktop) _buildQuickActionsSection(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (isDesktop)
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Colors.white,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: _buildQuickActionsSection(),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
  }

  Widget _buildMetricsSection() {
    int studentCount = summaryData.isNotEmpty ? (int.tryParse(summaryData[0].count) ?? 0) : 0;
    int teacherCount = summaryData.length > 1 ? (int.tryParse(summaryData[1].count) ?? 0) : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Overview',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = Responsive.gridColumns(context);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: columns,
              childAspectRatio: Responsive.isDesktop(context) ? 1.5 : 1.30,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                AnimatedMetricCard(
                  title: 'Total Students',
                  value: studentCount,
                  icon: Icons.school_outlined,
                  color: const Color(0xFF2196F3),
                  percentageChange: 5.2,
                  onTap: () => context.push('/admin/student-management'),
                ),
                AnimatedMetricCard(
                  title: 'Total Teachers',
                  value: teacherCount,
                  icon: Icons.people_outline,
                  color: const Color(0xFF4CAF50),
                  percentageChange: 2.1,
                  onTap: () => context.push('/admin/staff-management'),
                ),
                AnimatedMetricCard(
                  title: 'Total Classes',
                  value: studentCountsByClass.length,
                  icon: Icons.class_outlined,
                  color: const Color(0xFF9C27B0),
                  onTap: () => context.push('/admin/class-management'),
                ),
                AnimatedMetricCard(
                  title: 'Net Balance',
                  value: netBalance.round(),
                  icon: Icons.account_balance_wallet_outlined,
                  color: const Color(0xFFFF9800),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FinanceOverviewScreen()),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C2C2C),
          ),
        ),
        const SizedBox(height: 16),
        CategoryActionSection(
          category: 'Attendance',
          color: const Color(0xFF4CAF50),
          actions: [
            ActionItem(
              title: 'Student Attendance',
              subtitle: 'Mark today',
              icon: Icons.how_to_reg_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceMarkingScreen())),
            ),
            ActionItem(
              title: 'Staff Status',
              subtitle: 'View all staff',
              icon: Icons.people_alt_outlined,
              onTap: () => context.push('/admin/staff-status'),
            ),
            ActionItem(
              title: 'Clock In/Out',
              subtitle: 'Staff attendance',
              icon: Icons.access_time_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffAttendanceScreen())),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CategoryActionSection(
          category: 'Academic',
          color: const Color(0xFF2196F3),
          actions: [
            ActionItem(
              title: 'Exam Management',
              subtitle: 'Manage exams',
              icon: Icons.assignment_outlined,
              onTap: () => context.pushNamed('exam-overview'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CategoryActionSection(
          category: 'Finance',
          color: const Color(0xFF9C27B0),
          actions: [
            ActionItem(
              title: 'Finance Management',
              subtitle: 'Income & expenses',
              icon: Icons.account_balance_outlined,
              onTap: () => context.push('/admin/finance-management'),
            ),
            ActionItem(
              title: 'Fee Management',
              subtitle: 'Manage fees',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeStructureManagementScreen())),
            ),
            ActionItem(
              title: 'Donations',
              subtitle: 'View donations',
              icon: Icons.volunteer_activism_outlined,
              onTap: () => context.push('/admin/donation-management'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CategoryActionSection(
          category: 'Management',
          color: const Color(0xFFFF9800),
          actions: [
            ActionItem(
              title: 'Parent Management',
              subtitle: 'Manage parents',
              icon: Icons.family_restroom_outlined,
              onTap: () => context.push('/admin/parent-management'),
            ),
            ActionItem(
              title: 'Timetable',
              subtitle: 'View schedule',
              icon: Icons.schedule_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherTimetableScreen())),
            ),
          ],
        ),
      ],
    );
  }
}
