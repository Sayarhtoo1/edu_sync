import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider, ChangeNotifierProvider;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:edu_sync/config/providers.dart';
import 'package:edu_sync/config/router.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart';
import 'package:edu_sync/providers/locale_provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/utils/responsive.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase FIRST
  await Supabase.initialize(
    url: 'https://rcrhktgfkgkwuosyclbo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjcmhrdGdma2drd3Vvc3ljbGJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDY3NTMxNzIsImV4cCI6MjA2MjMyOTE3Mn0.mTD6GqRA650VinZzo5AIHLRbWUxor5GuvSjKMGtq5II',
  );

  final providers = await initializeProviders();
  final router = initializeRouter();

  runApp(
    ProviderScope(
      child: MultiProvider(
        providers: providers,
        child: MyApp(router: router),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final GoRouter router;
  
  const MyApp({super.key, required this.router});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Start listening to auth changes as soon as the app starts
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.listenToAuthChanges();
    // Ensure subscription if user is already logged in
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await authService.ensureAnnouncementSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp.router(
      title: 'EduSync Myanmar',
      locale: localeProvider.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.themeData,
      routerConfig: widget.router,
      builder: (context, child) {
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
