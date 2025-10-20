import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/school_service.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:provider/provider.dart';

class DesktopRegisterScreen extends StatefulWidget {
  const DesktopRegisterScreen({super.key});

  @override
  State<DesktopRegisterScreen> createState() => _DesktopRegisterScreenState();
}

class _DesktopRegisterScreenState extends State<DesktopRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AuthService _authService;
  late final SchoolService _schoolService;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _adminNameController = TextEditingController();

  String _schoolName = '';
  String _email = '';
  String _academicYear = '';
  String _contactInfo = '';
  File? _schoolLogoFile;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _schoolService = Provider.of<SchoolService>(context, listen: false);
  }

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
        SnackBar(content: Text(AppLocalizations.of(context)?.registrationSuccessMessage ?? 'Registration successful!')),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '${AppLocalizations.of(context)?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adminNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.registerSchoolAdminTitle ?? 'Register School Admin'),
        backgroundColor: const Color(0xFF3498DB),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
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
                      Text(
                        l10n?.registerSchoolAdminTitle ?? 'Register School Admin',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF3498DB)),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: l10n?.schoolNameLabel ?? 'School Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? l10n?.schoolNameValidator ?? 'School name cannot be empty.' : null,
                        onSaved: (value) => _schoolName = value!,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _adminNameController,
                        decoration: InputDecoration(
                          labelText: l10n?.adminFullNameLabel ?? 'Admin Full Name',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? l10n?.adminFullNameValidator ?? 'Admin full name cannot be empty.' : null,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: l10n?.adminEmailLabel ?? 'Admin Email',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) => (value == null || value.isEmpty) ? l10n?.adminEmailValidator ?? 'Admin email cannot be empty.' : null,
                        onSaved: (value) => _email = value!,
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: l10n?.adminPasswordLabel ?? 'Admin Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                        controller: _passwordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) return l10n?.passwordRequiredValidator ?? 'Password is required.';
                          if (value.length < 6) return l10n?.passwordTooShortValidator ?? 'Password is too short.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: l10n?.confirmAdminPasswordLabel ?? 'Confirm Admin Password',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) return l10n?.confirmPasswordValidator ?? 'Confirm password cannot be empty.';
                          if (value != _passwordController.text) return l10n?.passwordsDoNotMatchValidator ?? 'Passwords do not match.';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: l10n?.academicYearLabel ?? 'Academic Year',
                          hintText: l10n?.academicYearHint ?? 'e.g., 2023-2024',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onSaved: (value) => _academicYear = value ?? '',
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: l10n?.contactInfoLabel ?? 'Contact Info',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onSaved: (value) => _contactInfo = value ?? '',
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _schoolLogoFile == null ? l10n?.noLogoSelected ?? 'No logo selected.' : '${l10n?.logoSelectedLabel ?? 'Logo Selected'}: ${_schoolLogoFile!.path.split('/').last}',
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
                              foregroundColor: Colors.white,
                            ),
                            icon: const Icon(Icons.image),
                            label: Text(l10n?.selectLogoButton ?? 'Select Logo'),
                            onPressed: _pickSchoolLogo,
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB))))
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3498DB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: _registerAdminAndSchool,
                              child: Text(l10n?.registerButton ?? 'Register', style: const TextStyle(fontSize: 16)),
                            ),
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(color: Color(0xFFE74C3C), fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
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
