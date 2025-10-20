import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/providers/exam_provider.dart';
import 'package:edu_sync/providers/class_provider.dart';
import 'package:edu_sync/models/exam_class.dart';
import 'package:edu_sync/models/exam_subject.dart';
import 'package:edu_sync/models/subject.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/user_role.dart';

class DesktopMarksEntryScreen extends StatefulWidget {
  final String examId;
  final String examName;

  const DesktopMarksEntryScreen({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<DesktopMarksEntryScreen> createState() => _DesktopMarksEntryScreenState();
}

class _DesktopMarksEntryScreenState extends State<DesktopMarksEntryScreen> {
  bool _isLoading = false;
  List<ExamClass> _examClasses = [];
  ExamClass? _selectedExamClass;
  List<Subject> _classSubjects = [];
  Subject? _selectedSubject;
  ExamSubject? _examSubject;
  List<Map<String, dynamic>> _students = [];
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  bool _orderChanged = false;
  List<Subject> _orderedSubSubjects = [];
  final Map<String, bool> _isSaving = {};
  final Map<String, Timer?> _debounceTimers = {};
  final Set<String> _unsavedFields = {};

  @override
  void initState() {
    super.initState();
    _loadExamClasses();
  }

  @override
  void dispose() {
    for (var timer in _debounceTimers.values) {
      timer?.cancel();
    }
    for (var c in _controllers.values) {
      c.dispose();
    }
    for (var f in _focusNodes.values) {
      f.dispose();
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
      _focusNodes.clear();
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
      final authService = Provider.of<AuthService>(context, listen: false);
      
      final students = await examProvider.getStudentsForMarksEntry(
        examId: widget.examId,
        subjectId: _selectedSubject!.id,
        classId: _selectedExamClass!.classId,
      );

      final orderData = await Supabase.instance.client
          .from('student_display_order')
          .select('student_id, display_order')
          .eq('class_id', _selectedExamClass!.classId)
          .order('display_order');
      
      if (orderData.isNotEmpty) {
        final orderMap = {for (var item in orderData) item['student_id']: item['display_order']};
        students.sort((a, b) {
          final orderA = orderMap[a['studentId']] ?? 999999;
          final orderB = orderMap[b['studentId']] ?? 999999;
          return orderA.compareTo(orderB);
        });
      }

      _students = students;
      
      _examSubject = examProvider.examSubjects.where((es) => es.subjectId == _selectedSubject!.id).firstOrNull;
      
      for (var c in _controllers.values) {
        c.dispose();
      }
      for (var f in _focusNodes.values) {
        f.dispose();
      }
      _controllers.clear();
      _focusNodes.clear();
      
      if (_selectedSubject!.hasSubSubjects) {
        _orderedSubSubjects = List.from(_selectedSubject!.subSubjects!);
        for (var student in students) {
          final studentId = student['studentId'] as int;
          for (var subSubject in _selectedSubject!.subSubjects!) {
            final key = '${studentId}_${subSubject.id}';
            final marks = student['subSubjectMarks']?[subSubject.id];
            _controllers[key] = TextEditingController(
              text: marks != null ? marks.toString() : '',
            );
            _focusNodes[key] = FocusNode();
          }
        }
      } else {
        for (var student in students) {
          final studentId = student['studentId'] as int;
          final marksValue = student['marksObtained'];
          final key = '${studentId}_${_selectedSubject!.id}';
          _controllers[key] = TextEditingController(
            text: marksValue != null ? marksValue.toString() : '',
          );
          _focusNodes[key] = FocusNode();
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

  void _markAsUnsaved(String key) {
    _unsavedFields.add(key);
    _debounceTimers[key]?.cancel();
    _debounceTimers[key] = Timer(const Duration(seconds: 2), () {
      _saveMark(int.parse(key.split('_')[0]), key.split('_')[1], _controllers[key]?.text ?? '');
    });
  }

  Future<void> _saveMark(int studentId, String subjectId, String marks) async {
    final key = '${studentId}_$subjectId';
    
    if (marks.isEmpty) return;
    if (_isSaving[key] == true) return;
    
    _debounceTimers[key]?.cancel();
    _isSaving[key] = true;
    setState(() {});
    
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      await examProvider.saveStudentMark(
        examId: widget.examId,
        studentId: studentId,
        subjectId: subjectId,
        marksObtained: int.parse(marks),
      );
      _unsavedFields.remove(key);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () => _saveMark(studentId, subjectId, marks),
            ),
          ),
        );
      }
    } finally {
      _isSaving[key] = false;
      setState(() {});
    }
  }

  Future<void> _saveAllUnsaved() async {
    for (var key in _unsavedFields.toList()) {
      final parts = key.split('_');
      await _saveMark(int.parse(parts[0]), parts[1], _controllers[key]?.text ?? '');
    }
  }

  Map<String, dynamic> _calculateStatistics() {
    if (_students.isEmpty) return {'total': 0, 'entered': 0, 'average': 0.0, 'passRate': 0.0};
    
    int entered = 0;
    double totalMarks = 0;
    int passed = 0;
    final passingMarks = _selectedSubject?.hasSubSubjects ?? false
        ? (_selectedSubject?.passingMarks ?? 0)
        : (_examSubject?.passingMarks ?? 0);
    
    for (var student in _students) {
      final studentId = student['studentId'] as int;
      if (_selectedSubject?.hasSubSubjects ?? false) {
        final total = _calculateTotal(studentId);
        if (total > 0) {
          entered++;
          totalMarks += total;
          if (total >= passingMarks) passed++;
        }
      } else {
        final key = '${studentId}_${_selectedSubject!.id}';
        final controller = _controllers[key];
        if (controller != null && controller.text.isNotEmpty) {
          entered++;
          final marks = int.tryParse(controller.text) ?? 0;
          totalMarks += marks;
          if (marks >= passingMarks) passed++;
        }
      }
    }
    
    return {
      'total': _students.length,
      'entered': entered,
      'average': entered > 0 ? totalMarks / entered : 0.0,
      'passRate': entered > 0 ? (passed / entered) * 100 : 0.0,
    };
  }

  Future<void> _saveStudentOrder() async {
    if (_selectedExamClass == null || _students.isEmpty) return;
    
    setState(() => _isLoading = true);
    
    try {
      final classId = _selectedExamClass!.classId;
      
      await Supabase.instance.client
          .from('student_display_order')
          .delete()
          .eq('class_id', classId);
      
      final batch = <Map<String, dynamic>>[];
      for (int i = 0; i < _students.length; i++) {
        final studentId = _students[i]['studentId'] as int;
        batch.add({
          'class_id': classId,
          'student_id': studentId,
          'display_order': i,
        });
      }
      
      await Supabase.instance.client
          .from('student_display_order')
          .insert(batch);
      
      setState(() => _orderChanged = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order saved successfully'), backgroundColor: Color(0xFF2ECC71)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving order: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportToCSV() async {
    try {
      final className = Provider.of<ClassProvider>(context, listen: false)
          .classes
          .where((c) => c.id == _selectedExamClass?.classId)
          .firstOrNull
          ?.name ?? 'Class';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exporting marks for $className - ${_selectedSubject?.name}...'),
          backgroundColor: const Color(0xFF3498DB),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final classProvider = Provider.of<ClassProvider>(context);
    final stats = _calculateStatistics();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.examName),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          if (_unsavedFields.isNotEmpty)
            IconButton(
              onPressed: _saveAllUnsaved,
              icon: Stack(
                children: [
                  const Icon(Icons.save),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_unsavedFields.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              tooltip: 'Save ${_unsavedFields.length} unsaved marks',
            ),
          if (_orderChanged)
            IconButton(
              onPressed: _saveStudentOrder,
              icon: const Icon(Icons.reorder),
              tooltip: 'Save Order',
            ),
          if (_selectedSubject != null)
            IconButton(
              onPressed: _exportToCSV,
              icon: const Icon(Icons.download),
              tooltip: 'Export to CSV',
            ),
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
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        children: [
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _selectedExamClass?.classId,
                          decoration: const InputDecoration(
                            labelText: 'Class',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: _examClasses
                              .map((ec) => ec.classId)
                              .toSet()
                              .map((classId) {
                            final schoolClass = classProvider.classes.where((c) => c.id == classId).firstOrNull;
                            final className = schoolClass?.name ?? 'Class $classId';
                            return DropdownMenuItem(value: classId, child: Text(className));
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
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedSubject?.id,
                          decoration: const InputDecoration(
                            labelText: 'Subject',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      ),
                      if (_examSubject != null && !(_selectedSubject?.hasSubSubjects ?? false)) ...[
                        const SizedBox(width: 24),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3498DB).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Max: ${_examSubject!.maxMarks} | Pass: ${_examSubject!.passingMarks}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                        ],
                      ),
                      if (_selectedSubject != null && _students.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard('Total Students', '${stats['total']}', Icons.people, const Color(0xFF3498DB)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard('Marks Entered', '${stats['entered']}/${stats['total']}', Icons.edit, const Color(0xFF2ECC71)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard('Average', '${stats['average'].toStringAsFixed(1)}', Icons.analytics, const Color(0xFFF39C12)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildStatCard('Pass Rate', '${stats['passRate'].toStringAsFixed(1)}%', Icons.check_circle, const Color(0xFF2ECC71)),
                            ),
                          ],
                        ),
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
                                  ? _buildSubSubjectsTable()
                                  : _buildRegularSubjectsTable(),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRegularSubjectsTable() {
    final maxMarks = _examSubject?.maxMarks ?? 100;
    final passingMarks = _examSubject?.passingMarks ?? 40;

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40, child: Icon(Icons.drag_indicator, color: Colors.white, size: 20)),
                const SizedBox(width: 60, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                const Expanded(flex: 3, child: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                const Expanded(child: Text('Student ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                SizedBox(width: 120, child: Text('Marks (/$maxMarks)', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                const SizedBox(width: 100, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _students.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _students.removeAt(oldIndex);
                  _students.insert(newIndex, item);
                  _orderChanged = true;
                });
              },
              itemBuilder: (context, index) {
                final student = _students[index];
                final studentId = student['studentId'] as int;
                final key = '${studentId}_${_selectedSubject!.id}';
                final controller = _controllers[key];
                final focusNode = _focusNodes[key];
                
                if (controller == null || focusNode == null) return const SizedBox.shrink();
                
                final marks = int.tryParse(controller.text) ?? 0;
                final isPassed = marks >= passingMarks;

                return Container(
                  key: ValueKey(studentId),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 40, child: Icon(Icons.drag_indicator, color: Colors.grey, size: 20)),
                      SizedBox(width: 60, child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 3, child: Text(student['studentName'] as String)),
                      Expanded(child: Text('$studentId', style: TextStyle(color: Colors.grey[600]))),
                      SizedBox(
                        width: 120,
                        child: TextFormField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            hintText: '0',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                color: marks > maxMarks ? Colors.red : Colors.grey[300]!,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: marks > maxMarks ? Colors.red.withOpacity(0.1) : Colors.white,
                            errorText: marks > maxMarks ? 'Max: $maxMarks' : null,
                            errorStyle: const TextStyle(fontSize: 10),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          textAlign: TextAlign.center,
                          onChanged: (value) {
                            _markAsUnsaved(key);
                            setState(() {});
                          },
                          onFieldSubmitted: (value) async {
                            await _saveMark(studentId, _selectedSubject!.id, value);
                            if (index < _students.length - 1) {
                              final nextStudent = _students[index + 1];
                              final nextKey = '${nextStudent['studentId']}_${_selectedSubject!.id}';
                              _focusNodes[nextKey]?.requestFocus();
                            }
                          },
                        ),
                      ),
                      SizedBox(
                        width: 100,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: controller.text.isEmpty 
                                  ? Colors.grey.withOpacity(0.1)
                                  : (isPassed ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              controller.text.isEmpty ? 'Pending' : (isPassed ? 'Pass' : 'Fail'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: controller.text.isEmpty ? Colors.grey : (isPassed ? Colors.green : Colors.red),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubSubjectsTable() {
    final passingMarks = _selectedSubject!.passingMarks ?? 0;

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF2C3E50),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 40, child: Icon(Icons.drag_indicator, color: Colors.white, size: 20)),
                const SizedBox(width: 50, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                const Expanded(flex: 2, child: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                ..._orderedSubSubjects.asMap().entries.map((entry) {
                  final index = entry.key;
                  final sub = entry.value;
                  return Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (index > 0)
                          IconButton(
                            icon: const Icon(Icons.arrow_left, color: Colors.white, size: 16),
                            onPressed: () {
                              setState(() {
                                final temp = _orderedSubSubjects[index];
                                _orderedSubSubjects[index] = _orderedSubSubjects[index - 1];
                                _orderedSubSubjects[index - 1] = temp;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        Expanded(
                          child: Text(
                            '${sub.name}\n(/${sub.maxMarks ?? 100})',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (index < _orderedSubSubjects.length - 1)
                          IconButton(
                            icon: const Icon(Icons.arrow_right, color: Colors.white, size: 16),
                            onPressed: () {
                              setState(() {
                                final temp = _orderedSubSubjects[index];
                                _orderedSubSubjects[index] = _orderedSubSubjects[index + 1];
                                _orderedSubSubjects[index + 1] = temp;
                              });
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
                    ),
                  );
                }),
                const SizedBox(width: 100, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
                const SizedBox(width: 80, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: _students.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _students.removeAt(oldIndex);
                  _students.insert(newIndex, item);
                  _orderChanged = true;
                });
              },
              itemBuilder: (context, index) {
                final student = _students[index];
                final studentId = student['studentId'] as int;
                final total = _calculateTotal(studentId);
                final isPassed = total >= passingMarks;

                return Container(
                  key: ValueKey(studentId),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                    color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 40, child: Icon(Icons.drag_indicator, color: Colors.grey, size: 20)),
                      SizedBox(width: 50, child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600))),
                      Expanded(flex: 2, child: Text(student['studentName'] as String)),
                      ..._orderedSubSubjects.map((subSubject) {
                        final key = '${studentId}_${subSubject.id}';
                        final controller = _controllers[key];
                        final focusNode = _focusNodes[key];
                        
                        if (controller == null || focusNode == null) return const Expanded(child: SizedBox.shrink());
                        
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              decoration: InputDecoration(
                                hintText: '0',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              textAlign: TextAlign.center,
                              onChanged: (value) {
                                _markAsUnsaved(key);
                                setState(() {});
                              },
                              onFieldSubmitted: (value) => _saveMark(studentId, subSubject.id, value),
                            ),
                          ),
                        );
                      }),
                      SizedBox(
                        width: 100,
                        child: Center(
                          child: Text(
                            '$total / ${_selectedSubject!.totalMaxMarks}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPassed ? Colors.green : Colors.red,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 80,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPassed ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isPassed ? 'Pass' : 'Fail',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isPassed ? Colors.green : Colors.red,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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
