import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/exam.dart';
import 'package:edu_sync/models/exam_subject.dart';
import 'package:edu_sync/models/subject.dart';
import 'package:edu_sync/providers/exam_provider.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/providers/class_provider.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopEditExamSubjects extends StatefulWidget {
  final Exam exam;

  const DesktopEditExamSubjects({super.key, required this.exam});

  @override
  State<DesktopEditExamSubjects> createState() => _DesktopEditExamSubjectsState();
}

class _DesktopEditExamSubjectsState extends State<DesktopEditExamSubjects> {
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
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFE74C3C)),
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
        final examSubject = _examSubjects.firstWhere((es) => es.subjectId == subject.id);
        await Provider.of<ExamProvider>(context, listen: false).examService.deleteExamSubject(examSubject.id);
        setState(() {
          _examSubjects.removeWhere((es) => es.id == examSubject.id);
        });
      } else {
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
        await Provider.of<ExamProvider>(context, listen: false).fetchExamSubjectsForExam(widget.exam.id);
        setState(() {
          _examSubjects = Provider.of<ExamProvider>(context, listen: false).examSubjects;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: const Color(0xFFE74C3C)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _examSubjects.length;
    final totalCount = _allSubjects.length;

    return DesktopScaffold(
      title: 'Edit Exam - Subjects',
      actions: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$selectedCount / $totalCount selected',
            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3498DB)),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classSubjects.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.subject, size: 80, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('No classes found for this exam', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(32),
                  itemCount: _classSubjects.keys.length,
                  itemBuilder: (context, index) {
                    final classId = _classSubjects.keys.elementAt(index);
                    final subjects = _classSubjects[classId]!;
                    final className = _classNames[classId] ?? 'Class $classId';
                    final parentSubjects = subjects.where((s) => s.parentSubjectId == null).toList();
                    final classSelectedCount = subjects.where((s) => _isSubjectSelected(s.id)).length;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3498DB).withOpacity(0.1),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.class_, color: Color(0xFF3498DB), size: 24),
                                const SizedBox(width: 12),
                                Text(
                                  className,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3498DB),
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$classSelectedCount / ${subjects.length} selected',
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: parentSubjects.map((subject) {
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
                                          Icon(
                                            hasSubSubjects ? Icons.folder : Icons.subject,
                                            color: hasSubSubjects ? const Color(0xFF3498DB) : Colors.grey,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              subject.name,
                                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Padding(
                                        padding: const EdgeInsets.only(left: 32, top: 4),
                                        child: Text(
                                          hasSubSubjects 
                                              ? '${subSubjects.length} sub-subjects'
                                              : 'Max: ${subject.maxMarks ?? 100} | Pass: ${subject.passingMarks ?? 40}',
                                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                                        ),
                                      ),
                                    ),
                                    if (hasSubSubjects && isSelected)
                                      Container(
                                        margin: const EdgeInsets.only(left: 48, right: 16, bottom: 12),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3498DB).withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Column(
                                          children: subSubjects.map((sub) {
                                            final isSubSelected = _isSubjectSelected(sub.id);
                                            return CheckboxListTile(
                                              value: isSubSelected,
                                              onChanged: (selected) => _toggleSubject(sub),
                                              dense: true,
                                              title: Row(
                                                children: [
                                                  const Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
                                                  const SizedBox(width: 8),
                                                  Expanded(child: Text(sub.name, style: const TextStyle(fontSize: 14))),
                                                ],
                                              ),
                                              subtitle: Padding(
                                                padding: const EdgeInsets.only(left: 24),
                                                child: Text(
                                                  'Max: ${sub.maxMarks ?? 100} | Pass: ${sub.passingMarks ?? 40}',
                                                  style: const TextStyle(fontSize: 12),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
