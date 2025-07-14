import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/school_service.dart'; 
import 'package:edu_sync/models/user.dart' as app_user; 
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final SchoolService _schoolService = SchoolService();
  final ImagePicker _picker = ImagePicker();

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
      // Step 1: Sign up the admin user, passing full_name for the trigger
      final adminAuthUser = await _authService.signUp(
        _email, 
        _passwordController.text, 
        'Admin',
        fullName: _adminNameController.text // Pass admin's full name
      ); 
      if (adminAuthUser == null || adminAuthUser.id.isEmpty) {
        throw Exception('Admin user registration in auth failed.');
      }

      // Step 2: Create the School Profile
      // The adminUserId parameter in createSchool might be for associating who created it,
      // but the primary link is updating the admin's user profile with the school_id.
      final newSchool = await _schoolService.createSchool(
        name: _schoolName,
        academicYear: _academicYear,
        theme: _theme,
        contactInfo: _contactInfo,
        adminUserId: adminAuthUser.id, // If your backend uses this
      );

      if (newSchool == null) {
        // IMPORTANT: Consider deleting the auth user if school creation fails to avoid orphaned auth users.
        // This would require an admin-privileged delete, possibly via another Edge Function or careful handling.
        // For now, we'll just throw an error.
        throw Exception('School profile creation failed.');
      }
      
      // Step 3: Update the Admin's record in public.users with the new school_id
      // The trigger handle_new_user should have already created a basic profile.
      // We now update it with the school_id.
      final adminProfileToUpdate = app_user.User(
        id: adminAuthUser.id,
        fullName: _adminNameController.text, // Ensure this is consistent
        role: 'Admin', // Role is known
        schoolId: newSchool.id, // CRUCIAL: Link admin to the new school
        // email: _email, // Trigger should handle email based on auth.users.email
        profilePhotoUrl: null // Admin can set their photo later via profile edit
      );
      
      bool profileUpdateSuccess = await _authService.updateUser(adminProfileToUpdate);
      if (!profileUpdateSuccess) {
          // It's tricky to use AppLocalizations.of(context) here if context might be invalid after async
          // For critical errors like this, a non-localized string might be acceptable, or pass l10n
          throw Exception("Critical: Failed to link admin to the new school. Please contact support."); 
      }
      
      // Step 4: Upload School Logo if selected
      String? logoUrl;
      if (_schoolLogoFile != null) {
        final fileName = 'logo.${_schoolLogoFile!.path.split('.').last}';
        logoUrl = await _schoolService.uploadSchoolLogo(newSchool.id, _schoolLogoFile!.path, fileName);
        await _schoolService.updateSchool(newSchool.copyWith(logoUrl: logoUrl));
            }
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop(); 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).registrationSuccessMessage)),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          // Use AppLocalizations.of(context) here as it's within a setState guarded by mounted
          _errorMessage = '${AppLocalizations.of(context).errorOccurredPrefix}: ${e.toString()}';
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
      appBar: AppBar(title: Text(l10n.registerSchoolAdminTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: l10n.schoolNameLabel),
                validator: (value) => (value == null || value.isEmpty) ? l10n.schoolNameValidator : null,
                onSaved: (value) => _schoolName = value!,
              ),
              const SizedBox(height: 16),
               TextFormField( 
                controller: _adminNameController,
                decoration: InputDecoration(labelText: l10n.adminFullNameLabel),
                validator: (value) => (value == null || value.isEmpty) ? l10n.adminFullNameValidator : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.adminEmailLabel),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty) ? l10n.adminEmailValidator : null,
                onSaved: (value) => _email = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.adminPasswordLabel),
                obscureText: true,
                controller: _passwordController, 
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.passwordRequiredValidator; 
                  if (value.length < 6) return l10n.passwordTooShortValidator; 
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController, 
                decoration: InputDecoration(labelText: l10n.confirmAdminPasswordLabel),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n.confirmPasswordValidator; 
                  if (value != _passwordController.text) return l10n.passwordsDoNotMatchValidator; 
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.academicYearLabel, hintText: l10n.academicYearHint),
                onSaved: (value) => _academicYear = value ?? '',
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: l10n.contactInfoLabel),
                onSaved: (value) => _contactInfo = value ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _schoolLogoFile == null ? l10n.noLogoSelected : '${l10n.logoSelectedLabel}: ${_schoolLogoFile!.path.split('/').last}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: contextualAccentColor),
                    icon: const Icon(Icons.image),
                    label: Text(l10n.selectLogoButton),
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
                      child: Text(l10n.registerButton),
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
