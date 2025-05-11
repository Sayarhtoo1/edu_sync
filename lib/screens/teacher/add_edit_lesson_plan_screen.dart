import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/models/lesson_plan.dart';
import 'package:edu_sync/models/class.dart' as app_class;
import 'package:edu_sync/services/lesson_plan_service.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/auth_service.dart'; // Import AuthService
import 'package:edu_sync/services/timetable_service.dart'; // To get subjects
// For subjects
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme


class AddEditLessonPlanScreen extends StatefulWidget {
  final int schoolId;
  final String teacherId;
  final LessonPlan? lessonPlan;
  final int? initialClassId; // This should be int?

  const AddEditLessonPlanScreen({
    super.key,
    required this.schoolId,
    required this.teacherId,
    this.lessonPlan,
    this.initialClassId,
  });

  @override
  State<AddEditLessonPlanScreen> createState() => _AddEditLessonPlanScreenState();
}

class _AddEditLessonPlanScreenState extends State<AddEditLessonPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  final LessonPlanService _lessonPlanService = LessonPlanService();
  final ClassService _classService = ClassService();
  final TimetableService _timetableService = TimetableService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  
  DateTime? _selectedDate;
  app_class.Class? _selectedClass; // This will hold the selected Class object
  String? _selectedSubjectName; // From timetable entries for the class

  List<app_class.Class> _availableClasses = [];
  List<String> _availableSubjects = []; // Subjects for the selected class

  bool _isLoading = false;
  bool _isLoadingInitialData = true;
  String _errorMessage = '';
  bool get _isEditing => widget.lessonPlan != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.lessonPlan?.title ?? '');
    _descriptionController = TextEditingController(text: widget.lessonPlan?.description ?? '');
    _selectedDate = widget.lessonPlan?.date ?? DateTime.now();
    _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate!));
    
    // _selectedClass will be determined in _loadInitialScreenData
    _loadInitialScreenData();
  }

  Future<void> _loadInitialScreenData() async {
    setState(() => _isLoadingInitialData = true);
    
    final authService = AuthService(); 
    String? currentUserRole = authService.getUserRole();

    try {
      List<app_class.Class> allClassesInSchool = await _classService.getClassesBySchool(widget.schoolId);
      
      if (currentUserRole == 'Admin') {
        _availableClasses = allClassesInSchool;
      } else { 
        _availableClasses = allClassesInSchool.where((c) => c.teacherId == widget.teacherId).toList();
      }

      if (_availableClasses.isNotEmpty) {
        app_class.Class? initialSelection;
        // widget.lessonPlan.classId is int, widget.initialClassId is int?
        // Class.id is int?
        int? targetClassId = _isEditing ? widget.lessonPlan?.classId : widget.initialClassId; 

        if (targetClassId != null) {
          initialSelection = _availableClasses.firstWhere((c) => c.id == targetClassId, orElse: () => _availableClasses.first);
        } else if (!_isEditing) { 
          initialSelection = _availableClasses.length == 1 ? _availableClasses.first : null;
        } else { 
            initialSelection = _availableClasses.first;
        }
        
        if (_selectedClass != initialSelection) { // Check if it actually changed
             setState(() {
                _selectedClass = initialSelection;
                _selectedSubjectName = null; 
                _availableSubjects = []; 
             });
        }

        if (_selectedClass != null) {
            await _loadSubjectsForClass(); 
            if (_isEditing && widget.lessonPlan?.subjectName != null && _availableSubjects.contains(widget.lessonPlan!.subjectName)) {
              setState(() {
                _selectedSubjectName = widget.lessonPlan!.subjectName;
              });
            }
        } else {
           if(mounted) {
            setState(() { 
              _availableSubjects = [];
              _selectedSubjectName = null;
            });
          }
        }
      } else {
         if(mounted) {
            setState(() { 
              _selectedClass = null;
              _availableSubjects = [];
              _selectedSubjectName = null;
            });
          }
      }
    } catch (e) {
      if(mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() => _errorMessage = l10n.failedToLoadInitialData);
      }
    }
    if(mounted) setState(() => _isLoadingInitialData = false);
  }
  
  Future<void> _loadSubjectsForClass() async {
    if (_selectedClass == null || _selectedClass!.id == null) { // Class.id is int?
      if(mounted) {
        setState(() {
          _availableSubjects = [];
          _selectedSubjectName = null; 
        });
      }
      return;
    }
    if(mounted) setState(() => _isLoading = true); 
    try {
      // _selectedClass.id is int?, getTimetableForClass expects int
      final timetableEntries = await _timetableService.getTimetableForClass(_selectedClass!.id!); 
      final subjects = timetableEntries.map((e) => e.subjectName).toSet().toList();
      if(mounted) {
        setState(() {
          _availableSubjects = subjects;
          if (_selectedSubjectName != null && !_availableSubjects.contains(_selectedSubjectName)) {
            _selectedSubjectName = null;
          }
        });
      }
    } catch (e) {
       if(mounted) {
         final l10n = AppLocalizations.of(context);
         setState(() => _errorMessage = l10n.failedToLoadSubjects);
       }
    }
    if(mounted) setState(() => _isLoading = false);
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 1), 
      lastDate: DateTime(DateTime.now().year + 1), 
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
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveLessonPlan() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClass == null || _selectedClass!.id == null || _selectedSubjectName == null || _selectedDate == null) {
      setState(() => _errorMessage = l10n.fillAllRequiredFields); 
      return;
    }
    _formKey.currentState!.save();
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final lessonPlanData = LessonPlan(
        id: _isEditing ? widget.lessonPlan!.id : 0, // LessonPlan.id is int?
        classId: _selectedClass!.id!, // _selectedClass.id is int?
        teacherId: widget.teacherId, 
        title: _titleController.text,
        subjectName: _selectedSubjectName!, 
        description: _descriptionController.text, 
        date: _selectedDate!,
      );

      bool success;
      if (_isEditing) {
        success = await _lessonPlanService.updateLessonPlan(lessonPlanData);
      } else {
        final newPlan = await _lessonPlanService.createLessonPlan(lessonPlanData);
        success = newPlan != null;
      }

      if (success) {
        if(mounted) Navigator.of(context).pop(true); 
      } else {
        throw Exception(l10n.failedToSaveLessonPlanError); 
      }
    } catch (e) {
      if(mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = '${l10n.errorOccurredPrefix}: ${e.toString()}';
        });
      }
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    final String appBarTitle = _isEditing 
        ? l10n.editLessonPlanTitle 
        : l10n.addLessonPlanTitle;  

    return Scaffold( // Scaffold uses appBackgroundColor from theme
      appBar: AppBar( // AppBar uses appBarTheme from theme
        title: Text(appBarTitle),
      ),
      body: _isLoadingInitialData
        ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: l10n.titleLabel), // Uses global inputDecorationTheme
                    validator: (value) => (value == null || value.isEmpty) ? l10n.titleValidator : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<app_class.Class>(
                    value: _selectedClass,
                    hint: Text(l10n.selectClassHint),
                    items: _availableClasses.map((app_class.Class cls) {
                      return DropdownMenuItem<app_class.Class>(
                        value: cls,
                        child: Text(cls.name),
                      );
                    }).toList(),
                    onChanged: (app_class.Class? newValue) {
                      setState(() {
                        _selectedClass = newValue;
                        _selectedSubjectName = null; 
                        _availableSubjects = [];
                      });
                      if (newValue != null) {
                        _loadSubjectsForClass();
                      }
                    },
                    validator: (value) => value == null ? l10n.pleaseSelectClass : null,
                    decoration: InputDecoration(labelText: l10n.classLabel), // Uses global inputDecorationTheme
                  ),
                  const SizedBox(height: 16),
                   _availableSubjects.isNotEmpty
                    ? DropdownButtonFormField<String>(
                        value: _selectedSubjectName,
                        hint: Text(l10n.selectSubjectHint), 
                        items: _availableSubjects.map((String subject) {
                          return DropdownMenuItem<String>(
                            value: subject,
                            child: Text(subject),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedSubjectName = newValue;
                          });
                        },
                        validator: (value) => value == null ? l10n.subjectValidator : null, 
                        decoration: InputDecoration(labelText: l10n.subjectLabel), // Uses global inputDecorationTheme
                      )
                    : Column( // Fallback display if no subjects
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.subjectLabel, style: theme.textTheme.labelLarge?.copyWith(color: theme.inputDecorationTheme.labelStyle?.color)), 
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            decoration: BoxDecoration(
                              color: theme.inputDecorationTheme.fillColor ?? cardBackgroundColor, // Use imported constant as fallback
                              borderRadius: BorderRadius.circular(12.0), // Use a fixed fallback or ensure theme provides it consistently
                            ),
                            child: Text(
                              _selectedClass == null 
                                  ? l10n.pleaseSelectClassFirstForSubjects 
                                  : l10n.noSubjectsFoundForClass, 
                              style: theme.textTheme.bodyLarge?.copyWith(color: theme.inputDecorationTheme.hintStyle?.color),
                            ),
                          )
                        ],
                      ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      labelText: l10n.recordDateLabel, 
                      hintText: l10n.dateOfBirthHint, 
                    ), 
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    validator: (value) => (value == null || value.isEmpty) ? l10n.dateValidator : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController, 
                    decoration: InputDecoration(labelText: l10n.descriptionLabel), 
                    maxLines: 5,
                    validator: (value) => (value == null || value.isEmpty) ? l10n.descriptionValidator : null, 
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                      : ElevatedButton.icon( // Changed to ElevatedButton for consistency with theme
                          icon: Icon(_isEditing ? Icons.save_as_outlined : Icons.add_circle_outline),
                          onPressed: _saveLessonPlan,
                          label: Text(_isEditing ? l10n.updateButton : l10n.addButton),
                          style: ElevatedButton.styleFrom( // Use ElevatedButton.styleFrom
                            backgroundColor: contextualAccentColor, 
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            textStyle: theme.elevatedButtonTheme.style?.textStyle?.resolve({}) ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                          ),
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
