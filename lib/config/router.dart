import 'package:edu_sync/screens/admin/staff_management_screen.dart';
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
import 'package:edu_sync/screens/auth/login_screen.dart';
import 'package:edu_sync/screens/auth/reset_password_screen.dart';
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
        builder: (context, state) => const SplashScreen(), // Your initial screen
      ),
      GoRoute(
        path: '/login',
        name: 'login', // Add a name to the login route
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          // ResetPasswordScreen reads tokens from the current URI; no need to extract them here.
          return ResetPasswordScreen();
        },
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
        builder: (context, state) => const ModernTeacherDashboard(),
      ),
      GoRoute(
        path: '/parent-dashboard',
        builder: (context, state) => const ModernParentDashboard(),
      ),
      GoRoute(
        path: '/manager-dashboard',
        builder: (context, state) => const ManagerDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/edit-school-profile',
        builder: (context, state) => EditSchoolProfileScreen(school: state.extra as app_school.School),
      ),
      GoRoute(
        path: '/admin/school-profile',
        name: 'school-profile',
        builder: (context, state) => const SchoolProfileScreen(),
      ),
      GoRoute(
        path: '/admin/user-management',
        builder: (context, state) => const UserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/staff-management',
        builder: (context, state) => const StaffManagementScreen(),
      ),
      GoRoute(
        path: '/admin/staff-status',
        builder: (context, state) => const StaffStatusOverviewScreen(),
      ),
      GoRoute(
        path: '/admin/staff-attendance-summary',
        name: 'staff-attendance-summary',
        builder: (context, state) => const StaffAttendanceSummaryScreen(),
      ),
      GoRoute(
        path: '/admin/student-attendance-summary',
        name: 'student-attendance-summary',
        builder: (context, state) => const EnhancedStudentAttendanceSummary(),
      ),
      GoRoute(
        path: '/admin/student-management',
        builder: (context, state) => const StudentManagementScreen(),
      ),
      GoRoute(
        path: '/admin/class-management',
        builder: (context, state) => const ClassManagementScreen(),
      ),
      GoRoute(
        path: '/admin/timetable-management',
        builder: (context, state) => const TimetableManagementScreen(),
      ),
      GoRoute(
        path: '/admin/finance-management',
        builder: (context, state) => const FinanceOverviewScreen(),
      ),
      GoRoute(
        path: '/admin/finance-dashboard',
        name: 'finance-dashboard',
        builder: (context, state) => const EnhancedFinanceOverviewScreen(),
      ),
      GoRoute(
        path: '/admin/income-management',
        builder: (context, state) => const IncomeManagementScreen(),
      ),
      GoRoute(
        path: '/admin/expense-management',
        builder: (context, state) => const ExpenseManagementScreen(),
      ),
      GoRoute(
        path: '/teacher/attendance-marking',
        builder: (context, state) => const AttendanceMarkingScreen(),
      ),
      GoRoute(
        path: '/teacher/student-attendance-summary',
        name: 'teacher-student-attendance-summary',
        builder: (context, state) => const EnhancedStudentAttendanceSummary(),
      ),
      GoRoute(
        path: '/teacher/lesson-plan-management',
        builder: (context, state) => const LessonPlanManagementScreen(),
      ),
      GoRoute(
        path: '/admin/announcements',
        builder: (context, state) => const AdminAnnouncementsScreen(),
      ),
      GoRoute(
        path: '/admin/manage-custom-forms',
        builder: (context, state) => const ManageCustomFormsScreen(),
      ),
      GoRoute(
        path: '/admin/view-form-responses',
        builder: (context, state) => ViewFormResponsesScreen(schoolId: state.extra as int),
      ),
      GoRoute(
        path: '/admin/settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
      GoRoute(
        path: '/teacher/timetable',
        builder: (context, state) => const TeacherTimetableScreen(),
      ),
      GoRoute(
        path: '/teacher/students',
        builder: (context, state) => const TeacherStudentManagementScreen(),
      ),
      GoRoute(
        path: '/parent/child-attendance',
        builder: (context, state) => const ChildAttendanceScreen(),
      ),
      GoRoute(
        path: '/parent/child-schedule',
        builder: (context, state) => const ChildScheduleScreen(),
      ),
      GoRoute(
        path: '/parent/announcements',
        builder: (context, state) => const AnnouncementsScreen(),
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
          return ModernReportCardScreen(studentId: studentId, examId: examId);
        },
      ),
      GoRoute(
        path: '/report-card/:studentId/:examId',
        name: 'report-card',
        builder: (context, state) {
          final studentId = int.parse(state.pathParameters['studentId']!);
          final examId = state.pathParameters['examId']!;
          return ReportCardScreen(studentId: studentId, examId: examId);
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
          return StudentProfileScreen(student: student);
        },
      ),
      GoRoute(
        path: '/staff/profile',
        builder: (context, state) => StaffProfileScreen(staff: state.extra as model.Staff),
      ),
      // New exam module routes
      GoRoute(
        path: '/admin/exam-overview',
        name: 'exam-overview',
        builder: (context, state) => const ExamOverviewScreen(),
      ),
      GoRoute(
        path: '/admin/exam-management',
        name: 'exam-management',
        builder: (context, state) => const ExamListScreen(),
      ),
      GoRoute(
        path: '/admin/exam-form',
        name: 'exam-form',
        builder: (context, state) => ExamFormScreen(exam: state.extra as dynamic),
      ),
      GoRoute(
        path: '/admin/exam-subject-management',
        name: 'exam-subject-management',
        builder: (context, state) => ExamSubjectManagementScreen(exam: state.extra as exam_model.Exam),
      ),
      GoRoute(
        path: '/admin/subject-management',
        name: 'subject-management',
        builder: (context, state) => const SubjectManagementScreen(),
      ),
      GoRoute(
        path: '/admin/grade-management',
        name: 'grade-management',
        builder: (context, state) => const GradeManagementScreen(),
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
          return UnifiedMarksEntryScreen(
            examId: examId,
            examName: extra?['examName'] ?? 'Enter Marks',
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
          return ExamAnalyticsScreen(
            examId: examId,
            examName: extra?['examName'] ?? 'Exam Analytics',
          );
        },
      ),
      GoRoute(
        path: '/exam-calendar/:schoolId',
        name: 'exam-calendar',
        builder: (context, state) {
          final schoolId = int.parse(state.pathParameters['schoolId']!);
          return ExamCalendarScreen(schoolId: schoolId);
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
        name: 'student-performance',
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
          return AllReportCardsScreen(
            examId: examId,
            examName: extra?['examName'] ?? 'Exam',
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
        builder: (context, state) => const FeeStructureManagementScreen(),
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
        builder: (context, state) => const DonationManagementScreen(),
      ),
      GoRoute(
        path: '/admin/salary-management',
        builder: (context, state) => const SalaryManagementScreen(),
      ),
      // Financial Reports routes
      GoRoute(
        path: '/admin/financial-reports',
        name: 'financial-reports',
        builder: (context, state) => const FinancialReportsScreen(),
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
        builder: (context, state) => const ModernDonatorDashboard(),
      ),
    ],
  );
}