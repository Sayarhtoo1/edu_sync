import 'package:flutter/material.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/l10n/gen/app_localizations.dart';

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
    if (l10n == null) {
      return const SizedBox.shrink(); // Or a placeholder widget
    }
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.studentInformationLabel ?? 'Student Information',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.fullNameLabel ?? 'Full Name'),
              validator: (value) =>
                  (value == null || value.isEmpty) ? (l10n.fullNameValidator ?? 'Full name is required') : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: dobController,
              decoration: InputDecoration(
                  labelText: l10n.dateOfBirthLabel ?? 'Date of Birth',
                  hintText: l10n.dateOfBirthHint ?? 'Select Date'),
              readOnly: true,
              onTap: () => onSelectDateOfBirth(context),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: selectedClassId,
              hint: Text(l10n.selectClassOptionalHint ?? 'Select Class (Optional)'),
              items: availableClasses.map((app_class.SchoolClass cls) {
                return DropdownMenuItem<int>(
                  value: cls.id,
                  child: Text(cls.name),
                );
              }).toList(),
              onChanged: onClassChanged,
              decoration: InputDecoration(labelText: l10n.classOptionalLabel ?? 'Class (Optional)'),
              validator: (value) => value == null ? (l10n.classValidator ?? 'Class is required') : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedGender,
              hint: Text(l10n.selectGenderHint ?? 'Select Gender'),
              items: [
                DropdownMenuItem(value: 'Male', child: Text(l10n.genderMale ?? 'Male')),
                DropdownMenuItem(value: 'Female', child: Text(l10n.genderFemale ?? 'Female')),
                DropdownMenuItem(value: 'Other', child: Text(l10n.genderOther ?? 'Other')),
              ],
              onChanged: onGenderChanged,
              decoration: InputDecoration(labelText: l10n.genderLabel ?? 'Gender'),
            ),
          ],
        ),
      ),
    );
  }
}
