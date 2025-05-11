import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/models/class.dart' as app_class; 
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/models/user.dart' as app_user; // For Parent User
import 'package:edu_sync/services/auth_service.dart'; // To fetch parents
import 'package:edu_sync/l10n/app_localizations.dart'; 
import 'package:intl/intl.dart'; // For date formatting
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
// For firstWhereOrNull

class AddEditStudentScreen extends StatefulWidget {
  final Student? student;
  final int schoolId;

  const AddEditStudentScreen({super.key, this.student, required this.schoolId});

  @override
  State<AddEditStudentScreen> createState() => _AddEditStudentScreenState();
}

class _AddEditStudentScreenState extends State<AddEditStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final StudentService _studentService = StudentService();
  final ClassService _classService = ClassService(); 
  final AuthService _authService = AuthService(); // For fetching parents
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _dobController; // For date of birth
  
  File? _profilePhotoFile;
  String? _currentProfilePhotoUrl;
  DateTime? _selectedDateOfBirth;
  int? _selectedClassId; 
  List<app_class.Class> _availableClasses = [];
  List<app_user.User> _availableParents = [];
  List<String> _linkedParentIds = []; // Store IDs of parents linked to this student
  List<String> _initialLinkedParentIds = []; // To track changes
  String? _selectedGender; // Added for gender

  String _errorMessage = '';
  bool _isLoading = false; // General loading
  bool _isLoadingParents = false; // Specific for loading parents
  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student?.fullName ?? '');
    _selectedDateOfBirth = widget.student?.dateOfBirth;
    _dobController = TextEditingController(
        text: _selectedDateOfBirth != null ? DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!) : '');
    _currentProfilePhotoUrl = widget.student?.profilePhotoUrl;
    _selectedClassId = widget.student?.classId;
    _selectedGender = widget.student?.gender; // Initialize gender
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _loadClasses();
    await _loadAvailableParents();
    if (_isEditing && widget.student != null) {
      await _loadLinkedParents(widget.student!.id);
    }
    if(mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadClasses() async {
    try {
      _availableClasses = await _classService.getClassesBySchool(widget.schoolId);
    } catch (e) {
      print("Error loading classes: $e");
      if(mounted) setState(() => _errorMessage = AppLocalizations.of(context).failedToLoadClassesError);
    }
  }

  Future<void> _loadAvailableParents() async {
    setState(() => _isLoadingParents = true);
    try {
      _availableParents = await _authService.getUsersByRole('Parent', widget.schoolId);
    } catch (e) {
      print("Error loading parents: $e");
      if(mounted) setState(() => _errorMessage = "Failed to load parents."); // TODO: Localize
    }
    if(mounted) setState(() => _isLoadingParents = false);
  }

  Future<void> _loadLinkedParents(int studentId) async {
    try {
      _linkedParentIds = await _studentService.getParentIdsForStudent(studentId);
      _initialLinkedParentIds = List.from(_linkedParentIds); 
    } catch (e) {
      print("Error loading linked parents: $e");
      if(mounted) setState(() => _errorMessage = "Failed to load linked parents."); // TODO: Localize
    }
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

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students');

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 25), 
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: contextualAccentColor,
              onPrimary: Colors.white,
              onSurface: textDarkGrey,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: contextualAccentColor,
              ),
            ), dialogTheme: DialogThemeData(backgroundColor: cardBackgroundColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _updateParentLinks(int studentId) async {
    final l10n = AppLocalizations.of(context);
    final parentsToLink = _linkedParentIds.where((pid) => !_initialLinkedParentIds.contains(pid)).toList();
    final parentsToUnlink = _initialLinkedParentIds.where((pid) => !_linkedParentIds.contains(pid)).toList();

    for (String parentId in parentsToLink) {
      bool linked = await _studentService.linkParentToStudent(parentId, studentId, "Parent"); // Default relation type
      if (!linked && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to link parent $parentId"))); 
      }
    }
    for (String parentId in parentsToUnlink) {
      bool unlinked = await _studentService.unlinkParentFromStudent(parentId, studentId);
       if (!unlinked && mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to unlink parent $parentId"))); 
      }
    }
    _initialLinkedParentIds = List.from(_linkedParentIds);
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() { _isLoading = true; _errorMessage = ''; });

    String? photoUrl = _currentProfilePhotoUrl;

    try {
      Student studentData = Student(
        id: _isEditing ? widget.student!.id : 0, 
        schoolId: widget.schoolId,
        fullName: _nameController.text,
        dateOfBirth: _selectedDateOfBirth,
        classId: _selectedClassId,
        profilePhotoUrl: photoUrl,
        gender: _selectedGender, // Add gender to student data
      );

      Student? resultStudent;

      if (_isEditing) {
        if (_profilePhotoFile != null) {
          final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          photoUrl = await _studentService.uploadStudentProfilePhoto(widget.student!.id, _profilePhotoFile!.path, fileName);
          if (photoUrl == null) throw Exception(AppLocalizations.of(context).profilePhotoUploadFailedError);
          studentData = studentData.copyWith(profilePhotoUrl: photoUrl);
        }
        final success = await _studentService.updateStudent(studentData);
        if (!success) throw Exception(AppLocalizations.of(context).failedToUpdateStudentError);
        resultStudent = studentData;
      } else { 
        Student? createdStudent = await _studentService.createStudent(studentData.copyWith(profilePhotoUrl: null)); 
        if (createdStudent == null) throw Exception(AppLocalizations.of(context).failedToCreateStudentError);
        resultStudent = createdStudent; 

        if (_profilePhotoFile != null) {
          final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          photoUrl = await _studentService.uploadStudentProfilePhoto(resultStudent.id, _profilePhotoFile!.path, fileName);
          if (photoUrl != null) {
            resultStudent = resultStudent.copyWith(profilePhotoUrl: photoUrl);
            await _studentService.updateStudent(resultStudent); 
          } else {
            print('Photo upload failed, but student created without photo.');
          }
        }
      }

      await _updateParentLinks(resultStudent.id);
          
      if(mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true); 
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      String specificError = e.toString();
      if (e.toString().contains(l10n.profilePhotoUploadFailedError)) {
        specificError = l10n.profilePhotoUploadFailedError;
      } else if (e.toString().contains(l10n.failedToUpdateStudentError)) {
        specificError = l10n.failedToUpdateStudentError;
      } else if (e.toString().contains(l10n.failedToCreateStudentError)) {
        specificError = l10n.failedToCreateStudentError;
      }
      if(mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '${l10n.errorOccurredPrefix}: $specificError';
        });
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Widget _buildParentSelector(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students');
    
    if (_isLoadingParents) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)));
    }
    if (_availableParents.isEmpty) {
      return Text(l10n.noParentsAvailableToLink, style: theme.textTheme.bodyMedium); 
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(l10n.linkParentsTitle, style: theme.textTheme.titleMedium), 
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _availableParents.length,
          itemBuilder: (context, index) {
            final parent = _availableParents[index];
            return CheckboxListTile(
              title: Text(parent.fullName ?? l10n.unnamedParent, style: theme.textTheme.bodyLarge), 
              value: _linkedParentIds.contains(parent.id),
              activeColor: contextualAccentColor,
              onChanged: (bool? selected) {
                setState(() {
                  if (selected == true) {
                    _linkedParentIds.add(parent.id);
                  } else {
                    _linkedParentIds.remove(parent.id);
                  }
                });
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students');

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editStudentTitle : l10n.addStudentTitle)), // Theme applied globally
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
                controller: _dobController,
                decoration: InputDecoration(labelText: l10n.dateOfBirthLabel, hintText: l10n.dateOfBirthHint),
                readOnly: true,
                onTap: () => _selectDateOfBirth(context),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>( 
                value: _selectedClassId,
                hint: Text(l10n.selectClassOptionalHint),
                items: _availableClasses.map((app_class.Class cls) {
                  return DropdownMenuItem<int>( 
                    value: cls.id, 
                    child: Text(cls.name), 
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClassId = value;
                  });
                },
                decoration: InputDecoration(labelText: l10n.classOptionalLabel),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                hint: Text(l10n.selectGenderHint ?? "Select Gender"), 
                items: [ 
                  DropdownMenuItem(value: 'Male', child: Text(l10n.genderMale ?? "Male")), 
                  DropdownMenuItem(value: 'Female', child: Text(l10n.genderFemale ?? "Female")), 
                  DropdownMenuItem(value: 'Other', child: Text(l10n.genderOther ?? "Other")), 
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                decoration: InputDecoration(labelText: l10n.genderLabel ?? "Gender"), 
                validator: (value) => value == null || value.isEmpty ? (l10n.genderValidator ?? "Gender is required") : null, 
              ),
              const SizedBox(height: 16),
              _buildParentSelector(l10n),
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
                        border: Border.all(color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? textLightGrey.withOpacity(0.5))
                      ),
                      child: _profilePhotoFile != null
                          ? Image.file(_profilePhotoFile!, height: 90, fit: BoxFit.contain)
                          : (_currentProfilePhotoUrl != null && _currentProfilePhotoUrl!.isNotEmpty
                              ? Image.network(_currentProfilePhotoUrl!, height: 90, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => Text(l10n.couldNotLoadImage, style: theme.textTheme.bodySmall))
                              : Text(l10n.noProfilePhoto, style: theme.textTheme.bodyMedium?.copyWith(color: textLightGrey))),
                    )
                  ),
                  const SizedBox(width:16),
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
                      onPressed: _saveStudent,
                      child: Text(_isEditing ? l10n.updateStudentButton : l10n.addStudentButton),
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
