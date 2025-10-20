import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/exam.dart';
import 'package:edu_sync/providers/exam_provider.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopEditExamBasic extends StatefulWidget {
  final Exam exam;

  const DesktopEditExamBasic({super.key, required this.exam});

  @override
  State<DesktopEditExamBasic> createState() => _DesktopEditExamBasicState();
}

class _DesktopEditExamBasicState extends State<DesktopEditExamBasic> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _examinerController;
  late TextEditingController _descriptionController;
  String? _selectedExamType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exam.name);
    _selectedExamType = widget.exam.examType;
    _examinerController = TextEditingController(text: widget.exam.examinerName ?? 'Not Specified');
    _descriptionController = TextEditingController(text: widget.exam.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
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
          examType: _selectedExamType,
          examinerName: _examinerController.text,
          description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Exam updated successfully'), backgroundColor: Color(0xFF2ECC71)),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFE74C3C)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Edit Exam - Basic Info',
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Basic Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Exam Name *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.edit, color: Color(0xFF3498DB)),
                              ),
                              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedExamType,
                              decoration: const InputDecoration(
                                labelText: 'Exam Type',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.category, color: Color(0xFF3498DB)),
                              ),
                              items: ['Midterm', 'Final', 'Quiz', 'Monthly', 'Unit Test', 'Other']
                                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedExamType = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _examinerController,
                        decoration: const InputDecoration(
                          labelText: 'Examiner Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person, color: Color(0xFF3498DB)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description, color: Color(0xFF3498DB)),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isLoading ? null : _saveChanges,
                            icon: _isLoading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.save),
                            label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3498DB),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          OutlinedButton.icon(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancel'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF3498DB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF3498DB)),
                        SizedBox(width: 8),
                        Text('Exam Information', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Exam ID', '#${widget.exam.id}'),
                    _buildInfoRow('Created', widget.exam.createdAt.toString().split(' ')[0]),
                    _buildInfoRow('Classes', '${widget.exam.examClasses?.length ?? 0}'),
                    const SizedBox(height: 24),
                    const Text('Tips:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildTip('Use clear, descriptive exam names'),
                    _buildTip('Specify exam type for better organization'),
                    _buildTip('Add examiner name for accountability'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildTip(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF3498DB))),
          Expanded(child: Text(tip, style: TextStyle(fontSize: 12, color: Colors.grey[700]))),
        ],
      ),
    );
  }
}
