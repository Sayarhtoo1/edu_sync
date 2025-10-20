import 'package:flutter/material.dart';
import 'package:edu_sync/screens/admin/finance/donation_management_screen.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopDonationManagement extends StatelessWidget {
  const DesktopDonationManagement({super.key});

  @override
  Widget build(BuildContext context) {
    return const DesktopScaffold(
      title: 'Donation Management',
      body: DonationManagementScreen(),
    );
  }
}
