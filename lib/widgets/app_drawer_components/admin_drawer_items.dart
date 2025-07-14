import 'package:flutter/material.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/screens/admin/edit_school_profile_screen.dart';
import 'package:edu_sync/screens/admin/user_management_screen.dart';
import 'package:edu_sync/screens/admin/student_management_screen.dart';
import 'package:edu_sync/screens/admin/class_management_screen.dart';
import 'package:edu_sync/screens/admin/timetable_management_screen.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/teacher/lesson_plan_management_screen.dart';
import 'package:edu_sync/screens/admin/admin_announcements_screen.dart';
import 'package:edu_sync/screens/admin/manage_custom_forms_screen.dart';
import 'package:edu_sync/screens/admin/view_form_responses_screen.dart';
import 'package:edu_sync/screens/admin/finance_overview_screen.dart';
import 'package:edu_sync/l10n/app_localizations.dart';

const Color drawerIconColor = Color(0xFF7A6FF0);
const Color drawerTextDarkGrey = Color(0xFF2C2C2C);
const Color drawerTextLightGrey = Color(0xFF8C8C8C);

class AdminDrawerItems extends StatelessWidget {
  final School? school;

  const AdminDrawerItems({super.key, required this.school});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (school != null)
          ListTile(
            leading: const Icon(Icons.edit_note, color: drawerIconColor),
            title: Text('Edit School Profile', style: TextStyle(color: drawerTextDarkGrey)),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditSchoolProfileScreen(school: school!)));
            },
          ),
        ListTile(
          leading: const Icon(Icons.people, color: drawerIconColor),
          title: Text('User Management', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => UserManagementScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.school_outlined, color: drawerIconColor),
          title: Text('Student Management', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudentManagementScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.class_, color: drawerIconColor),
          title: Text('Class Management', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ClassManagementScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today, color: drawerIconColor),
          title: Text('Timetable Management', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => TimetableManagementScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.monetization_on, color: drawerIconColor),
          title: Text('Finance Overview', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => FinanceOverviewScreen()));
          },
        ),
        const Divider(indent: 16, endIndent: 16),
        ListTile(
          leading: const Icon(Icons.check_circle_outline, color: drawerIconColor),
          title: Text('Mark School Attendance', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => AttendanceMarkingScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.book_outlined, color: drawerIconColor),
          title: Text('Manage School Lesson Plans', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonPlanManagementScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.campaign_outlined, color: drawerIconColor),
          title: Text(l10n.manageAnnouncementsDrawerItem, style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminAnnouncementsScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.assignment_outlined, color: drawerIconColor),
          title: Text(l10n.manageDailyReportsDrawerItem, style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => ManageCustomFormsScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.list_alt_outlined, color: drawerIconColor),
          title: Text(l10n.viewFormResponsesTitle, style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            if (school != null) {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewFormResponsesScreen(schoolId: school!.id)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.error_school_not_selected_or_found)));
            }
          },
        ),
      ],
    );
  }
}
