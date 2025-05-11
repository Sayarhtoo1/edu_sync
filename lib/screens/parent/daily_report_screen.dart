import 'dart:convert'; // Added for jsonEncode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/models/custom_form.dart';
import 'package:edu_sync/models/form_field_item.dart';
import 'package:edu_sync/models/form_response.dart';
import 'package:edu_sync/models/form_response_answer.dart';
import 'package:edu_sync/models/form_field_type.dart'; // Ensure this is imported

import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/custom_form_service.dart';
import 'package:edu_sync/services/form_response_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart'; 
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  final StudentService _studentService = StudentService();
  final CustomFormService _customFormService = CustomFormService();
  final FormResponseService _formResponseService = FormResponseService();
  final AuthService _authService = AuthService();
  final Uuid _uuid = const Uuid();

  List<Student> _linkedStudents = [];
  Student? _selectedStudent;
  List<CustomForm> _activeForms = [];
  CustomForm? _selectedForm;
  List<FormFieldItem> _formFields = [];
  Map<String, dynamic> _answers = {}; // fieldId -> answer
  final Map<String, bool> _submittedForms = {}; // formId_date -> true if submitted

  bool _isLoadingStudents = true;
  bool _isLoadingForms = false;
  bool _isLoadingFields = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  int? _schoolId;
  String? _parentId;

  final GlobalKey<FormState> _reportFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    _schoolId = schoolProvider.currentSchool?.id;
    _parentId = _authService.getCurrentUser()?.id;

    if (_parentId != null && _schoolId != null) {
      _loadLinkedStudents();
    } else {
      // If parentId or schoolId is null, we can't load students.
      // Set loading to false and show an error.
      // Ensure this runs after the first frame to use context for AppLocalizations.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
           final l10n = AppLocalizations.of(context);
          setState(() {
            _isLoadingStudents = false;
            _errorMessage = _parentId == null ? l10n.error_user_not_found : l10n.error_school_not_selected_or_found;
          });
        }
      });
      // If not using WidgetsBinding, set _isLoadingStudents to false directly,
      // but then AppLocalizations.of(context) might not be available yet.
      // For safety, if we can't get l10n, use a generic error.
      if (!mounted) { // Should not happen in initState but as a fallback
         _isLoadingStudents = false;
         _errorMessage = "User or school data not available.";
      }
    }
  }

  Future<void> _loadLinkedStudents() async {
    if (_parentId == null || _schoolId == null) return;
    setState(() => _isLoadingStudents = true);
    try {
      _linkedStudents = await _studentService.getStudentsByParent(_parentId!, _schoolId!);
      if (_linkedStudents.isNotEmpty) {
        _selectedStudent = _linkedStudents.first;
        // _loadActiveFormsForStudent will set _isLoadingForms and then _isLoadingStudents will be false.
        await _loadActiveFormsForStudent(); 
      }
      // If _linkedStudents is empty, _loadActiveFormsForStudent won't be called.
      // Ensure _isLoadingStudents is set to false in all paths.
      if (mounted) {
        setState(() {
          _isLoadingStudents = false; 
          if (_linkedStudents.isEmpty && _errorMessage == null) { // Only set this if no other error occurred
            _errorMessage = AppLocalizations.of(context).noChildrenLinked;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false; // Ensure this is false on error too
          _errorMessage = "${AppLocalizations.of(context).errorOccurredPrefix}: ${e.toString()}";
        });
      }
    }
  }

  Future<void> _loadActiveFormsForStudent() async {
    if (_selectedStudent == null || _parentId == null) {
      if (mounted) setState(() => _isLoadingForms = false); // Ensure loading state is cleared
      return;
    }
    setState(() {
      _isLoadingForms = true;
      _activeForms = [];
      _selectedForm = null;
      _formFields = [];
      _answers = {};
      _errorMessage = null;
    });
    try {
      // Get forms active today for the selected student
      List<int> studentClassIds = [];
      if (_selectedStudent?.classId != null) {
        studentClassIds.add(_selectedStudent!.classId!);
      }
      _activeForms = await _customFormService.getActiveFormsForStudent(
        _selectedStudent!.id, 
        studentClassIds, 
        _schoolId!, 
        DateTime.now()
      );
      
      // Check submission status for each active form
      for (var form in _activeForms) {
        String submissionKey = "${form.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
         bool submitted = await _formResponseService.checkIfResponseSubmitted(form.id, _selectedStudent!.id, _parentId!, DateTime.now());
        _submittedForms[submissionKey] = submitted;
      }

      if (_activeForms.isNotEmpty) {
        // Auto-select the first form that is not yet submitted
        _selectedForm = _activeForms.firstWhereOrNull(
          (form) => !(_submittedForms["${form.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}"] ?? false),
        );
        // If no unsubmitted form is found, _selectedForm will be null. 
        // If you want to default to the first form regardless of submission status if all are submitted:
        _selectedForm ??= _activeForms.first;

        if (_selectedForm != null) {
          await _loadFieldsForForm();
        } else {
           if (mounted) setState(() => _isLoadingFields = false); // No form selected, stop loading fields
        }
      } else {
        // No active forms found
        if (mounted) setState(() => _isLoadingFields = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "${AppLocalizations.of(context).errorFetchingForms}: ${e.toString()}");
      }
    }
    // Ensure _isLoadingForms is set to false in all paths of this function
    if (mounted) setState(() => _isLoadingForms = false);
  }

  Future<void> _loadFieldsForForm() async {
    if (_selectedForm == null) {
      if (mounted) setState(() => _isLoadingFields = false); // Ensure loading state is cleared
      return;
    }
    setState(() {
      _isLoadingFields = true;
      _formFields = [];
      _answers = {}; // Reset answers when form changes
    });
    try {
      _formFields = await _customFormService.getFormFields(_selectedForm!.id);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "${AppLocalizations.of(context).errorFetchingFormDetails}: ${e.toString()}");
      }
    }
    if (mounted) setState(() => _isLoadingFields = false);
  }
  
  void _handleAnswerChange(String fieldId, dynamic value) {
    setState(() {
      _answers[fieldId] = value;
    });
  }

  Future<void> _submitReport() async {
    if (!_reportFormKey.currentState!.validate()) return;
    if (_selectedForm == null || _selectedStudent == null || _parentId == null) return;

    _reportFormKey.currentState!.save(); // Important to trigger onSaved for FormFields

    setState(() => _isSubmitting = true);

    final responseId = _uuid.v4();
    final formResponse = FormResponse(
      id: responseId,
      formId: _selectedForm!.id,
      studentId: _selectedStudent!.id,
      parentId: _parentId!,
      submittedAt: DateTime.now(),
      // schoolId is not a parameter in FormResponse constructor
    );

    List<FormResponseAnswer> responseAnswers = [];
    _answers.forEach((fieldId, answer) {
      // Find the field to determine its type for correct answer formatting if needed
      final field = _formFields.firstWhere((f) => f.id == fieldId);
      String answerValue;

      if (answer is bool) {
        answerValue = answer.toString();
      } else if (answer is Map<String, bool>) { // For checkboxes
        List<String> selectedOptions = [];
        answer.forEach((option, isSelected) {
          if (isSelected) {
            selectedOptions.add(option);
          }
        });
        answerValue = jsonEncode(selectedOptions);
      } else if (answer is String) {
        answerValue = answer;
      } else if (answer == null && field.type == FormFieldType.checkbox) {
         answerValue = jsonEncode([]); // Empty list for unselected checkboxes
      }
      else {
        answerValue = answer?.toString() ?? '';
      }

      responseAnswers.add(FormResponseAnswer(
        id: _uuid.v4(),
        responseId: responseId,
        fieldId: fieldId,
        answerJson: answerValue, // Corrected to answerJson
      ));
    });

    try {
      final success = await _formResponseService.submitResponse(formResponse, responseAnswers);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).reportSubmittedSuccessfully)),
          );
          // Update submission status and potentially reload forms or fields
          String submissionKey = "${_selectedForm!.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
          setState(() {
            _submittedForms[submissionKey] = true;
            _selectedForm = _activeForms.firstWhereOrNull(
              (form) => !(_submittedForms["${form.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}"] ?? false),
            );
            // If _selectedForm is null here, it means all forms are submitted or no forms left.
            if (_selectedForm != null) {
              _loadFieldsForForm();
            } else {
              _formFields = []; // Clear fields if no form is selected
            }
          });
        }
      } else {
        if (mounted) {
          setState(() => _errorMessage = AppLocalizations.of(context).failedToSubmitReport);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "${AppLocalizations.of(context).errorSubmittingReport}: ${e.toString()}");
      }
    }
    if (mounted) setState(() => _isSubmitting = false);
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context); // Get theme context
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyReportsTitle ?? 'Daily Reports')), // Theme applied globally
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');

    if (_isLoadingStudents) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)));
    }
    if (_errorMessage != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error))));
    }
    if (_linkedStudents.isEmpty) {
      return Center(child: Text(l10n.noChildrenLinked, style: theme.textTheme.bodyLarge));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Child Selector
          if (_linkedStudents.length > 1) ...[
            DropdownButtonFormField<Student>(
              value: _selectedStudent,
              hint: Text(l10n.selectChildHint, style: theme.textTheme.bodyLarge),
              items: _linkedStudents.map((Student student) {
                return DropdownMenuItem<Student>(
                  value: student,
                  child: Text(student.fullName, style: theme.textTheme.bodyLarge),
                );
              }).toList(),
              onChanged: (Student? newValue) {
                if (newValue != null && newValue != _selectedStudent) {
                  setState(() {
                    _selectedStudent = newValue;
                  });
                  _loadActiveFormsForStudent();
                }
              },
              decoration: InputDecoration(labelText: l10n.childLabel), // InputDecorationTheme applied globally
            ),
            const SizedBox(height: 16),
          ],
          // Form Selector (if multiple active forms)
          if (_isLoadingForms)
            Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          else if (_activeForms.isNotEmpty && _activeForms.length > 1) ...[
            Text(l10n.selectReportForm, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<CustomForm>(
              value: _selectedForm,
              hint: Text(l10n.selectFormHint, style: theme.textTheme.bodyLarge),
              items: _activeForms.map((CustomForm form) {
                String submissionKey = "${form.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
                bool isSubmitted = _submittedForms[submissionKey] ?? false;
                return DropdownMenuItem<CustomForm>(
                  value: form,
                  enabled: !isSubmitted,
                  child: Text("${form.title}${isSubmitted ? ' (${l10n.submitted})' : ''}", style: theme.textTheme.bodyLarge),
                );
              }).toList(),
              onChanged: (CustomForm? newValue) {
                if (newValue != null && newValue != _selectedForm) {
                  setState(() {
                    _selectedForm = newValue;
                  });
                  _loadFieldsForForm();
                }
              },
              decoration: InputDecoration(labelText: l10n.formLabel), // InputDecorationTheme applied globally
            ),
            const SizedBox(height: 16),
          ] else if (_activeForms.length == 1 && _selectedForm != null) ... [
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0),
               child: Text("${l10n.formLabel}: ${_selectedForm!.title}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
             ),
          ],
          
          // Form Fields
          if (_isLoadingFields)
            Expanded(child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor))))
          else if (_selectedForm == null)
            Expanded(child: Center(child: Text(_activeForms.isEmpty ? (l10n.noActiveFormsForToday ?? "No active forms for today.") : (l10n.pleaseSelectForm ?? "Please select a form."), style: theme.textTheme.bodyLarge)))
          else if (_formFields.isEmpty && _selectedForm != null)
             Expanded(child: Center(child: Text(l10n.formHasNoQuestions ?? "This form has no questions.", style: theme.textTheme.bodyLarge)))
          else
            _buildFormFields(l10n),
        ],
      ),
    );
  }

  Widget _buildFormFields(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');
    String submissionKey = "${_selectedForm!.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
    bool isSubmitted = _submittedForms[submissionKey] ?? false;

    if (isSubmitted) {
      return Expanded(child: Center(child: Text(l10n.reportAlreadySubmitted ?? "Report already submitted for today.", style: theme.textTheme.bodyLarge)));
    }

    return Expanded(
      child: Form(
        key: _reportFormKey,
        child: ListView.builder(
          itemCount: _formFields.length + 1, // +1 for submit button
          itemBuilder: (context, index) {
            if (index == _formFields.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: _isSubmitting
                    ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: contextualAccentColor, 
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16)
                        ),
                        onPressed: _submitReport,
                        child: Text(l10n.submitReportButton ?? "Submit Report"),
                      ),
              );
            }
            final field = _formFields[index];
            return _buildFormFieldWidget(field, l10n);
          },
        ),
      ),
    );
  }

  Widget _buildFormFieldWidget(FormFieldItem field, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');

    if (field.type == FormFieldType.checkbox && _answers[field.id] == null) {
      _answers[field.id] = <String, bool>{}; 
       for (var option in (field.options)) { 
        (_answers[field.id] as Map<String, bool>)[option] = false;
      }
    }

    Widget fieldWidget;
    switch (field.type) {
      case FormFieldType.text:
        fieldWidget = TextFormField(
          initialValue: _answers[field.id] as String?,
          decoration: InputDecoration(labelText: field.question + (field.required ? " *" : "")), // InputDecorationTheme applied globally
          maxLines: field.question.toLowerCase().contains("description") || field.question.length > 50 ? 3 : 1,
          validator: field.required ? (value) => (value == null || value.isEmpty) ? (l10n.fieldRequiredValidation) : null : null,
          onSaved: (value) => _handleAnswerChange(field.id, value),
        );
        break;
      case FormFieldType.yesNo:
        fieldWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.question + (field.required ? " *" : ""), style: theme.textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(l10n.yes, style: theme.textTheme.bodyLarge),
                    value: true,
                    groupValue: _answers[field.id] as bool?,
                    onChanged: (value) => _handleAnswerChange(field.id, value),
                    activeColor: contextualAccentColor,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(l10n.no, style: theme.textTheme.bodyLarge),
                    value: false,
                    groupValue: _answers[field.id] as bool?,
                    onChanged: (value) => _handleAnswerChange(field.id, value),
                    activeColor: contextualAccentColor,
                  ),
                ),
              ],
            ),
             if (field.required && _answers[field.id] == null) 
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(l10n.fieldRequiredValidation, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
              ),
          ],
        );
        break;
      case FormFieldType.multipleChoice:
        fieldWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.question + (field.required ? " *" : ""), style: theme.textTheme.titleMedium),
            ...field.options.map((option) => RadioListTile<String>(
                  title: Text(option, style: theme.textTheme.bodyLarge),
                  value: option,
                  groupValue: _answers[field.id] as String?,
                  onChanged: (value) => _handleAnswerChange(field.id, value),
                  activeColor: contextualAccentColor,
                )),
             if (field.required && _answers[field.id] == null)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(l10n.fieldRequiredValidation, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
              ),
          ],
        );
        break;
      case FormFieldType.checkbox:
        Map<String, bool> currentSelections = (_answers[field.id] is Map<String, bool>)
            ? _answers[field.id] as Map<String, bool>
            : <String, bool>{};
         for (var option in field.options) {
          currentSelections.putIfAbsent(option, () => false);
        }

        fieldWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(field.question + (field.required ? " *" : ""), style: theme.textTheme.titleMedium),
            ...field.options.map((option) => CheckboxListTile(
                  title: Text(option, style: theme.textTheme.bodyLarge),
                  value: currentSelections[option] ?? false,
                  onChanged: (bool? newValue) {
                    setState(() {
                       currentSelections[option] = newValue ?? false;
                      _handleAnswerChange(field.id, Map<String, bool>.from(currentSelections)); 
                    });
                  },
                  activeColor: contextualAccentColor,
                  controlAffinity: ListTileControlAffinity.leading,
                )),
            if (field.required && !(currentSelections.values.any((isSelected) => isSelected)))
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(l10n.fieldRequiredValidation, style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
              ),
          ],
        );
        break;
      case FormFieldType.number:
        fieldWidget = TextFormField(
          initialValue: _answers[field.id]?.toString(),
          decoration: InputDecoration(labelText: field.question + (field.required ? " *" : "")), // InputDecorationTheme applied globally
          keyboardType: TextInputType.number,
          validator: field.required ? (value) {
            if (value == null || value.isEmpty) return l10n.fieldRequiredValidation;
            if (int.tryParse(value) == null) return l10n.pleaseEnterValidNumber;
            return null;
          } : null,
          onSaved: (value) => _handleAnswerChange(field.id, value != null && value.isNotEmpty ? int.tryParse(value) : null),
        );
        break;
      default:
        fieldWidget = Text("Unsupported field type: ${field.type}", style: theme.textTheme.bodyMedium);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: fieldWidget,
    );
  }
}
