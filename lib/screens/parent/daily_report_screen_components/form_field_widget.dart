import 'package:flutter/material.dart';
import 'package:edu_sync/models/form_field_item.dart';
import 'package:edu_sync/models/form_field_type.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';

class FormFieldWidget extends StatefulWidget {
  final FormFieldItem field;
  final AppLocalizations l10n;
  final ThemeData theme;
  final Color contextualAccentColor;
  final Function(String fieldId, dynamic value) onAnswerChange;
  final Map<String, dynamic> answers;

  const FormFieldWidget({
    super.key,
    required this.field,
    required this.l10n,
    required this.theme,
    required this.contextualAccentColor,
    required this.onAnswerChange,
    required this.answers,
  });

  @override
  State<FormFieldWidget> createState() => _FormFieldWidgetState();
}

class _FormFieldWidgetState extends State<FormFieldWidget> {
  late Map<String, bool> _checkboxSelections;

  @override
  void initState() {
    super.initState();
    if (widget.field.type == FormFieldType.checkbox) {
      _checkboxSelections = (widget.answers[widget.field.id] is Map<String, bool>)
          ? Map<String, bool>.from(widget.answers[widget.field.id] as Map<String, bool>)
          : <String, bool>{};
      for (var option in widget.field.options) {
        _checkboxSelections.putIfAbsent(option, () => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget fieldWidget;
    switch (widget.field.type) {
      case FormFieldType.text:
        fieldWidget = TextFormField(
          initialValue: widget.answers[widget.field.id] as String?,
          decoration: InputDecoration(labelText: widget.field.question + (widget.field.required ? " *" : "")),
          maxLines: widget.field.question.toLowerCase().contains("description") || widget.field.question.length > 50 ? 3 : 1,
          validator: widget.field.required ? (value) => (value == null || value.isEmpty) ? (widget.l10n.fieldRequiredValidation ?? 'This field is required') : null : null,
          onSaved: (value) => widget.onAnswerChange(widget.field.id, value),
        );
        break;
      case FormFieldType.yesNo:
        fieldWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.field.question + (widget.field.required ? " *" : ""), style: widget.theme.textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(widget.l10n.yes ?? 'Yes', style: widget.theme.textTheme.bodyLarge),
                    value: true,
                    groupValue: widget.answers[widget.field.id] as bool?,
                    onChanged: (value) => widget.onAnswerChange(widget.field.id, value),
                    activeColor: widget.contextualAccentColor,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: Text(widget.l10n.no ?? 'No', style: widget.theme.textTheme.bodyLarge),
                    value: false,
                    groupValue: widget.answers[widget.field.id] as bool?,
                    onChanged: (value) => widget.onAnswerChange(widget.field.id, value),
                    activeColor: widget.contextualAccentColor,
                  ),
                ),
              ],
            ),
            if (widget.field.required && widget.answers[widget.field.id] == null)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(widget.l10n.fieldRequiredValidation ?? 'This field is required', style: TextStyle(color: widget.theme.colorScheme.error, fontSize: 12)),
              ),
          ],
        );
        break;
      case FormFieldType.multipleChoice:
        fieldWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.field.question + (widget.field.required ? " *" : ""), style: widget.theme.textTheme.titleMedium),
            ...widget.field.options.map((option) => RadioListTile<String>(
                  title: Text(option, style: widget.theme.textTheme.bodyLarge),
                  value: option,
                  groupValue: widget.answers[widget.field.id] as String?,
                  onChanged: (value) => widget.onAnswerChange(widget.field.id, value),
                  activeColor: widget.contextualAccentColor,
                )),
            if (widget.field.required && widget.answers[widget.field.id] == null)
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(widget.l10n.fieldRequiredValidation ?? 'This field is required', style: TextStyle(color: widget.theme.colorScheme.error, fontSize: 12)),
              ),
          ],
        );
        break;
      case FormFieldType.checkbox:
        fieldWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.field.question + (widget.field.required ? " *" : ""), style: widget.theme.textTheme.titleMedium),
            ...widget.field.options.map((option) => CheckboxListTile(
                  title: Text(option, style: widget.theme.textTheme.bodyLarge),
                  value: _checkboxSelections[option] ?? false,
                  onChanged: (bool? newValue) {
                    setState(() {
                      _checkboxSelections[option] = newValue ?? false;
                      widget.onAnswerChange(widget.field.id, Map<String, bool>.from(_checkboxSelections));
                    });
                  },
                  activeColor: widget.contextualAccentColor,
                  controlAffinity: ListTileControlAffinity.leading,
                )),
            if (widget.field.required && !(_checkboxSelections.values.any((isSelected) => isSelected)))
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 4.0),
                child: Text(widget.l10n.fieldRequiredValidation ?? 'This field is required', style: TextStyle(color: widget.theme.colorScheme.error, fontSize: 12)),
              ),
          ],
        );
        break;
      case FormFieldType.number:
        fieldWidget = TextFormField(
          initialValue: widget.answers[widget.field.id]?.toString(),
          decoration: InputDecoration(labelText: widget.field.question + (widget.field.required ? " *" : "")),
          keyboardType: TextInputType.number,
          validator: widget.field.required ? (value) {
            if (value == null || value.isEmpty) return widget.l10n.fieldRequiredValidation ?? 'This field is required';
            if (int.tryParse(value) == null) return widget.l10n.pleaseEnterValidNumber ?? 'Please enter a valid number';
            return null;
          } : null,
          onSaved: (value) => widget.onAnswerChange(widget.field.id, value != null && value.isNotEmpty ? int.tryParse(value) : null),
        );
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: fieldWidget,
    );
  }
}
