import 'package:flutter/material.dart';
import 'package:edu_sync/screens/admin/finance/income_management_screen.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopIncomeManagement extends StatelessWidget {
  const DesktopIncomeManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesktopScaffold(
      title: 'Income Management',
      body: IncomeManagementScreen(),
    );
  }
}
