import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:edu_sync/screens/splash_screen.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/providers/locale_provider.dart'; // Import LocaleProvider
import 'package:edu_sync/l10n/app_localizations.dart'; // Import generated localizations
import 'package:edu_sync/services/notification_service.dart'; // Import NotificationService
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase FIRST
  await Supabase.initialize(
    url: 'https://rcrhktgfkgkwuosyclbo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjcmhrdGdma2drd3Vvc3ljbGJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3NTMxNzIsImV4cCI6MjA2MjMyOTE3Mn0.mTD6GqRA650VinZzo5AIHLRbWUxor5GuvSjKMGtq5II',
  );

  final sharedPreferences = await SharedPreferences.getInstance();
  
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  getIt.registerSingleton<SupabaseClient>(Supabase.instance.client);
  getIt.registerSingleton<Connectivity>(Connectivity());

  // Create NotificationService instance AFTER Supabase is initialized
  final notificationService = NotificationService();
  await notificationService.initialize(); // Initialize local notifications part

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SchoolProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => notificationService), // Provide the single instance
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'EduSync Myanmar', // This could also be localized
      locale: localeProvider.locale, // Set locale from provider
      localizationsDelegates: AppLocalizations.localizationsDelegates, // Use generated delegates
      supportedLocales: AppLocalizations.supportedLocales, // Use generated supported locales
      theme: AppTheme.themeData, // Apply the custom theme
      home: const SplashScreen(), // Set SplashScreen as home
    );
  }
}
