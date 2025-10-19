import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/models/staff.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:provider/provider.dart';
// Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
import 'package:edu_sync/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/user_role.dart';

class AddEditStaffScreen extends StatefulWidget {
  final Staff? staff; // Existing staff to edit, null if adding new
  final int schoolId;

  const AddEditStaffScreen({super.key, this.staff, required this.schoolId});

  @override
  State<AddEditStaffScreen> createState() => _AddEditStaffScreenState();
}

class _AddEditStaffScreenState extends State<AddEditStaffScreen> {
  final _formKey = GlobalKey<FormState>();
  late final AuthService _authService;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _salaryController;
  late UserRole _selectedRole;

  File? _profilePhotoFile;
  String? _currentProfilePhotoUrl;
  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.staff != null;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _nameController = TextEditingController(text: widget.staff?.fullName ?? '');
    _emailController = TextEditingController(text: widget.staff?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.staff?.phoneNumber ?? '');
    _salaryController = TextEditingController(text: widget.staff?.salary?.toString() ?? '');
    _selectedRole = UserRole.fromString(widget.staff?.role) ?? UserRole.Teacher;
    _currentProfilePhotoUrl = widget.staff?.profilePhotoUrl;
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePhotoFile = File(pickedFile.path);
        _currentProfilePhotoUrl = null;
      });
    }
  }

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() { _isLoading = true; _errorMessage = ''; });

    String? photoUrl = _currentProfilePhotoUrl;

    try {
      app_user.User? resultUser;

      if (_isEditing) {
        if (_profilePhotoFile != null) {
          final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          photoUrl = await _authService.uploadProfilePhoto(widget.staff!.id, _profilePhotoFile!.path, fileName);
        }
        final updatedUser = app_user.User(
          id: widget.staff!.id,
          fullName: _nameController.text,
          email: _emailController.text,
          role: _selectedRole.name,
          profilePhotoUrl: photoUrl,
          schoolId: widget.staff!.schoolId,
          phoneNumber1: _phoneController.text.isEmpty ? null : _phoneController.text,
          salary: _salaryController.text.isEmpty ? null : double.tryParse(_salaryController.text),
        );
        final success = await _authService.updateUser(updatedUser);
        if (!success) throw Exception('Failed to update staff.');
        resultUser = updatedUser;
      } else {
        if (_passwordController.text.isEmpty) {
           setState(() { _isLoading = false; _errorMessage = 'Password is required for a new staff member.'; });
           return;
        }

        logger.i('Creating staff user with role: ${_selectedRole.name} for schoolId: ${widget.schoolId}');
        logger.i('Request data: email=${_emailController.text}, schoolId=${widget.schoolId}, fullName=${_nameController.text}');

        final newUser = await _authService.createStaffByAdmin(
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole.name,
          schoolId: widget.schoolId,
          fullName: _nameController.text,
          profilePhotoUrl: photoUrl,
          phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
          salary: _salaryController.text.isEmpty ? null : double.tryParse(_salaryController.text),
        );

        logger.i('Staff user created successfully');

        if (newUser == null) {
          throw Exception('Failed to create staff member.');
        }
        resultUser = newUser;

        if (_profilePhotoFile != null) {
          final correctFileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          final correctPhotoUrl = await _authService.uploadProfilePhoto(resultUser.id, _profilePhotoFile!.path, correctFileName);
          if (correctPhotoUrl != null) {
            final updatedUser = app_user.User(
              id: resultUser.id,
              fullName: resultUser.fullName,
              email: resultUser.email,
              role: resultUser.role,
              profilePhotoUrl: correctPhotoUrl,
              schoolId: resultUser.schoolId,
              phoneNumber1: resultUser.phoneNumber1,
              salary: resultUser.salary,
            );
            await _authService.updateUser(updatedUser);
          } else {
            logger.e("Photo upload failed for new staff ${resultUser.id} after creation.");
          }
        }
      }

      setState(() => _isLoading = false);
      if (mounted) Navigator.of(context).pop(true);

    } catch (e) {
      String specificError = e.toString();
      if (e.toString().contains('Profile photo upload failed')) {
        specificError = 'Profile photo upload failed.';
      } else if (e.toString().contains('Failed to update staff')) {
        specificError = 'Failed to update staff member.';
      } else if (e.toString().contains('Failed to create staff')) {
        specificError = 'Failed to create staff member.';
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $specificError';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('staff');

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Staff' : 'Add Staff')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Full name cannot be empty.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty) ? 'Email cannot be empty.' : null,
                readOnly: _isEditing,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _salaryController,
                decoration: InputDecoration(labelText: 'Salary'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: InputDecoration(labelText: 'Role'),
                items: UserRole.values.map((role) {
                  return DropdownMenuItem<UserRole>(
                    value: role,
                    child: Text(role.name),
                  );
                }).toList(),
                onChanged: (UserRole? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  }
                },
                validator: (value) => value == null ? 'Role cannot be empty.' : null,
              ),
              const SizedBox(height: 16),
              if (!_isEditing)
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (!_isEditing && (value == null || value.isEmpty)) return 'Password is required.';
                    if (value != null && value.isNotEmpty && value.length < 6) return 'Password is too short.';
                    return null;
                  },
                ),
              if (!_isEditing) const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor ?? Colors.grey.withAlpha(50),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.5))
                      ),
                      child: _profilePhotoFile != null
                          ? Image.file(_profilePhotoFile!, height: 90, fit: BoxFit.contain)
                          : (_currentProfilePhotoUrl != null && _currentProfilePhotoUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _currentProfilePhotoUrl!,
                                  height: 90,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Text('Could not load image.', style: theme.textTheme.bodySmall),
                                )
                              : Text('No profile photo.', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey))),
                    )
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: contextualAccentColor),
                    icon: const Icon(Icons.image),
                    label: Text('Select Photo'),
                    onPressed: _pickProfilePhoto,
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
                      onPressed: _saveStaff,
                      child: Text(_isEditing ? 'Update Staff' : 'Add Staff'),
                    ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_errorMessage, style: TextStyle(color: theme.colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}