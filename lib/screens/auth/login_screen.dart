import 'package:flutter/material.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/screens/admin/admin_panel_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_dashboard_screen.dart';
import 'package:edu_sync/screens/parent/parent_dashboard_screen.dart';
import 'register_screen.dart';
import 'package:edu_sync/l10n/app_localizations.dart'; 
// import 'package:edu_sync/theme/app_theme.dart'; // Unused Import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  Future<void> _login(AppLocalizations l10n) async { // Pass l10n
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (mounted) { // Guard setState
        setState(() {
          _errorMessage = '';
        });
      }
      try {
        final user = await _authService.signIn(_email, _password);
        if (!mounted) return; // Guard against async gap

        if (user != null) {
          final role = _authService.getUserRole();
          if (role == 'Admin') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const AdminPanelScreen()));
          } else if (role == 'Teacher') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()));
          } else if (role == 'Parent') {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ParentDashboardScreen()));
          } else {
            if (mounted) {
              setState(() {
                _errorMessage = l10n.unknownUserRoleError; 
              });
            }
          }
        } else {
          if (mounted) {
            setState(() {
              _errorMessage = l10n.loginFailedError; 
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = '${l10n.errorOccurredPrefix}: ${e.toString()}'; 
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context); // Get theme context

    return Scaffold(
      appBar: AppBar(title: Text(l10n.login)), // Theme applied globally
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Added SingleChildScrollView
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: l10n.email), 
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty) ? l10n.emailValidator : null,
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.password), 
                obscureText: true,
                validator: (value) => (value == null || value.isEmpty) ? l10n.passwordRequiredValidator : null, 
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 24),
              ElevatedButton( 
                onPressed: () => _login(l10n), // Pass l10n
                child: Text(l10n.login),
              ),
              TextButton( 
                onPressed: () {
                  // TODO: Implement Forgot Password logic
                },
                child: Text(l10n.forgotPasswordButtonLabel), 
              ),
              // Language switch is now in AppSettings, accessible via drawer
              // TextButton(
              //   onPressed: () {
              //     // Placeholder for Switch Language
              //   },
              //   child: const Text('Switch Language (EN/MY)'),
              // ),
              if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: theme.colorScheme.error, fontSize: theme.textTheme.bodyMedium?.fontSize),
                    ),
                  ),
                TextButton( 
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: Text(l10n.registerNewSchoolButtonLabel), 
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
