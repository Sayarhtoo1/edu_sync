import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../models/exam.dart';
import '../../../providers/school_provider.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:edu_sync/models/school_class.dart'; // Assuming you need to select a class
import 'package:edu_sync/providers/class_provider.dart'; // For fetching classes

class AddEditExamScreen extends StatefulWidget {
  final Exam? exam;

  const AddEditExamScreen({super.key, this.exam});

  @override
  AddEditExamScreenState createState() => AddEditExamScreenState();
}

class AddEditExamScreenState extends State<AddEditExamScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _examinerNameController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDate;
  SchoolClass? _selectedClass;
  List<SchoolClass> _classes = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exam?.name ?? '');
    _examinerNameController = TextEditingController(text: widget.exam?.examinerName ?? '');
    _descriptionController = TextEditingController(text: widget.exam?.description ?? '');
    _selectedDate = widget.exam?.examDate;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchClasses();
  }

  Future<void> _fetchClasses() async {
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id;
    if (schoolId != null) {
      await classProvider.fetchClasses(schoolId.toString());
      setState(() {
        _classes = classProvider.classes;
        if (widget.exam != null) {
          _selectedClass = _classes.firstWhere(
            (c) => c.id == widget.exam!.classId,
            orElse: () => _classes.first, // Fallback if class not found
          );
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveExam() async {
    final localizations = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.dateValidator ?? 'Error')),
      );
      return;
    }
    if (_selectedClass == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.classValidator ?? 'Error')),
      );
      return;
    }

    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id;

    if (schoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.error_school_not_found ?? 'Error')),
      );
      return;
    }

    try {
      if (widget.exam == null) {
        await examProvider.createExam(
          classId: _selectedClass!.id!,
          schoolId: schoolId,
          name: _nameController.text,
          examDate: _selectedDate!,
          examinerName: _examinerNameController.text,
          description: _descriptionController.text,
        );
      } else {
        await examProvider.updateExam(
          id: widget.exam!.id,
          classId: _selectedClass!.id!,
          schoolId: schoolId,
          name: _nameController.text,
          examDate: _selectedDate!,
          examinerName: _examinerNameController.text,
          description: _descriptionController.text,
        );
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.failedToSaveExamError ?? 'Error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam == null ? (localizations?.addExamTitle ?? 'Add Exam') : (localizations?.editExamTitle ?? 'Edit Exam')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: localizations?.examNameLabel ?? 'Exam Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations?.examNameValidator ?? 'Exam name cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _examinerNameController,
                decoration: InputDecoration(labelText: localizations?.examinerNameLabel ?? 'Examiner Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations?.examinerNameValidator ?? 'Examiner name cannot be empty';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text(
                  '${localizations?.dateLabel ?? 'Date'}: ${_selectedDate == null ? (localizations?.dateNotSet ?? 'Date not set') : _selectedDate!.toLocal().toString().split(' ')[0]}',
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<SchoolClass>(
                value: _selectedClass,
                decoration: InputDecoration(labelText: localizations?.classLabel ?? 'Class'),
                items: _classes.map((schoolClass) {
                  return DropdownMenuItem(
                    value: schoolClass,
                    child: Text(schoolClass.name),
                  );
                }).toList(),
                onChanged: (schoolClass) {
                  setState(() {
                    _selectedClass = schoolClass;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return localizations?.classValidator ?? 'Please select a class';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveExam,
                child: Text(localizations?.saveButton ?? 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _examinerNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
