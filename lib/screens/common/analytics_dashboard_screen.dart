import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/gen/app_localizations.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/school_provider.dart';
import '../../providers/class_provider.dart';
import '../../models/school_class.dart';
import '../../models/user_role.dart'; // Assuming UserRole enum is defined
import '../../services/auth_service.dart'; // Assuming AuthService to get current user role
import 'analytics_dashboard_components/overall_performance_tab.dart';
import 'analytics_dashboard_components/subject_analysis_tab.dart';
import 'analytics_dashboard_components/student_progress_tab.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SchoolClass? _selectedClass;
  UserRole? _currentUserRole;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeUserAndData();
  }

  Future<void> _initializeUserAndData() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.getCurrentUser();
    if (user != null) {
      _currentUserId = user.id;
      final userRoleString = await authService.getUserRole();
      setState(() {
        _currentUserRole = UserRole.fromString(userRoleString);
      });
    }
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final analyticsProvider = Provider.of<AnalyticsProvider>(context, listen: false);

    final schoolId = schoolProvider.currentSchool?.id;

    if (schoolId != null) {
      if (_currentUserRole == UserRole.Admin) {
        await analyticsProvider.fetchSchoolPerformanceOverview(schoolId);
        await analyticsProvider.fetchSubjectPerformance(schoolId: schoolId);
      } else if (_currentUserRole == UserRole.Teacher && _selectedClass != null) {
        await analyticsProvider.fetchClassPerformanceOverview(_selectedClass!.id!);
        await analyticsProvider.fetchSubjectPerformance(classId: _selectedClass!.id!);
      }
      // Student progress will be fetched on demand for a specific student
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    // No need to listen to AnalyticsProvider at the top level, as it's consumed by tabs
    // final analyticsProvider = Provider.of<AnalyticsProvider>(context);

    final schoolId = schoolProvider.currentSchool?.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.analyticsDashboardTitle),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.overallPerformanceTab),
            Tab(text: localizations.subjectAnalysisTab),
            Tab(text: localizations.studentProgressTab),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_currentUserRole == UserRole.Admin && schoolProvider.schoolClasses.isNotEmpty)
              DropdownButtonFormField<SchoolClass>(
                decoration: InputDecoration(
                  labelText: localizations.filterByClass,
                  border: const OutlineInputBorder(),
                ),
                value: _selectedClass,
                items: [
                  DropdownMenuItem<SchoolClass>(
                    value: null,
                    child: Text(localizations.allClasses),
                  ),
                  ...schoolProvider.schoolClasses.map((e) => DropdownMenuItem<SchoolClass>(
                    value: e,
                    child: Text(e.name),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value;
                    _fetchInitialData(); // Refetch data based on new class selection
                  });
                },
              ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  OverallPerformanceTab(
                    currentUserRole: _currentUserRole,
                    selectedClass: _selectedClass,
                  ),
                  const SubjectAnalysisTab(),
                  const StudentProgressTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}