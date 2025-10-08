import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../models/exam.dart';
import '../../../providers/school_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../models/school_class.dart';
import '../../../l10n/gen/app_localizations.dart';

class ModernAddEditExamScreen extends StatefulWidget {
  final Exam? exam;

  const ModernAddEditExamScreen({super.key, this.exam});

  @override
  _ModernAddEditExamScreenState createState() => _ModernAddEditExamScreenState();
}

class _ModernAddEditExamScreenState extends State<ModernAddEditExamScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _examinerNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _maxMarksController;

  DateTime? _selectedDate;
  SchoolClass? _selectedClass;
  List<SchoolClass> _classes = [];
  bool _isLoading = false;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exam?.name ?? '');
    _examinerNameController = TextEditingController(text: widget.exam?.examinerName ?? '');
    _descriptionController = TextEditingController(text: widget.exam?.description ?? '');
    _maxMarksController = TextEditingController(text: widget.exam?.maxMarks?.toString() ?? '');
    _selectedDate = widget.exam?.examDate;

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _examinerNameController.dispose();
    _descriptionController.dispose();
    _maxMarksController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id.toString();

    if (schoolId != null) {
      await classProvider.fetchClasses(schoolId);
      setState(() {
        _classes = classProvider.classes;
        if (widget.exam != null) {
          _selectedClass = _classes.firstWhere(
            (c) => c.id == widget.exam!.classId,
            orElse: () => _classes.first,
          );
        } else if (_classes.isNotEmpty) {
          _selectedClass = _classes.first;
        }
      });
    }
  }

  Future<void> _saveExam() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedClass == null) {
      _showErrorSnackBar('Please select a class');
      return;
    }

    if (_selectedDate == null) {
      _showErrorSnackBar('Please select an exam date');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id;

      if (schoolId == null) {
        _showErrorSnackBar('School not found');
        return;
      }

      final maxMarks = int.tryParse(_maxMarksController.text);

      if (widget.exam == null) {
        await examProvider.createExam(
          classId: _selectedClass!.id!,
          schoolId: schoolId,
          name: _nameController.text.trim(),
          examDate: _selectedDate!,
          examinerName: _examinerNameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          maxMarks: maxMarks,
        );
        _showSuccessSnackBar('Exam created successfully');
      } else {
        await examProvider.updateExam(
          id: widget.exam!.id,
          classId: _selectedClass!.id!,
          schoolId: schoolId,
          name: _nameController.text.trim(),
          examDate: _selectedDate!,
          examinerName: _examinerNameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
          maxMarks: maxMarks,
        );
        _showSuccessSnackBar('Exam updated successfully');
      }

      Navigator.pop(context);
    } catch (e) {
      _showErrorSnackBar('Failed to save exam: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final isEditing = widget.exam != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? (localizations?.editExamTitle ?? 'Edit Exam') : (localizations?.addExamTitle ?? 'Add Exam'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            Container(
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: _saveExam,
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeController,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderCard(isEditing),
                  const SizedBox(height: 24),
                  _buildFormCard(localizations),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(bool isEditing) {
    return Card(
      elevation: 8,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.2),
              ),
              child: Icon(
                isEditing ? Icons.edit : Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exam == null ? 'Create Exam' : 'Update Exam',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isEditing ? 'Update exam information' : 'Fill in the details to create a new exam',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard(AppLocalizations? localizations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exam Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Exam Name',
              icon: Icons.assignment,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Exam name cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildClassDropdown(localizations),
            const SizedBox(height: 16),
            _buildDatePicker(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _examinerNameController,
              label: 'Examiner Name',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Examiner name cannot be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _maxMarksController,
              label: 'Maximum Marks (Optional)',
              icon: Icons.score,
              keyboardType: TextInputType.number,
              hintText: 'Enter maximum marks for the exam',
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Description (Optional)',
              icon: Icons.description,
              maxLines: 3,
              hintText: 'Enter exam description or instructions',
            ),
            const SizedBox(height: 32),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveExam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.exam == null ? (localizations?.createExam ?? 'Create Exam') : (localizations?.updateExam ?? 'Update Exam'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  Widget _buildClassDropdown(AppLocalizations? localizations) {
    return DropdownButtonFormField<SchoolClass>(
      value: _selectedClass,
      decoration: InputDecoration(
        labelText: localizations?.classLabel ?? 'Class',
        prefixIcon: Icon(Icons.class_, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: _classes.map((classItem) {
        return DropdownMenuItem(
          value: classItem,
          child: Text(classItem.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedClass = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a class';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Theme.of(context).primaryColor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade50,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDate == null
                    ? 'Select Exam Date'
                    : 'Exam Date: ${_selectedDate!.toLocal().toString().split(' ')[0]}',
                style: TextStyle(
                  color: _selectedDate == null ? Colors.grey.shade600 : Colors.black,
                  fontSize: 16,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          ],
        ),
      ),
    );
  }
}
