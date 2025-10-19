import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../models/exam.dart';
import '../../../models/school_class.dart';
import '../../../models/subject.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../theme/app_theme.dart';

enum FormStep { basic, classScheduling, subjects, settings }

class ExamFormScreen extends StatefulWidget {
  final Exam? exam; // For editing existing exam

  const ExamFormScreen({super.key, this.exam});

  @override
  State<ExamFormScreen> createState() => _ExamFormScreenState();
}

class _ExamFormScreenState extends State<ExamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  late FormStep _currentStep;
  bool _isLoading = false;
  String? _errorMessage;

  // Form controllers for each step
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _examinerController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _maxMarksController = TextEditingController();

  DateTime? _selectedDate;
  SchoolClass? _selectedClass;
  List<Subject> _selectedSubjects = [];
  List<Subject> _availableSubjects = [];
  final bool _autoSaveEnabled = true;
  
  // Multi-class exam support
  final Set<int> _selectedClasses = {};
  final Map<int, DateTime> _classDates = {};
  final Map<int, List<Subject>> _classSubjects = {}; // Subjects per class
  String? _selectedExamType;

  // Auto-save timer
  DateTime _lastSaveTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentStep = FormStep.basic;
    _loadData();
    _setupAutoSave();
    _loadDraftIfAvailable();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _examinerController.dispose();
    _descriptionController.dispose();
    _maxMarksController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _setupAutoSave() {
    // Auto-save every 30 seconds if enabled
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (_autoSaveEnabled && mounted && _hasUnsavedChanges()) {
        await _autoSaveDraft();
      }
      return true;
    });
  }

  bool _hasUnsavedChanges() {
    return _nameController.text.isNotEmpty ||
           _examinerController.text.isNotEmpty ||
           _selectedDate != null ||
           _selectedClass != null ||
           _selectedSubjects.isNotEmpty ||
           _descriptionController.text.isNotEmpty ||
           _maxMarksController.text.isNotEmpty;
  }

  Future<void> _autoSaveDraft() async {
    // Implementation for auto-saving draft to local storage
    // For now, just update last save time
    _lastSaveTime = DateTime.now();
  }

  Future<void> _loadDraftIfAvailable() async {
    // Implementation for loading draft from local storage
    // For now, just populate with existing exam data if editing
    if (widget.exam != null) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        _populateFormWithExam(widget.exam!);
      }
    }
  }

  void _populateFormWithExam(Exam exam) {
    setState(() {
      _nameController.text = exam.name;
      _examinerController.text = exam.examinerName;
      _selectedDate = exam.examDate;
      _descriptionController.text = exam.description ?? '';
      _maxMarksController.text = exam.maxMarks?.toString() ?? '';
    });

    // Load class and subjects for this exam
    _loadExamDetails(exam);
  }

  Future<void> _loadExamDetails(Exam exam) async {
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final classProvider = Provider.of<ClassProvider>(context, listen: false);

      // Load class details
      final classes = classProvider.classes;
      final selectedClass = classes.where((c) => c.id == exam.classId).firstOrNull;

      // Load subjects for this exam
      await examProvider.fetchExamSubjectsForExam(exam.id);
      final examSubjects = examProvider.examSubjects;
      
      // Get the actual Subject objects from the exam subjects
      final selectedSubjects = _availableSubjects.where((subject) {
        return examSubjects.any((es) => es.subjectId == subject.id);
      }).toList();

      setState(() {
        _selectedClass = selectedClass;
        _selectedSubjects = selectedSubjects;
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id.toString();

      if (schoolId != null) {
        // Load classes and all subjects
        await Future.wait([
          Provider.of<ClassProvider>(context, listen: false).fetchClasses(schoolId),
          Provider.of<ExamProvider>(context, listen: false).fetchSubjects(schoolId),
        ]);

        _availableSubjects = Provider.of<ExamProvider>(context, listen: false).subjects;

        if (widget.exam != null) {
          _loadExamDetails(widget.exam!);
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Subject> _getSubjectsForClass(int classId) {
    return _availableSubjects.where((subject) => subject.classId == classId).toList();
  }

  List<Subject> _getAllSelectedSubjects() {
    final allSubjects = <Subject>[];
    _classSubjects.forEach((classId, subjects) {
      allSubjects.addAll(subjects);
    });
    return allSubjects;
  }

  Widget _buildSubjectsStepPerClass() {
    final classes = Provider.of<ClassProvider>(context).classes;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Subjects per Class', style: Theme.of(context).textTheme.titleLarge),
            OutlinedButton.icon(
              onPressed: () async {
                await context.pushNamed('subject-management');
                await _loadData();
              },
              icon: const Icon(Icons.settings, size: 18),
              label: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ..._selectedClasses.map((classId) {
          final className = classes.firstWhere((c) => c.id == classId).name;
          final classSubjects = _getSubjectsForClass(classId);
          final selectedForClass = _classSubjects[classId] ?? [];
          
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${selectedForClass.length} subjects selected'),
              children: [
                ...classSubjects.map((subject) {
                  final isSelected = selectedForClass.any((s) => s.id == subject.id);
                  return CheckboxListTile(
                    value: isSelected,
                    title: Text(subject.name),
                    onChanged: (selected) {
                      setState(() {
                        if (!_classSubjects.containsKey(classId)) {
                          _classSubjects[classId] = [];
                        }
                        if (selected!) {
                          _classSubjects[classId]!.add(subject);
                        } else {
                          _classSubjects[classId]!.removeWhere((s) => s.id == subject.id);
                        }
                      });
                    },
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id;

      if (schoolId == null) throw Exception('No school selected');
      if (_selectedClasses.isEmpty) throw Exception('Please select at least one class');

      final examProvider = Provider.of<ExamProvider>(context, listen: false);

      // Create multi-class exam
      final newExam = await examProvider.createMultiClassExam(
        schoolId: schoolId,
        name: _nameController.text,
        classIds: _selectedClasses.toList(),
        classDates: _classDates,
        examType: _selectedExamType,
        examinerName: 'School',
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );

      // Save exam subjects if any selected
      final allSubjects = _getAllSelectedSubjects();
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

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepCircle(FormStep.basic, 'Basic'),
          _buildStepLine(),
          _buildStepCircle(FormStep.classScheduling, 'Classes'),
          _buildStepLine(),
          _buildStepCircle(FormStep.subjects, 'Subjects'),
          _buildStepLine(),
          _buildStepCircle(FormStep.settings, 'Settings'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(FormStep step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _isStepCompleted(step);

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppTheme.getAccentColorForContext('form')
                  : isActive
                      ? AppTheme.getAccentColorForContext('form').withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
              border: Border.all(
                color: isActive
                    ? AppTheme.getAccentColorForContext('form')
                    : Colors.grey.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              _getStepIcon(step),
              color: isCompleted || isActive
                  ? Colors.white
                  : Colors.grey,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppTheme.getAccentColorForContext('form') : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepLine() {
    return Expanded(
      child: Container(
        height: 2,
        color: _currentStep == FormStep.subjects
            ? AppTheme.getAccentColorForContext('form').withOpacity(0.3)
            : Colors.grey.withOpacity(0.3),
      ),
    );
  }

  IconData _getStepIcon(FormStep step) {
    switch (step) {
      case FormStep.basic:
        return Icons.info;
      case FormStep.classScheduling:
        return Icons.class_;
      case FormStep.subjects:
        return Icons.subject;
      case FormStep.settings:
        return Icons.settings;
    }
  }

  bool _isStepCompleted(FormStep step) {
    switch (step) {
      case FormStep.basic:
        return _nameController.text.isNotEmpty;
      case FormStep.classScheduling:
        return _selectedClasses.isNotEmpty && _classDates.length == _selectedClasses.length;
      case FormStep.subjects:
        return _classSubjects.isNotEmpty && _classSubjects.values.every((subjects) => subjects.isNotEmpty);
      case FormStep.settings:
        return true;
      default:
        return false;
    }
  }

  void _goToNextStep() {
    if (_currentStep == FormStep.settings) {
      _saveExam();
    } else {
      setState(() => _currentStep = FormStep.values[_currentStep.index + 1]);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousStep() {
    if (_currentStep != FormStep.basic) {
      setState(() => _currentStep = FormStep.values[_currentStep.index - 1]);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canGoNext() {
    switch (_currentStep) {
      case FormStep.basic:
        return _nameController.text.isNotEmpty;
      case FormStep.classScheduling:
        return _selectedClasses.isNotEmpty && _classDates.length == _selectedClasses.length;
      case FormStep.subjects:
        return _classSubjects.isNotEmpty && _classSubjects.values.every((subjects) => subjects.isNotEmpty);
      case FormStep.settings:
        return true;
      default:
        return false;
    }
  }

  Widget _buildClassSchedulingStep() {
    final classes = Provider.of<ClassProvider>(context).classes;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          value: _selectedExamType,
          decoration: const InputDecoration(
            labelText: 'Exam Type',
            border: OutlineInputBorder(),
          ),
          items: ['Midterm', 'Final', 'Quiz', 'Monthly', 'Unit Test', 'Other']
              .map((type) => DropdownMenuItem(value: type, child: Text(type)))
              .toList(),
          onChanged: (value) => setState(() => _selectedExamType = value),
        ),
        const SizedBox(height: 24),
        Text('Select Classes', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ...classes.map((schoolClass) => CheckboxListTile(
          title: Text(schoolClass.name),
          value: _selectedClasses.contains(schoolClass.id),
          onChanged: (selected) {
            setState(() {
              if (selected!) {
                _selectedClasses.add(schoolClass.id!);
                _classDates[schoolClass.id!] = DateTime.now().add(const Duration(days: 7));
              } else {
                _selectedClasses.remove(schoolClass.id);
                _classDates.remove(schoolClass.id);
              }
            });
          },
        )),
        if (_selectedClasses.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text('Schedule Exam Dates', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ..._selectedClasses.map((classId) {
            final className = classes.firstWhere((c) => c.id == classId).name;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(className),
                subtitle: Text(
                  _classDates[classId] != null
                      ? '${_classDates[classId]!.day}/${_classDates[classId]!.month}/${_classDates[classId]!.year}'
                      : 'Not set',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectDateForClass(classId),
                ),
              ),
            );
          }),
        ],
      ],
    );
  }

  Future<void> _selectDateForClass(int classId) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _classDates[classId] ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _classDates[classId] = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = AppTheme.getAccentColorForContext('form');
    final isEditing = widget.exam != null;

    if (_isLoading && _availableSubjects.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(isEditing ? 'Edit Exam' : 'Create Exam')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(isEditing ? 'Edit Exam' : 'Create Exam'),
        actions: [
          if (_hasUnsavedChanges())
            TextButton(
              onPressed: _autoSaveDraft,
              child: Text(
                'Save Draft',
                style: TextStyle(color: accentColor),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Step Indicator
          _buildStepIndicator(),

          // Error Message
          if (_errorMessage != null)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _errorMessage = null),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            ),

          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Exam Name *',
                          hintText: 'e.g., Midterm Exam 2025',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Optional exam details',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                  _buildClassSchedulingStep(),
                  _buildSubjectsStepPerClass(),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        'Additional Settings',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      const Text('Review your exam details and click Create Exam to finish.'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardTheme.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_currentStep != FormStep.basic)
              Expanded(
                child: OutlinedButton(
                  onPressed: _goToPreviousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
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
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _currentStep == FormStep.settings
                            ? (isEditing ? 'Update Exam' : 'Create Exam')
                            : 'Next',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}