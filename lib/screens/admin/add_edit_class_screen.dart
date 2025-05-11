import 'package:flutter/material.dart';
import 'package:edu_sync/models/class.dart' as app_class;
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/auth_service.dart'; // To fetch teachers
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
import 'package:uuid/uuid.dart'; // For generating UUIDs

class AddEditClassScreen extends StatefulWidget {
  final app_class.Class? classDetails;
  final int schoolId;

  const AddEditClassScreen({super.key, this.classDetails, required this.schoolId});

  @override
  State<AddEditClassScreen> createState() => _AddEditClassScreenState();
}

class _AddEditClassScreenState extends State<AddEditClassScreen> {
  final _formKey = GlobalKey<FormState>();
  final ClassService _classService = ClassService();
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid(); // UUID generator

  late TextEditingController _nameController;
  String? _selectedTeacherId; // Store as String (UUID)
  List<app_user.User> _availableTeachers = [];
  String? _sectionControllerText; // For section input

  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.classDetails != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.classDetails?.name ?? '');
    _selectedTeacherId = widget.classDetails?.teacherId; 
    _sectionControllerText = widget.classDetails?.section;
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() => _isLoading = true);
    try {
      // Assuming getTeachersBySchool or similar method exists that returns List<app_user.User>
      // For now, using getUsersByRole as a placeholder if it fetches teachers.
      _availableTeachers = await _authService.getUsersByRole('Teacher', widget.schoolId);
      
      if (_isEditing && widget.classDetails?.teacherId != null) {
        if (!_availableTeachers.any((t) => t.id == widget.classDetails!.teacherId)) {
          _selectedTeacherId = widget.classDetails!.teacherId; 
        }
      }
    } catch (e) {
      print("Error loading teachers: $e");
      if(mounted) setState(() => _errorMessage = AppLocalizations.of(context).failedToLoadTeachersError);
    }
    if(mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final classData = app_class.Class(
        id: _isEditing ? widget.classDetails!.id : null, // ID is int?, null for new
        name: _nameController.text,
        teacherId: _selectedTeacherId, 
        schoolId: widget.schoolId,
        section: _sectionControllerText,
      );

      bool success;
      if (_isEditing) {
        success = await _classService.updateClass(classData);
      } else {
        final newClass = await _classService.createClass(classData);
        success = newClass != null;
      }

      if (success) {
        if(mounted) Navigator.of(context).pop(true); // Indicate success
      } else {
        throw Exception(AppLocalizations.of(context).failedToSaveClassError);
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '${AppLocalizations.of(context).errorOccurredPrefix}: ${e.toString()}';
        });
      }
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Contextual color for class management - using 'students' accent
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students');

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editClassTitle : l10n.addClassTitle)), // Theme applied globally
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: l10n.classNameLabel),
                validator: (value) => (value == null || value.isEmpty) ? l10n.classNameValidator : null,
              ),
              const SizedBox(height: 16),
              TextFormField( 
                initialValue: _sectionControllerText,
                decoration: const InputDecoration(
                  labelText: "Section", 
                  hintText: "e.g., A, B (Optional)", 
                ),
                onChanged: (value) => _sectionControllerText = value.trim().isEmpty ? null : value.trim(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedTeacherId,
                hint: Text(l10n.selectClassTeacherHint),
                items: _availableTeachers.map((app_user.User teacher) {
                  return DropdownMenuItem<String>(
                    value: teacher.id, 
                    child: Text(teacher.fullName ?? '${l10n.unnamedTeacher} (${teacher.id.substring(0,8)})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTeacherId = value;
                  });
                },
                // validator: (value) => value == null ? l10n.classTeacherValidator : null, // Teacher can be optional for a class
                decoration: InputDecoration(labelText: l10n.classTeacherLabel),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: contextualAccentColor,
                        foregroundColor: Colors.white, // Assuming white text on this accent
                      ),
                      onPressed: _saveClass,
                      child: Text(_isEditing ? l10n.updateClassButton : l10n.addClassButton),
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
