import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:edu_sync/config/providers.dart';
import 'package:edu_sync/config/router.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart';
import 'package:edu_sync/providers/locale_provider.dart';

late final GoRouter _router;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase FIRST
  await Supabase.initialize(
    url: 'https://rcrhktgfkgkwuosyclbo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjcmhrdGdma2drd3Vvc3ljbGJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3NTMxNzIsImV4cCI6MjA2MjMyOTE3Mn0.mTD6GqRA650VinZzo5AIHLRbWUxor5GuvSjKMGtq5II',
  );

  _router = initializeRouter();
  final providers = await initializeProviders();

  runApp(
    MultiProvider(
      providers: providers,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp.router(
      title: 'EduSync Myanmar', // This could also be localized
      locale: localeProvider.locale, // Set locale from provider
      localizationsDelegates: AppLocalizations.localizationsDelegates, // Use generated delegates
      supportedLocales: AppLocalizations.supportedLocales, // Use generated supported locales
      theme: AppTheme.themeData, // Apply the custom theme
      routerConfig: _router, // Use go_router for navigation
    );
  }
}
