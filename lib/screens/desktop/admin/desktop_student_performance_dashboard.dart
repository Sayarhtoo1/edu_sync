import 'package:flutter/material.dart';
import 'package:edu_sync/screens/admin/student_performance_dashboard.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopStudentPerformanceDashboard extends StatelessWidget {
  const DesktopStudentPerformanceDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesktopScaffold(
      title: 'Student Performance Dashboard',
      body: StudentPerformanceDashboard(),
    );
  }
}
