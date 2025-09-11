import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/bottom_section.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/charts.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/financial_summary_card.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/greeting_section.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/quick_actions_section.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/summary_grid.dart';
import 'package:edu_sync/screens/admin/admin_panel_components/admin_panel_models.dart';
import 'package:edu_sync/widgets/app_drawer.dart';
import 'package:edu_sync/widgets/hijri_calendar_card.dart';
import 'package:edu_sync/utils/timetable_status_helper.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/models/timetable.dart' as timetable_model;
import 'package:edu_sync/screens/admin/admin_panel_constants.dart';
import 'package:edu_sync/screens/admin/admin_panel_state.dart';
import 'package:edu_sync/screens/admin/finance_overview_screen.dart'; // Re-add FinanceOverviewScreen import

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with AdminPanelStateMixin<AdminPanelScreen> {
  @override
  void initState() {
    super.initState();
    initializeServices(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDashboardData(context);
      startScheduleTimer();
    });
  }

  @override
  void dispose() {
    cancelScheduleTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDarkGrey),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none_outlined), onPressed: () { /* Handle notification tap */ }),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: adminProfilePhotoUrl != null && adminProfilePhotoUrl!.isNotEmpty 
                  ? NetworkImage(adminProfilePhotoUrl!) 
                  : null,
              child: (adminProfilePhotoUrl == null || adminProfilePhotoUrl!.isEmpty) 
                  ? const Icon(Icons.person, size: 18) 
                  : null,
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(iconColorStudents)))
          : RefreshIndicator(
              onRefresh: () => loadDashboardData(context),
              color: iconColorStudents,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const GreetingSection(),
                      const SizedBox(height: 24),
                      HijriCalendarCard(),
                      const SizedBox(height: 24),
                      const SizedBox(height: 24),
                      SummaryGrid(summaryData: summaryData),
                      const SizedBox(height: 24),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const FinanceOverviewScreen(),)),
                        child: FinancialSummaryCard(
                          totalIncome: totalIncome,
                          totalExpenses: totalExpenses,
                          netBalance: netBalance,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const QuickActionsSection(),
                      const SizedBox(height: 24),
                      ChartsSection(studentCountsByClass: studentCountsByClass),
                      const SizedBox(height: 24),
                      BottomSection(
                        activityLogs: activityLogs,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
