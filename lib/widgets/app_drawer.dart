import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/screens/auth/login_screen.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/models/school.dart';
// Import other screens as needed for navigation
import 'package:edu_sync/screens/admin/user_management_screen.dart';
import 'package:edu_sync/screens/admin/student_management_screen.dart';
import 'package:edu_sync/screens/admin/view_form_responses_screen.dart'; // Import ViewFormResponsesScreen
import 'package:edu_sync/screens/admin/class_management_screen.dart';
import 'package:edu_sync/screens/admin/timetable_management_screen.dart';
import 'package:edu_sync/screens/admin/finance_management_screen.dart';
import 'package:edu_sync/screens/admin/edit_school_profile_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_dashboard_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_timetable_screen.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/teacher/lesson_plan_management_screen.dart';
import 'package:edu_sync/screens/admin/admin_announcements_screen.dart'; // Import AdminAnnouncementsScreen
import 'package:edu_sync/screens/admin/manage_custom_forms_screen.dart'; // Import ManageCustomFormsScreen
// import 'package:edu_sync/screens/teacher/student_view_screen.dart'; // If a separate one is made
import 'package:edu_sync/screens/parent/parent_dashboard_screen.dart';
import 'package:edu_sync/screens/parent/child_attendance_screen.dart';
import 'package:edu_sync/screens/parent/child_schedule_screen.dart';
import 'package:edu_sync/screens/parent/announcements_screen.dart';
import 'package:edu_sync/screens/parent/daily_report_screen.dart'; // Import DailyReportScreen
import 'package:edu_sync/screens/settings/app_settings_screen.dart'; 
import 'package:edu_sync/l10n/app_localizations.dart';
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
    final authService = AuthService();
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final notificationService = Provider.of<NotificationService>(context); // Listen to changes
    final School? currentSchool = schoolProvider.currentSchool;
    final l10n = AppLocalizations.of(context); // Get l10n instance

    // Drawer items for Admin
    List<Widget> buildAdminDrawerItems(BuildContext context, School? school) {
      return [
        if (school != null)
          ListTile(
            leading: const Icon(Icons.edit_note, color: drawerIconColor),
            title: Text('Edit School Profile', style: TextStyle(color: drawerTextDarkGrey)),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditSchoolProfileScreen(school: school)));
            },
          ),
        ListTile(
          leading: const Icon(Icons.people, color: drawerIconColor),
          title: Text('User Management', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UserManagementScreen()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.school_outlined, color: drawerIconColor),
          title: Text('Student Management', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudentManagementScreen()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.class_, color: drawerIconColor),
          title: Text('Class Management', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ClassManagementScreen()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.calendar_today, color: drawerIconColor),
          title: Text('Timetable Management', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TimetableManagementScreen()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.attach_money, color: drawerIconColor),
          title: Text('Finance Management', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinanceManagementScreen()));
          },
        ),
        const Divider(indent: 16, endIndent: 16), 
        ListTile(
          leading: const Icon(Icons.check_circle_outline, color: drawerIconColor),
          title: Text('Mark School Attendance', style: TextStyle(color: drawerTextDarkGrey)), // Admin context
          onTap: () {
            Navigator.pop(context);
            // Admin might need a different view or ability to select class/teacher
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceMarkingScreen()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.book_outlined, color: drawerIconColor),
          title: Text('Manage School Lesson Plans', style: TextStyle(color: drawerTextDarkGrey)), // Admin context
          onTap: () {
            Navigator.pop(context);
            // Admin might need a different view or ability to select class/teacher
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LessonPlanManagementScreen()));
          },
        ),
        ListTile( 
          leading: const Icon(Icons.campaign_outlined, color: drawerIconColor), 
          title: Text(AppLocalizations.of(context).manageAnnouncementsDrawerItem, style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdminAnnouncementsScreen()));
          },
          ),
        ListTile(
          leading: const Icon(Icons.assignment_outlined, color: drawerIconColor), 
          title: Text(AppLocalizations.of(context).manageDailyReportsDrawerItem, style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ManageCustomFormsScreen()));
          },
          ),
        ListTile(
          leading: const Icon(Icons.list_alt_outlined, color: drawerIconColor), 
          title: Text(l10n.viewFormResponsesTitle, style: TextStyle(color: drawerTextDarkGrey)), 
          onTap: () {
            Navigator.pop(context);
            if (school != null) {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewFormResponsesScreen(schoolId: school.id)));
            } else {
              // Handle case where school is null, maybe show a snackbar
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.error_school_not_selected_or_found)));
            }
          },
        ),
      ];
    }

    // Drawer items for Teacher
    List<Widget> buildTeacherDrawerItems(BuildContext context) {
      return [
        ListTile(
          leading: const Icon(Icons.dashboard, color: drawerIconColor),
          title: Text('Dashboard', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.calendar_today, color: drawerIconColor),
          title: Text('My Timetable', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TeacherTimetableScreen()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.check_circle_outline, color: drawerIconColor),
          title: Text('Mark Attendance', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AttendanceMarkingScreen()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.book_outlined, color: drawerIconColor),
          title: Text('Lesson Plans', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LessonPlanManagementScreen()));
            },
          ),
         ListTile(
          leading: const Icon(Icons.people_alt_outlined, color: drawerIconColor),
          title: Text('View Students', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            // Assuming teachers can view the same student list screen as admins for now
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StudentManagementScreen()));
          },
          ),
        ListTile(
          leading: const Icon(Icons.list_alt, color: drawerIconColor), 
          title: Text(l10n.viewFormResponsesTitle, style: TextStyle(color: drawerTextDarkGrey)), 
          onTap: () {
            Navigator.pop(context);
            // Teachers also need schoolId context for this screen
            final schoolId = schoolProvider.currentSchool?.id;
            if (schoolId != null) {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewFormResponsesScreen(schoolId: schoolId)));
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
          title: Text('Dashboard', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ParentDashboardScreen()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.check_circle, color: drawerIconColor),
          title: Text('Child\'s Attendance', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChildAttendanceScreen()));
            },
          ),
        ListTile(
          leading: const Icon(Icons.schedule, color: drawerIconColor),
          title: Text('Child\'s Schedule', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChildScheduleScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.campaign, color: drawerIconColor),
          title: Row(
            children: [
              Text(AppLocalizations.of(context).announcementsTitle, style: TextStyle(color: drawerTextDarkGrey)), 
              if (notificationService.hasNewAnnouncements)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(radius: 4, backgroundColor: Colors.red),
                )
            ],
          ),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnnouncementsScreen())).then((_){
              if (notificationService.hasNewAnnouncements) {
                 // Consider clearing flag here or within AnnouncementsScreen
              }
            });
          },
          ),
        ListTile(
          leading: const Icon(Icons.assessment_outlined, color: drawerIconColor), 
          title: Text(l10n.dailyReportsTitle, style: TextStyle(color: drawerTextDarkGrey)), 
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DailyReportScreen()));
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
          if (userRole == 'Admin') {
            drawerItems = buildAdminDrawerItems(context, currentSchool);
          } else if (userRole == 'Teacher') {
            drawerItems = buildTeacherDrawerItems(context);
          } else if (userRole == 'Parent') {
            drawerItems = buildParentDrawerItems(context);
          }

          return ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text(currentSchool?.name ?? 'EduSync User', style: TextStyle(color: drawerTextDarkGrey)),
                accountEmail: Text(authService.getCurrentUser()?.email ?? '', style: TextStyle(color: drawerTextLightGrey)),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: (currentSchool?.logoUrl != null && currentSchool!.logoUrl.isNotEmpty)
                      ? NetworkImage(currentSchool.logoUrl)
                      : null,
                  child: (currentSchool?.logoUrl == null || currentSchool!.logoUrl.isEmpty)
                      ? Icon(Icons.school, size: 40, color: drawerIconColor)
                      : null,
                ),
                decoration: BoxDecoration(
                  color: drawerAppBackgroundColor,
                ),
              ),
              ...drawerItems,
              const Divider(color: drawerTextLightGrey),
              ListTile(
                leading: const Icon(Icons.settings, color: drawerIconColor),
                title: Text('App Settings', style: TextStyle(color: drawerTextDarkGrey)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AppSettingsScreen()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: drawerIconColor),
                title: Text('Logout', style: TextStyle(color: drawerTextDarkGrey)),
                onTap: () async {
                  Navigator.pop(context);
                  await authService.signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
