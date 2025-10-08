import 'package:flutter/material.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import for SVG
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
// import 'package:edu_sync/theme/app_theme.dart'; // Unused Import

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
        // Successful login is handled by the GoRouter redirect.
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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.primaryColor, theme.colorScheme.secondary],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/EduSync.svg',
                    height: screenHeight * 0.15,
                    colorFilter: ColorFilter.mode(theme.colorScheme.onPrimary, BlendMode.srcIn),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    l10n?.appTitle ?? 'EduSync',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    l10n?.appTagline ?? 'Your Partner in Education',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    margin: EdgeInsets.symmetric(horizontal: screenHeight * 0.02),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n?.login ?? 'Login',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: l10n?.email ?? 'Email',
                              prefixIcon: Icon(Icons.email, color: theme.colorScheme.primary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) => (value == null || value.isEmpty) ? (l10n?.emailValidator ?? 'Email cannot be empty') : null,
                            onSaved: (value) => _email = value!,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: l10n?.password ?? 'Password',
                              prefixIcon: Icon(Icons.lock, color: theme.colorScheme.primary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                              ),
                            ),
                            obscureText: true,
                            validator: (value) => (value == null || value.isEmpty) ? (l10n?.passwordRequiredValidator ?? 'Password is required') : null,
                            onSaved: (value) => _password = value!,
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => _login(l10n),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                l10n?.login ?? 'Login',
                                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
                            },
                            child: Text(
                              l10n?.forgotPasswordButtonLabel ?? 'Forgot Password?',
                              style: TextStyle(color: theme.colorScheme.primary),
                            ),
                          ),
                          if (_errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                _errorMessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: theme.colorScheme.error, fontSize: theme.textTheme.bodyMedium?.fontSize),
                              ),
                            ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
                            },
                            child: Text(
                              l10n?.registerNewSchoolButtonLabel ?? 'Register New School',
                              style: TextStyle(color: theme.colorScheme.secondary),
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
    );
  }
}
