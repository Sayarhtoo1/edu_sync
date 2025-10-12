import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/exam.dart';
import '../../../models/exam_subject.dart';
import '../../../models/subject.dart';
import '../../../providers/exam_provider.dart';
import '../../../theme/app_theme.dart';

class ExamSubjectManagementScreen extends StatefulWidget {
  final Exam exam;

  const ExamSubjectManagementScreen({super.key, required this.exam});

  @override
  State<ExamSubjectManagementScreen> createState() => _ExamSubjectManagementScreenState();
}

class _ExamSubjectManagementScreenState extends State<ExamSubjectManagementScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  List<ExamSubject> _examSubjects = [];
  List<Subject> _availableSubjects = [];
  final Map<String, TextEditingController> _maxMarksControllers = {};
  final Map<String, TextEditingController> _passingMarksControllers = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    for (var controller in _maxMarksControllers.values) {
      controller.dispose();
    }
    for (var controller in _passingMarksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      await examProvider.fetchExamSubjectsForExam(widget.exam.id);
      await examProvider.fetchSubjectsByClassId(widget.exam.classId.toString());

      _examSubjects = examProvider.examSubjects;
      _availableSubjects = examProvider.subjects;

      for (var examSubject in _examSubjects) {
        _maxMarksControllers[examSubject.subjectId] = TextEditingController(text: examSubject.maxMarks.toString());
        _passingMarksControllers[examSubject.subjectId] = TextEditingController(text: examSubject.passingMarks.toString());
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addSubject(Subject subject) async {
    setState(() => _isLoading = true);

    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      await examProvider.examService.upsertExamSubject(
        examId: widget.exam.id,
        subjectId: subject.id,
        maxMarks: 100,
        passingMarks: 40,
      );
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${subject.name} added to exam')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateExamSubject(ExamSubject examSubject) async {
    final maxMarks = int.tryParse(_maxMarksControllers[examSubject.subjectId]?.text ?? '');
    final passingMarks = int.tryParse(_passingMarksControllers[examSubject.subjectId]?.text ?? '');

    if (maxMarks == null || passingMarks == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid marks')),
      );
      return;
    }

    if (passingMarks > maxMarks) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passing marks cannot exceed max marks')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      await examProvider.examService.upsertExamSubject(
        id: examSubject.id,
        examId: widget.exam.id,
        subjectId: examSubject.subjectId,
        maxMarks: maxMarks,
        passingMarks: passingMarks,
      );
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject updated successfully')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeSubject(ExamSubject examSubject) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Subject'),
        content: const Text('Are you sure you want to remove this subject from the exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.from('exam_subjects').delete().eq('id', examSubject.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject removed from exam')),
        );
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddSubjectDialog() {
    final addedSubjectIds = _examSubjects.map((es) => es.subjectId).toSet();
    final availableToAdd = _availableSubjects.where((s) => !addedSubjectIds.contains(s.id)).toList();

    if (availableToAdd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All subjects have been added to this exam')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subject'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableToAdd.length,
            itemBuilder: (context, index) {
              final subject = availableToAdd[index];
              return ListTile(
                title: Text(subject.name),
                trailing: const Icon(Icons.add),
                onTap: () {
                  Navigator.pop(context);
                  _addSubject(subject);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Subjects - ${widget.exam.name}'),
        backgroundColor: appBackgroundColor,
      ),
      body: _isLoading && _examSubjects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
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
                        Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))),
                        IconButton(
                          onPressed: () => setState(() => _errorMessage = null),
                          icon: const Icon(Icons.close, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Exam Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: defaultAccentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Date: ${widget.exam.examDate.day}/${widget.exam.examDate.month}/${widget.exam.examDate.year}'),
                          Text('Examiner: ${widget.exam.examinerName}'),
                          Text('Total Subjects: ${_examSubjects.length}'),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _examSubjects.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.subject, size: 64, color: Colors.grey.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              Text(
                                'No subjects added yet',
                                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: _showAddSubjectDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Subject'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _examSubjects.length,
                          itemBuilder: (context, index) {
                            final examSubject = _examSubjects[index];
                            final subject = _availableSubjects.firstWhere((s) => s.id == examSubject.subjectId);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            subject.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _removeSubject(examSubject),
                                          icon: const Icon(Icons.delete, color: Colors.red),
                                          tooltip: 'Remove subject',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _maxMarksControllers[examSubject.subjectId],
                                            decoration: InputDecoration(
                                              labelText: 'Max Marks',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              prefixIcon: const Icon(Icons.score),
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _passingMarksControllers[examSubject.subjectId],
                                            decoration: InputDecoration(
                                              labelText: 'Passing Marks',
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              prefixIcon: const Icon(Icons.check_circle),
                                            ),
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () => _updateExamSubject(examSubject),
                                        icon: const Icon(Icons.save),
                                        label: const Text('Update'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: defaultAccentColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: _examSubjects.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showAddSubjectDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Subject'),
              backgroundColor: defaultAccentColor,
            )
          : null,
    );
  }
}
