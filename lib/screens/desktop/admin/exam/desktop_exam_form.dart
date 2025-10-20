import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';
import 'package:edu_sync/models/exam.dart';
import 'package:edu_sync/models/school_class.dart';
import 'package:edu_sync/models/subject.dart';
import 'package:edu_sync/providers/exam_provider.dart';
import 'package:edu_sync/providers/class_provider.dart';
import 'package:edu_sync/providers/school_provider.dart';

enum FormStep { basic, classScheduling, subjects, settings }

class DesktopExamForm extends StatefulWidget {
  final Exam? exam;

  const DesktopExamForm({super.key, this.exam});

  @override
  State<DesktopExamForm> createState() => _DesktopExamFormState();
}

class _DesktopExamFormState extends State<DesktopExamForm> {
  final _formKey = GlobalKey<FormState>();
  late FormStep _currentStep;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _examinerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxMarksController = TextEditingController();

  final Set<int> _selectedClasses = {};
  final Map<int, DateTime> _classDates = {};
  final Map<int, List<Subject>> _classSubjects = {};
  String? _selectedExamType;
  List<Subject> _availableSubjects = [];

  @override
  void initState() {
    super.initState();
    _currentStep = FormStep.basic;
    _loadData();
    if (widget.exam != null) {
      _populateFormWithExam(widget.exam!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _examinerController.dispose();
    _descriptionController.dispose();
    _maxMarksController.dispose();
    super.dispose();
  }

  void _populateFormWithExam(Exam exam) {
    _nameController.text = exam.name;
    _examinerController.text = exam.examinerName;
    _descriptionController.text = exam.description ?? '';
    _maxMarksController.text = exam.maxMarks?.toString() ?? '';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id.toString();
      if (schoolId != null) {
        await Future.wait([
          Provider.of<ClassProvider>(context, listen: false).fetchClasses(schoolId),
          Provider.of<ExamProvider>(context, listen: false).fetchSubjects(schoolId),
        ]);
        _availableSubjects = Provider.of<ExamProvider>(context, listen: false).subjects;
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Subject> _getSubjectsForClass(int classId) {
    return _availableSubjects.where((s) => s.classId == classId).toList();
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id;
      if (schoolId == null) throw Exception('No school selected');
      if (_selectedClasses.isEmpty) throw Exception('Select at least one class');

      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final newExam = await examProvider.createMultiClassExam(
        schoolId: schoolId,
        name: _nameController.text,
        classIds: _selectedClasses.toList(),
        classDates: _classDates,
        examType: _selectedExamType,
        examinerName: 'School',
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      final allSubjects = <Subject>[];
      _classSubjects.forEach((_, subjects) => allSubjects.addAll(subjects));
      if (allSubjects.isNotEmpty) {
        await examProvider.saveExamSubjects(newExam.id, allSubjects);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam created successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  bool _canGoNext() {
    switch (_currentStep) {
      case FormStep.basic:
        return _nameController.text.isNotEmpty && _selectedExamType != null;
      case FormStep.classScheduling:
        return _selectedClasses.isNotEmpty && _classDates.length == _selectedClasses.length;
      case FormStep.subjects:
        return _classSubjects.isNotEmpty && _classSubjects.values.every((s) => s.isNotEmpty);
      case FormStep.settings:
        return true;
    }
  }

  void _goToNextStep() {
    if (_currentStep == FormStep.settings) {
      _saveExam();
    } else {
      setState(() => _currentStep = FormStep.values[_currentStep.index + 1]);
    }
  }

  void _goToPreviousStep() {
    if (_currentStep != FormStep.basic) {
      setState(() => _currentStep = FormStep.values[_currentStep.index - 1]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: widget.exam != null ? 'Edit Exam' : 'Create Exam',
      body: _isLoading && _availableSubjects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildStepIndicator(),
                        if (_errorMessage != null) _buildErrorBanner(),
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: _buildCurrentStep(),
                          ),
                        ),
                        _buildNavigationButtons(),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 320,
                  color: const Color(0xFFF5F7FA),
                  padding: const EdgeInsets.all(24),
                  child: _buildSidebar(),
                ),
              ],
            ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          _buildStep(FormStep.basic, 'Basic Info', Icons.info),
          _buildStepLine(),
          _buildStep(FormStep.classScheduling, 'Classes', Icons.class_),
          _buildStepLine(),
          _buildStep(FormStep.subjects, 'Subjects', Icons.subject),
          _buildStepLine(),
          _buildStep(FormStep.settings, 'Review', Icons.check_circle),
        ],
      ),
    );
  }

  Widget _buildStep(FormStep step, String label, IconData icon) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep.index > step.index;
    final color = isCompleted ? const Color(0xFF2ECC71) : isActive ? const Color(0xFF3498DB) : Colors.grey;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted || isActive ? color : Colors.grey.shade200,
            ),
            child: Icon(icon, color: isCompleted || isActive ? Colors.white : Colors.grey, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? color : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(height: 2, color: Colors.grey.shade300, margin: const EdgeInsets.only(bottom: 32)),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red),
            onPressed: () => setState(() => _errorMessage = null),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case FormStep.basic:
        return _buildBasicStep();
      case FormStep.classScheduling:
        return _buildClassSchedulingStep();
      case FormStep.subjects:
        return _buildSubjectsStep();
      case FormStep.settings:
        return _buildSettingsStep();
    }
  }

  Widget _buildBasicStep() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const Text('Basic Information', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Exam Name *',
                  hintText: 'e.g., Midterm Exam 2025',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedExamType,
                decoration: const InputDecoration(
                  labelText: 'Exam Type *',
                  border: OutlineInputBorder(),
                ),
                items: ['Midterm', 'Final', 'Quiz', 'Monthly', 'Unit Test', 'Other']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedExamType = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Optional exam details',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildClassSchedulingStep() {
    final classes = Provider.of<ClassProvider>(context).classes;
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const Text('Select Classes & Schedule', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ...classes.map((c) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: CheckboxListTile(
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                subtitle: _selectedClasses.contains(c.id) && _classDates[c.id!] != null
                    ? Text('Date: ${_classDates[c.id!]!.day}/${_classDates[c.id!]!.month}/${_classDates[c.id!]!.year}')
                    : null,
                value: _selectedClasses.contains(c.id),
                onChanged: (selected) {
                  setState(() {
                    if (selected!) {
                      _selectedClasses.add(c.id!);
                      _classDates[c.id!] = DateTime.now().add(const Duration(days: 7));
                    } else {
                      _selectedClasses.remove(c.id);
                      _classDates.remove(c.id);
                    }
                  });
                },
                secondary: _selectedClasses.contains(c.id)
                    ? IconButton(
                        icon: const Icon(Icons.calendar_today, color: Color(0xFF3498DB)),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _classDates[c.id!] ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) setState(() => _classDates[c.id!] = date);
                        },
                      )
                    : null,
              ),
            )),
      ],
    );
  }

  Widget _buildSubjectsStep() {
    final classes = Provider.of<ClassProvider>(context).classes;
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const Text('Select Subjects per Class', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        ..._selectedClasses.map((classId) {
          final className = classes.firstWhere((c) => c.id == classId).name;
          final classSubjects = _getSubjectsForClass(classId);
          final selectedForClass = _classSubjects[classId] ?? [];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${selectedForClass.length} subjects selected'),
              children: classSubjects.map((subject) {
                final isSelected = selectedForClass.any((s) => s.id == subject.id);
                return CheckboxListTile(
                  value: isSelected,
                  title: Text(subject.name),
                  onChanged: (selected) {
                    setState(() {
                      _classSubjects[classId] ??= [];
                      if (selected!) {
                        _classSubjects[classId]!.add(subject);
                      } else {
                        _classSubjects[classId]!.removeWhere((s) => s.id == subject.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSettingsStep() {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const Text('Review & Create', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        const Text('Review your exam details and click Create Exam to finish.'),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: Row(
        children: [
          if (_currentStep != FormStep.basic)
            Expanded(
              child: OutlinedButton(
                onPressed: _goToPreviousStep,
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Previous'),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _canGoNext() ? _goToNextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                    )
                  : Text(_currentStep == FormStep.settings ? 'Create Exam' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Progress', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        _buildProgressItem('Basic Info', _nameController.text.isNotEmpty),
        _buildProgressItem('Classes', _selectedClasses.isNotEmpty && _classDates.length == _selectedClasses.length),
        _buildProgressItem('Subjects', _classSubjects.isNotEmpty && _classSubjects.values.every((s) => s.isNotEmpty)),
        const SizedBox(height: 32),
        const Text('Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        const Text('• Fill all required fields', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        const Text('• Select at least one class', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),
        const Text('• Choose subjects for each class', style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProgressItem(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.radio_button_unchecked,
            color: completed ? const Color(0xFF2ECC71) : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: completed ? Colors.black : Colors.grey)),
        ],
      ),
    );
  }
}
