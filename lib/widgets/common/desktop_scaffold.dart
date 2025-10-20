import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';

class DesktopScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const DesktopScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    String currentRoute = '';
    try {
      currentRoute = GoRouterState.of(context).matchedLocation;
    } catch (e) {
      // No GoRouter context available (e.g., opened via Navigator.push)
      currentRoute = '';
    }
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          _buildSidebar(context, currentRoute),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(child: body),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, String currentRoute) {
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
                _buildNavItem(context, Icons.dashboard_outlined, 'Dashboard', '/admin', currentRoute),
                _buildNavItem(context, Icons.school_outlined, 'Students', '/admin/student-management', currentRoute),
                _buildNavItem(context, Icons.people_outline, 'Staff', '/admin/staff-management', currentRoute),
                _buildNavItem(context, Icons.family_restroom_outlined, 'Parents', '/admin/parent-management', currentRoute),
                _buildNavItem(context, Icons.class_outlined, 'Classes', '/admin/class-management', currentRoute),
                _buildNavItem(context, Icons.schedule_outlined, 'Timetable', '/admin/timetable-management', currentRoute),
                _buildNavItem(context, Icons.assignment_outlined, 'Exams', '/admin/exam-overview', currentRoute),
                _buildNavItem(context, Icons.account_balance_wallet_outlined, 'Finance', '/admin/finance-management', currentRoute),
                _buildNavItem(context, Icons.campaign_outlined, 'Announcements', '/admin/announcements', currentRoute),
                _buildNavItem(context, Icons.analytics_outlined, 'Performance', '/admin/student-performance', currentRoute),
                _buildNavItem(context, Icons.person_outline, 'Users', '/admin/user-management', currentRoute),
              ],
            ),
          ),
          const Divider(color: Color(0xFF34495E), height: 1),
          _buildNavItem(context, Icons.settings_outlined, 'Settings', '/admin/settings', currentRoute),
          _buildNavItem(context, Icons.logout_outlined, 'Logout', null, currentRoute, onTap: () => _logout(context)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String? route, String currentRoute, {VoidCallback? onTap}) {
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
        onTap: onTap ?? (route != null ? () {
          try {
            context.go(route);
          } catch (e) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        } : null),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
          const Spacer(),
          if (actions != null) ...actions!,
          const SizedBox(width: 16),
          Consumer<AuthService>(
            builder: (context, authService, _) {
              final user = authService.getCurrentUser();
              return CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF3498DB),
                child: Text(
                  (user?.email?.substring(0, 1) ?? 'A').toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) async {
    final authService = context.read<AuthService>();
    await authService.signOut();
    if (context.mounted) {
      try {
        context.go('/login');
      } catch (e) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}
