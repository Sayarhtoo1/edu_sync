import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // For generating UUIDs for new forms/fields
import 'package:edu_sync/models/custom_form.dart';
import 'package:edu_sync/models/form_field_item.dart';
import 'package:edu_sync/models/form_field_type.dart';
import 'package:edu_sync/services/custom_form_service.dart';
import 'package:edu_sync/services/class_service.dart'; // For fetching classes
// For fetching students
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
import 'package:collection/collection.dart'; // Import collection package
// Import provider
// Import AppDatabase

class AddEditCustomFormScreen extends StatefulWidget {
  final int schoolId;
  final String userId; // User creating/editing the form
  final CustomForm? form; // Existing form if editing, null if adding

  const AddEditCustomFormScreen({
    super.key,
    required this.schoolId,
    required this.userId,
    this.form,
  });

  @override
  State<AddEditCustomFormScreen> createState() => _AddEditCustomFormScreenState();
}

class _AddEditCustomFormScreenState extends State<AddEditCustomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CustomFormService _customFormService = CustomFormService();
  late final ClassService _classService;
  final Uuid _uuid = const Uuid();

  late TextEditingController _titleController;
  late TextEditingController _activeFromController;
  late TextEditingController _activeToController;

  DateTime? _activeFromDate;
  DateTime? _activeToDate;
  bool _isDaily = true;
  bool _assignToWholeSchool = false;

  List<FormFieldItem> _fields = [];
  List<app_class.SchoolClass> _availableClasses = [];
  
  List<int> _selectedClassIds = []; 
  List<int> _selectedStudentIds = []; 

  // For tracking changes to fields when editing
  List<FormFieldItem> _originalFields = []; 
  final List<String> _deletedFieldIds = [];


  bool _isLoading = false;
  String? _errorMessage;
  bool get _isEditing => widget.form != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.form?.title ?? '');
    _activeFromDate = widget.form?.activeFrom ?? DateTime.now();
    _activeToDate = widget.form?.activeTo ?? DateTime.now().add(const Duration(days: 7));
    _activeFromController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_activeFromDate!));
    _activeToController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_activeToDate!));
    _isDaily = widget.form?.isDaily ?? true;
    _assignToWholeSchool = widget.form?.assignToWholeSchool ?? false;

    if (_isEditing && widget.form != null) {
      _selectedClassIds = List<int>.from(widget.form!.assignedClassIds); // CustomForm.assignedClassIds is List<int>
      _selectedStudentIds = List<int>.from(widget.form!.assignedStudentIds);
      _loadFieldsForEditing();
    }
    _classService = ClassService();
    _loadAssignableEntities();
  }

  Future<void> _loadFieldsForEditing() async {
    if (widget.form?.id == null) return;
    setState(() => _isLoading = true);
    try {
      final loadedFields = await _customFormService.getFormFields(widget.form!.id);
      setState(() {
        _fields = List<FormFieldItem>.from(loadedFields); // Make a mutable copy
        _originalFields = List<FormFieldItem>.from(loadedFields); // Store original for diffing
      });
    } catch (e) {
      if(mounted) setState(() => _errorMessage = "Error loading form fields: ${e.toString()}");
    }
    if(mounted) setState(() => _isLoading = false);
  }
  
  Future<void> _loadAssignableEntities() async {
    // In a real app, consider pagination or searching for large lists
    try {
      _availableClasses = await _classService.getClasses(widget.schoolId);
      // _availableStudents = await _studentService.getStudentsBySchool(widget.schoolId);
    } catch (e) {
       if(mounted) setState(() => _errorMessage = "Error loading classes/students: ${e.toString()}");
    }
    if(mounted) setState((){});
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
    final theme = Theme.of(context); 
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isFromDate ? (_activeFromDate ?? DateTime.now()) : (_activeToDate ?? DateTime.now()),
      firstDate: DateTime(DateTime.now().year - 5), 
      lastDate: DateTime(DateTime.now().year + 5),
      builder: (context, child) { // Theme the DatePicker
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: contextualAccentColor, 
              onPrimary: Colors.white, 
              onSurface: textDarkGrey, 
            ),
            dialogTheme: DialogThemeData(backgroundColor: cardBackgroundColor),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: contextualAccentColor, 
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isFromDate) {
          _activeFromDate = picked;
          _activeFromController.text = DateFormat('yyyy-MM-dd').format(picked);
        } else {
          _activeToDate = picked;
          _activeToController.text = DateFormat('yyyy-MM-dd').format(picked);
        }
      });
    }
  }

  // TODO: UI methods for adding/editing/removing fields
  // TODO: UI methods for selecting classes/students

  Future<void> _saveForm() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    if (_activeFromDate == null || _activeToDate == null) {
      if (mounted) setState(() => _errorMessage = l10n?.pleaseSelectActiveDatesError ?? 'Please select active dates.');
      return;
    }
    if (_activeToDate!.isBefore(_activeFromDate!)) {
      if (mounted) setState(() => _errorMessage = l10n?.activeToDateError ?? 'Active to date cannot be before active from date.');
      return;
    }
    if (_fields.isEmpty) {
       if (mounted) setState(() => _errorMessage = l10n?.addAtLeastOneQuestionError ?? 'Please add at least one question.');
      return;
    }

    _formKey.currentState!.save();
    setState(() { _isLoading = true; _errorMessage = null; });

    final formId = _isEditing ? widget.form!.id : _uuid.v4();

    final String? assignedClassesJson = CustomForm.sToJsonListInt(_selectedClassIds); // Use sToJsonListInt
    final String? assignedStudentsJson = CustomForm.sToJsonListInt(_selectedStudentIds); 

    final customFormData = CustomForm(
      id: formId,
      schoolId: widget.schoolId,
      title: _titleController.text,
      createdBy: widget.userId, // Changed from createdByUserId
      assignedClassIdsJson: assignedClassesJson,
      assignedStudentIdsJson: assignedStudentsJson,
      assignToWholeSchool: _assignToWholeSchool,
      activeFrom: _activeFromDate!,
      activeTo: _activeToDate!,
      isDaily: _isDaily,
      createdAt: _isEditing ? widget.form!.createdAt : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // For simplicity, new fields are assigned new UUIDs here.
    // In a real scenario, if fields are edited, their existing IDs should be preserved.
    final List<FormFieldItem> fieldsToSave = _fields.map((f) {
      return FormFieldItem(
        id: f.id.isEmpty ? _uuid.v4() : f.id, // Assign new ID if it's a new field
        formId: formId, // Will be linked to the parent form
        question: f.question,
        type: f.type,
        optionsJson: f.optionsJson,
        required: f.required,
      );
    }).toList();


    try {
      bool success;
      if (_isEditing) {
        // Diffing logic for fields:
        List<FormFieldItem> newFields = [];
        List<FormFieldItem> updatedFields = [];
        // _deletedFieldIds is already a state variable, populated by UI actions

        for (var field in fieldsToSave) {
          // Check if field.id exists in _originalFields
          final originalField = _originalFields.firstWhereOrNull((of) => of.id == field.id);
          if (originalField == null) {
            // This field's ID is not in originalFields, so it's new
            // (This assumes new fields in _fields list have client-generated UUIDs already)
             newFields.add(field);
          } else {
            // Field existed, check if it changed (simplistic check, could be more granular)
            if (field.question != originalField.question || 
                field.type != originalField.type ||
                field.optionsJson != originalField.optionsJson ||
                field.required != originalField.required) {
              updatedFields.add(field);
            }
          }
        }
        // _deletedFieldIds should be populated when user deletes a field in the UI

        success = await _customFormService.updateCustomForm(
          customFormData, 
          newFields, 
          _deletedFieldIds, 
          updatedFields
        );

      } else {
        final createdForm = await _customFormService.createCustomForm(customFormData, fieldsToSave);
        success = createdForm != null;
      }

      if (success) {
        if(mounted) Navigator.of(context).pop(true); 
      } else {
        if(mounted) setState(() => _errorMessage = l10n?.failedToSaveFormError ?? 'Failed to save form.');
      }
    } catch (e) {
      if(mounted) setState(() => _errorMessage = "${l10n?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}");
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }
  
  String formFieldTypeToString(FormFieldType type, AppLocalizations? l10n) {
    switch (type) {
      case FormFieldType.text:
        return l10n?.fieldType_text ?? 'Text';
      case FormFieldType.yesNo:
        return l10n?.fieldType_yesNo ?? 'Yes/No';
      case FormFieldType.multipleChoice:
        return l10n?.fieldType_multipleChoice ?? 'Multiple Choice';
      case FormFieldType.checkbox:
        return l10n?.fieldType_checkbox ?? 'Checkbox';
      case FormFieldType.number:
        return l10n?.fieldType_number ?? 'Number';
    }
    // The default clause is removed as all enum cases are covered.
  }

  // Placeholder for field editor dialog/widget
  void _showFormFieldDialog({FormFieldItem? fieldToEdit, int? fieldIndex}) {
    final l10n = AppLocalizations.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');
    final dialogFormKey = GlobalKey<FormState>();
    String question = fieldToEdit?.question ?? '';
    FormFieldType type = fieldToEdit?.type ?? FormFieldType.text;
    String optionsStr = fieldToEdit?.options.join('\n') ?? ''; // For text input of options
    bool required = fieldToEdit?.required ?? false;
    bool isEditingField = fieldToEdit != null;

    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        // Use StatefulBuilder to manage dialog's own state for type changes
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dialogTheme = Theme.of(context); // Get theme for dialog elements
            return AlertDialog(
              title: Text(isEditingField ? l10n?.editQuestionTitle ?? 'Edit Question' : l10n?.addQuestionTitle ?? 'Add Question'),
              content: SingleChildScrollView(
                child: Form(
                  key: dialogFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        initialValue: question,
                        decoration: InputDecoration(labelText: l10n?.questionTextLabel ?? 'Question Text'),
                        validator: (value) => (value == null || value.isEmpty) ? l10n?.questionTextValidator ?? 'Question text cannot be empty.' : null,
                        onSaved: (value) => question = value!,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<FormFieldType>(
                        value: type,
                        decoration: InputDecoration(labelText: l10n?.questionTypeLabel ?? 'Question Type'),
                        items: FormFieldType.values.map((FormFieldType value) {
                          return DropdownMenuItem<FormFieldType>(
                            value: value,
                            child: Text(formFieldTypeToString(value, l10n)),
                          );
                        }).toList(),
                        onChanged: (FormFieldType? newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              type = newValue;
                            });
                          }
                        },
                      ),
                      if (type == FormFieldType.multipleChoice || type == FormFieldType.checkbox)
                        TextFormField(
                          initialValue: optionsStr,
                          decoration: InputDecoration(labelText: l10n?.optionsLabel ?? 'Options (one per line)'),
                          maxLines: 3,
                          onSaved: (value) => optionsStr = value ?? '',
                           validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n?.optionsRequiredError ?? 'Options are required for this question type.';
                            }
                            if (value.trim().split('\n').where((s) => s.trim().isNotEmpty).length < 2) {
                               return l10n?.atLeastTwoOptionsError ?? 'Please provide at least two options.';
                            }
                            return null;
                          }
                        ),
                      SwitchListTile(
                        title: Text(l10n?.requiredLabel ?? 'Required', style: dialogTheme.textTheme.bodyLarge),
                        value: required,
                        onChanged: (bool value) {
                          setDialogState(() {
                            required = value;
                          });
                        },
                         activeColor: contextualAccentColor,
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(l10n?.cancel ?? 'Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(isEditingField ? l10n?.updateButton ?? 'Update' : l10n?.addButton ?? 'Add'), // Uses existing l10n keys
                  onPressed: () {
                    if (dialogFormKey.currentState!.validate()) {
                      dialogFormKey.currentState!.save();
                      List<String> optionsList = [];
                      if (type == FormFieldType.multipleChoice || type == FormFieldType.checkbox) {
                        optionsList = optionsStr.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
                      }

                      final newOrEditedField = FormFieldItem(
                        id: isEditingField ? fieldToEdit.id : "temp_${_uuid.v4()}", 
                        formId: isEditingField ? fieldToEdit.formId : widget.form?.id ?? "temp_form", 
                        question: question,
                        type: type,
                        optionsJson: optionsList.isNotEmpty ? CustomForm.sToJsonListString(optionsList) : null, // This is for FormFieldItem options, which are List<String>
                        required: required,
                      );

                      setState(() {
                        if (isEditingField && fieldIndex != null) {
                          _fields[fieldIndex] = newOrEditedField;
                        } else {
                          _fields.add(newOrEditedField);
                        }
                      });
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          }
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n?.editReportFormTitle ?? 'Edit Report Form' : l10n?.createReportFormTitle ?? 'Create Report Form'),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: contextualAccentColor),
            tooltip: l10n?.saveButton ?? 'Save',
            onPressed: _isLoading ? null : _saveForm
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n?.formDetailsTitle ?? 'Form Details', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: l10n?.titleLabel ?? 'Title'),
                      validator: (value) => (value == null || value.isEmpty) ? l10n?.titleValidator ?? 'Title cannot be empty.' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _activeFromController,
                            decoration: InputDecoration(labelText: l10n?.activeFrom ?? 'Active From'),
                            readOnly: true,
                            onTap: () => _selectDate(context, true),
                            validator: (value) => (value == null || value.isEmpty) ? l10n?.dateValidator ?? 'Date cannot be empty.' : null,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _activeToController,
                            decoration: InputDecoration(labelText: l10n?.activeTo ?? 'Active To'),
                            readOnly: true,
                            onTap: () => _selectDate(context, false),
                            validator: (value) => (value == null || value.isEmpty) ? l10n?.dateValidator ?? 'Date cannot be empty.' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: Text(l10n?.dailyReportLabel ?? 'Daily Report', style: theme.textTheme.bodyLarge),
                      value: _isDaily,
                      onChanged: (bool value) => setState(() => _isDaily = value),
                      activeColor: contextualAccentColor,
                    ),
                    const SizedBox(height: 16),
                    Text(l10n?.assignToLabel ?? 'Assign To', style: theme.textTheme.titleMedium),
                    SwitchListTile(
                      title: Text(l10n?.assignToWholeSchoolLabel ?? 'Assign to Whole School', style: theme.textTheme.bodyLarge),
                      value: _assignToWholeSchool,
                      onChanged: (bool value) {
                        setState(() {
                          _assignToWholeSchool = value;
                          if (value) {
                            _selectedClassIds.clear();
                            _selectedStudentIds.clear();
                          }
                        });
                      },
                       activeColor: contextualAccentColor,
                    ),
                    if (!_assignToWholeSchool) ...[
                      const SizedBox(height: 16),
                      Text(l10n?.assignToClassesLabel ?? 'Assign to Classes', style: theme.textTheme.titleMedium),
                      _availableClasses.isEmpty
                          ? Padding(
                               padding: const EdgeInsets.symmetric(vertical: 8.0),
                               child: Text(l10n?.noClassesAvailableText ?? 'No classes available.', style: theme.textTheme.bodyMedium),
                             )
                           : ListView.builder(
                               shrinkWrap: true,
                               physics: const NeverScrollableScrollPhysics(),
                               itemCount: _availableClasses.length,
                               itemBuilder: (context, index) {
                                 final appClass = _availableClasses[index];
                                 return CheckboxListTile(
                                   title: Text(appClass.name, style: theme.textTheme.bodyLarge),
                                   value: _selectedClassIds.contains(appClass.id),
                                   onChanged: (bool? selected) {
                                     setState(() {
                                       if (selected == true) {
                                         if (appClass.id != null) _selectedClassIds.add(appClass.id!);
                                       } else {
                                         _selectedClassIds.remove(appClass.id);
                                       }
                                     });
                                   },
                                   activeColor: contextualAccentColor,
                                 );
                               },
                             ),
                     ],
                     
                     const SizedBox(height: 24),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Text(l10n?.formQuestionsTitle ?? 'Form Questions', style: theme.textTheme.titleLarge),
                         IconButton(
                           icon: Icon(Icons.add_circle, color: contextualAccentColor, size: 28),
                           tooltip: l10n?.addQuestionTooltip ?? 'Add Question',
                           onPressed: () => _showFormFieldDialog(),
                         ),
                       ],
                     ),
                     _fields.isEmpty
                       ? Padding(
                           padding: const EdgeInsets.symmetric(vertical: 16.0),
                           child: Center(child: Text(l10n?.noQuestionsAddedText ?? 'No questions added yet.', style: theme.textTheme.bodyMedium)),
                         )
                       : ListView.builder(
                           shrinkWrap: true,
                           physics: const NeverScrollableScrollPhysics(),
                           itemCount: _fields.length,
                           itemBuilder: (context, index) {
                             final field = _fields[index];
                             return Card(
                               margin: const EdgeInsets.symmetric(vertical: 4.0),
                               child: ListTile(
                                 title: Text(field.question, style: theme.textTheme.titleMedium),
                                 subtitle: Text(
                                   "${l10n?.questionTypeLabel ?? 'Question Type'}: ${formFieldTypeToString(field.type, l10n)}${field.required ? ' (${l10n?.requiredLabel ?? 'Required'})' : ''}",
                                   style: theme.textTheme.bodySmall
                                 ),
                                 trailing: Row(
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     IconButton(
                                       icon: Icon(Icons.edit, size: 20, color: theme.iconTheme.color ?? textDarkGrey),
                                       tooltip: l10n?.editButton ?? 'Edit',
                                       onPressed: () => _showFormFieldDialog(fieldToEdit: field, fieldIndex: index),
                                     ),
                                     IconButton(
                                       icon: Icon(Icons.delete, color: theme.colorScheme.error, size: 20),
                                       tooltip: l10n?.deleteButton ?? 'Delete',
                                       onPressed: () {
                                         setState(() {
                                           if (_isEditing && !_fields[index].id.startsWith("temp_")) { // Check if it's an existing field from DB
                                             _deletedFieldIds.add(_fields[index].id);
                                           }
                                           _fields.removeAt(index);
                                         });
                                       },
                                     ),
                                   ],
                                 ),
                               ),
                             );
                           },
                         ),
                     
                     if (_errorMessage != null)
                       Padding(
                         padding: const EdgeInsets.only(top:16.0),
                         child: Text(_errorMessage!, style: TextStyle(color: theme.colorScheme.error, fontSize: theme.textTheme.bodyMedium?.fontSize)),
                       )
                   ],
                 ),
               ),
             ),
     );
   }
 }
 
 // Helper extension for CustomForm to access fields (if not directly part of the model)
 // This is a placeholder; actual field management will be via _fields list in the state.
 extension CustomFormFields on CustomForm {
   List<FormFieldItem> get fields => []; // This would be populated by service if needed
 }
