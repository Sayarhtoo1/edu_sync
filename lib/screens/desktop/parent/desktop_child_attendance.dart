import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/screens/parent/child_attendance_screen.dart';
import 'package:edu_sync/services/auth_service.dart';

class DesktopChildAttendance extends StatelessWidget {
  const DesktopChildAttendance({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
      children: [
        Container(
          width: 250,
          color: Colors.white,
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('EduSync', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              _buildNavItem(context, Icons.dashboard, 'Dashboard', '/parent-dashboard'),
              _buildNavItem(context, Icons.check_circle, 'Attendance', '/parent/child-attendance'),
              _buildNavItem(context, Icons.schedule, 'Schedule', '/parent/child-schedule'),
              _buildNavItem(context, Icons.announcement, 'Announcements', '/parent/announcements'),
              const Spacer(),
              _buildNavItem(context, Icons.settings, 'Settings', '/app-settings'),
              _buildNavItem(context, Icons.logout, 'Logout', null, onTap: () => _logout(context)),
              const SizedBox(height: 20),
            ],
          ),
        ),
        const Expanded(child: ChildAttendanceScreen()),
      ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String? route, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: onTap ?? (route != null ? () => context.push(route) : null),
    );
  }

  void _logout(BuildContext context) async {
    final authService = context.read<AuthService>();
    await authService.signOut();
    if (context.mounted) context.go('/login');
  }
}
