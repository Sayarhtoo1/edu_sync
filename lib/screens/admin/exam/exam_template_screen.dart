import 'package:flutter/material.dart';
import '../../../services/exam_template_service.dart';
import '../../../models/exam_template.dart';

class ExamTemplateScreen extends StatefulWidget {
  final int schoolId;

  const ExamTemplateScreen({super.key, required this.schoolId});

  @override
  State<ExamTemplateScreen> createState() => _ExamTemplateScreenState();
}

class _ExamTemplateScreenState extends State<ExamTemplateScreen> {
  final _templateService = ExamTemplateService();
  List<ExamTemplate> _templates = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    setState(() => _isLoading = true);
    try {
      final templates = await _templateService.getTemplates(widget.schoolId);
      setState(() => _templates = templates);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading templates: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTemplate(String id) async {
    try {
      await _templateService.deleteTemplate(id);
      await _loadTemplates();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Template deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Templates')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _templates.isEmpty
              ? const Center(child: Text('No templates found'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _templates.length,
                  itemBuilder: (context, index) {
                    final template = _templates[index];
                    return Card(
                      child: ListTile(
                        title: Text(template.name),
                        subtitle: Text(template.description ?? ''),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteTemplate(template.id),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
