import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/models/exam.dart';
import 'package:edu_sync/models/exam_class.dart';
import 'package:edu_sync/models/school_class.dart';
import 'package:edu_sync/providers/exam_provider.dart';
import 'package:edu_sync/providers/class_provider.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopEditExamClasses extends StatefulWidget {
  final Exam exam;

  const DesktopEditExamClasses({super.key, required this.exam});

  @override
  State<DesktopEditExamClasses> createState() => _DesktopEditExamClassesState();
}

class _DesktopEditExamClassesState extends State<DesktopEditExamClasses> {
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
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFE74C3C)),
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
    final newDate = await showDatePicker(
      context: context,
      initialDate: examClass.examDate,
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
            const SnackBar(content: Text('Date updated successfully'), backgroundColor: Color(0xFF2ECC71)),
          );
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
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE74C3C)),
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
            const SnackBar(content: Text('Class removed successfully'), backgroundColor: Color(0xFF2ECC71)),
          );
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
                trailing: const Icon(Icons.calendar_today, color: Color(0xFF3498DB)),
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3498DB)),
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
            const SnackBar(content: Text('Class added successfully'), backgroundColor: Color(0xFF2ECC71)),
          );
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
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Edit Exam - Classes & Schedule',
      actions: [
        IconButton(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: _addExamClass,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Class'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _examClasses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.class_, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No classes added yet', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _addExamClass,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Class'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3498DB),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(32),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: _examClasses.length,
                  itemBuilder: (context, index) {
                    final examClass = _examClasses[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3498DB).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.class_, color: Color(0xFF3498DB), size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _getClassName(examClass.classId),
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  DateFormat('MMM dd, yyyy').format(examClass.examDate),
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => _editExamClass(examClass),
                                  icon: const Icon(Icons.edit_calendar, size: 16),
                                  label: const Text('Edit Date'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF3498DB),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  onPressed: () => _deleteExamClass(examClass),
                                  icon: const Icon(Icons.delete, size: 20),
                                  color: const Color(0xFFE74C3C),
                                  tooltip: 'Remove',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
