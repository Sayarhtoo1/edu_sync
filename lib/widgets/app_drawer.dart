import 'package:edu_sync/models/user_role.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/models/school.dart';
// Import other screens as needed for navigation
// Import ViewFormResponsesScreen
// Import AdminAnnouncementsScreen
// Import ManageCustomFormsScreen
// Import AdminSettingsScreen
// import 'package:edu_sync/screens/teacher/student_view_screen.dart'; // If a separate one is made
// Import DailyReportScreen
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Corrected import
import 'package:edu_sync/services/notification_service.dart';

// Matching colors from AdminPanelScreen for theming
const Color drawerAppBackgroundColor = Color(0xFFF5F0FF); // Very light pastel purple
const Color drawerTextDarkGrey = Color(0xFF2C2C2C);
const Color drawerTextLightGrey = Color(0xFF8C8C8C);
const Color drawerIconColor = Color(0xFF7A6FF0); // Using iconColorStudents as a general accent


class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context); // Listen to changes
    final School? currentSchool = schoolProvider.currentSchool;
    final l10n = AppLocalizations.of(context)!; // Get l10n instance and assert non-null

    // Drawer items for Admin
    List<Widget> buildAdminDrawerItems(BuildContext context, School? school) {
      return [
        if (school != null)
          ListTile(
            leading: const Icon(Icons.edit_note, color: drawerIconColor),
            title: Text('Edit School Profile', style: const TextStyle(color: drawerTextDarkGrey)),
            onTap: () {
              Navigator.pop(context); // Close drawer
              context.push('/admin/edit-school-profile', extra: school);
            },
          ),
        ListTile(
          leading: const Icon(Icons.people, color: drawerIconColor),
          title: Text('Staff Management', style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/staff-management');
            },
          ),
        ListTile(
          leading: const Icon(Icons.school_outlined, color: drawerIconColor),
          title: Text(l10n.studentManagementTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/student-management');
            },
          ),
        ListTile(
          leading: const Icon(Icons.class_, color: drawerIconColor),
          title: Text(l10n.classManagementTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/class-management');
            },
          ),
        ListTile(
          leading: const Icon(Icons.calendar_today, color: drawerIconColor),
          title: Text(l10n.timetableManagementTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/timetable-management');
            },
          ),
        ListTile(
          leading: const Icon(Icons.attach_money, color: drawerIconColor),
          title: Text(l10n.financeManagementTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/finance-management');
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          leading: const Icon(Icons.check_circle_outline, color: drawerIconColor),
          title: Text(l10n.markSchoolAttendance, style: const TextStyle(color: drawerTextDarkGrey)), // Admin context
          onTap: () {
            Navigator.pop(context);
            context.push('/teacher/attendance-marking');
            },
          ),
        ListTile(
          leading: const Icon(Icons.book_outlined, color: drawerIconColor),
          title: Text(l10n.manageSchoolLessonPlans, style: const TextStyle(color: drawerTextDarkGrey)), // Admin context
          onTap: () {
            Navigator.pop(context);
            context.push('/teacher/lesson-plan-management');
          },
        ),
        ListTile(
          leading: const Icon(Icons.campaign_outlined, color: drawerIconColor),
          title: Text(l10n.manageAnnouncementsDrawerItem, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/announcements');
          },
          ),
        ListTile(
          leading: const Icon(Icons.assignment_outlined, color: drawerIconColor),
          title: Text(l10n.manageDailyReportsDrawerItem, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/manage-custom-forms');
          },
          ),
        ListTile(
          leading: const Icon(Icons.list_alt_outlined, color: drawerIconColor),
          title: Text(l10n.viewFormResponsesTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            if (school != null) {
              context.push('/admin/view-form-responses', extra: school.id);
            } else {
              // Handle case where school is null, maybe show a snackbar
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.error_school_not_selected_or_found)));
            }
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          leading: const Icon(Icons.admin_panel_settings, color: drawerIconColor),
          title: Text(l10n.adminSettingsTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/settings');
          },
        ),
      ];
    }

    // Drawer items for Teacher
    List<Widget> buildTeacherDrawerItems(BuildContext context) {
      return [
        ListTile(
          leading: const Icon(Icons.dashboard, color: drawerIconColor),
          title: Text(l10n.dashboardTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.go('/teacher-dashboard');
            },
          ),
        ListTile(
          leading: const Icon(Icons.calendar_today, color: drawerIconColor),
          title: Text(l10n.myTimetableTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/teacher/timetable');
            },
          ),
        ListTile(
          leading: const Icon(Icons.check_circle_outline, color: drawerIconColor),
          title: Text(l10n.markAttendance, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/teacher/attendance-marking');
            },
          ),
        ListTile(
          leading: const Icon(Icons.book_outlined, color: drawerIconColor),
          title: Text(l10n.lessonPlansTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/teacher/lesson-plan-management');
            },
          ),
         ListTile(
          leading: const Icon(Icons.people_alt_outlined, color: drawerIconColor),
          title: Text(l10n.viewStudentsTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            // Assuming teachers can view the same student list screen as admins for now
            context.push('/admin/student-management');
          },
          ),
        ListTile(
          leading: const Icon(Icons.list_alt, color: drawerIconColor),
          title: Text(l10n.viewFormResponsesTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            // Teachers also need schoolId context for this screen
            final schoolId = schoolProvider.currentSchool?.id;
            if (schoolId != null) {
              context.push('/admin/view-form-responses', extra: schoolId);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.error_school_not_selected_or_found)));
            }
          },
        ),
      ];
    }

    // Drawer items for Parent
    List<Widget> buildParentDrawerItems(BuildContext context) {
      return [
         ListTile(
          leading: const Icon(Icons.dashboard, color: drawerIconColor),
          title: Text(l10n.dashboardTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.go('/parent-dashboard');
            },
          ),
        ListTile(
          leading: const Icon(Icons.check_circle, color: drawerIconColor),
          title: Text(l10n.childAttendanceTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/parent/child-attendance');
            },
          ),
        ListTile(
          leading: const Icon(Icons.schedule, color: drawerIconColor),
          title: Text(l10n.childScheduleTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/parent/child-schedule');
          },
        ),
        ListTile(
          leading: const Icon(Icons.campaign, color: drawerIconColor),
          title: Row(
            children: [
              Text(l10n.announcementsTitle, style: const TextStyle(color: drawerTextDarkGrey)),
              if (notificationService.hasNewAnnouncements)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                )
            ],
          ),
          onTap: () {
            Navigator.pop(context);
            context.push('/parent/announcements').then((_){
              if (notificationService.hasNewAnnouncements) {
                 // Consider clearing flag here or within AnnouncementsScreen
              }
            });
          },
          ),
        ListTile(
          leading: const Icon(Icons.assessment_outlined, color: drawerIconColor),
          title: Text(l10n.dailyReportsTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/parent/daily-report');
          },
        ),
      ];
    }

    List<Widget> buildManagerDrawerItems(BuildContext context) {
      return [
        ListTile(
          leading: const Icon(Icons.dashboard, color: drawerIconColor),
          title: Text(l10n.dashboardTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.go('/manager-dashboard');
            },
          ),
        ListTile(
          leading: const Icon(Icons.people, color: drawerIconColor),
          title: Text('Staff Management', style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/staff-management');
            },
          ),
        ListTile(
          leading: const Icon(Icons.school_outlined, color: drawerIconColor),
          title: Text(l10n.studentManagementTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/student-management');
            },
          ),
        ListTile(
          leading: const Icon(Icons.class_, color: drawerIconColor),
          title: Text(l10n.classManagementTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/class-management');
            },
          ),
        ListTile(
          leading: const Icon(Icons.calendar_today, color: drawerIconColor),
          title: Text(l10n.timetableManagementTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/timetable-management');
            },
          ),
        ListTile(
          leading: const Icon(Icons.attach_money, color: drawerIconColor),
          title: Text(l10n.financeManagementTitle, style: const TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            context.push('/admin/finance-management');
          },
        ),
      ];
    }

    return Drawer(
      backgroundColor: drawerAppBackgroundColor,
      child: FutureBuilder<String?>(
        future: authService.getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userRole = snapshot.data;
          List<Widget> drawerItems = [];
          if (userRole == UserRole.Admin.name) {
            drawerItems = buildAdminDrawerItems(context, currentSchool);
          } else if (userRole == UserRole.Teacher.name) {
            drawerItems = buildTeacherDrawerItems(context);
          } else if (userRole == UserRole.Parent.name) {
            drawerItems = buildParentDrawerItems(context);
          } else if (userRole == UserRole.Manager.name) {
            drawerItems = buildManagerDrawerItems(context);
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(currentSchool?.name ?? l10n.eduSyncUser, style: const TextStyle(color: drawerTextDarkGrey)),
                accountEmail: Text(authService.getCurrentUser()?.email ?? '', style: const TextStyle(color: drawerTextLightGrey)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (currentSchool?.logoUrl != null && currentSchool!.logoUrl.isNotEmpty)
                      ? NetworkImage(currentSchool.logoUrl)
                      : null,
                  child: (currentSchool?.logoUrl == null || currentSchool!.logoUrl.isEmpty)
                      ? const Icon(Icons.school, size: 40, color: drawerIconColor)
                      : null,
                ),
                decoration: const BoxDecoration(
                  color: drawerAppBackgroundColor,
                ),
              ),
              ...drawerItems,
              const Divider(color: drawerTextLightGrey),
              ListTile(
                leading: const Icon(Icons.settings, color: drawerIconColor),
                title: Text(l10n.appSettingsTitle, style: const TextStyle(color: drawerTextDarkGrey)),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/app-settings');
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: drawerIconColor),
                title: Text(l10n.logoutButtonText, style: const TextStyle(color: drawerTextDarkGrey)),
                onTap: () async {
                  Navigator.pop(context);
                  await authService.signOut();
                  if (!context.mounted) return; // Add mounted check
                  context.go('/login'); // Use go_router for navigation
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
