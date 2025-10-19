import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/native.dart';

import 'package:edu_sync/database/app_database.dart';
import 'package:edu_sync/database/migration_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/providers/locale_provider.dart';
import 'package:edu_sync/services/notification_service.dart';
import 'package:edu_sync/services/announcement_service.dart';
import 'package:edu_sync/services/attendance_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/cache_service.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/custom_form_service.dart';
import 'package:edu_sync/services/finance_service.dart';
import 'package:edu_sync/services/form_response_service.dart';
import 'package:edu_sync/services/lesson_plan_service.dart';
import 'package:edu_sync/services/role_service.dart';
import 'package:edu_sync/services/school_service.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/timetable_service.dart';
import 'package:edu_sync/services/user_service.dart';
import 'package:edu_sync/services/schedule_summary_service.dart';
import 'package:edu_sync/services/fee_structure_service.dart';
import 'package:edu_sync/services/fee_payment_service.dart';
import 'package:edu_sync/services/donation_service.dart';
import 'package:edu_sync/services/salary_service.dart';
import 'package:edu_sync/services/finance_category_service.dart';
import 'package:edu_sync/services/financial_report_service.dart';
import 'package:edu_sync/providers/admin_panel_provider.dart';
import 'package:edu_sync/providers/exam_provider.dart';
import 'package:edu_sync/providers/class_provider.dart';

Future<List<SingleChildWidget>> initializeProviders() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  final notificationService = NotificationService();
  await notificationService.initialize();

  final appDatabase = AppDatabase(NativeDatabase.memory());
  final cacheService = CacheService(appDatabase);
  final migrationService = MigrationService(appDatabase);
  await migrationService.migrateData();

  return [
    // Core Services
    Provider<SupabaseClient>.value(value: Supabase.instance.client),
    Provider<SharedPreferences>.value(value: sharedPreferences),
    Provider<Connectivity>(create: (_) => Connectivity()),
    ChangeNotifierProvider.value(value: notificationService),


    // Database and Cache first
    Provider<AppDatabase>.value(value: appDatabase),
    Provider<CacheService>.value(value: cacheService),
    
    // App Services
    ProxyProvider5<SupabaseClient, SharedPreferences, Connectivity, NotificationService, CacheService, AuthService>(
      update: (_, supabase, prefs, connectivity, notificationService, cache, previous) {
        final authService = previous ?? AuthService(
          supabaseClient: supabase,
          sharedPreferences: prefs,
          connectivity: connectivity,
          notificationService: notificationService,
        );
        authService.setCacheService(cache);
        return authService;
      },
    ),
    Provider<SchoolService>(create: (_) => SchoolService(cacheService)),
    Provider<StudentService>(create: (_) => StudentService(appDatabase, cacheService)),
    Provider<ClassService>(create: (_) => ClassService(cacheService)),
    ProxyProvider2<SupabaseClient, CacheService, TimetableService>(
      update: (_, supabase, cache, __) => TimetableService(supabase, cache),
    ),
    Provider<AttendanceService>(create: (_) => AttendanceService(cacheService)),
    Provider<LessonPlanService>(create: (_) => LessonPlanService()),
    Provider<CustomFormService>(create: (_) => CustomFormService()),
    Provider<FormResponseService>(create: (_) => FormResponseService()),
    ProxyProvider2<SupabaseClient, CacheService, AnnouncementService>(
      update: (_, supabase, cache, __) => AnnouncementService(supabase, cache),
    ),
    Provider<FinanceService>(create: (_) => FinanceService(cacheService)),
    ProxyProvider2<SupabaseClient, CacheService, UserService>(
      update: (_, supabase, cache, __) => UserService(supabase, cache),
    ),
    ProxyProvider<SupabaseClient, FeeStructureService>(
      update: (_, supabase, __) => FeeStructureService(supabase),
    ),
    ProxyProvider<SupabaseClient, FeePaymentService>(
      update: (_, supabase, __) => FeePaymentService(supabase),
    ),
    ProxyProvider2<SupabaseClient, CacheService, DonationService>(
      update: (_, supabase, cache, __) => DonationService(supabase, cache),
    ),
    ProxyProvider<SupabaseClient, SalaryService>(
      update: (_, supabase, __) => SalaryService(supabase),
    ),
    ProxyProvider<SupabaseClient, FinanceCategoryService>(
      update: (_, supabase, __) => FinanceCategoryService(supabase),
    ),
    Provider<FinancialReportService>(create: (_) => FinancialReportService()),
    ProxyProvider<AuthService, RoleService>(
      update: (_, authService, _) => RoleService(authService),
    ),
    ProxyProvider3<TimetableService, AuthService, UserService, ScheduleSummaryService>(
      update: (_, timetableService, authService, userService, _) => ScheduleSummaryService(
        timetableService,
        authService,
        userService,
      ),
    ),
    // Admin Panel Provider
    ChangeNotifierProxyProvider3<TimetableService, AuthService, ClassService, AdminPanelProvider>(
      create: (context) => AdminPanelProvider(
        timetableService: context.read<TimetableService>(),
        authService: context.read<AuthService>(),
        classService: context.read<ClassService>(),
      ),
      update: (context, timetableService, authService, classService, previous) => previous ?? AdminPanelProvider(
        timetableService: timetableService,
        authService: authService,
        classService: classService,
      ),
    ),

    // State Notifiers
    ChangeNotifierProxyProvider2<AuthService, SchoolService, SchoolProvider>(
      create: (context) => SchoolProvider(
        context.read<SchoolService>(),
        context.read<AuthService>(),
      ),
      update: (context, auth, school, previous) =>
          SchoolProvider(school, auth),
    ),
    ChangeNotifierProvider(create: (_) => LocaleProvider()),
    ChangeNotifierProvider(create: (_) => ExamProvider()),
    ChangeNotifierProxyProvider<ClassService, ClassProvider>(
      create: (context) => ClassProvider(context.read<ClassService>()),
      update: (_, classService, previous) => previous ?? ClassProvider(classService),
    ),
  ];
}
