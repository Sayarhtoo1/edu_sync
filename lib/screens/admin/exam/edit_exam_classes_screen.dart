import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/exam.dart';
import '../../../models/exam_class.dart';
import '../../../models/school_class.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../theme/app_theme.dart';

class EditExamClassesScreen extends StatefulWidget {
  final Exam exam;

  const EditExamClassesScreen({super.key, required this.exam});

  @override
  State<EditExamClassesScreen> createState() => _EditExamClassesScreenState();
}

class _EditExamClassesScreenState extends State<EditExamClassesScreen> {
  bool _isLoading = false;
  List<ExamClass> _examClasses = [];
  List<SchoolClass> _allClasses = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id.toString();

      if (schoolId != null) {
        await Provider.of<ClassProvider>(context, listen: false).fetchClasses(schoolId);
        _allClasses = Provider.of<ClassProvider>(context, listen: false).classes;
        
        final examProvider = Provider.of<ExamProvider>(context, listen: false);
        await examProvider.fetchExamClasses(widget.exam.id);
        _examClasses = examProvider.examClasses;
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

  String _getClassName(int classId) {
    final schoolClass = _allClasses.where((c) => c.id == classId).firstOrNull;
    return schoolClass?.name ?? 'Class $classId';
  }

  Future<void> _editExamClass(ExamClass examClass) async {
    DateTime selectedDate = examClass.examDate;

    final newDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 730)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (newDate != null) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<ExamProvider>(context, listen: false).updateExamClass(
          id: examClass.id,
          examId: widget.exam.id,
          classId: examClass.classId,
          examDate: newDate,
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Date updated successfully')),
          );
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
  }

  Future<void> _deleteExamClass(ExamClass examClass) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Class'),
        content: Text('Remove ${_getClassName(examClass.classId)} from this exam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<ExamProvider>(context, listen: false).deleteExamClass(examClass.id, widget.exam.id);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class removed successfully')),
          );
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
  }

  Future<void> _addExamClass() async {
    final availableClasses = _allClasses.where((c) {
      return !_examClasses.any((ec) => ec.classId == c.id);
    }).toList();

    if (availableClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All classes already added')),
      );
      return;
    }

    SchoolClass? selectedClass;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Class'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<SchoolClass>(
                value: selectedClass,
                decoration: const InputDecoration(
                  labelText: 'Select Class',
                  border: OutlineInputBorder(),
                ),
                items: availableClasses.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c.name));
                }).toList(),
                onChanged: (v) => setDialogState(() => selectedClass = v),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Exam Date'),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 730)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setDialogState(() => selectedDate = date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedClass != null) {
                  Navigator.pop(context, {
                    'class': selectedClass,
                    'date': selectedDate,
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await Provider.of<ExamProvider>(context, listen: false).addExamClass(
          examId: widget.exam.id,
          classId: result['class'].id!,
          examDate: result['date'],
        );
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Class added successfully')),
          );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Exam - Classes & Schedule'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _examClasses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.class_, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('No classes added yet'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addExamClass,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Class'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _examClasses.length,
                  itemBuilder: (context, index) {
                    final examClass = _examClasses[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: defaultAccentColor.withOpacity(0.1),
                          child: Icon(Icons.class_, color: defaultAccentColor),
                        ),
                        title: Text(_getClassName(examClass.classId)),
                        subtitle: Text(DateFormat('MMM dd, yyyy').format(examClass.examDate)),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'edit') {
                              _editExamClass(examClass);
                            } else if (action == 'delete') {
                              _deleteExamClass(examClass);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit Date')),
                            const PopupMenuItem(value: 'delete', child: Text('Remove')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExamClass,
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
        backgroundColor: defaultAccentColor,
      ),
    );
  }
}
