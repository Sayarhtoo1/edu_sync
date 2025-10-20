import 'package:flutter/material.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:edu_sync/screens/auth/register_screen.dart';
import 'package:edu_sync/screens/auth/forgot_password_screen.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';

class DesktopLoginScreen extends StatefulWidget {
  const DesktopLoginScreen({super.key});

  @override
  State<DesktopLoginScreen> createState() => _DesktopLoginScreenState();
}

class _DesktopLoginScreenState extends State<DesktopLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AuthService _authService;
  String _email = '';
  String _password = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
  }

  Future<void> _login(AppLocalizations? l10n) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (mounted) {
        setState(() {
          _errorMessage = '';
        });
      }
      try {
        final user = await _authService.signIn(_email, _password);
        if (user == null) {
          if (mounted) {
            setState(() {
              _errorMessage = l10n?.loginFailedError ?? 'Login failed';
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = '${l10n?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

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
                      height: 120,
                      colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n?.appTitle ?? 'EduSync',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.appTagline ?? 'Your Partner in Education',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 18,
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
                            Text(
                              l10n?.login ?? 'Login',
                              style: const TextStyle(
                                color: Color(0xFF3498DB),
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 32),
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
                            const SizedBox(height: 24),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: l10n?.password ?? 'Password',
                                prefixIcon: const Icon(Icons.lock, color: Color(0xFF3498DB)),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFF3498DB), width: 2),
                                ),
                              ),
                              obscureText: true,
                              validator: (value) => (value == null || value.isEmpty) ? (l10n?.passwordRequiredValidator ?? 'Password is required') : null,
                              onSaved: (value) => _password = value!,
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _login(l10n),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF3498DB),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: Text(
                                  l10n?.login ?? 'Login',
                                  style: const TextStyle(color: Colors.white, fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                              },
                              child: Text(
                                l10n?.forgotPasswordButtonLabel ?? 'Forgot Password?',
                                style: const TextStyle(color: Color(0xFF3498DB)),
                              ),
                            ),
                            if (_errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  _errorMessage,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: theme.colorScheme.error, fontSize: 14),
                                ),
                              ),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                              },
                              child: Text(
                                l10n?.registerNewSchoolButtonLabel ?? 'Register New School',
                                style: const TextStyle(color: Color(0xFF2ECC71)),
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
