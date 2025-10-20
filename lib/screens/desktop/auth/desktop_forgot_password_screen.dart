import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DesktopForgotPasswordScreen extends StatefulWidget {
  const DesktopForgotPasswordScreen({super.key});

  @override
  State<DesktopForgotPasswordScreen> createState() => _DesktopForgotPasswordScreenState();
}

class _DesktopForgotPasswordScreenState extends State<DesktopForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AuthService _authService;
  String _email = '';
  String _message = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  Future<void> _resetPassword(AppLocalizations? l10n) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _message = '';
      });

      try {
        await _authService.resetPassword(_email);
        if (mounted) {
          setState(() {
            _message = l10n?.passwordResetEmailSent(_email) ?? 'Password reset email sent to $_email';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _message = '${l10n?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}';
          });
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/EduSync.svg',
                      height: 100,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n?.forgotPassword ?? 'Forgot Password',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n?.forgotPasswordInstructions ?? 'Enter your email to receive a password reset link.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: l10n?.email ?? 'Email',
                                prefixIcon: const Icon(Icons.email, color: Color(0xFF3498DB)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => (value == null || value.isEmpty) ? (l10n?.emailValidator ?? 'Email cannot be empty') : null,
                              onSaved: (value) => _email = value!,
                            ),
                            const SizedBox(height: 32),
                            _isLoading
                                ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB)))
                                : SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _resetPassword(l10n),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF3498DB),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      child: Text(
                                        l10n?.resetPassword ?? 'Reset Password',
                                        style: const TextStyle(color: Colors.white, fontSize: 16),
                                      ),
                                    ),
                                  ),
                            if (_message.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  _message,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _message.contains(l10n?.errorOccurredPrefix ?? 'Error') ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                l10n?.login ?? 'Login',
                                style: const TextStyle(color: Color(0xFF3498DB)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
