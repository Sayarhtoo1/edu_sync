import 'package:flutter/material.dart';
// Import Provider
// Import SchoolProvider
// Import NotificationService
// Import go_router for navigation
// import 'package:edu_sync/database.dart'; // For local DB initialization

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Removed _authService and _connectivity as they are no longer needed here
  // Removed _initializeApp as navigation is now handled by GoRouter's redirect

  @override
  void initState() {
    super.initState();
    // No need to call _initializeApp here anymore
  }

  @override
  Widget build(BuildContext context) {
    // Removed unused variables
    final textTheme = Theme.of(context).textTheme;
    final progressIndicatorColor = Theme.of(context).primaryColor; // Uses defaultAccentColor from theme

    return Scaffold( // Scaffold background will be appBackgroundColor from theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(progressIndicatorColor),
            ),
            const SizedBox(height: 20),
            Text(
              'EduSync Myanmar',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold), // Using themed text style
            ),
            const SizedBox(height: 8),
            Text(
              'Initializing...',
              style: textTheme.bodyMedium, // Using themed text style
            ),
          ],
        ),
      ),
    );
  }
}
