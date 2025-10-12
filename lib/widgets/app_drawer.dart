import 'package:edu_sync/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:edu_sync/services/notification_service.dart';

// Modern drawer colors matching the school dashboard design
const Color drawerBackgroundColor = Color(0xFF4A5568); // Dark blue-grey
const Color drawerTextColor = Colors.white;
const Color drawerSelectedColor = Colors.white;
const Color drawerSelectedTextColor = Color(0xFF2D3748);

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: isSelected ? drawerSelectedColor : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? drawerSelectedTextColor : drawerTextColor,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? drawerSelectedTextColor : drawerTextColor,
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final School? currentSchool = schoolProvider.currentSchool;

    List<Widget> buildAdminDrawerItems(BuildContext context) {
      return [
        _buildDrawerItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () {
            Navigator.pop(context);
            context.go('/admin');
          },
          isSelected: true,
        ),
        _buildDrawerItem(
          icon: Icons.school_outlined,
          title: 'Students',
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/student-management');
          },
        ),
        _buildDrawerItem(
          icon: Icons.people_outline,
          title: 'Teachers',
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/staff-management');
          },
        ),
        _buildDrawerItem(
          icon: Icons.check_circle_outline,
          title: 'Attendance',
          onTap: () {
            Navigator.pop(context);
            context.push('/teacher/attendance-marking');
          },
        ),
        _buildDrawerItem(
          icon: Icons.class_,
          title: 'Courses',
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/class-management');
          },
        ),
        _buildDrawerItem(
          icon: Icons.assignment_outlined,
          title: 'Exam',
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/exam-overview');
          },
        ),
        _buildDrawerItem(
          icon: Icons.payment,
          title: 'Payment',
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/finance-management');
          },
        ),
        const SizedBox(height: 20),
      ];
    }

    List<Widget> buildTeacherDrawerItems(BuildContext context) {
      return [
        _buildDrawerItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () {
            Navigator.pop(context);
            context.go('/teacher-dashboard');
          },
          isSelected: true,
        ),
        _buildDrawerItem(
          icon: Icons.school_outlined,
          title: 'Students',
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/student-management');
          },
        ),
        _buildDrawerItem(
          icon: Icons.check_circle_outline,
          title: 'Attendance',
          onTap: () {
            Navigator.pop(context);
            context.push('/teacher/attendance-marking');
          },
        ),
        _buildDrawerItem(
          icon: Icons.calendar_today,
          title: 'Timetable',
          onTap: () {
            Navigator.pop(context);
            context.push('/teacher/timetable');
          },
        ),
        _buildDrawerItem(
          icon: Icons.book_outlined,
          title: 'Lesson Plans',
          onTap: () {
            Navigator.pop(context);
            context.push('/teacher/lesson-plan-management');
          },
        ),
        const SizedBox(height: 20),
      ];
    }

    List<Widget> buildParentDrawerItems(BuildContext context) {
      return [
        _buildDrawerItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () {
            Navigator.pop(context);
            context.go('/parent-dashboard');
          },
          isSelected: true,
        ),
        _buildDrawerItem(
          icon: Icons.check_circle_outline,
          title: 'Attendance',
          onTap: () {
            Navigator.pop(context);
            context.push('/parent/child-attendance');
          },
        ),
        _buildDrawerItem(
          icon: Icons.schedule,
          title: 'Schedule',
          onTap: () {
            Navigator.pop(context);
            context.push('/parent/child-schedule');
          },
        ),
        _buildDrawerItem(
          icon: Icons.campaign,
          title: 'Announcements',
          onTap: () {
            Navigator.pop(context);
            context.push('/parent/announcements');
          },
        ),
        _buildDrawerItem(
          icon: Icons.assessment_outlined,
          title: 'Reports',
          onTap: () {
            Navigator.pop(context);
            context.push('/parent/daily-report');
          },
        ),
        const SizedBox(height: 20),
      ];
    }

    List<Widget> buildManagerDrawerItems(BuildContext context) {
      return [
        _buildDrawerItem(
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () {
            Navigator.pop(context);
            context.go('/manager-dashboard');
          },
          isSelected: true,
        ),
        _buildDrawerItem(
          icon: Icons.school_outlined,
          title: 'Students',
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/student-management');
          },
        ),
        _buildDrawerItem(
          icon: Icons.people_outline,
          title: 'Staff',
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/staff-management');
          },
        ),
        _buildDrawerItem(
          icon: Icons.payment,
          title: 'Finance',
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/finance-management');
          },
        ),
        const SizedBox(height: 20),
      ];
    }

    return Drawer(
      backgroundColor: drawerBackgroundColor,
      child: FutureBuilder<String?>(
        future: authService.getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userRole = snapshot.data;
          List<Widget> drawerItems = [];
          if (userRole == UserRole.Admin.name) {
            drawerItems = buildAdminDrawerItems(context);
          } else if (userRole == UserRole.Teacher.name) {
            drawerItems = buildTeacherDrawerItems(context);
          } else if (userRole == UserRole.Parent.name) {
            drawerItems = buildParentDrawerItems(context);
          } else if (userRole == UserRole.Manager.name) {
            drawerItems = buildManagerDrawerItems(context);
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: (currentSchool?.logoUrl != null && currentSchool!.logoUrl.isNotEmpty)
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                currentSchool.logoUrl,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.school, size: 28, color: drawerBackgroundColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        currentSchool?.name ?? 'SCHOOL',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ...drawerItems,
              const Spacer(),
              _buildDrawerItem(
                icon: Icons.settings,
                title: 'Settings',
                onTap: () {
                  Navigator.pop(context);
                  context.push('/app-settings');
                },
              ),
              _buildDrawerItem(
                icon: Icons.logout,
                title: 'Logout',
                onTap: () async {
                  Navigator.pop(context);
                  await authService.signOut();
                  if (!context.mounted) return;
                  context.go('/login');
                },
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
