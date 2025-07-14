import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
// import 'package:edu_sync/models/student.dart'; // Will be needed for linking
// import 'package:edu_sync/services/student_service.dart'; // Will be needed for linking

class AddEditParentScreen extends StatefulWidget {
  final app_user.User? parent; // Existing parent to edit, null if adding new
  final int schoolId;

  const AddEditParentScreen({super.key, this.parent, required this.schoolId});

  @override
  State<AddEditParentScreen> createState() => _AddEditParentScreenState();
}

class _AddEditParentScreenState extends State<AddEditParentScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();
  // final StudentService _studentService = StudentService(); // For fetching students to link

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController; // Only for adding new parent
  
  File? _profilePhotoFile;
  String? _currentProfilePhotoUrl;
  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.parent != null;

  // List<app_user.Student> _availableStudents = []; // For linking
  // List<int> _selectedStudentIds = []; // IDs of students linked to this parent

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.parent?.fullName ?? '');
    _emailController = TextEditingController(text: widget.parent?.id != null ? _getEmailFromSupabaseUser(widget.parent!.id) : '');
    _passwordController = TextEditingController();
    _currentProfilePhotoUrl = widget.parent?.profilePhotoUrl;

    // if (_isEditing && widget.parent != null) {
    //   _loadLinkedStudents(widget.parent!.id);
    // }
    // _loadAvailableStudents();
  }

  String _getEmailFromSupabaseUser(String userId) {
    // Placeholder - similar to AddEditTeacherScreen
    return widget.parent?.id ?? ''; 
  }

  // Future<void> _loadAvailableStudents() async {
  //   // _availableStudents = await _studentService.getStudentsBySchool(widget.schoolId);
  //   // setState(() {});
  // }

  // Future<void> _loadLinkedStudents(String parentId) async {
  //   // _selectedStudentIds = await _studentService.getStudentIdsForParent(parentId);
  //   // setState(() {});
  // }

  Future<void> _pickProfilePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePhotoFile = File(pickedFile.path);
        _currentProfilePhotoUrl = null; 
      });
    }
  }

  Future<void> _saveParent() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() { _isLoading = true; _errorMessage = ''; });

    String? photoUrl = _currentProfilePhotoUrl;

    try {
      app_user.User? resultUser;
      String userIdToUpdate = _isEditing ? widget.parent!.id : '';

      if (_profilePhotoFile != null) {
        String tempUserIdForPhoto = _isEditing ? widget.parent!.id : DateTime.now().millisecondsSinceEpoch.toString();
        final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
        photoUrl = await _authService.uploadProfilePhoto(tempUserIdForPhoto, _profilePhotoFile!.path, fileName);
      }

      if (_isEditing) {
        final updatedParent = widget.parent!.copyWith(
          fullName: _nameController.text,
          profilePhotoUrl: photoUrl,
        );
        final success = await _authService.updateUser(updatedParent);
        if (!success) throw Exception(AppLocalizations.of(context).failedToUpdateParentError);
        resultUser = updatedParent;
      } else {
        if (_passwordController.text.isEmpty) {
           setState(() { _isLoading = false; _errorMessage = AppLocalizations.of(context).passwordRequiredForNewParentError; });
           return;
        }
        // Adding new parent
        if (_passwordController.text.isEmpty) {
           setState(() { _isLoading = false; _errorMessage = AppLocalizations.of(context).passwordRequiredForNewParentError; });
           return;
        }

        // Create user via Edge Function
        final newParent = await _authService.createUserViaEdgeFunction(
          email: _emailController.text,
          password: _passwordController.text,
          role: 'Parent',
          schoolId: widget.schoolId,
          fullName: _nameController.text,
          profilePhotoUrl: photoUrl, // This might be null if photo is uploaded after user creation
        );

        if (newParent == null) {
          throw Exception(AppLocalizations.of(context).failedToCreateParentError);
        }
        resultUser = newParent;

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
             }
        }
      }
      
      // TODO: Implement logic to save/update linked students (_selectedStudentIds) for this parent (resultUser.id)
      setState(() => _isLoading = false);
      Navigator.of(context).pop(true); // Indicate success for both edit and new
      
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      String specificError = e.toString();
      if (e.toString().contains('Profile photo upload failed')) { 
        specificError = l10n.profilePhotoUploadFailedError;
      } else if (e.toString().contains(l10n.failedToUpdateParentError)) { 
        specificError = l10n.failedToUpdateParentError;
      } else if (e.toString().contains(l10n.failedToCreateParentError) || e.toString().contains('Failed to create user')) {
        specificError = l10n.failedToCreateParentError;
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
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('parents');

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editParentTitle : l10n.addParentTitle)), // Theme applied globally
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
                readOnly: _isEditing,
              ),
              const SizedBox(height: 16),
              if (!_isEditing)
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
              const SizedBox(height: 16),
              // TODO: Implement UI for linking students to parent
              // This could be a multi-select dropdown or a list of checkboxes
              // Text('Link Students:', style: theme.textTheme.titleMedium),
              // ... UI for student selection ...
              const SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: contextualAccentColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _saveParent,
                      child: Text(_isEditing ? l10n.updateParentButton : l10n.addParentButton),
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
