import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class AddEditTeacherScreen extends StatefulWidget {
  final app_user.User? teacher; // Existing teacher to edit, null if adding new
  final int schoolId;

  const AddEditTeacherScreen({super.key, this.teacher, required this.schoolId});

  @override
  State<AddEditTeacherScreen> createState() => _AddEditTeacherScreenState();
}

class _AddEditTeacherScreenState extends State<AddEditTeacherScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController; // Only for adding new teacher
  
  File? _profilePhotoFile;
  String? _currentProfilePhotoUrl;
  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.teacher != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.teacher?.fullName ?? '');
    _emailController = TextEditingController(text: widget.teacher?.id != null ? _getEmailFromSupabaseUser(widget.teacher!.id) : ''); // Fetch email if editing
    _passwordController = TextEditingController();
    _currentProfilePhotoUrl = widget.teacher?.profilePhotoUrl;

    if (_isEditing && widget.teacher?.id != null) {
      _fetchUserDetails(widget.teacher!.id);
    }
  }

  // Helper to fetch Supabase auth user email if not stored in public.users
  String _getEmailFromSupabaseUser(String userId) {
    // This is a placeholder. In a real app, you might not store email in public.users
    // or you might fetch it separately if needed for display in edit mode.
    // For adding, email is entered. For editing, it's often fixed or managed via auth settings.
    // Supabase User object (from authService.getCurrentUser()) has email.
    // If editing another user, you'd typically fetch this from your backend/Supabase.
    // For simplicity, if we are editing, we might make email read-only or handle it carefully.
    // For now, let's assume email is part of the app_user.User model or fetched.
    // If not, this field might need to be handled differently for editing.
    final supUser = _authService.getCurrentUser(); // This is the current admin, not the teacher being edited
    // We'd need a way to get the teacher's auth email.
    // For now, if not in app_user.User, we'll leave it blank or make it non-editable.
    return widget.teacher?.id ?? ''; // Placeholder, ideally fetch actual email
  }


  Future<void> _fetchUserDetails(String userId) async {
    // If email is not part of your app_user.User model and you need to display it for editing,
    // you might need a way to fetch it, e.g., via an admin endpoint if Supabase allows.
    // For now, we assume email is either part of app_user.User or handled by admin.
    // If email is stored in user_metadata or a separate profiles table, fetch it here.
    // This example assumes email is not directly editable or is pre-filled if available.
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

  Future<void> _saveTeacher() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() { _isLoading = true; _errorMessage = ''; });

    String? photoUrl = _currentProfilePhotoUrl;

    try {
      app_user.User? resultUser;
      String userIdToUpdate = _isEditing ? widget.teacher!.id : '';
      String tempUserIdForPhoto = userIdToUpdate; // Initialize with existing ID or empty for new

      if (!_isEditing) {
        // For new users, generate a temporary ID for potential initial photo upload.
        // This will be compared later with the actual ID received after user creation.
        tempUserIdForPhoto = DateTime.now().millisecondsSinceEpoch.toString();
      }
      
      if (_profilePhotoFile != null) {
        // Use userIdToUpdate if editing, or tempUserIdForPhoto if adding a new user.
        String idForPhotoPath = _isEditing ? userIdToUpdate : tempUserIdForPhoto;
        final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
        photoUrl = await _authService.uploadProfilePhoto(idForPhotoPath, _profilePhotoFile!.path, fileName);
      }

      if (_isEditing) {
        final updatedTeacher = widget.teacher!.copyWith(
          fullName: _nameController.text,
          profilePhotoUrl: photoUrl,
          // Role and schoolId are typically not changed here by this form for an existing teacher
        );
        final success = await _authService.updateUser(updatedTeacher);
        if (!success) throw Exception('Failed to update teacher.');
        resultUser = updatedTeacher;
      } else {
        // Adding new teacher
        if (_passwordController.text.isEmpty) {
           setState(() { _isLoading = false; _errorMessage = AppLocalizations.of(context).passwordRequiredForNewTeacherError; });
           return;
        }
        // Adding new teacher
        if (_passwordController.text.isEmpty) {
           setState(() { _isLoading = false; _errorMessage = AppLocalizations.of(context).passwordRequiredForNewTeacherError; });
           return;
        }

        // Create user via Edge Function
        final newTeacher = await _authService.createUserViaEdgeFunction(
          email: _emailController.text,
          password: _passwordController.text,
          role: 'Teacher',
          schoolId: widget.schoolId,
          fullName: _nameController.text,
          profilePhotoUrl: photoUrl, // This might be null if photo is uploaded after user creation
        );

        if (newTeacher == null) {
          // Error is already printed by AuthService, or rethrow specific error
          throw Exception(AppLocalizations.of(context).failedToCreateTeacherError);
        }
        resultUser = newTeacher;

        // If a new photo was picked and initial photoUrl was null (or based on temp ID),
        // and now we have the actual user ID, upload/update the photo URL.
        if (_profilePhotoFile != null && photoUrl == null) { // Only if photo wasn't uploaded with temp ID
             final correctFileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
             final correctPhotoUrl = await _authService.uploadProfilePhoto(resultUser.id, _profilePhotoFile!.path, correctFileName);
             if (correctPhotoUrl != null) {
                resultUser = resultUser.copyWith(profilePhotoUrl: correctPhotoUrl);
                // Update the user record in public.users with the correct photo URL
                await _authService.updateUser(resultUser);
             } else {
                print("Photo upload failed for new user ${resultUser.id} after creation, during explicit photo step.");
                // Optionally set an error message or allow user to proceed without photo
             }
        }
      }
      
      setState(() => _isLoading = false);
      Navigator.of(context).pop(true); // Indicate success for both edit and new
      
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      String specificError = e.toString();
      if (e.toString().contains('Profile photo upload failed')) {
        specificError = l10n.profilePhotoUploadFailedError;
      } else if (e.toString().contains('Failed to update teacher')) { 
        specificError = l10n.failedToUpdateTeacherError;
      } else if (e.toString().contains(l10n.failedToCreateTeacherError) || e.toString().contains('Failed to create user')) {
        specificError = l10n.failedToCreateTeacherError;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = '${l10n.errorOccurredPrefix}: $specificError';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editTeacherTitle : l10n.addTeacherTitle)), // Theme applied globally
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.fullNameLabel),
                validator: (value) => (value == null || value.isEmpty) ? l10n.fullNameValidator : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: l10n.emailLabel),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty) ? l10n.emailValidator : null,
                readOnly: _isEditing, // Email usually not editable after creation
              ),
              const SizedBox(height: 16),
              if (!_isEditing) // Password field only for adding new teacher
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: l10n.passwordLabel),
                  obscureText: true,
                  validator: (value) {
                    if (!_isEditing && (value == null || value.isEmpty)) return l10n.passwordRequiredValidator;
                    if (value != null && value.isNotEmpty && value.length < 6) return l10n.passwordTooShortValidator;
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
                        color: theme.inputDecorationTheme.fillColor ?? cardBackgroundColor.withAlpha(200),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? textLightGrey.withOpacity(0.5))
                      ),
                      child: _profilePhotoFile != null
                          ? Image.file(_profilePhotoFile!, height: 90, fit: BoxFit.contain)
                          : (_currentProfilePhotoUrl != null && _currentProfilePhotoUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _currentProfilePhotoUrl!,
                                  height: 90,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Text(l10n.couldNotLoadImage, style: theme.textTheme.bodySmall),
                                )
                              : Text(l10n.noProfilePhoto, style: theme.textTheme.bodyMedium?.copyWith(color: textLightGrey))),
                    )
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: contextualAccentColor),
                    icon: const Icon(Icons.image),
                    label: Text(l10n.selectPhotoButton),
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
                      onPressed: _saveTeacher,
                      child: Text(_isEditing ? l10n.updateTeacherButton : l10n.addTeacherButton),
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
