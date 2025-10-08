import 'package:edu_sync/screens/manager/manager_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:edu_sync/screens/admin/admin_panel_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_dashboard_screen.dart';
import 'package:edu_sync/screens/parent/parent_dashboard_screen.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/utils/logger.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  late final AuthService _authService;
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _loadUserRoleAndNavigate();
  }

  Future<void> _loadUserRoleAndNavigate() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      _userRole = await _authService.getUserRole();
      if (_userRole != null) {
        _navigateToDashboard(_userRole!);
      }
    } catch (e) {
      logger.e("Error loading user role: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error loading user role: $e")),
        );
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToDashboard(String role) {
    Widget dashboardScreen;
    switch (role) {
      case 'Admin':
        dashboardScreen = const AdminPanelScreen();
        break;
      case 'Teacher':
        dashboardScreen = const TeacherDashboardScreen();
        break;
      case 'Parent':
        dashboardScreen = const ParentDashboardScreen();
        break;
      case 'Manager':
        dashboardScreen = const ManagerDashboardScreen();
        break;
      default:
        // Should not happen if roles are validated, but as a fallback
        logger.w("Attempted to navigate to unknown role dashboard: $role");
        return;
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => dashboardScreen));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.appTitle ?? 'EduSync'),
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
