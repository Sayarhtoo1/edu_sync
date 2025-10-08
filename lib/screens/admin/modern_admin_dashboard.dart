import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/widgets/admin/animated_metric_card.dart';
import 'package:edu_sync/widgets/admin/hero_welcome_card.dart';
import 'package:edu_sync/widgets/admin/category_action_section.dart';
import 'package:edu_sync/screens/admin/admin_announcements_screen.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/staff/staff_attendance_screen.dart';
import 'package:edu_sync/screens/common/attendance_report_screen.dart';
import 'package:edu_sync/screens/admin/exam/modern_exam_management_screen.dart';
import 'package:edu_sync/screens/admin/exam/subject_management_screen.dart';
import 'package:edu_sync/screens/admin/exam/grade_management_screen.dart';
import 'package:edu_sync/screens/teacher/exam/input_marks_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_timetable_screen.dart';
import 'package:edu_sync/screens/admin/teacher_status_overview_screen.dart';
import 'package:edu_sync/screens/admin/fee/fee_structure_management_screen.dart';
import 'package:edu_sync/screens/admin/fee/donation_management_screen.dart';
import 'package:edu_sync/screens/admin/finance_overview_screen.dart';
import 'package:edu_sync/widgets/admin/modern_admin_drawer.dart';
import 'package:edu_sync/screens/admin/admin_panel_state.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/admin_panel_models.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'dart:async';

class ModernAdminDashboard extends StatefulWidget {
  const ModernAdminDashboard({super.key});

  @override
  State<ModernAdminDashboard> createState() => _ModernAdminDashboardState();
}

class _ModernAdminDashboardState extends State<ModernAdminDashboard>
    with AdminPanelStateMixin<ModernAdminDashboard>, TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  StreamSubscription? _announcementSubscription;
  String? _adminName;
  String? _schoolName;
  final Map<String, int> _summaryMetrics = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    
    initializeServices(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDashboardData(context).then((_) {
        if (mounted) {
          final authService = context.read<AuthService>();
          final schoolProvider = context.read<SchoolProvider>();
          setState(() {
            final user = authService.getCurrentUser();
            _adminName = user?.email?.split('@')[0] ?? 'Admin';
            _schoolName = schoolProvider.currentSchool?.name;
            final studentItem = summaryData.firstWhere((s) => s.title.contains('Student'), orElse: () => SummaryItemData(title: '', count: '0', icon: Icons.school, backgroundColor: Colors.white, iconBackgroundColor: Colors.white, iconColor: Colors.white));
            _summaryMetrics['totalStudents'] = int.tryParse(studentItem.count) ?? 0;
            final teacherItem = summaryData.firstWhere((s) => s.title.contains('Teacher'), orElse: () => SummaryItemData(title: '', count: '0', icon: Icons.school, backgroundColor: Colors.white, iconBackgroundColor: Colors.white, iconColor: Colors.white));
            _summaryMetrics['totalTeachers'] = int.tryParse(teacherItem.count) ?? 0;
            _summaryMetrics['totalClasses'] = studentCountsByClass.length;
          });
        }
      });
      startScheduleTimer();
      _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _announcementSubscription?.cancel();
    cancelScheduleTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const ModernAdminDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => loadDashboardData(context),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                      _buildQuickActionsSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
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

  Widget _buildMetricsSection() {
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
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 1.30,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            AnimatedMetricCard(
              title: 'Total Students',
              value: _summaryMetrics['totalStudents'] ?? 0,
              icon: Icons.school_outlined,
              color: const Color(0xFF2196F3),
              percentageChange: 5.2,
            ),
            AnimatedMetricCard(
              title: 'Total Teachers',
              value: _summaryMetrics['totalTeachers'] ?? 0,
              icon: Icons.people_outline,
              color: const Color(0xFF4CAF50),
              percentageChange: 2.1,
            ),
            AnimatedMetricCard(
              title: 'Total Classes',
              value: _summaryMetrics['totalClasses'] ?? 0,
              icon: Icons.class_outlined,
              color: const Color(0xFF9C27B0),
            ),
            AnimatedMetricCard(
              title: 'Net Balance',
              value: netBalance.toInt(),
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
              title: 'Staff Attendance',
              subtitle: 'Mark today',
              icon: Icons.badge_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffAttendanceScreen())),
            ),
            ActionItem(
              title: 'Attendance Report',
              subtitle: 'View reports',
              icon: Icons.assessment_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceReportScreen())),
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
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ModernExamManagementScreen())),
            ),
            ActionItem(
              title: 'Subject Management',
              subtitle: 'Manage subjects',
              icon: Icons.menu_book_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SubjectManagementScreen())),
            ),
            ActionItem(
              title: 'Grade Management',
              subtitle: 'Manage grades',
              icon: Icons.grade_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GradeManagementScreen())),
            ),
            ActionItem(
              title: 'Input Marks',
              subtitle: 'Enter marks',
              icon: Icons.edit_note_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => InputMarksScreen())),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CategoryActionSection(
          category: 'Finance',
          color: const Color(0xFF9C27B0),
          actions: [
            ActionItem(
              title: 'Fee Management',
              subtitle: 'Manage fees',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeeStructureManagementScreen())),
            ),
            ActionItem(
              title: 'Donations',
              subtitle: 'View donations',
              icon: Icons.favorite_border_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationManagementScreen())),
            ),
          ],
        ),
        const SizedBox(height: 24),
        CategoryActionSection(
          category: 'Management',
          color: const Color(0xFFFF9800),
          actions: [
            ActionItem(
              title: 'Timetable',
              subtitle: 'View schedule',
              icon: Icons.schedule_outlined,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherTimetableScreen())),
            ),
            ActionItem(
              title: 'Teacher Overview',
              subtitle: 'View status',
              icon: Icons.people_outline,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TeacherStatusOverviewScreen())),
            ),
          ],
        ),
      ],
    );
  }
}
