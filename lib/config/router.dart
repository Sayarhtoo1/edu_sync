import 'package:edu_sync/screens/admin/staff_management_screen.dart';
import 'package:edu_sync/screens/admin/parent_management_screen.dart';
import 'package:edu_sync/screens/admin/school_profile_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:edu_sync/utils/logger.dart'; // Import logger

import 'package:edu_sync/models/school.dart' as app_school;
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/providers/school_provider.dart'; // Corrected import
import 'package:edu_sync/services/auth_service.dart';

import 'package:edu_sync/screens/splash_screen.dart';
import 'package:edu_sync/screens/desktop/common/desktop_splash_screen.dart';
import 'package:edu_sync/screens/auth/login_screen.dart';
import 'package:edu_sync/screens/desktop/auth/desktop_login_screen.dart';
import 'package:edu_sync/screens/auth/reset_password_screen.dart';
import 'package:edu_sync/screens/desktop/auth/desktop_reset_password_screen.dart';
import 'package:edu_sync/screens/auth/register_screen.dart';
import 'package:edu_sync/screens/desktop/auth/desktop_register_screen.dart';
import 'package:edu_sync/screens/admin/modern_admin_dashboard.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_admin_dashboard.dart';
import 'package:edu_sync/widgets/common/platform_adaptive_screen.dart';
import 'package:edu_sync/screens/teacher/modern_teacher_dashboard.dart';
import 'package:edu_sync/screens/teacher/teacher_student_management_screen.dart';
import 'package:edu_sync/screens/parent/modern_parent_dashboard.dart';
import 'package:edu_sync/screens/manager/manager_dashboard_screen.dart';
import 'package:edu_sync/screens/admin/user_management_screen.dart';
import 'package:edu_sync/screens/admin/student_management_screen.dart'; // Corrected import
import 'package:edu_sync/screens/admin/view_form_responses_screen.dart';
import 'package:edu_sync/screens/admin/class_management_screen.dart';
import 'package:edu_sync/screens/admin/timetable_management_screen.dart';
import 'package:edu_sync/screens/admin/edit_school_profile_screen.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/teacher/lesson_plan_management_screen.dart';
import 'package:edu_sync/screens/admin/admin_announcements_screen.dart';
import 'package:edu_sync/screens/admin/manage_custom_forms_screen.dart';
import 'package:edu_sync/screens/admin/admin_settings_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_timetable_screen.dart';
import 'package:edu_sync/screens/parent/child_attendance_screen.dart';
import 'package:edu_sync/screens/parent/child_schedule_screen.dart';
import 'package:edu_sync/screens/parent/announcements_screen.dart';
import 'package:edu_sync/screens/parent/daily_report_screen.dart';
import 'package:edu_sync/screens/settings/app_settings_screen.dart';
import 'package:edu_sync/screens/common/analytics_dashboard_screen.dart';
import 'package:edu_sync/screens/student/exam/modern_report_card_screen.dart';
import 'package:edu_sync/screens/desktop/student/exam/desktop_modern_report_card.dart';
import 'package:edu_sync/screens/student/student_profile_screen.dart';
import 'package:edu_sync/screens/staff/staff_profile_screen.dart';
import 'package:edu_sync/models/staff.dart' as model;
import 'package:edu_sync/models/student.dart' as model;

// Import new exam screens
import 'package:edu_sync/screens/admin/exam/exam_list_screen.dart';
import 'package:edu_sync/screens/admin/exam/exam_overview_screen.dart';
import 'package:edu_sync/screens/admin/exam/exam_form_screen.dart';
import 'package:edu_sync/screens/admin/exam/exam_subject_management_screen.dart';
import 'package:edu_sync/screens/admin/exam/subject_management_screen.dart';
import 'package:edu_sync/screens/admin/exam/grade_management_screen.dart';
import 'package:edu_sync/screens/admin/exam/unified_marks_entry_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_marks_entry_selection_screen.dart';
import 'package:edu_sync/screens/common/report_card_screen.dart';
import 'package:edu_sync/screens/admin/exam/exam_analytics_screen.dart';
import 'package:edu_sync/screens/admin/exam/exam_calendar_screen.dart';
import 'package:edu_sync/screens/settings/exam_notification_preferences_screen.dart';
import 'package:edu_sync/screens/admin/exam/exam_template_screen.dart';
import 'package:edu_sync/screens/student/student_performance_screen.dart';
import 'package:edu_sync/screens/parent/child_exam_schedule_screen.dart';
import 'package:edu_sync/screens/admin/exam/marks_approval_screen.dart';
import 'package:edu_sync/screens/admin/exam/all_report_cards_screen.dart';
import 'package:edu_sync/screens/desktop/admin/exam/desktop_all_report_cards.dart';
import 'package:edu_sync/models/exam.dart' as exam_model;
import 'package:edu_sync/screens/admin/fee/fee_structure_management_screen.dart';
import 'package:edu_sync/screens/admin/finance/donation_management_screen.dart';
import 'package:edu_sync/screens/admin/salary_management_screen.dart';
import 'package:edu_sync/screens/admin/finance/finance_overview_screen.dart';
import 'package:edu_sync/screens/admin/finance/enhanced_finance_overview_screen.dart';
import 'package:edu_sync/screens/admin/finance/income_management_screen.dart';
import 'package:edu_sync/screens/admin/finance/expense_management_screen.dart';
import 'package:edu_sync/screens/admin/finance/fee_payment_management_screen.dart';
import 'package:edu_sync/screens/admin/finance/add_edit_fee_payment_screen.dart';
import 'package:edu_sync/screens/admin/finance/category_management_screen.dart';
import 'package:edu_sync/screens/admin/finance/add_edit_category_screen.dart';
import 'package:edu_sync/models/fee_payment.dart';
import 'package:edu_sync/models/finance_category.dart';
import 'package:edu_sync/screens/admin/finance/financial_reports_screen.dart';
import 'package:edu_sync/screens/admin/finance/profit_loss_report_screen.dart';
import 'package:edu_sync/screens/admin/finance/cash_flow_report_screen.dart';
import 'package:edu_sync/screens/admin/finance/fee_collection_report_screen.dart';
import 'package:edu_sync/screens/donator/modern_donator_dashboard.dart';
import 'package:edu_sync/screens/admin/staff_status_overview_screen.dart';
import 'package:edu_sync/screens/admin/staff_attendance_summary_screen.dart';
import 'package:edu_sync/screens/common/enhanced_student_attendance_summary.dart';
import 'package:edu_sync/services/notification_service.dart';

// Desktop screen imports
import 'package:edu_sync/screens/desktop/admin/desktop_admin_announcements.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_admin_dashboard.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_admin_settings.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_class_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_donation_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_expense_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_grade_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_income_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_manage_custom_forms.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_salary_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_school_profile.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_staff_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_parent_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_staff_status_overview.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_student_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_subject_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_timetable_management.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_user_management.dart';
import 'package:edu_sync/screens/desktop/admin/exam/desktop_exam_form.dart';
import 'package:edu_sync/screens/desktop/admin/exam/desktop_exam_list.dart';
import 'package:edu_sync/screens/desktop/admin/exam/desktop_edit_exam_basic.dart';
import 'package:edu_sync/screens/desktop/admin/exam/desktop_edit_exam_classes.dart';
import 'package:edu_sync/screens/desktop/admin/exam/desktop_edit_exam_subjects.dart';
import 'package:edu_sync/screens/desktop/admin/exam/desktop_exam_calendar.dart';
import 'package:edu_sync/screens/desktop/admin/exam/desktop_exam_analytics.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_exam_overview.dart';
import 'package:edu_sync/screens/admin/exam/edit_exam_basic_screen.dart';
import 'package:edu_sync/screens/admin/exam/edit_exam_classes_screen.dart';
import 'package:edu_sync/screens/admin/exam/edit_exam_subjects_screen.dart';
import 'package:edu_sync/screens/desktop/admin/fee/desktop_fee_structure_management.dart';
import 'package:edu_sync/screens/desktop/admin/finance/desktop_finance_overview.dart';
import 'package:edu_sync/screens/desktop/admin/finance/desktop_financial_reports.dart';
import 'package:edu_sync/screens/desktop/donator/desktop_donator_dashboard.dart';
import 'package:edu_sync/screens/desktop/manager/desktop_manager_dashboard.dart';
import 'package:edu_sync/screens/desktop/parent/desktop_announcements.dart';
import 'package:edu_sync/screens/desktop/parent/desktop_child_attendance.dart';
import 'package:edu_sync/screens/desktop/parent/desktop_child_schedule.dart';
import 'package:edu_sync/screens/desktop/parent/desktop_parent_dashboard.dart';
import 'package:edu_sync/screens/desktop/teacher/desktop_attendance_marking.dart';
import 'package:edu_sync/screens/desktop/teacher/desktop_lesson_plan_management.dart';
import 'package:edu_sync/screens/desktop/teacher/desktop_teacher_dashboard.dart';
import 'package:edu_sync/screens/desktop/teacher/desktop_teacher_student_management.dart';
import 'package:edu_sync/screens/desktop/teacher/desktop_teacher_timetable.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_marks_entry_screen.dart';
import 'package:edu_sync/screens/desktop/student/desktop_student_profile.dart';
import 'package:edu_sync/screens/desktop/staff/desktop_staff_profile.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_class_profile.dart';
import 'package:edu_sync/screens/admin/student_performance_dashboard.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_student_performance_dashboard.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_teacher_status_overview.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_whole_school_schedule.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_staff_attendance_summary.dart';
import 'package:edu_sync/screens/admin/class_profile_screen.dart';
import 'package:edu_sync/models/school_class.dart';

// A class that converts a stream into a listenable for GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<AuthState> _subscription;

  GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter initializeRouter() {
  return GoRouter(
    navigatorKey: NotificationService.navigatorKey,
    refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    redirect: (BuildContext context, GoRouterState state) async {
      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
        final connectivity = Provider.of<Connectivity>(context, listen: false);
        
        // Skip redirect for non-auth routes when already logged in
        if (authService.getCurrentUser() != null && 
            !state.matchedLocation.startsWith('/login') && 
            !state.matchedLocation.startsWith('/reset-password') &&
            state.matchedLocation != '/') {
          return null;
        }

      // Handle deep links for password recovery.
      // Only check the initial link when we're on the splash route ('/') to avoid repeated async work
      // and potential redirect loops. Wrap in try/catch to be safe.
      if (state.matchedLocation == '/') {
        try {
          final appLinks = AppLinks();
          final initialLink = await appLinks.getInitialLink();
          if (initialLink != null) {
            logger.i('Deep link received: ${initialLink.toString()}');
            logger.i('Deep link scheme: ${initialLink.scheme}');
            logger.i('Deep link host: ${initialLink.host}');
            logger.i('Deep link path: ${initialLink.path}');
            logger.i('Deep link query parameters: ${initialLink.queryParameters}');
            if (initialLink.scheme == 'com.example.edusync' && initialLink.host == 'reset-password') {
              // Only navigate to reset-password if the current matched location isn't already the reset-password route.
              if (state.matchedLocation != '/reset-password') {
                return '/reset-password';
              }
            }
          }
        } catch (e, st) {
          logger.w('Error while checking initial deep link: $e');
          logger.w(st.toString());
        }
      }

  final loggedIn = authService.getCurrentUser() != null;
  final goingToLogin = state.matchedLocation == '/login';
  final goingToResetPassword = state.matchedLocation == '/reset-password';

  // Debug logs to trace redirect decisions
  logger.i('Router redirect: matchedLocation=${state.matchedLocation}, loggedIn=$loggedIn, goingToLogin=$goingToLogin, goingToResetPassword=$goingToResetPassword');


      // If not logged in, and not going to login or reset password, redirect to login
      if (!loggedIn && !goingToLogin && !goingToResetPassword) {
        return '/login';
      }

      // If logged in, but going to login or reset password, redirect to dashboard
      if (loggedIn && state.matchedLocation == '/') {
        final connectivityResult = await connectivity.checkConnectivity();
        final isOnline = !connectivityResult.contains(ConnectivityResult.none);
        
        if (isOnline) {
          await schoolProvider.fetchCurrentSchool();
        }
        
        final role = await authService.getUserRole();

        if (role == UserRole.Admin.name) {
          return '/admin';
        } else if (role == UserRole.Teacher.name) {
          return '/teacher-dashboard';
        } else if (role == UserRole.Parent.name) {
          return '/parent-dashboard';
        } else if (role == UserRole.Manager.name) {
          return '/manager-dashboard';
        } else if (role == UserRole.Donator.name) {
          return '/donator-dashboard';
        }
        
        // If role is null (offline and no cache), stay on splash
        return null;
      }

      if (loggedIn && goingToLogin) {
        final connectivityResult = await connectivity.checkConnectivity();
        final isOnline = !connectivityResult.contains(ConnectivityResult.none);
        
        if (isOnline) {
          await schoolProvider.fetchCurrentSchool();
        }
        
        final role = await authService.getUserRole();

        if (role == UserRole.Admin.name) {
          return '/admin';
        } else if (role == UserRole.Teacher.name) {
          return '/teacher-dashboard';
        } else if (role == UserRole.Parent.name) {
          return '/parent-dashboard';
        } else if (role == UserRole.Manager.name) {
          return '/manager-dashboard';
        } else if (role == UserRole.Donator.name) {
          return '/donator-dashboard';
        }
        
        // If role is null, allow staying on login
        return null;
      }

      // No redirect needed
      return null;
      } catch (e) {
        logger.e('Router redirect error: $e');
        return null;
      }
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: SplashScreen(),
          desktopScreen: DesktopSplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: LoginScreen(),
          desktopScreen: DesktopLoginScreen(),
        ),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ResetPasswordScreen(),
          desktopScreen: DesktopResetPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ModernAdminDashboard(),
          desktopScreen: DesktopAdminDashboard(),
        ),
      ),
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ModernTeacherDashboard(),
          desktopScreen: DesktopTeacherDashboard(),
        ),
      ),
      GoRoute(
        path: '/parent-dashboard',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ModernParentDashboard(),
          desktopScreen: DesktopParentDashboard(),
        ),
      ),
      GoRoute(
        path: '/manager-dashboard',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ManagerDashboardScreen(),
          desktopScreen: DesktopManagerDashboard(),
        ),
      ),
      GoRoute(
        path: '/admin/edit-school-profile',
        builder: (context, state) => EditSchoolProfileScreen(school: state.extra as app_school.School),
      ),
      GoRoute(
        path: '/admin/school-profile',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: SchoolProfileScreen(),
          desktopScreen: DesktopSchoolProfile(),
        ),
      ),
      GoRoute(
        path: '/admin/user-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: UserManagementScreen(),
          desktopScreen: DesktopUserManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/staff-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: StaffManagementScreen(),
          desktopScreen: DesktopStaffManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/parent-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ParentManagementScreen(),
          desktopScreen: DesktopParentManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/staff-status',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: StaffStatusOverviewScreen(),
          desktopScreen: DesktopStaffStatusOverview(),
        ),
      ),
      GoRoute(
        path: '/admin/staff-attendance-summary',
        name: 'staff-attendance-summary',
        builder: (context, state) => const StaffAttendanceSummaryScreen(),
      ),
      GoRoute(
        path: '/admin/teacher-status',
        name: 'teacher-status-overview',
        builder: (context, state) => const DesktopTeacherStatusOverview(),
      ),
      GoRoute(
        path: '/admin/whole-school-schedule',
        name: 'whole-school-schedule',
        builder: (context, state) => const DesktopWholeSchoolSchedule(),
      ),
      GoRoute(
        path: '/admin/student-attendance-summary',
        name: 'student-attendance-summary',
        builder: (context, state) => const EnhancedStudentAttendanceSummary(),
      ),
      GoRoute(
        path: '/admin/student-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: StudentManagementScreen(),
          desktopScreen: DesktopStudentManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/class-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ClassManagementScreen(),
          desktopScreen: DesktopClassManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/timetable-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: TimetableManagementScreen(),
          desktopScreen: DesktopTimetableManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/finance-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: FinanceOverviewScreen(),
          desktopScreen: DesktopFinanceOverview(),
        ),
      ),
      GoRoute(
        path: '/admin/finance-dashboard',
        name: 'finance-dashboard',
        builder: (context, state) => const EnhancedFinanceOverviewScreen(),
      ),
      GoRoute(
        path: '/admin/income-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: IncomeManagementScreen(),
          desktopScreen: DesktopIncomeManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/expense-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ExpenseManagementScreen(),
          desktopScreen: DesktopExpenseManagement(),
        ),
      ),
      GoRoute(
        path: '/teacher/attendance-marking',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: AttendanceMarkingScreen(),
          desktopScreen: DesktopAttendanceMarking(),
        ),
      ),
      GoRoute(
        path: '/teacher/student-attendance-summary',
        name: 'teacher-student-attendance-summary',
        builder: (context, state) => const EnhancedStudentAttendanceSummary(),
      ),
      GoRoute(
        path: '/teacher/lesson-plan-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: LessonPlanManagementScreen(),
          desktopScreen: DesktopLessonPlanManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/announcements',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: AdminAnnouncementsScreen(),
          desktopScreen: DesktopAdminAnnouncements(),
        ),
      ),
      GoRoute(
        path: '/admin/manage-custom-forms',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ManageCustomFormsScreen(),
          desktopScreen: DesktopManageCustomForms(),
        ),
      ),
      GoRoute(
        path: '/admin/view-form-responses',
        builder: (context, state) => ViewFormResponsesScreen(schoolId: state.extra as int),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: AdminSettingsScreen(),
          desktopScreen: DesktopAdminSettings(),
        ),
      ),
      GoRoute(
        path: '/teacher/timetable',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: TeacherTimetableScreen(),
          desktopScreen: DesktopTeacherTimetable(),
        ),
      ),
      GoRoute(
        path: '/teacher/students',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: TeacherStudentManagementScreen(),
          desktopScreen: DesktopTeacherStudentManagement(),
        ),
      ),
      GoRoute(
        path: '/parent/child-attendance',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ChildAttendanceScreen(),
          desktopScreen: DesktopChildAttendance(),
        ),
      ),
      GoRoute(
        path: '/parent/child-schedule',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ChildScheduleScreen(),
          desktopScreen: DesktopChildSchedule(),
        ),
      ),
      GoRoute(
        path: '/parent/announcements',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: AnnouncementsScreen(),
          desktopScreen: DesktopAnnouncements(),
        ),
      ),
      GoRoute(
        path: '/parent/daily-report',
        builder: (context, state) => const DailyReportScreen(),
      ),
      GoRoute(
        path: '/app-settings',
        builder: (context, state) => const AppSettingsScreen(),
      ),
      GoRoute(
        path: '/analytics-dashboard',
        builder: (context, state) => const AnalyticsDashboardScreen(),
      ),
      GoRoute(
        path: '/parent/report-card/:studentId/:examId',
        builder: (context, state) {
          final studentId = state.pathParameters['studentId']!;
          final examId = state.pathParameters['examId']!;
          return PlatformAdaptiveScreen(
            mobileScreen: ModernReportCardScreen(studentId: studentId, examId: examId),
            desktopScreen: DesktopModernReportCard(studentId: studentId, examId: examId),
          );
        },
      ),
      GoRoute(
        path: '/report-card/:studentId/:examId',
        name: 'report-card',
        builder: (context, state) {
          final studentId = state.pathParameters['studentId']!;
          final examId = state.pathParameters['examId']!;
          return PlatformAdaptiveScreen(
            mobileScreen: ModernReportCardScreen(studentId: studentId, examId: examId),
            desktopScreen: DesktopModernReportCard(studentId: studentId, examId: examId),
          );
        },
      ),
      GoRoute(
        path: '/student/profile',
        builder: (context, state) {
          final student = state.extra as model.Student?;
          if (student == null) {
            return const Scaffold(
              body: Center(child: Text('Student not found')),
            );
          }
          return PlatformAdaptiveScreen(
            mobileScreen: StudentProfileScreen(student: student),
            desktopScreen: DesktopStudentProfile(student: student),
          );
        },
      ),
      GoRoute(
        path: '/staff/profile',
        builder: (context, state) => PlatformAdaptiveScreen(
          mobileScreen: StaffProfileScreen(staff: state.extra as model.Staff),
          desktopScreen: DesktopStaffProfile(staff: state.extra as model.Staff),
        ),
      ),
      GoRoute(
        path: '/admin/class-profile',
        name: 'class-profile',
        builder: (context, state) => PlatformAdaptiveScreen(
          mobileScreen: ClassProfileScreen(schoolClass: state.extra as SchoolClass),
          desktopScreen: DesktopClassProfile(schoolClass: state.extra as SchoolClass),
        ),
      ),
      GoRoute(
        path: '/admin/student-performance',
        name: 'student-performance',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: StudentPerformanceDashboard(),
          desktopScreen: DesktopStudentPerformanceDashboard(),
        ),
      ),
      // New exam module routes
      GoRoute(
        path: '/admin/exam-overview',
        name: 'exam-overview',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ExamOverviewScreen(),
          desktopScreen: DesktopExamOverview(),
        ),
      ),
      GoRoute(
        path: '/admin/exam-management',
        name: 'exam-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ExamListScreen(),
          desktopScreen: DesktopExamList(),
        ),
      ),
      GoRoute(
        path: '/admin/exam-form',
        name: 'exam-form',
        builder: (context, state) => PlatformAdaptiveScreen(
          mobileScreen: ExamFormScreen(exam: state.extra as dynamic),
          desktopScreen: DesktopExamForm(exam: state.extra as dynamic),
        ),
      ),
      GoRoute(
        path: '/admin/edit-exam-basic',
        name: 'edit-exam-basic',
        builder: (context, state) => PlatformAdaptiveScreen(
          mobileScreen: EditExamBasicScreen(exam: state.extra as exam_model.Exam),
          desktopScreen: DesktopEditExamBasic(exam: state.extra as exam_model.Exam),
        ),
      ),
      GoRoute(
        path: '/admin/edit-exam-classes',
        name: 'edit-exam-classes',
        builder: (context, state) => PlatformAdaptiveScreen(
          mobileScreen: EditExamClassesScreen(exam: state.extra as exam_model.Exam),
          desktopScreen: DesktopEditExamClasses(exam: state.extra as exam_model.Exam),
        ),
      ),
      GoRoute(
        path: '/admin/edit-exam-subjects',
        name: 'edit-exam-subjects',
        builder: (context, state) => PlatformAdaptiveScreen(
          mobileScreen: EditExamSubjectsScreen(exam: state.extra as exam_model.Exam),
          desktopScreen: DesktopEditExamSubjects(exam: state.extra as exam_model.Exam),
        ),
      ),
      GoRoute(
        path: '/admin/exam-subject-management',
        name: 'exam-subject-management',
        builder: (context, state) => ExamSubjectManagementScreen(exam: state.extra as exam_model.Exam),
      ),
      GoRoute(
        path: '/admin/subject-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: SubjectManagementScreen(),
          desktopScreen: DesktopSubjectManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/grade-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: GradeManagementScreen(),
          desktopScreen: DesktopGradeManagement(),
        ),
      ),
      GoRoute(
        path: '/exam-management/create',
        builder: (context, state) => const ExamFormScreen(),
      ),
      GoRoute(
        path: '/exam-management/edit/:examId',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          return ExamFormScreen(exam: state.extra as exam_model.Exam?);
        },
      ),
      GoRoute(
        path: '/admin/marks-entry/:examId',
        name: 'marks-entry',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          final extra = state.extra as Map<String, String>?;
          return PlatformAdaptiveScreen(
            mobileScreen: UnifiedMarksEntryScreen(
              examId: examId,
              examName: extra?['examName'] ?? 'Enter Marks',
            ),
            desktopScreen: DesktopMarksEntryScreen(
              examId: examId,
              examName: extra?['examName'] ?? 'Enter Marks',
            ),
          );
        },
      ),
      GoRoute(
        path: '/teacher/marks-entry-selection',
        name: 'teacher-marks-entry-selection',
        builder: (context, state) => const TeacherMarksEntrySelectionScreen(),
      ),
      GoRoute(
        path: '/teacher/marks-entry/:examId',
        name: 'teacher-marks-entry',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          final extra = state.extra as Map<String, String>?;
          return UnifiedMarksEntryScreen(
            examId: examId,
            examName: extra?['examName'] ?? 'Enter Marks',
          );
        },
      ),
      GoRoute(
        path: '/exam-analytics/:examId',
        name: 'exam-analytics',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          final extra = state.extra as Map<String, String>?;
          return PlatformAdaptiveScreen(
            mobileScreen: ExamAnalyticsScreen(
              examId: examId,
              examName: extra?['examName'] ?? 'Exam Analytics',
            ),
            desktopScreen: DesktopExamAnalytics(
              examId: examId,
              examName: extra?['examName'] ?? 'Exam Analytics',
            ),
          );
        },
      ),
      GoRoute(
        path: '/exam-calendar/:schoolId',
        name: 'exam-calendar',
        builder: (context, state) {
          final schoolId = int.parse(state.pathParameters['schoolId']!);
          return PlatformAdaptiveScreen(
            mobileScreen: ExamCalendarScreen(schoolId: schoolId),
            desktopScreen: DesktopExamCalendar(schoolId: schoolId),
          );
        },
      ),
      GoRoute(
        path: '/exam-notification-preferences',
        name: 'exam-notification-preferences',
        builder: (context, state) => const ExamNotificationPreferencesScreen(),
      ),
      GoRoute(
        path: '/exam-templates/:schoolId',
        name: 'exam-templates',
        builder: (context, state) {
          final schoolId = int.parse(state.pathParameters['schoolId']!);
          return ExamTemplateScreen(schoolId: schoolId);
        },
      ),
      GoRoute(
        path: '/student-performance/:studentId/:classId',
        name: 'student-performance-detail',
        builder: (context, state) {
          final studentId = int.parse(state.pathParameters['studentId']!);
          final classId = int.parse(state.pathParameters['classId']!);
          return StudentPerformanceScreen(studentId: studentId, classId: classId);
        },
      ),
      GoRoute(
        path: '/child-exam-schedule/:classId',
        name: 'child-exam-schedule',
        builder: (context, state) {
          final classId = int.parse(state.pathParameters['classId']!);
          return ChildExamScheduleScreen(classId: classId);
        },
      ),
      GoRoute(
        path: '/marks-approval/:schoolId',
        name: 'marks-approval',
        builder: (context, state) {
          final schoolId = int.parse(state.pathParameters['schoolId']!);
          return MarksApprovalScreen(schoolId: schoolId);
        },
      ),
      GoRoute(
        path: '/all-report-cards/:examId',
        name: 'all-report-cards',
        builder: (context, state) {
          final examId = state.pathParameters['examId']!;
          final extra = state.extra as Map<String, String>?;
          return PlatformAdaptiveScreen(
            mobileScreen: AllReportCardsScreen(
              examId: examId,
              examName: extra?['examName'] ?? 'Exam',
            ),
            desktopScreen: DesktopAllReportCards(
              examId: examId,
              examName: extra?['examName'] ?? 'Exam',
            ),
          );
        },
      ),
      GoRoute(
        path: '/exam-settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      // Fee Management routes
      GoRoute(
        path: '/admin/fee-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: FeeStructureManagementScreen(),
          desktopScreen: DesktopFeeStructureManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/fee-payment-management',
        name: 'fee-payment-management',
        builder: (context, state) => const FeePaymentManagementScreen(),
      ),
      GoRoute(
        path: '/admin/add-fee-payment',
        name: 'add-fee-payment',
        builder: (context, state) => AddEditFeePaymentScreen(
          payment: state.extra as FeePayment?,
        ),
      ),
      GoRoute(
        path: '/admin/finance-categories',
        name: 'finance-categories',
        builder: (context, state) => const CategoryManagementScreen(),
      ),
      GoRoute(
        path: '/admin/add-finance-category',
        name: 'add-finance-category',
        builder: (context, state) => AddEditCategoryScreen(
          category: state.extra as FinanceCategory?,
        ),
      ),
      GoRoute(
        path: '/admin/donation-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: DonationManagementScreen(),
          desktopScreen: DesktopDonationManagement(),
        ),
      ),
      GoRoute(
        path: '/admin/salary-management',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: SalaryManagementScreen(),
          desktopScreen: DesktopSalaryManagement(),
        ),
      ),
      // Financial Reports routes
      GoRoute(
        path: '/admin/financial-reports',
        name: 'financial-reports',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: FinancialReportsScreen(),
          desktopScreen: DesktopFinancialReports(),
        ),
      ),
      GoRoute(
        path: '/admin/reports/profit-loss',
        name: 'profit-loss-report',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ProfitLossReportScreen(
            startDate: extra?['startDate'] as DateTime?,
            endDate: extra?['endDate'] as DateTime?,
          );
        },
      ),
      GoRoute(
        path: '/admin/reports/cash-flow',
        name: 'cash-flow-report',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return CashFlowReportScreen(
            startDate: extra?['startDate'] as DateTime?,
            endDate: extra?['endDate'] as DateTime?,
          );
        },
      ),
      GoRoute(
        path: '/admin/reports/fee-collection',
        name: 'fee-collection-report',
        builder: (context, state) => const FeeCollectionReportScreen(),
      ),
      // Donator routes
      GoRoute(
        path: '/donator-dashboard',
        builder: (context, state) => const PlatformAdaptiveScreen(
          mobileScreen: ModernDonatorDashboard(),
          desktopScreen: DesktopDonatorDashboard(),
        ),
      ),
    ],
  );
}