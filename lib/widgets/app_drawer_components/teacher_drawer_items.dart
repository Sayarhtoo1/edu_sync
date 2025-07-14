import 'package:flutter/material.dart';
import 'package:edu_sync/screens/teacher/teacher_dashboard_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_timetable_screen.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/teacher/lesson_plan_management_screen.dart';
import 'package:edu_sync/screens/admin/student_management_screen.dart';
import 'package:edu_sync/screens/admin/view_form_responses_screen.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/l10n/app_localizations.dart';

const Color drawerIconColor = Color(0xFF7A6FF0);
const Color drawerTextDarkGrey = Color(0xFF2C2C2C);

class TeacherDrawerItems extends StatelessWidget {
  const TeacherDrawerItems({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.dashboard, color: drawerIconColor),
          title: Text('Dashboard', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => TeacherDashboardScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today, color: drawerIconColor),
          title: Text('My Timetable', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => TeacherTimetableScreen()));
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
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => LessonPlanManagementScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.people_alt_outlined, color: drawerIconColor),
          title: Text('View Students', style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => StudentManagementScreen()));
          },
        ),
        ListTile(
          leading: const Icon(Icons.list_alt, color: drawerIconColor),
          title: Text(l10n.viewFormResponsesTitle, style: TextStyle(color: drawerTextDarkGrey)),
          onTap: () {
            Navigator.pop(context);
            final schoolId = schoolProvider.currentSchool?.id;
            if (schoolId != null) {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => ViewFormResponsesScreen(schoolId: schoolId)));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.error_school_not_selected_or_found)));
            }
          },
        ),
      ],
    );
  }
}
