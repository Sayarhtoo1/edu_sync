import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/exam.dart';
import '../../../models/exam_subject.dart';
import '../../../models/subject.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../theme/app_theme.dart';

class EditExamSubjectsScreen extends StatefulWidget {
  final Exam exam;

  const EditExamSubjectsScreen({super.key, required this.exam});

  @override
  State<EditExamSubjectsScreen> createState() => _EditExamSubjectsScreenState();
}

class _EditExamSubjectsScreenState extends State<EditExamSubjectsScreen> {
  bool _isLoading = false;
  List<ExamSubject> _examSubjects = [];
  List<Subject> _allSubjects = [];
  final Map<int, List<Subject>> _classSubjects = {};
  final Map<int, String> _classNames = {};

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
        final examProvider = Provider.of<ExamProvider>(context, listen: false);
        await examProvider.fetchSubjects(schoolId);
        _allSubjects = examProvider.subjects;
        await examProvider.fetchExamSubjectsForExam(widget.exam.id);
        _examSubjects = examProvider.examSubjects;
        
        // Group subjects by class
        _classSubjects.clear();
        _classNames.clear();
        
        if (widget.exam.examClasses != null) {
          for (final examClass in widget.exam.examClasses!) {
            final classSubjects = _allSubjects.where((s) => s.classId == examClass.classId).toList();
            _classSubjects[examClass.classId] = classSubjects;
            _classNames[examClass.classId] = await _getClassName(examClass.classId);
          }
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
  
  Future<String> _getClassName(int classId) async {
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final schoolClass = classProvider.classes.where((c) => c.id == classId).firstOrNull;
    return schoolClass?.name ?? 'Class $classId';
  }

  bool _isSubjectSelected(String subjectId) {
    return _examSubjects.any((es) => es.subjectId == subjectId);
  }

  Future<void> _toggleSubject(Subject subject) async {
    final isSelected = _isSubjectSelected(subject.id);
    
    try {
      if (isSelected) {
        // Remove subject
        final examSubject = _examSubjects.firstWhere((es) => es.subjectId == subject.id);
        await Provider.of<ExamProvider>(context, listen: false).examService.deleteExamSubject(examSubject.id);
        setState(() {
          _examSubjects.removeWhere((es) => es.id == examSubject.id);
        });
      } else {
        // Add subject with default marks from subject
        await Provider.of<ExamProvider>(context, listen: false).upsertExamSubject(
          ExamSubject(
            id: '',
            examId: widget.exam.id,
            subjectId: subject.id,
            maxMarks: subject.maxMarks ?? 100,
            passingMarks: subject.passingMarks ?? 40,
            createdAt: DateTime.now(),
          ),
        );
        // Reload to get the new exam subject with ID
        await Provider.of<ExamProvider>(context, listen: false).fetchExamSubjectsForExam(widget.exam.id);
        setState(() {
          _examSubjects = Provider.of<ExamProvider>(context, listen: false).examSubjects;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Exam - Subjects'),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classSubjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.subject, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      const Text('No classes found for this exam'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _classSubjects.keys.length,
                  itemBuilder: (context, index) {
                    final classId = _classSubjects.keys.elementAt(index);
                    final subjects = _classSubjects[classId]!;
                    final className = _classNames[classId] ?? 'Class $classId';
                    final parentSubjects = subjects.where((s) => s.parentSubjectId == null).toList();
                    final selectedCount = subjects.where((s) => _isSubjectSelected(s.id)).length;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: defaultAccentColor.withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.class_, color: defaultAccentColor),
                                const SizedBox(width: 8),
                                Text(
                                  className,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: defaultAccentColor,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '$selectedCount/${subjects.length} selected',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                          ...parentSubjects.map((subject) {
                            final subSubjects = subjects.where((s) => s.parentSubjectId == subject.id).toList();
                            final hasSubSubjects = subSubjects.isNotEmpty;
                            final isSelected = _isSubjectSelected(subject.id);
                            
                            return Column(
                              children: [
                                CheckboxListTile(
                                  value: isSelected,
                                  onChanged: (selected) => _toggleSubject(subject),
                                  title: Row(
                                    children: [
                                      if (hasSubSubjects)
                                        Icon(Icons.folder, color: defaultAccentColor, size: 20),
                                      if (!hasSubSubjects)
                                        Icon(Icons.subject, color: Colors.grey, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          subject.name,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: hasSubSubjects 
                                      ? Text('${subSubjects.length} sub-subjects')
                                      : Text('Max: ${subject.maxMarks ?? 100} | Pass: ${subject.passingMarks ?? 40}'),
                                ),
                                if (hasSubSubjects && isSelected)
                                  Container(
                                    padding: const EdgeInsets.only(left: 40, right: 16, bottom: 12),
                                    child: Column(
                                      children: subSubjects.map((sub) {
                                        final isSubSelected = _isSubjectSelected(sub.id);
                                        return Container(
                                          margin: const EdgeInsets.only(bottom: 4),
                                          decoration: BoxDecoration(
                                            color: defaultAccentColor.withOpacity(0.05),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: CheckboxListTile(
                                            value: isSubSelected,
                                            onChanged: (selected) => _toggleSubject(sub),
                                            dense: true,
                                            title: Row(
                                              children: [
                                                Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
                                                const SizedBox(width: 8),
                                                Expanded(child: Text(sub.name, style: const TextStyle(fontSize: 14))),
                                              ],
                                            ),
                                            subtitle: Text('Max: ${sub.maxMarks ?? 100} | Pass: ${sub.passingMarks ?? 40}', style: const TextStyle(fontSize: 12)),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                              ],
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
