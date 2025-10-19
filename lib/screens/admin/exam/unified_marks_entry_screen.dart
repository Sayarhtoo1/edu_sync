import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../models/exam_class.dart';
import '../../../models/exam_subject.dart';
import '../../../models/subject.dart';
import '../../../theme/app_theme.dart';
import '../../../services/auth_service.dart';
import '../../../models/user_role.dart';

class UnifiedMarksEntryScreen extends StatefulWidget {
  final String examId;
  final String examName;

  const UnifiedMarksEntryScreen({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<UnifiedMarksEntryScreen> createState() => _UnifiedMarksEntryScreenState();
}

class _UnifiedMarksEntryScreenState extends State<UnifiedMarksEntryScreen> {
  bool _isLoading = false;
  List<ExamClass> _examClasses = [];
  ExamClass? _selectedExamClass;
  List<Subject> _classSubjects = [];
  Subject? _selectedSubject;
  ExamSubject? _examSubject;
  List<Map<String, dynamic>> _students = [];
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadExamClasses();
  }

  @override
  void dispose() {
    for (var c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _loadExamClasses() async {
    setState(() => _isLoading = true);
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      final classProvider = Provider.of<ClassProvider>(context, listen: false);
      
      final schoolId = await authService.getCurrentUserSchoolId();
      if (schoolId != null) {
        await classProvider.fetchClasses(schoolId.toString());
      }
      await examProvider.fetchExamClasses(widget.examId);
      final allExamClasses = examProvider.examClasses;
      
      final role = await authService.getUserRole();
      
      if (role == UserRole.Teacher.name) {
        final userId = authService.getCurrentUser()?.id;
        if (userId != null) {
          final teacherClasses = classProvider.classes
              .where((c) => c.teacherId == userId)
              .map((c) => c.id)
              .toList();
          
          _examClasses = allExamClasses
              .where((ec) => teacherClasses.contains(ec.classId))
              .toList();
        }
      } else {
        _examClasses = allExamClasses;
      }
      
      if (_examClasses.isNotEmpty) {
        _selectedExamClass = _examClasses.first;
        await _loadClassSubjects();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadClassSubjects() async {
    if (_selectedExamClass == null) return;
    
    setState(() {
      _isLoading = true;
      _selectedSubject = null;
      _students = [];
      _controllers.clear();
    });
    
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);
      
      await examProvider.fetchExamSubjectsForExam(widget.examId);
      
      final schoolId = await authService.getCurrentUserSchoolId();
      if (schoolId != null) {
        await examProvider.fetchSubjectsWithSubSubjects(
          schoolId,
          classId: _selectedExamClass!.classId,
        );
      }
      
      final seenIds = <String>{};
      _classSubjects = examProvider.subjects
          .where((s) => 
              s.classId == _selectedExamClass!.classId && 
              !s.isSubSubject && 
              seenIds.add(s.id))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStudents() async {
    if (_selectedSubject == null || _selectedExamClass == null) return;
    
    setState(() => _isLoading = true);
    
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      
      final students = await examProvider.getStudentsForMarksEntry(
        examId: widget.examId,
        subjectId: _selectedSubject!.id,
        classId: _selectedExamClass!.classId,
      );

      _students = students;
      
      _examSubject = examProvider.examSubjects.where((es) => es.subjectId == _selectedSubject!.id).firstOrNull;
      
      for (var c in _controllers.values) {
        c.dispose();
      }
      _controllers.clear();
      
      if (_selectedSubject!.hasSubSubjects) {
        for (var student in students) {
          final studentId = student['studentId'] as int;
          for (var subSubject in _selectedSubject!.subSubjects!) {
            final key = '${studentId}_${subSubject.id}';
            final marks = student['subSubjectMarks']?[subSubject.id];
            _controllers[key] = TextEditingController(
              text: marks != null ? marks.toString() : '',
            );
          }
        }
      } else {
        for (var student in students) {
          final studentId = student['studentId'] as int;
          final marksValue = student['marksObtained'];
          _controllers['${studentId}_${_selectedSubject!.id}'] = TextEditingController(
            text: marksValue != null ? marksValue.toString() : '',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _calculateTotal(int studentId) {
    if (!_selectedSubject!.hasSubSubjects) return 0;
    int total = 0;
    for (var subSubject in _selectedSubject!.subSubjects!) {
      final key = '${studentId}_${subSubject.id}';
      final controller = _controllers[key];
      total += int.tryParse(controller?.text ?? '') ?? 0;
    }
    return total;
  }

  Future<void> _autoSaveMark(int studentId, String subjectId, String marks) async {
    if (marks.isEmpty) return;
    
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      await examProvider.saveStudentMark(
        examId: widget.examId,
        studentId: studentId,
        subjectId: subjectId,
        marksObtained: int.parse(marks),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examName),
        actions: [
          IconButton(
            onPressed: _loadStudents,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading && _examClasses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: defaultAccentColor.withOpacity(0.1),
                  child: Column(
                    children: [
                      DropdownButtonFormField<int>(
                        value: _selectedExamClass?.classId,
                        decoration: const InputDecoration(
                          labelText: 'Select Class',
                          border: OutlineInputBorder(),
                        ),
                        items: _examClasses.map((ec) {
                          final schoolClass = classProvider.classes.where((c) => c.id == ec.classId).firstOrNull;
                          final className = schoolClass?.name ?? 'Class ${ec.classId}';
                          return DropdownMenuItem(
                            value: ec.classId,
                            child: Text(className),
                          );
                        }).toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            final examClass = _examClasses.where((ec) => ec.classId == value).firstOrNull;
                            if (examClass != null) {
                              setState(() => _selectedExamClass = examClass);
                              await _loadClassSubjects();
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedSubject?.id,
                        decoration: const InputDecoration(
                          labelText: 'Select Subject',
                          border: OutlineInputBorder(),
                        ),
                        items: _classSubjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                        onChanged: (value) async {
                          if (value != null) {
                            final subject = _classSubjects.where((s) => s.id == value).firstOrNull;
                            if (subject != null) {
                              setState(() => _selectedSubject = subject);
                              await _loadStudents();
                            }
                          }
                        },
                      ),
                      if (_examSubject != null && !(_selectedSubject?.hasSubSubjects ?? false)) ...[
                        const SizedBox(height: 8),
                        Text('Max: ${_examSubject!.maxMarks} | Pass: ${_examSubject!.passingMarks}', style: const TextStyle(color: textLightGrey)),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: _selectedSubject == null
                      ? const Center(child: Text('Select class and subject'))
                      : _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : _students.isEmpty
                              ? const Center(child: Text('No students found'))
                              : _selectedSubject!.hasSubSubjects
                                  ? _buildSubSubjectsList()
                                  : _buildRegularSubjectsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildSubSubjectsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final studentId = student['studentId'] as int;
        final studentName = student['studentName'] as String;
        final total = _calculateTotal(studentId);
        final passingMarks = _selectedSubject!.passingMarks ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(studentName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._selectedSubject!.subSubjects!.map((subSubject) {
                  final key = '${studentId}_${subSubject.id}';
                  final controller = _controllers[key];
                  if (controller == null) return const SizedBox.shrink();
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(flex: 2, child: Text(subSubject.name)),
                        SizedBox(
                          width: 100,
                          child: TextFormField(
                            controller: controller,
                            decoration: InputDecoration(
                              hintText: '0',
                              suffixText: '/${subSubject.maxMarks ?? 100}',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              setState(() {});
                              _autoSaveMark(studentId, subSubject.id, value);
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      '$total / ${_selectedSubject!.totalMaxMarks}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: total >= passingMarks ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegularSubjectsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (context, index) {
        final student = _students[index];
        final studentId = student['studentId'] as int;
        final key = '${studentId}_${_selectedSubject!.id}';
        final controller = _controllers[key];
        
        if (controller == null) return const SizedBox.shrink();
        
        final maxMarks = _examSubject?.maxMarks ?? 100;
        final passingMarks = _examSubject?.passingMarks ?? 40;
        final marks = int.tryParse(controller.text) ?? 0;
        final isPassed = marks >= passingMarks;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: controller.text.isNotEmpty ? (isPassed ? Colors.green : Colors.red) : Colors.grey,
              child: Text('${index + 1}'),
            ),
            title: Text(student['studentName'] as String),
            subtitle: Text('ID: $studentId'),
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
                  setState(() {});
                  _autoSaveMark(studentId, _selectedSubject!.id, value);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
