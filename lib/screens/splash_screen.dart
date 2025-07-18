import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart'; // Import SchoolProvider
import 'package:edu_sync/screens/auth/login_screen.dart';
import 'package:edu_sync/screens/admin/admin_panel_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_dashboard_screen.dart';
import 'package:edu_sync/screens/parent/parent_dashboard_screen.dart';
import 'package:edu_sync/services/notification_service.dart'; // Import NotificationService
// import 'package:edu_sync/database.dart'; // For local DB initialization

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    super.initState();
    // Defer the initialization that might call notifyListeners until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final connectivityResult = await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // Offline mode
      final role = await _authService.getUserRole();
      if (role != null) {
        // User is logged in and role is cached, navigate to the correct dashboard
        if (role == 'Admin') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
        } else if (role == 'Teacher') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()));
        } else if (role == 'Parent') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ParentDashboardScreen()));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
      } else {
        // User is not logged in or role is not cached, navigate to login screen
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    } else {
      // Online mode
      final currentUser = _authService.getCurrentUser();

      if (currentUser != null) {
        await schoolProvider.fetchCurrentSchool(); // Fetch school details
      } else {
        schoolProvider.clearSchool();
      }

      if (!mounted) return;

      final freshCurrentUser = _authService.getCurrentUser();
      if (freshCurrentUser == null) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
      } else {
        final role = await _authService.getUserRole();
        if (!mounted) return;

        final schoolId = schoolProvider.currentSchool?.id; // Get schoolId from provider
        final notificationService = Provider.of<NotificationService>(context, listen: false);

        if (role != null && schoolId != null) {
          // Subscribe to announcements after role and schoolId are confirmed
          notificationService.subscribeToAnnouncements(schoolId, freshCurrentUser.id, role);
        }

        if (role == 'Admin') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
        } else if (role == 'Teacher') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()));
        } else if (role == 'Parent') {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ParentDashboardScreen()));
        } else {
          print("Unknown role or role not in metadata: $role. Navigating to Login.");
          notificationService.unsubscribeFromAnnouncements(); // Unsubscribe if navigating to login
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
