import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/models/custom_form.dart';
import 'package:edu_sync/models/form_response.dart';
import 'package:edu_sync/models/form_response_answer.dart';
import 'package:edu_sync/models/form_field_item.dart';
import 'package:edu_sync/models/form_field_type.dart'; // Import FormFieldType
import 'package:edu_sync/models/student.dart'; 
import 'package:edu_sync/services/custom_form_service.dart';
import 'dart:convert'; // Import for jsonDecode
import 'package:edu_sync/services/form_response_service.dart';
import 'package:edu_sync/services/student_service.dart'; // To get student details
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class ViewFormResponsesScreen extends StatefulWidget {
  final int schoolId;

  const ViewFormResponsesScreen({super.key, required this.schoolId});

  @override
  State<ViewFormResponsesScreen> createState() => _ViewFormResponsesScreenState();
}

class _ViewFormResponsesScreenState extends State<ViewFormResponsesScreen> {
  final CustomFormService _customFormService = CustomFormService();
  final FormResponseService _formResponseService = FormResponseService();
  final StudentService _studentService = StudentService(); // For fetching student names
  final AuthService _authService = AuthService();


  List<CustomForm> _availableForms = [];
  CustomForm? _selectedForm;
  List<FormResponse> _responses = [];
  Map<String, List<FormResponseAnswer>> _answersForResponse = {}; // responseId -> List<Answers>
  final Map<String, List<FormFieldItem>> _fieldsForForm = {}; // formId -> List<Fields>
  final Map<int, Student> _studentDetailsCache = {}; // studentId -> Student object

  bool _isLoadingForms = true;
  bool _isLoadingResponses = false;
  String? _errorMessage;
  String? _currentUserId;
  String? _currentUserRole;


  @override
  void initState() {
    super.initState();
    _currentUserId = _authService.getCurrentUser()?.id;
    _currentUserRole = _authService.getUserRole();
    _loadForms();
  }

  Future<void> _loadForms() async {
    setState(() => _isLoadingForms = true);
    try {
      // Admins/Teachers see forms they can manage (e.g., created by them or for their school)
      // Assuming getManageableForms handles role-based access appropriately.
      if (_currentUserId != null && _currentUserRole != null) {
         _availableForms = await _customFormService.getManageableForms(_currentUserId!, _currentUserRole!, widget.schoolId);
      } else {
        _availableForms = await _customFormService.getCustomFormsForSchool(widget.schoolId);
      }
     
      if (_availableForms.isNotEmpty) {
        _selectedForm = _availableForms.first;
        await _loadResponsesForForm();
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "Error loading forms: ${e.toString()}");
    }
    if (mounted) setState(() => _isLoadingForms = false);
  }

  Future<void> _loadResponsesForForm() async {
    if (_selectedForm == null) return;
    setState(() {
      _isLoadingResponses = true;
      _responses = [];
      _answersForResponse = {};
      _errorMessage = null;
    });
    try {
      _responses = await _formResponseService.getResponsesForForm(_selectedForm!.id);
      if (_fieldsForForm[_selectedForm!.id] == null) {
        _fieldsForForm[_selectedForm!.id] = await _customFormService.getFormFields(_selectedForm!.id);
      }
      for (var response in _responses) {
        _answersForResponse[response.id] = await _formResponseService.getAnswersForResponse(response.id);
        // Cache student details if not already fetched
        if (!_studentDetailsCache.containsKey(response.studentId)) {
          // This is a simplified fetch; ideally, StudentService would have getStudentById
          // For now, we'll fetch all students for the school and find the one. This is not efficient.
          // Consider adding getStudentById(int studentId) to StudentService.
          final studentsInSchool = await _studentService.getStudentsBySchool(widget.schoolId);
          final student = studentsInSchool.firstWhere((s) => s.id == response.studentId, orElse: () => Student(id: response.studentId, schoolId: widget.schoolId, fullName: 'Unknown Student'));
          _studentDetailsCache[response.studentId] = student;
        }
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = "Error loading responses: ${e.toString()}");
    }
    if (mounted) setState(() => _isLoadingResponses = false);
  }
  
  String _getStudentName(int studentId) {
    return _studentDetailsCache[studentId]?.fullName ?? 'Student ID: $studentId';
  }

  String _getQuestionText(String formId, String fieldId) {
    final fields = _fieldsForForm[formId];
    if (fields != null) {
      final field = fields.firstWhere((f) => f.id == fieldId, orElse: () => FormFieldItem(id: fieldId, formId: formId, question: 'Unknown Question', type: FormFieldType.text, required: false));
      return field.question;
    }
    return 'Question ID: $fieldId';
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.viewFormResponsesTitle ?? "View Form Responses")), 
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');

    if (_isLoadingForms) {
      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)));
    }
    if (_errorMessage != null) {
      return Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error))));
    }
    if (_availableForms.isEmpty) {
      return Center(child: Text(l10n.noFormsAvailableToViewResponses ?? "No forms available to view responses.", style: theme.textTheme.bodyLarge));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<CustomForm>(
            value: _selectedForm,
            hint: Text(l10n.selectFormToViewResponses ?? "Select a form to view responses", style: theme.textTheme.bodyLarge),
            items: _availableForms.map((CustomForm form) {
              return DropdownMenuItem<CustomForm>(
                value: form,
                child: Text(form.title, style: theme.textTheme.bodyLarge),
              );
            }).toList(),
            onChanged: (CustomForm? newValue) {
              if (newValue != null && newValue != _selectedForm) {
                setState(() {
                  _selectedForm = newValue;
                });
                _loadResponsesForForm();
              }
            },
            decoration: InputDecoration(labelText: l10n.formLabel ?? "Form"), // InputDecorationTheme applied globally
          ),
        ),
        if (_isLoadingResponses)
          Expanded(child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor))))
        else if (_responses.isEmpty && _selectedForm != null)
          Expanded(child: Center(child: Text(l10n.noResponsesForThisForm ?? "No responses found for this form.", style: theme.textTheme.bodyLarge)))
        else
          Expanded(
            child: ListView.builder(
              itemCount: _responses.length,
              itemBuilder: (context, index) {
                final response = _responses[index];
                final answers = _answersForResponse[response.id] ?? [];
                final studentName = _getStudentName(response.studentId);
                return Card( // CardTheme applied globally
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ExpansionTile(
                    iconColor: contextualAccentColor,
                    collapsedIconColor: textLightGrey, // Use top-level constant
                    title: Text("${l10n.responseFrom}: $studentName", style: theme.textTheme.titleMedium), 
                    subtitle: Text("${l10n.submittedOn}: ${DateFormat.yMd(l10n.localeName).add_jm().format(response.submittedAt.toLocal())}", style: theme.textTheme.bodySmall), 
                    children: answers.map((answer) {
                      final questionText = _getQuestionText(response.formId, answer.fieldId);
                      String displayAnswer = answer.answerJson;
                      try {
                        var decoded = jsonDecode(answer.answerJson);
                        if (decoded is List) {
                          displayAnswer = decoded.join(', ');
                        } else if (decoded is bool || decoded is num) {
                           displayAnswer = decoded.toString();
                        }
                      } catch (_) {
                        // It's not a valid JSON string, or it's a simple string answer.
                      }
                      return ListTile(
                        title: Text(questionText, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text(displayAnswer, style: theme.textTheme.bodyMedium),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
