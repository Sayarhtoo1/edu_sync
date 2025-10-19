import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../models/school_class.dart';
import '../../../../models/subject.dart';
import '../../../../theme/app_theme.dart';

class ExamFormFields {
  // Basic Info Step
  static Widget buildBasicInfoStep({
    required BuildContext context,
    required TextEditingController nameController,
    required TextEditingController examinerController,
    required DateTime? selectedDate,
    required SchoolClass? selectedClass,
    required List<SchoolClass> classes,
    required Function(DateTime) onDateChanged,
    required Function(SchoolClass?) onClassChanged,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.getAccentColorForContext('form'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the basic details for the exam',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Exam Name
          TextFormField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: 'Exam Name *',
              hintText: 'e.g., Mid-term Exam, Final Exam',
              prefixIcon: const Icon(Icons.assignment),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Exam name is required';
              }
              if (value.length < 3) {
                return 'Exam name must be at least 3 characters';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 16),

          // Class Selection
          DropdownButtonFormField<SchoolClass>(
            value: selectedClass,
            decoration: InputDecoration(
              labelText: 'Class *',
              hintText: 'Select the class for this exam',
              prefixIcon: const Icon(Icons.class_),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items: classes.map((schoolClass) {
              return DropdownMenuItem<SchoolClass>(
                value: schoolClass,
                child: Text(schoolClass.name),
              );
            }).toList(),
            onChanged: onClassChanged,
            validator: (value) => value == null ? 'Please select a class' : null,
          ),

          const SizedBox(height: 16),

          // Exam Date
          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                onDateChanged(date);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedDate != null
                          ? 'Selected Date: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                          : 'Select Exam Date *',
                      style: TextStyle(
                        color: selectedDate != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: selectedDate != null ? AppTheme.getAccentColorForContext('form') : Colors.grey,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Examiner Name
          TextFormField(
            controller: examinerController,
            decoration: InputDecoration(
              labelText: 'Examiner Name *',
              hintText: 'Name of the person conducting the exam',
              prefixIcon: const Icon(Icons.person),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Examiner name is required';
              }
              if (value.length < 2) {
                return 'Examiner name must be at least 2 characters';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  // Subjects Step
  static Widget buildSubjectsStep({
    required List<Subject> selectedSubjects,
    required List<Subject> availableSubjects,
    required Function(List<Subject>) onSubjectsChanged,
    VoidCallback? onManageSubjects,
  }) {
    final parentSubjects = availableSubjects.where((s) => s.parentSubjectId == null).toList();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Exam Subjects',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.getAccentColorForContext('form'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select subjects for this exam. Parent subjects will include all sub-subjects.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Available Subjects
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available Subjects',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getAccentColorForContext('form'),
                ),
              ),
              if (onManageSubjects != null)
                OutlinedButton.icon(
                  onPressed: onManageSubjects,
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Manage'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...parentSubjects.map((subject) {
            final subSubjects = availableSubjects.where((s) => s.parentSubjectId == subject.id).toList();
            final hasSubSubjects = subSubjects.isNotEmpty;
            final isSelected = selectedSubjects.any((s) => s.id == subject.id);
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CheckboxListTile(
                    value: isSelected,
                    onChanged: (selected) {
                      final updatedSubjects = List<Subject>.from(selectedSubjects);
                      if (selected!) {
                        updatedSubjects.add(subject);
                        if (hasSubSubjects) {
                          for (var sub in subSubjects) {
                            if (!updatedSubjects.any((s) => s.id == sub.id)) {
                              updatedSubjects.add(sub);
                            }
                          }
                        }
                      } else {
                        updatedSubjects.removeWhere((s) => s.id == subject.id);
                        if (hasSubSubjects) {
                          updatedSubjects.removeWhere((s) => subSubjects.any((sub) => sub.id == s.id));
                        }
                      }
                      onSubjectsChanged(updatedSubjects);
                    },
                    title: Row(
                      children: [
                        if (hasSubSubjects)
                          Icon(Icons.folder, color: AppTheme.getAccentColorForContext('form'), size: 20),
                        if (!hasSubSubjects)
                          Icon(Icons.subject, color: Colors.grey, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          subject.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    subtitle: hasSubSubjects ? Text('${subSubjects.length} sub-subjects') : null,
                  ),
                  if (hasSubSubjects && isSelected)
                    Container(
                      padding: const EdgeInsets.only(left: 40, right: 16, bottom: 12),
                      child: Column(
                        children: subSubjects.map((sub) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.getAccentColorForContext('form').withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(sub.name, style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 24),

          // Selected Subjects
          if (selectedSubjects.isNotEmpty) ...[
            Text(
              'Selected Subjects (${selectedSubjects.length})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.getAccentColorForContext('form'),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.getAccentColorForContext('form').withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.getAccentColorForContext('form').withOpacity(0.2),
                ),
              ),
              child: Column(
                children: selectedSubjects.asMap().entries.map((entry) {
                  final index = entry.key;
                  final subject = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppTheme.getAccentColorForContext('form'),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            subject.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            final updatedSubjects = List<Subject>.from(selectedSubjects);
                            updatedSubjects.remove(subject);
                            onSubjectsChanged(updatedSubjects);
                          },
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          tooltip: 'Remove subject',
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.subject,
                    size: 48,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No subjects selected',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Select subjects from the list above to include them in the exam',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),

          // Subject Selection Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: selectedSubjects.isNotEmpty
                  ? AppTheme.getAccentColorForContext('form').withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selectedSubjects.isNotEmpty
                    ? AppTheme.getAccentColorForContext('form').withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: selectedSubjects.isNotEmpty
                      ? AppTheme.getAccentColorForContext('form')
                      : Colors.grey,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    selectedSubjects.isNotEmpty
                        ? '${selectedSubjects.length} subjects selected for this exam'
                        : 'Please select at least one subject to continue',
                    style: TextStyle(
                      color: selectedSubjects.isNotEmpty ? null : Colors.grey[600],
                      fontWeight: selectedSubjects.isNotEmpty ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Settings Step
  static Widget buildSettingsStep({
    required TextEditingController descriptionController,
    required TextEditingController maxMarksController,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.getAccentColorForContext('form'),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure additional exam settings and preferences',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Description
          TextFormField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Optional description or instructions for the exam',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),

          const SizedBox(height: 16),

          // Max Marks
          TextFormField(
            controller: maxMarksController,
            decoration: InputDecoration(
              labelText: 'Maximum Marks (Optional)',
              hintText: 'Total marks for the entire exam',
              prefixIcon: const Icon(Icons.score),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                final marks = int.tryParse(value);
                if (marks == null || marks <= 0) {
                  return 'Please enter a valid positive number';
                }
                if (marks > 1000) {
                  return 'Maximum marks cannot exceed 1000';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: 24),

          // Grade Scale Preview (if max marks is set)
          ValueListenableBuilder(
            valueListenable: maxMarksController,
            builder: (context, value, child) {
              if (value.text.isEmpty) return const SizedBox.shrink();

              return _buildGradeScalePreview(int.tryParse(value.text) ?? 100);
            },
          ),

          const SizedBox(height: 24),

          // Settings Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.getAccentColorForContext('form').withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.getAccentColorForContext('form').withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exam Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.getAccentColorForContext('form'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'You\'re about to ${maxMarksController.text.isNotEmpty ? 'create an exam with a maximum of ${maxMarksController.text} marks' : 'create an exam'}. '
                  '${descriptionController.text.isNotEmpty ? 'The exam includes specific instructions.' : 'No additional instructions have been added.'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildGradeScalePreview(int maxMarks) {
    final gradeRanges = [
      {'grade': 'A', 'min': (maxMarks * 0.9).ceil(), 'max': maxMarks, 'color': Colors.green},
      {'grade': 'B', 'min': (maxMarks * 0.8).ceil(), 'max': (maxMarks * 0.9).ceil() - 1, 'color': Colors.blue},
      {'grade': 'C', 'min': (maxMarks * 0.7).ceil(), 'max': (maxMarks * 0.8).ceil() - 1, 'color': Colors.orange},
      {'grade': 'D', 'min': (maxMarks * 0.6).ceil(), 'max': (maxMarks * 0.7).ceil() - 1, 'color': Colors.yellow.shade700},
      {'grade': 'F', 'min': 0, 'max': (maxMarks * 0.6).ceil() - 1, 'color': Colors.red},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.grade,
                color: AppTheme.getAccentColorForContext('form'),
              ),
              const SizedBox(width: 8),
              Text(
                'Grade Scale Preview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.getAccentColorForContext('form'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...gradeRanges.map((grade) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (grade['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: (grade['color'] as Color).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: grade['color'] as Color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    grade['grade'] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${grade['min']} - ${grade['max']} marks',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}