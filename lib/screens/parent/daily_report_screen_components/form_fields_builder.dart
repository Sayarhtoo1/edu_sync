import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/models/custom_form.dart';
import 'package:edu_sync/models/form_field_item.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart';
import 'package:edu_sync/screens/parent/daily_report_screen_components/form_field_widget.dart';

class FormFieldsBuilder extends StatelessWidget {
  final List<FormFieldItem> formFields;
  final CustomForm? selectedForm;
  final Map<String, bool> submittedForms;
  final bool isSubmitting;
  final Function() onSubmitReport;
  final Function(String fieldId, dynamic value) onAnswerChange;
  final Map<String, dynamic> answers;
  final GlobalKey<FormState> reportFormKey;

  const FormFieldsBuilder({
    super.key,
    required this.formFields,
    required this.selectedForm,
    required this.submittedForms,
    required this.isSubmitting,
    required this.onSubmitReport,
    required this.onAnswerChange,
    required this.answers,
    required this.reportFormKey,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');
    String submissionKey = "${selectedForm!.id}_${DateFormat('yyyy-MM-dd').format(DateTime.now())}";
    bool isSubmitted = submittedForms[submissionKey] ?? false;

    if (isSubmitted) {
      return Expanded(child: Center(child: Text(l10n.reportAlreadySubmitted ?? "Report already submitted for today.", style: theme.textTheme.bodyLarge)));
    }

    return Expanded(
      child: Form(
        key: reportFormKey,
        child: ListView.builder(
          itemCount: formFields.length + 1, // +1 for submit button
          itemBuilder: (context, index) {
            if (index == formFields.length) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: isSubmitting
                    ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: contextualAccentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16)
                        ),
                        onPressed: onSubmitReport,
                        child: Text(l10n.submitReportButton ?? "Submit Report"),
                      ),
              );
            }
            final field = formFields[index];
            return FormFieldWidget(
              key: ValueKey(field.id),
              field: field,
              l10n: l10n,
              theme: theme,
              contextualAccentColor: contextualAccentColor,
              onAnswerChange: onAnswerChange,
              answers: answers,
            );
          },
        ),
      ),
    );
  }
}
