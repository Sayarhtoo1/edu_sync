import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/exam.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/school_provider.dart';

class EditExamBasicScreen extends StatefulWidget {
  final Exam exam;

  const EditExamBasicScreen({super.key, required this.exam});

  @override
  State<EditExamBasicScreen> createState() => _EditExamBasicScreenState();
}

class _EditExamBasicScreenState extends State<EditExamBasicScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _examTypeController;
  late TextEditingController _examinerController;
  late TextEditingController _descriptionController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exam.name);
    _examTypeController = TextEditingController(text: widget.exam.examType ?? '');
    _examinerController = TextEditingController(text: widget.exam.examinerName ?? 'Not Specified');
    _descriptionController = TextEditingController(text: widget.exam.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _examTypeController.dispose();
    _examinerController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id;

      if (schoolId != null) {
        await Provider.of<ExamProvider>(context, listen: false).updateExam(
          id: widget.exam.id,
          schoolId: schoolId,
          name: _nameController.text,
          examType: _examTypeController.text.isEmpty ? null : _examTypeController.text,
          examinerName: _examinerController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exam updated successfully')),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Exam - Basic Info'),
        actions: [
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ))
          else
            TextButton.icon(
              onPressed: _saveChanges,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Exam Name *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _examTypeController,
              decoration: const InputDecoration(
                labelText: 'Exam Type',
                hintText: 'e.g., Midterm, Final',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _examinerController,
              decoration: const InputDecoration(
                labelText: 'Examiner Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }
}
