import 'package:flutter/material.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart';
import 'package:intl/intl.dart';

class StudentFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dobController;
  final DateTime? selectedDateOfBirth;
  final Function(BuildContext) onSelectDateOfBirth;
  final int? selectedClassId;
  final List<app_class.SchoolClass> availableClasses;
  final Function(int?) onClassChanged;
  final String? selectedGender;
  final Function(String?) onGenderChanged;
  final Color contextualAccentColor;

  const StudentFormFields({
    super.key,
    required this.nameController,
    required this.dobController,
    required this.selectedDateOfBirth,
    required this.onSelectDateOfBirth,
    required this.selectedClassId,
    required this.availableClasses,
    required this.onClassChanged,
    required this.selectedGender,
    required this.onGenderChanged,
    required this.contextualAccentColor,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.studentInformationLabel,
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.fullNameLabel),
              validator: (value) =>
                  (value == null || value.isEmpty) ? l10n.fullNameValidator : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: dobController,
              decoration: InputDecoration(
                  labelText: l10n.dateOfBirthLabel,
                  hintText: l10n.dateOfBirthHint),
              readOnly: true,
              onTap: () => onSelectDateOfBirth(context),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedClassId,
              hint: Text(l10n.selectClassOptionalHint),
              items: availableClasses.map((app_class.SchoolClass cls) {
                return DropdownMenuItem<int>(
                  value: cls.id,
                  child: Text(cls.name),
                );
              }).toList(),
              onChanged: onClassChanged,
              decoration: InputDecoration(labelText: l10n.classOptionalLabel),
              validator: (value) => value == null ? l10n.classValidator : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGender,
              hint: Text(l10n.selectGenderHint),
              items: [
                DropdownMenuItem(value: 'Male', child: Text(l10n.genderMale)),
                DropdownMenuItem(value: 'Female', child: Text(l10n.genderFemale)),
                DropdownMenuItem(value: 'Other', child: Text(l10n.genderOther)),
              ],
              onChanged: onGenderChanged,
              decoration: InputDecoration(labelText: l10n.genderLabel),
            ),
          ],
        ),
      ),
    );
  }
}
