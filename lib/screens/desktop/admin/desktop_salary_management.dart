import 'package:flutter/material.dart';
import 'package:edu_sync/screens/admin/salary_management_screen.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopSalaryManagement extends StatelessWidget {
  const DesktopSalaryManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesktopScaffold(
      title: 'Salary Management',
      body: SalaryManagementScreen(),
    );
  }
}
