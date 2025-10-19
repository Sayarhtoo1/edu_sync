import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';

class ModernAdminDrawer extends StatefulWidget {
  const ModernAdminDrawer({super.key});

  @override
  State<ModernAdminDrawer> createState() => _ModernAdminDrawerState();
}

class _ModernAdminDrawerState extends State<ModernAdminDrawer> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final authService = context.read<AuthService>();
    final user = authService.getCurrentUser();
    if (user != null) {
      final userDetails = await authService.getUserById(user.id);
      if (mounted) {
        setState(() {
          _userName = userDetails?.fullName ?? user.email?.split('@')[0];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final schoolProvider = context.watch<SchoolProvider>();
    final user = authService.getCurrentUser();

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context, _userName ?? user?.email?.split('@')[0], schoolProvider.currentSchool?.name),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildSection(context, 'Dashboard', Icons.dashboard_rounded, '/admin'),
                  const SizedBox(height: 4),
                  _buildSection(context, 'People', Icons.people_rounded, null, children: [
                    _buildMenuItem(context, 'Students', Icons.school_rounded, '/admin/student-management'),
                    _buildMenuItem(context, 'Teachers', Icons.person_rounded, '/admin/user-management'),
                    _buildMenuItem(context, 'Staff', Icons.badge_rounded, '/admin/staff-management'),
                  ]),
                  const SizedBox(height: 4),
                  _buildSection(context, 'Academic', Icons.menu_book_rounded, null, children: [
                    _buildMenuItem(context, 'Classes', Icons.class_rounded, '/admin/class-management'),
                    _buildMenuItem(context, 'Timetable', Icons.schedule_rounded, '/admin/timetable-management'),
                    _buildMenuItem(context, 'Exams', Icons.assignment_rounded, '/admin/exam-management'),
                  ]),
                  const SizedBox(height: 4),
                  _buildSection(context, 'Attendance', Icons.fact_check_rounded, null, children: [
                    _buildMenuItem(context, 'Student Attendance Summary', Icons.school_rounded, '/admin/student-attendance-summary'),
                    _buildMenuItem(context, 'Staff Attendance Summary', Icons.badge_rounded, '/admin/staff-attendance-summary'),
                  ]),
                  const SizedBox(height: 4),
                  _buildSection(context, 'Finance', Icons.account_balance_wallet_rounded, null, children: [
                    _buildMenuItem(context, 'Fee Management', Icons.payments_rounded, '/admin/fee-management'),
                    _buildMenuItem(context, 'Donations', Icons.favorite_rounded, '/admin/donation-management'),
                    _buildMenuItem(context, 'Income & Expenses', Icons.trending_up_rounded, '/admin/finance-management'),
                  ]),
                  const SizedBox(height: 4),
                  _buildSection(context, 'Communication', Icons.campaign_rounded, null, children: [
                    _buildMenuItem(context, 'Announcements', Icons.notifications_rounded, '/admin/announcements'),
                    _buildMenuItem(context, 'Forms', Icons.article_rounded, '/admin/manage-custom-forms'),
                  ]),
                  const SizedBox(height: 4),
                  _buildSection(context, 'Settings', Icons.settings_rounded, null, children: [
                    _buildMenuItem(context, 'School Profile', Icons.business_rounded, '/admin/school-profile'),
                    _buildMenuItem(context, 'Admin Settings', Icons.admin_panel_settings_rounded, '/admin/settings'),
                    _buildMenuItem(context, 'App Settings', Icons.settings_applications_rounded, '/app-settings'),
                  ]),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? userName, String? schoolName) {
    final schoolProvider = context.watch<SchoolProvider>();
    final schoolLogo = schoolProvider.currentSchool?.logoUrl;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: (schoolLogo != null && schoolLogo.isNotEmpty)
                ? ColorFiltered(
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                    child: CachedNetworkImage(
                      imageUrl: schoolLogo,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Icon(Icons.school_rounded, size: 48, color: Colors.white),
                      errorWidget: (context, url, error) => const Icon(Icons.school_rounded, size: 48, color: Colors.white),
                    ),
                  )
                : const Icon(Icons.school_rounded, size: 48, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            userName?.toUpperCase() ?? 'ADMIN',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              schoolName ?? 'School Admin',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, String? route, {List<Widget>? children, Widget? screen}) {
    if (children != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E88E5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF1E88E5), size: 20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            children: children,
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF1E88E5), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2C2C2C),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (screen != null) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
          } else if (route != null && route == '/admin') {
            context.go(route);
          }
        },
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            Navigator.pop(context);
            context.push(route);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF64B5F6), size: 18),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF424242),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final authService = context.read<AuthService>();
                await authService.signOut();
                if (context.mounted) context.go('/login');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'EduSync v3.2.0',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
