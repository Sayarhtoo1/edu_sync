import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/school_service.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AuthService _authService;
  late final SchoolService _schoolService;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _schoolService = Provider.of<SchoolService>(context, listen: false);
  }

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController(); 
  final TextEditingController _adminNameController = TextEditingController(); // For Admin's full name

  String _schoolName = '';
  String _email = '';
  // String _adminFullName = ''; // Will be taken from _adminNameController
  String _academicYear = '';
  final String _theme = 'green-orange'; 
  String _contactInfo = '';
  File? _schoolLogoFile;
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _pickSchoolLogo() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _schoolLogoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerAdminAndSchool() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save(); 
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      await _authService.registerSchoolAndAdmin(
        email: _email,
        password: _passwordController.text,
        fullName: _adminNameController.text,
        schoolName: _schoolName,
        schoolLogoUrl: _schoolLogoFile?.path,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)
                    ?.registrationSuccessMessage ??
                'Registration successful!')),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              '${AppLocalizations.of(context)?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminNameController.dispose(); // Dispose new controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = defaultAccentColor;

    return Scaffold(
      appBar: AppBar(title: Text(l10n?.registerSchoolAdminTitle ?? 'Register School Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: l10n?.schoolNameLabel ?? 'School Name'),
                validator: (value) => (value == null || value.isEmpty) ? l10n?.schoolNameValidator ?? 'School name cannot be empty.' : null,
                onSaved: (value) => _schoolName = value!,
              ),
              const SizedBox(height: 16),
               TextFormField( 
                controller: _adminNameController,
                decoration: InputDecoration(labelText: l10n?.adminFullNameLabel ?? 'Admin Full Name'),
                validator: (value) => (value == null || value.isEmpty) ? l10n?.adminFullNameValidator ?? 'Admin full name cannot be empty.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n?.adminEmailLabel ?? 'Admin Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty) ? l10n?.adminEmailValidator ?? 'Admin email cannot be empty.' : null,
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n?.adminPasswordLabel ?? 'Admin Password'),
                obscureText: true,
                controller: _passwordController, 
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n?.passwordRequiredValidator ?? 'Password is required.'; 
                  if (value.length < 6) return l10n?.passwordTooShortValidator ?? 'Password is too short.'; 
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController, 
                decoration: InputDecoration(labelText: l10n?.confirmAdminPasswordLabel ?? 'Confirm Admin Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n?.confirmPasswordValidator ?? 'Confirm password cannot be empty.'; 
                  if (value != _passwordController.text) return l10n?.passwordsDoNotMatchValidator ?? 'Passwords do not match.'; 
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n?.academicYearLabel ?? 'Academic Year', hintText: l10n?.academicYearHint ?? 'e.g., 2023-2024'),
                onSaved: (value) => _academicYear = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n?.contactInfoLabel ?? 'Contact Info'),
                onSaved: (value) => _contactInfo = value ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _schoolLogoFile == null ? l10n?.noLogoSelected ?? 'No logo selected.' : '${l10n?.logoSelectedLabel ?? 'Logo Selected'}: ${_schoolLogoFile!.path.split('/').last}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: contextualAccentColor),
                    icon: const Icon(Icons.image),
                    label: Text(l10n?.selectLogoButton ?? 'Select Logo'),
                    onPressed: _pickSchoolLogo,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: contextualAccentColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _registerAdminAndSchool,
                      child: Text(l10n?.registerButton ?? 'Register'),
                    ),
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
            ],
          ),
        ),
      ),
    );
  }
}
