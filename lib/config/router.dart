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
import 'package:edu_sync/services/notification_service.dart';

import 'package:edu_sync/screens/splash_screen.dart';
import 'package:edu_sync/screens/auth/login_screen.dart';
import 'package:edu_sync/screens/auth/reset_password_screen.dart';
import 'package:edu_sync/screens/admin/admin_panel_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_dashboard_screen.dart';
import 'package:edu_sync/screens/parent/parent_dashboard_screen.dart';
import 'package:edu_sync/screens/manager/manager_dashboard_screen.dart';
import 'package:edu_sync/screens/admin/user_management_screen.dart';
import 'package:edu_sync/screens/admin/student_management_screen.dart'; // Corrected import
import 'package:edu_sync/screens/admin/view_form_responses_screen.dart';
import 'package:edu_sync/screens/admin/class_management_screen.dart';
import 'package:edu_sync/screens/admin/timetable_management_screen.dart';
import 'package:edu_sync/screens/admin/finance_management_screen.dart';
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
    refreshListenable: GoRouterRefreshStream(Supabase.instance.client.auth.onAuthStateChange),
    redirect: (BuildContext context, GoRouterState state) async {
      final authService = Provider.of<AuthService>(context, listen: false);
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final connectivity = Provider.of<Connectivity>(context, listen: false);
      final notificationService = Provider.of<NotificationService>(context, listen: false);

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
        if (connectivityResult != ConnectivityResult.none) {
          await schoolProvider.fetchCurrentSchool();
          final role = await authService.getUserRole();
          final schoolId = schoolProvider.currentSchool?.id;

          if (role != null && schoolId != null) {
            notificationService.subscribeToAnnouncements(schoolId, authService.getCurrentUser()!.id, role);
          }

          if (role == UserRole.Admin.name) {
            return '/admin';
          } else if (role == UserRole.Teacher.name) {
            return '/teacher-dashboard';
          } else if (role == UserRole.Parent.name) {
            return '/parent-dashboard';
          } else if (role == UserRole.Manager.name) {
            return '/manager-dashboard';
          }
        }
        // Fallback if role is not determined or offline
        return '/login'; // Go to login screen if offline
      }

      if (loggedIn && goingToLogin) {
        final connectivityResult = await connectivity.checkConnectivity();
        if (connectivityResult != ConnectivityResult.none) {
          await schoolProvider.fetchCurrentSchool();
          final role = await authService.getUserRole();
          final schoolId = schoolProvider.currentSchool?.id;

          if (role != null && schoolId != null) {
            notificationService.subscribeToAnnouncements(schoolId, authService.getCurrentUser()!.id, role);
          }

          if (role == UserRole.Admin.name) {
            return '/admin';
          } else if (role == UserRole.Teacher.name) {
            return '/teacher-dashboard';
          } else if (role == UserRole.Parent.name) {
            return '/parent-dashboard';
          } else if (role == UserRole.Manager.name) {
            return '/manager-dashboard';
          }
        }
        // Fallback if role is not determined or offline
        return '/'; // Go to splash screen to re-evaluate
      }

      // No redirect needed
      return null;
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
        builder: (context, state) => const AdminPanelScreen(),
      ),
      GoRoute(
        path: '/teacher-dashboard',
        builder: (context, state) => const TeacherDashboardScreen(),
      ),
      GoRoute(
        path: '/parent-dashboard',
        builder: (context, state) => const ParentDashboardScreen(),
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
        path: '/admin/user-management',
        builder: (context, state) => const UserManagementScreen(),
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
        builder: (context, state) => const FinanceManagementScreen(),
      ),
      GoRoute(
        path: '/teacher/attendance-marking',
        builder: (context, state) => const AttendanceMarkingScreen(),
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
    ],
  );
}
