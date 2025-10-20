import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class DesktopResetPasswordScreen extends StatefulWidget {
  const DesktopResetPasswordScreen({super.key});

  @override
  State<DesktopResetPasswordScreen> createState() => _DesktopResetPasswordScreenState();
}

class _DesktopResetPasswordScreenState extends State<DesktopResetPasswordScreen> {
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
    if (Supabase.instance.client.auth.currentUser != null) {
      await Supabase.instance.client.auth.signOut();
    }

    final uri = GoRouter.of(context).routeInformationProvider.value.uri;
    final accessToken = uri.queryParameters['access_token'];
    final refreshToken = uri.queryParameters['refresh_token'];
    final code = uri.queryParameters['code'];

    if (accessToken != null && refreshToken != null) {
      setState(() {
        _message = 'Please set your new password.';
      });
    } else if (code != null) {
      setState(() {
        _message = 'Open this password reset link in a browser to complete the reset, or use the web app.';
      });
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
      if (mounted) {
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
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Reset Password',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3498DB)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      if (_message.isNotEmpty)
                        Text(
                          _message,
                          style: TextStyle(
                            color: _message.contains('Error') ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          prefixIcon: const Icon(Icons.lock, color: Color(0xFF3498DB)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || value.length < 6) {
                            return 'Password must be at least 6 characters long.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF3498DB)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value != _newPasswordController.text) {
                            return 'Passwords do not match.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB))))
                          : ElevatedButton(
                              onPressed: _updatePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3498DB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Set New Password', style: TextStyle(fontSize: 16)),
                            ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () async {
                          await Supabase.instance.client.auth.signOut();
                          if (mounted) context.go('/login');
                        },
                        child: const Text('Back to Login', style: TextStyle(color: Color(0xFF3498DB))),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
