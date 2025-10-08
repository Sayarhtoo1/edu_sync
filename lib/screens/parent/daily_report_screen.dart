import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/models/custom_form.dart';
import 'package:edu_sync/models/form_field_item.dart';
import 'package:edu_sync/models/form_response.dart';
import 'package:edu_sync/models/form_response_answer.dart';
import 'package:edu_sync/models/form_field_type.dart';

import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/custom_form_service.dart';
import 'package:edu_sync/services/form_response_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';
import 'package:edu_sync/theme/app_theme.dart';

import 'package:edu_sync/screens/parent/daily_report_screen_components/form_fields_builder.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  late final StudentService _studentService;
  late final CustomFormService _customFormService;
  late final FormResponseService _formResponseService;
  late final AuthService _authService;
  final Uuid _uuid = const Uuid();

  List<Student> _linkedStudents = [];
  Student? _selectedStudent;
  List<CustomForm> _activeForms = [];
  CustomForm? _selectedForm;
  List<FormFieldItem> _formFields = [];
  Map<String, dynamic> _answers = {};
  final Map<String, bool> _submittedForms = {};

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
    _studentService = Provider.of<StudentService>(context, listen: false);
    _customFormService = Provider.of<CustomFormService>(context, listen: false);
    _formResponseService = Provider.of<FormResponseService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    _schoolId = schoolProvider.currentSchool?.id;
    _parentId = _authService.getCurrentUser()?.id;

    if (_parentId != null && _schoolId != null) {
      _loadLinkedStudents();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
           final l10n = AppLocalizations.of(context)!; // Assert non-null
          setState(() {
            _isLoadingStudents = false;
            _errorMessage = _parentId == null ? l10n.error_user_not_found : l10n.error_school_not_selected_or_found;
          });
        }
      });
      // The l10n object is not available here, so use a non-localized fallback.
      if (!mounted) {
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
        await _loadActiveFormsForStudent();
      }
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
          if (_linkedStudents.isEmpty && _errorMessage == null) {
            _errorMessage = AppLocalizations.of(context)!.noChildrenLinked; // Assert non-null
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingStudents = false;
          _errorMessage = "${AppLocalizations.of(context)!.errorOccurredPrefix}: ${e.toString()}"; // Assert non-null
        });
      }
    }
  }

  Future<void> _loadActiveFormsForStudent() async {
    if (_selectedStudent == null || _parentId == null) {
      if (mounted) setState(() => _isLoadingForms = false);
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

      for (var form in _activeForms) {
        String submissionKey = "${form.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
         bool submitted = await _formResponseService.checkIfResponseSubmitted(form.id, _selectedStudent!.id, _parentId!, DateTime.now());
        _submittedForms[submissionKey] = submitted;
      }

      if (_activeForms.isNotEmpty) {
        _selectedForm = _activeForms.firstWhereOrNull(
          (form) => !(_submittedForms["${form.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}"] ?? false),
        );
        _selectedForm ??= _activeForms.first;

        if (_selectedForm != null) {
          await _loadFieldsForForm();
        } else {
           if (mounted) setState(() => _isLoadingFields = false);
        }
      } else {
        if (mounted) setState(() => _isLoadingFields = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "${AppLocalizations.of(context)!.errorFetchingForms}: ${e.toString()}"); // Assert non-null
      }
    }
    if (mounted) setState(() => _isLoadingForms = false);
  }

  Future<void> _loadFieldsForForm() async {
    if (_selectedForm == null) {
      if (mounted) setState(() => _isLoadingFields = false);
      return;
    }
    setState(() {
      _isLoadingFields = true;
      _formFields = [];
      _answers = {};
    });
    try {
      _formFields = await _customFormService.getFormFields(_selectedForm!.id);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "${AppLocalizations.of(context)!.errorFetchingFormDetails}: ${e.toString()}"); // Assert non-null
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

    _reportFormKey.currentState!.save();

    setState(() => _isSubmitting = true);

    final responseId = _uuid.v4();
    final formResponse = FormResponse(
      id: responseId,
      formId: _selectedForm!.id,
      studentId: _selectedStudent!.id,
      parentId: _parentId!,
      submittedAt: DateTime.now(),
    );

    List<FormResponseAnswer> responseAnswers = [];
    _answers.forEach((fieldId, answer) {
      final field = _formFields.firstWhere((f) => f.id == fieldId);
      String answerValue;

      if (answer is bool) {
        answerValue = answer.toString();
      } else if (answer is Map<String, bool>) {
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
         answerValue = jsonEncode([]);
      }
      else {
        answerValue = answer?.toString() ?? '';
      }

      responseAnswers.add(FormResponseAnswer(
        id: _uuid.v4(),
        responseId: responseId,
        fieldId: fieldId,
        answerJson: answerValue,
      ));
    });

    try {
      final success = await _formResponseService.submitResponse(formResponse, responseAnswers);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.reportSubmittedSuccessfully)), // Assert non-null
          );
          String submissionKey = "${_selectedForm!.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
          setState(() {
            _submittedForms[submissionKey] = true;
            _selectedForm = _activeForms.firstWhereOrNull(
              (form) => !(_submittedForms["${form.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}"] ?? false),
            );
            if (_selectedForm != null) {
              _loadFieldsForForm();
            } else {
              _formFields = [];
            }
          });
        }
      } else {
        if (mounted) {
          setState(() => _errorMessage = AppLocalizations.of(context)!.failedToSubmitReport); // Assert non-null
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "${AppLocalizations.of(context)!.errorSubmittingReport}: ${e.toString()}"); // Assert non-null
      }
    }
    if (mounted) setState(() => _isSubmitting = false);
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Assert non-null
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.dailyReportsTitle)),
      body: _buildBody(l10n, theme, contextualAccentColor),
    );
  }

  Widget _buildBody(AppLocalizations l10n, ThemeData theme, Color contextualAccentColor) {
    if (_isLoadingStudents) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)));
    }
    if (_errorMessage != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.error))));
    }
    if (_linkedStudents.isEmpty) {
      return Center(child: Text(l10n.noChildrenLinked, style: theme.textTheme.bodyLarge)); // Use noChildrenLinked
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              decoration: InputDecoration(labelText: l10n.childLabel),
            ),
            const SizedBox(height: 16),
          ],
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
                  child: Text("${form.title}${isSubmitted ? ' (${l10n.reportAlreadySubmitted})' : ''}", style: theme.textTheme.bodyLarge),
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
              decoration: InputDecoration(labelText: l10n.formTitleLabel),
            ),
            const SizedBox(height: 16),
          ] else if (_activeForms.length == 1 && _selectedForm != null) ... [
             Padding(
               padding: const EdgeInsets.symmetric(vertical: 8.0),
               child: Text("${l10n.formTitleLabel}: ${_selectedForm!.title}", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
             ),
          ],

          if (_isLoadingFields)
            Expanded(child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor))))
          else if (_selectedForm == null)
            Expanded(child: Center(child: Text(_activeForms.isEmpty ? l10n.noActiveFormsForToday : l10n.pleaseSelectForm, style: theme.textTheme.bodyLarge)))
          else if (_formFields.isEmpty && _selectedForm != null)
             Expanded(child: Center(child: Text(l10n.formHasNoQuestions, style: theme.textTheme.bodyLarge)))
          else
            FormFieldsBuilder(
              formFields: _formFields,
              selectedForm: _selectedForm,
              submittedForms: _submittedForms,
              isSubmitting: _isSubmitting,
              onSubmitReport: _submitReport,
              onAnswerChange: _handleAnswerChange,
              answers: _answers,
              reportFormKey: _reportFormKey,
            ),
        ],
      ),
    );
  }
}
