import 'dart:io';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/services/school_service.dart';
// import 'package:edu_sync/services/auth_service.dart'; // Unused import
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class EditSchoolProfileScreen extends StatefulWidget {
  final School school; // School to edit

  const EditSchoolProfileScreen({super.key, required this.school});

  @override
  State<EditSchoolProfileScreen> createState() => _EditSchoolProfileScreenState();
}

class _EditSchoolProfileScreenState extends State<EditSchoolProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final SchoolService _schoolService = SchoolService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _academicYearController;
  late TextEditingController _themeController;
  late TextEditingController _contactInfoController;
  File? _schoolLogoFile;
  String? _currentLogoUrl;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.school.name);
    _academicYearController = TextEditingController(text: widget.school.academicYear);
    _themeController = TextEditingController(text: widget.school.theme);
    _contactInfoController = TextEditingController(text: widget.school.contact);
    _currentLogoUrl = widget.school.logoUrl;
  }

  Future<void> _pickSchoolLogo() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _schoolLogoFile = File(pickedFile.path);
        _currentLogoUrl = null; // Clear current URL if new file is picked
      });
    }
  }

  Future<void> _updateSchoolProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String? newLogoUrl = _currentLogoUrl; // Keep current logo if no new one is picked

    try {
      if (_schoolLogoFile != null) {
        final fileName = 'logo.${_schoolLogoFile!.path.split('.').last}';
        newLogoUrl = await _schoolService.uploadSchoolLogo(widget.school.id, _schoolLogoFile!.path, fileName);
        if (newLogoUrl == null) {
          throw Exception('Logo upload failed.');
        }
      }

      final updatedSchool = widget.school.copyWith(
        name: _nameController.text,
        academicYear: _academicYearController.text,
        theme: _themeController.text,
        contact: _contactInfoController.text,
        logoUrl: newLogoUrl,
      );

      final success = await _schoolService.updateSchool(updatedSchool);

      if (success) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pop(); // Go back
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('School profile updated successfully!')), // Consider localizing this
          );
        }
      } else {
        throw Exception('Failed to update school profile.'); // Consider localizing this
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'An error occurred: ${e.toString()}'; // Consider localizing this
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _academicYearController.dispose();
    _themeController.dispose();
    _contactInfoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Using defaultAccentColor for general profile updates
    final Color contextualAccentColor = defaultAccentColor; 

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editSchoolProfileTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.schoolNameLabel), // Assuming key exists
                validator: (value) => (value == null || value.isEmpty) ? l10n.schoolNameValidator : null, // Assuming key exists
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _academicYearController,
                decoration: InputDecoration(labelText: l10n.academicYearLabel, hintText: l10n.academicYearHint), // Assuming key exists
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _themeController,
                decoration: InputDecoration(labelText: l10n.themeLabel, hintText: l10n.themeHint), // Assuming key exists
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactInfoController,
                decoration: InputDecoration(labelText: l10n.contactInfoLabel), // Assuming key exists
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.inputDecorationTheme.fillColor ?? cardBackgroundColor.withAlpha(200),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? textLightGrey.withAlpha((255 * 0.5).round()))
                      ),
                      child: _schoolLogoFile != null
                          ? Image.file(_schoolLogoFile!, height: 90, fit: BoxFit.contain)
                          : (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty
                              ? Image.network(_currentLogoUrl!, height: 90, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Text(l10n.couldNotLoadImage, style: theme.textTheme.bodySmall))
                              : Text(l10n.noLogoSelected, style: theme.textTheme.bodyMedium?.copyWith(color: textLightGrey))), 
                    )
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: contextualAccentColor),
                    icon: const Icon(Icons.image),
                    label: Text(l10n.changeLogoButton), 
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
                      onPressed: _updateSchoolProfile,
                      child: Text(l10n.updateProfileButton), 
                    ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
