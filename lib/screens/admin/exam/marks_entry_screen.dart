import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../services/exam_csv_service.dart';
import '../../../models/exam_subject.dart';
import '../../../theme/app_theme.dart';

class MarksEntryScreen extends StatefulWidget {
  final String examId;
  final String? examName;

  const MarksEntryScreen({
    super.key,
    required this.examId,
    this.examName,
  });

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ExamSubject> _examSubjects = [];
  final Map<String, String> _subjectNames = {};
  int _currentSubjectIndex = 0;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  bool _isLoading = false;
  bool _isSaving = false;
  Timer? _autoSaveTimer;
  final Map<int, TextEditingController> _controllers = {};
  int _totalMarksEntered = 0;
  int _totalStudents = 0;

  @override
  void initState() {
    super.initState();
    _loadExamSubjects();
    _searchController.addListener(_filterStudents);
    _startAutoSave();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _autoSaveTimer?.cancel();
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isSaving && _examSubjects.isNotEmpty) _saveCurrentSubjectMarks(showMessage: false);
    });
  }

  Future<void> _loadExamSubjects() async {
    setState(() => _isLoading = true);
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      
      await examProvider.fetchSubjects(schoolProvider.currentSchool!.id.toString());
      await examProvider.fetchExamSubjectsForExam(widget.examId);
      _examSubjects = examProvider.examSubjects;
      
      for (var examSubject in _examSubjects) {
        try {
          final subject = examProvider.subjects.firstWhere(
            (s) => s.id == examSubject.subjectId,
          );
          _subjectNames[examSubject.subjectId] = subject.name;
        } catch (e) {
          _subjectNames[examSubject.subjectId] = 'Subject ${_examSubjects.indexOf(examSubject) + 1}';
        }
      }
      
      if (_examSubjects.isNotEmpty) {
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    if (_examSubjects.isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final currentSubject = _examSubjects[_currentSubjectIndex];
      final students = await examProvider.getStudentsForMarksEntry(
        examId: widget.examId,
        subjectId: currentSubject.subjectId,
      );

      _controllers.clear();
      setState(() {
        _students = students;
        _filteredStudents = students;
        _totalStudents = students.length;
        _totalMarksEntered = students.where((s) => s['marksObtained'] != null).length;
        for (var student in students) {
          final controller = TextEditingController(
            text: student['marksObtained']?.toString() ?? '',
          );
          _controllers[student['studentId']] = controller;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterStudents() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredStudents = _students.where((s) {
        return s['studentName'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _saveCurrentSubjectMarks({bool showMessage = true}) async {
    if (_examSubjects.isEmpty) return;
    
    setState(() => _isSaving = true);
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final currentSubject = _examSubjects[_currentSubjectIndex];
      final marksToSave = <Map<String, dynamic>>[];

      for (var student in _students) {
        final controller = _controllers[student['studentId']];
        if (controller != null && controller.text.isNotEmpty) {
          marksToSave.add({
            'studentId': student['studentId'],
            'marksObtained': int.parse(controller.text),
          });
        }
      }

      await examProvider.bulkSaveMarks(
        examId: widget.examId,
        subjectId: currentSubject.subjectId,
        marks: marksToSave,
      );

      await _loadData();

      if (showMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marks saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  void _nextSubject() async {
    if (_currentSubjectIndex < _examSubjects.length - 1) {
      await _saveCurrentSubjectMarks(showMessage: false);
      setState(() => _currentSubjectIndex++);
      await _loadData();
    }
  }

  void _previousSubject() async {
    if (_currentSubjectIndex > 0) {
      await _saveCurrentSubjectMarks(showMessage: false);
      setState(() => _currentSubjectIndex--);
      await _loadData();
    }
  }

  void _showSubjectSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ..._examSubjects.asMap().entries.map((entry) {
              final index = entry.key;
              final subject = entry.value;
              final subjectName = _subjectNames[subject.subjectId] ?? 'Subject ${index + 1}';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: index == _currentSubjectIndex ? defaultAccentColor : Colors.grey,
                  child: Text('${index + 1}'),
                ),
                title: Text(subjectName),
                subtitle: Text('Max: ${subject.maxMarks}, Pass: ${subject.passingMarks}'),
                trailing: index == _currentSubjectIndex ? const Icon(Icons.check) : null,
                onTap: () async {
                  Navigator.pop(context);
                  if (index != _currentSubjectIndex) {
                    await _saveCurrentSubjectMarks(showMessage: false);
                    setState(() => _currentSubjectIndex = index);
                    await _loadData();
                  }
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_examSubjects.isEmpty && !_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.examName ?? 'Enter Marks')),
        body: const Center(child: Text('No subjects found for this exam')),
      );
    }

    final currentSubject = _examSubjects.isNotEmpty ? _examSubjects[_currentSubjectIndex] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examName ?? 'Enter Marks'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            TextButton.icon(
              onPressed: () => _saveCurrentSubjectMarks(),
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: defaultAccentColor.withOpacity(0.1),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _currentSubjectIndex > 0 ? _previousSubject : null,
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: _showSubjectSelector,
                              child: Column(
                                children: [
                                  Text(
                                    _subjectNames[currentSubject?.subjectId] ?? 'Subject ${_currentSubjectIndex + 1}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${_currentSubjectIndex + 1} of ${_examSubjects.length}',
                                    style: const TextStyle(fontSize: 12, color: textLightGrey),
                                  ),
                                  if (currentSubject != null)
                                    Text(
                                      'Max: ${currentSubject.maxMarks} | Pass: ${currentSubject.passingMarks}',
                                      style: const TextStyle(fontSize: 14, color: textLightGrey),
                                    ),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _currentSubjectIndex < _examSubjects.length - 1 ? _nextSubject : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _totalStudents > 0 ? _totalMarksEntered / _totalStudents : 0,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(accentEarnings),
                      ),
                      const SizedBox(height: 4),
                      Text('$_totalMarksEntered / $_totalStudents students completed'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredStudents.isEmpty
                      ? const Center(child: Text('No students found'))
                      : ListView.builder(
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) {
                            final student = _filteredStudents[index];
                            final controller = _controllers[student['studentId']]!;
                            final maxMarks = currentSubject?.maxMarks ?? 100;
                            final passingMarks = currentSubject?.passingMarks ?? 40;
                            final marks = int.tryParse(controller.text) ?? 0;
                            final isPassed = marks >= passingMarks;

                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: controller.text.isNotEmpty
                                      ? (isPassed ? Colors.green : Colors.red)
                                      : Colors.grey,
                                  child: Text('${index + 1}'),
                                ),
                                title: Text(student['studentName']),
                                subtitle: Text('ID: ${student['studentId']}'),
                                trailing: SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      hintText: '0',
                                      suffixText: '/$maxMarks',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    textAlign: TextAlign.center,
                                    onChanged: (value) {
                                      setState(() {
                                        _totalMarksEntered = _students.where((s) {
                                          final c = _controllers[s['studentId']];
                                          return c != null && c.text.isNotEmpty;
                                        }).length;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
