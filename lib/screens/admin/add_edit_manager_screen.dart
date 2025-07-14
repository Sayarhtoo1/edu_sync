import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/user.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/app_localizations.dart'; // Localization
import 'package:edu_sync/theme/app_theme.dart'; // Theme

class AddEditManagerScreen extends StatefulWidget {
  final User? manager;
  final int schoolId;

  const AddEditManagerScreen({super.key, this.manager, required this.schoolId});

  @override
  State<AddEditManagerScreen> createState() => _AddEditManagerScreenState();
}

class _AddEditManagerScreenState extends State<AddEditManagerScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  File? _profilePhotoFile;
  String? _currentProfilePhotoUrl;
  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.manager != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.manager?.fullName ?? '');
    _emailController = TextEditingController(text: widget.manager?.id ?? '');
    _passwordController = TextEditingController();
    _currentProfilePhotoUrl = widget.manager?.profilePhotoUrl;

    if (_isEditing && widget.manager?.id != null) {
      _fetchUserDetails(widget.manager!.id);
    }
  }

  Future<void> _fetchUserDetails(String userId) async {
    // Reserved for future: fetching manager email or other info
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

  Future<void> _saveManager() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String? photoUrl = _currentProfilePhotoUrl;

    try {
      User? resultUser;
      String userIdToUpdate = _isEditing ? widget.manager!.id : '';
      String tempUserIdForPhoto = userIdToUpdate;

      if (!_isEditing) {
        tempUserIdForPhoto = DateTime.now().millisecondsSinceEpoch.toString();
      }

      if (_profilePhotoFile != null) {
        String idForPhotoPath = _isEditing ? userIdToUpdate : tempUserIdForPhoto;
        final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
        photoUrl = await _authService.uploadProfilePhoto(idForPhotoPath, _profilePhotoFile!.path, fileName);
      }

      if (_isEditing) {
        final updatedManager = widget.manager!.copyWith(
          profilePhotoUrl: photoUrl,
        );
        final success = await _authService.updateUser(updatedManager);
        if (!success) throw Exception('Failed to update manager.');
        resultUser = updatedManager;
      } else {
        if (_passwordController.text.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = AppLocalizations.of(context).passwordRequiredForNewTeacherError;
          });
          return;
        }

        final newManager = await _authService.createUserViaEdgeFunction(
          email: _emailController.text,
          password: _passwordController.text,
          role: 'Manager',
          schoolId: widget.schoolId,
          fullName: _nameController.text,
          profilePhotoUrl: photoUrl,
        );

        if (newManager == null) {
          throw Exception(AppLocalizations.of(context).failedToCreateTeacherError);
        }
        resultUser = newManager;

        if (_profilePhotoFile != null && photoUrl == null) {
          final correctFileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          final correctPhotoUrl = await _authService.uploadProfilePhoto(resultUser.id, _profilePhotoFile!.path, correctFileName);
          if (correctPhotoUrl != null) {
            resultUser = resultUser.copyWith(profilePhotoUrl: correctPhotoUrl);
            await _authService.updateUser(resultUser);
          }
        }
      }

      setState(() => _isLoading = false);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return; // Added mounted check
      final l10n = AppLocalizations.of(context);
      String specificError = e.toString();
      if (e.toString().contains('Profile photo upload failed')) {
        specificError = l10n.profilePhotoUploadFailedError;
      } else if (e.toString().contains('Failed to update manager')) {
        specificError = l10n.failedToUpdateTeacherError;
      } else if (e.toString().contains(l10n.failedToCreateTeacherError) || e.toString().contains('Failed to create user')) {
        specificError = l10n.failedToCreateTeacherError;
      }
      if (!mounted) return; // Added mounted check
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
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('managers');

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editManagerTitle : l10n.addManagerTitle)),
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
                      border: Border.all(color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? textLightGrey.withAlpha(128)),
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
                  ),
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
                      onPressed: _saveManager,
                      child: Text(_isEditing ? l10n.updateManagerButton : l10n.addManagerButton),
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
