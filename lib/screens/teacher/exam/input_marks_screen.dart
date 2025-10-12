import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/exam_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../models/exam.dart';
import '../../../models/student.dart';
import '../../../models/exam_subject.dart';
import '../../../theme/app_theme.dart';
import '../../common/error_display.dart';
import '../../common/empty_state.dart';

class InputMarksScreen extends StatefulWidget {
  final String examId;

  const InputMarksScreen({super.key, required this.examId});

  @override
  State<InputMarksScreen> createState() => _InputMarksScreenState();
}

class _InputMarksScreenState extends State<InputMarksScreen> {
  bool _isLoading = false;
  String? _error;
  Exam? _exam;
  List<Student> _students = [];
  List<ExamSubject> _examSubjects = [];
  final Map<String, Map<String, TextEditingController>> _marksControllers = {};
  final Map<String, Map<String, int>> _marks = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var studentControllers in _marksControllers.values) {
      for (var controller in studentControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);

      // Find the exam
      await examProvider.fetchExams(schoolProvider.currentSchool!.id.toString());
      _exam = examProvider.exams.where((e) => e.id == widget.examId).firstOrNull;

      if (_exam == null) {
        throw Exception('Exam not found');
      }

      // Load exam subjects and students
      await Future.wait([
        examProvider.fetchExamSubjectsForExam(widget.examId),
        examProvider.fetchStudentsByClassId(_exam!.classId.toString()),
      ]);

      _examSubjects = examProvider.examSubjects;
      _students = examProvider.students;

      // Initialize controllers and load existing marks
      _initializeControllers();
      await _loadExistingMarks();

    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _initializeControllers() {
    _marksControllers.clear();
    _marks.clear();

    for (var student in _students) {
      _marksControllers[student.id.toString()] = {};
      _marks[student.id.toString()] = {};

      for (var examSubject in _examSubjects) {
        final controller = TextEditingController();
        _marksControllers[student.id.toString()]![examSubject.subjectId] = controller;
        _marks[student.id.toString()]![examSubject.subjectId] = 0;
      }
    }
  }

  Future<void> _loadExistingMarks() async {
    // TODO: Load existing marks from database
    // This would involve calling a service to get existing student exam marks
  }

  Future<void> _saveMarks() async {
    setState(() => _isLoading = true);

    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);

      for (var studentId in _marks.keys) {
        for (var subjectId in _marks[studentId]!.keys) {
          final marks = _marks[studentId]![subjectId]!;
          if (marks > 0) {
            await examProvider.upsertStudentExamMark(
              examId: widget.examId,
              studentId: int.parse(studentId),
              subjectId: subjectId,
              marksObtained: marks,
            );
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Marks saved successfully')),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _updateMarks(String studentId, String subjectId, String value) {
    final marks = int.tryParse(value) ?? 0;
    setState(() {
      _marks[studentId]![subjectId] = marks;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _exam == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Input Marks')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Input Marks')),
        body: ErrorDisplay(
          message: 'Failed to load exam data',
          description: _error!,
          onRetry: _loadData,
        ),
      );
    }

    if (_exam == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Input Marks')),
        body: const EmptyState(
          icon: Icons.assignment_outlined,
          message: 'Exam not found',
          description: 'The requested exam could not be found.',
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Input Marks - ${_exam!.name}'),
        backgroundColor: appBackgroundColor,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveMarks,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            label: const Text('Save All'),
            style: TextButton.styleFrom(
              foregroundColor: accentEarnings,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Exam Info Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _exam!.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Examiner: ${_exam!.examinerName}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: textLightGrey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 16, color: textLightGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${_students.length} students',
                      style: const TextStyle(fontSize: 14, color: textDarkGrey),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.subject, size: 16, color: textLightGrey),
                    const SizedBox(width: 4),
                    Text(
                      '${_examSubjects.length} subjects',
                      style: const TextStyle(fontSize: 14, color: textDarkGrey),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Error Message
          if (_error != null)
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
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _error = null),
                    icon: const Icon(Icons.close, color: Colors.red),
                  ),
                ],
              ),
            ),

          // Marks Input Table
          Expanded(
            child: _examSubjects.isEmpty || _students.isEmpty
                ? const EmptyState(
                    icon: Icons.assignment_outlined,
                    message: 'No data available',
                    description: 'No subjects or students found for this exam.',
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Table Header
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: defaultAccentColor.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 2,
                                child: Text(
                                  'Student Name',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              ..._examSubjects.map((examSubject) => Expanded(
                                    child: Text(
                                      'Subject ${_examSubjects.indexOf(examSubject) + 1}\n(${examSubject.maxMarks})',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )),
                            ],
                          ),
                        ),

                        // Student Rows
                        ..._students.asMap().entries.map((entry) {
                          final index = entry.key;
                          final student = entry.value;
                          final isEven = index % 2 == 0;

                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isEven
                                  ? Colors.grey.withOpacity(0.05)
                                  : Colors.white,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.fullName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'ID: ${student.id}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ..._examSubjects.map((examSubject) {
                                  final controller = _marksControllers[
                                      student.id.toString()]![examSubject.subjectId]!;

                                  return Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4),
                                      child: TextFormField(
                                        controller: controller,
                                        decoration: InputDecoration(
                                          hintText: '0',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 8,
                                          ),
                                          isDense: true,
                                        ),
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        textAlign: TextAlign.center,
                                        onChanged: (value) => _updateMarks(
                                          student.id.toString(),
                                          examSubject.subjectId,
                                          value,
                                        ),
                                        validator: (value) {
                                          if (value != null && value.isNotEmpty) {
                                            final marks = int.tryParse(value);
                                            if (marks == null) {
                                              return 'Invalid';
                                            }
                                            if (marks > examSubject.maxMarks) {
                                              return 'Max ${examSubject.maxMarks}';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),

                        // Table Footer
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: defaultAccentColor.withOpacity(0.05),
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Expanded(
                                flex: 2,
                                child: Text(
                                  'Total Students: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                '${_students.length}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
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
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveMarks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentEarnings,
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
                        : const Text('Save All Marks'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}