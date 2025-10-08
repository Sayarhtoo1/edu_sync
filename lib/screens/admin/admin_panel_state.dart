import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/custom_form_service.dart';
import 'package:edu_sync/services/form_response_service.dart';
import 'package:edu_sync/models/form_response.dart';
import 'package:edu_sync/services/finance_service.dart';
import 'package:edu_sync/models/income.dart';
import 'package:edu_sync/models/expense.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/services/timetable_service.dart';
import 'package:edu_sync/utils/timetable_status_helper.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/utils/logger.dart';
import 'package:edu_sync/models/schedule_summary.dart';
import 'package:edu_sync/services/schedule_summary_service.dart';
import 'package:edu_sync/models/timetable.dart' as timetable_model;
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/screens/admin/admin_panel_components/admin_panel_models.dart';
import 'package:edu_sync/screens/admin/admin_panel_constants.dart'; // For accent colors
import 'package:edu_sync/screens/admin/student_management_screen.dart';
import 'package:edu_sync/screens/admin/user_management_screen.dart';
import 'package:edu_sync/screens/admin/manage_custom_forms_screen.dart';

mixin AdminPanelStateMixin<T extends StatefulWidget> on State<T> {
  late final AuthService _authService;
  late final StudentService _studentService;
  late final ClassService _classService;
  late final CustomFormService _customFormService;
  late final FormResponseService _formResponseService;
  late final FinanceService _financeService;
  late final ScheduleSummaryService _scheduleSummaryService;
  late final TimetableService _timetableService;

  bool _isLoading = true;

  List<SummaryItemData> _summaryData = [];
  Map<String, int> _studentCountsByClass = {};
  List<ActivityLogItem> _activityLogs = [];
  String? _adminProfilePhotoUrl;

  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  double _netBalance = 0.0;

  List<ScheduleSummary> _allTeachersScheduleSummaries = [];
  Timer? _adminScheduleTimer;
  List<app_user.User> _allTeachers = [];
  final Map<String, List<timetable_model.Timetable>> _teacherTimetables = {};
  Map<int, app_class.SchoolClass> _classMap = {};
  int _teachersTeachingNowCount = 0;
  int _teachersFreeNowCount = 0;

  bool get isLoading => _isLoading;
  List<SummaryItemData> get summaryData => _summaryData;
  Map<String, int> get studentCountsByClass => _studentCountsByClass;
  List<ActivityLogItem> get activityLogs => _activityLogs;
  String? get adminProfilePhotoUrl => _adminProfilePhotoUrl;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;
  double get netBalance => _netBalance;
  List<app_user.User> get allTeachers => _allTeachers;
  Map<String, List<timetable_model.Timetable>> get teacherTimetables => _teacherTimetables;
  Map<int, app_class.SchoolClass> get classMap => _classMap;
  int get teachersTeachingNowCount => _teachersTeachingNowCount;
  int get teachersFreeNowCount => _teachersFreeNowCount;

  void initializeServices(BuildContext context) {
    _authService = Provider.of<AuthService>(context, listen: false);
    _studentService = Provider.of<StudentService>(context, listen: false);
    _classService = Provider.of<ClassService>(context, listen: false);
    _customFormService = Provider.of<CustomFormService>(context, listen: false);
    _formResponseService = Provider.of<FormResponseService>(context, listen: false);
    _financeService = Provider.of<FinanceService>(context, listen: false);
    _scheduleSummaryService = Provider.of<ScheduleSummaryService>(context, listen: false);
    _timetableService = TimetableService();
  }

  void startScheduleTimer() {
    _adminScheduleTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateAllTeachersScheduleSummaries();
    });
  }

  void cancelScheduleTimer() {
    _adminScheduleTimer?.cancel();
  }

  Future<void> loadDashboardData(BuildContext context) async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);

    if (schoolProvider.currentSchool == null && _authService.getCurrentUser() != null) {
      await schoolProvider.fetchCurrentSchool();
    }
    
    if (!mounted) return;
    final School? currentSchool = schoolProvider.currentSchool;

    if (currentSchool != null) {
      try {
        await _loadFinancialSummary(currentSchool.id);

        final allClasses = await _classService.getClasses(currentSchool.id);
        _classMap = {for (var cls in allClasses) cls.id!: cls};

        _allTeachers = await _authService.getUsersByRole(UserRole.Teacher, currentSchool.id);
        final parents = await _authService.getUsersByRole(UserRole.Parent, currentSchool.id);
        final students = await _studentService.getStudentsBySchool(currentSchool.id);
        final activeForms = await _customFormService.getCustomFormsForSchool(currentSchool.id);
        int formsTodayCount = activeForms.where((form) {
              final today = DateTime.now();
              return form.activeFrom.isBefore(today.add(const Duration(days: 1))) &&
                     form.activeTo.isAfter(today.subtract(const Duration(days: 1)));
        }).length;

        _teacherTimetables.clear();
        int teachingNow = 0;
        int freeNow = 0;
        final now = DateTime.now();

        for (var teacher in _allTeachers) {
          final timetables = await _timetableService.getTimetableForTeacher(teacher.id);
          _teacherTimetables[teacher.id] = timetables;

          timetable_model.Timetable? currentEntry;
          final todayEntries = timetables
              .where((entry) => TimetableStatusHelper.convertDayOfWeekStringToInt(entry.dayOfWeek) == now.weekday)
              .toList();
          todayEntries.sort((a, b) => a.startTimeString.compareTo(b.startTimeString));

          for (var entry in todayEntries) {
            final status = TimetableStatusHelper.getStatusForTimetableEntry(entry, now);
            if (status == TimetableStatus.inProcess) {
              currentEntry = entry;
              break;
            }
          }

          if (currentEntry != null) {
            teachingNow++;
          } else {
            freeNow++;
          }
                }
        _teachersTeachingNowCount = teachingNow;
        _teachersFreeNowCount = freeNow;

        final List<app_class.SchoolClass> schoolClasses = await _classService.getClasses(currentSchool.id);
        Map<String, int> studentCounts = {};
        Map<int?, String> classNameMap = {for (var c in schoolClasses) c.id: c.name};
        classNameMap[null] = l10n?.unassigned ?? 'Unassigned';

        for (var student in students) {
          String className = classNameMap[student.classId] ?? l10n?.unknown_class ?? 'Unknown Class';
          studentCounts[className] = (studentCounts[className] ?? 0) + 1;
        }
        
        setState(() {
          _summaryData = [
            SummaryItemData(
              title: l10n?.students ?? 'Students',
              count: students.length.toString(),
              icon: Icons.school_outlined,
              backgroundColor: accentStudents,
              iconBackgroundColor: iconBgStudents,
              iconColor: iconColorStudents,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const StudentManagementScreen()));
              },
            ),
            SummaryItemData(
              title: l10n?.teachers ?? 'Teachers',
              count: _allTeachers.length.toString(),
              icon: Icons.person_outline,
              backgroundColor: accentTeachers,
              iconBackgroundColor: iconBgTeachers,
              iconColor: iconColorTeachers,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserManagementScreen(initialTabIndex: 0)));
              },
            ),
            SummaryItemData(
              title: l10n?.parents ?? 'Parents',
              count: parents.length.toString(),
              icon: Icons.group_outlined,
              backgroundColor: accentParents,
              iconBackgroundColor: iconBgParents,
              iconColor: iconColorParents,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const UserManagementScreen(initialTabIndex: 1)));
              },
            ),
            SummaryItemData(
              title: l10n?.formsToday ?? 'Forms Today',
              count: formsTodayCount.toString(),
              icon: Icons.article_outlined,
              backgroundColor: accentEarnings,
              iconBackgroundColor: iconBgEarnings,
              iconColor: iconColorEarnings,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ManageCustomFormsScreen()));
              },
            ),
          ];
          _studentCountsByClass = studentCounts;
        });

        final List<FormResponse> recentResponses = await _formResponseService.getRecentResponses(currentSchool.id, limit: 3);
        List<ActivityLogItem> activities = [];
        for (var response in recentResponses) {
          final studentDetails = await _studentService.getStudentById(response.studentId, currentSchool.id);
          activities.add(ActivityLogItem(
            icon: Icons.check_circle_outline,
            message: "${studentDetails?.fullName ?? 'A student'} submitted a report.",
            timestamp: DateFormat('h:mm a').format(response.submittedAt.toLocal()),
          ));
        }
         _activityLogs = activities;

        final currentAuthUser = _authService.getCurrentUser();
        if (currentAuthUser != null) {
          final adminUserDetails = await _authService.getUserById(currentAuthUser.id);
          if (mounted) {
            setState(() {
              _adminProfilePhotoUrl = adminUserDetails?.profilePhotoUrl;
            });
          }
        }

      } catch (e) {
        logger.e("Error loading dashboard data: $e");
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading data: $e")));
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFinancialSummary(int schoolId) async {
    if (!mounted) return;
    try {
      final List<Income> incomeRecords = await _financeService.getIncomes(schoolId);
      final List<Expense> expenseRecords = await _financeService.getExpenses(schoolId);

      double currentTotalIncome = incomeRecords.fold(0.0, (sum, item) => sum + item.amount);
      double currentTotalExpenses = expenseRecords.fold(0.0, (sum, item) => sum + item.amount);
      double currentNetBalance = currentTotalIncome - currentTotalExpenses;

      if (mounted) {
        setState(() {
          _totalIncome = currentTotalIncome;
          _totalExpenses = currentTotalExpenses;
          _netBalance = currentNetBalance;
        });
      }
    } catch (e) {
      logger.e("Error loading financial summary: $e");
    }
  }

  Future<void> _updateAllTeachersScheduleSummaries() async {
    if (!mounted) return;
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final l10n = AppLocalizations.of(context);
    final School? currentSchool = schoolProvider.currentSchool;

    if (currentSchool != null) {
      try {
        final summaries = await _scheduleSummaryService.getAllTeachersScheduleSummary(DateTime.now());
        setState(() {
          _allTeachersScheduleSummaries = summaries;
        });
      } catch (e) {
        logger.e("Error fetching all teachers' schedule summaries: $e");
        if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${l10n?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}")));
      }
    }
  }
}
