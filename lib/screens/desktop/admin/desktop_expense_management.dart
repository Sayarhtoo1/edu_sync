import 'package:flutter/material.dart';
import 'package:edu_sync/screens/admin/finance/expense_management_screen.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopExpenseManagement extends StatelessWidget {
  const DesktopExpenseManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesktopScaffold(
      title: 'Expense Management',
      body: ExpenseManagementScreen(),
    );
  }
}
