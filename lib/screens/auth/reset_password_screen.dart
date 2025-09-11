import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart'; // Assuming you use go_router for navigation

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _message = '';

  bool _sessionHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_sessionHandled) {
      _handleSession();
      _sessionHandled = true;
    }
  }

  Future<void> _handleSession() async {
    // It's important to handle the session only once.
    if (Supabase.instance.client.auth.currentUser != null) {
      // If a user is already logged in, sign them out before proceeding with password reset.
      // This prevents conflicts with the existing session.
      await Supabase.instance.client.auth.signOut();
    }

    final uri = GoRouter.of(context).routeInformationProvider.value.uri;
    // Debug logs to capture incoming URI and query params
    // ignore: avoid_print
    print('DEBUG: reset_password_screen - uri=$uri');
    // ignore: avoid_print
    print('DEBUG: reset_password_screen - queryParameters=${uri.queryParameters}');
    final accessToken = uri.queryParameters['access_token'];
    final refreshToken = uri.queryParameters['refresh_token'];
    final code = uri.queryParameters['code'];

    // Only restore session automatically if both access and refresh tokens are present.
    // Some deep links (mobile) include only a 'code' and cannot be used to create a session here.
    if (accessToken != null && refreshToken != null) {
      // The presence of access and refresh tokens indicates a deep link for password reset.
      // We don't want to automatically restore the session here, as the user needs to set a new password.
      // The user will be prompted to set a new password and then redirected to login.
      setState(() {
        _message = 'Please set your new password.';
      });
    } else if (code != null) {
      // When only a 'code' is present, the link likely must be opened in a browser to complete the flow.
      setState(() {
        _message = 'Open this password reset link in a browser to complete the reset, or use the web app.';
      });
      // Optionally, you could open the URL externally using url_launcher here.
    } else {
      setState(() {
        _message = 'Invalid password reset link or tokens missing.';
      });
    }
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final newPassword = _newPasswordController.text;
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      // After successful password reset, sign out and send user to login so they can re-authenticate
      if (mounted) {
        // Sign out to clear the restored session
        await Supabase.instance.client.auth.signOut();
        setState(() {
          _message = 'Password updated. Please log in with your new password.';
        });
        if (mounted) context.go('/login');
      }
    } on AuthException catch (e) {
      setState(() {
        _message = 'Error updating password: ${e.message}';
      });
    } catch (e) {
      setState(() {
        _message = 'An unexpected error occurred: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(_message, style: TextStyle(color: _message.contains('Error') ? Colors.red : Colors.green)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'New Password'),
                validator: (value) {
                  if (value == null || value.isEmpty || value.length < 6) {
                    return 'Password must be at least 6 characters long.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm New Password'),
                validator: (value) {
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updatePassword,
                      child: const Text('Set New Password'),
                    ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  // Sign out first to ensure router doesn't redirect logged-in users away from /login
                  await Supabase.instance.client.auth.signOut();
                  if (mounted) context.go('/login');
                },
                child: const Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
