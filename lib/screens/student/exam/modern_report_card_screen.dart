import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../models/grade.dart';
import '../../../services/exam_analytics_service.dart';

class ModernReportCardScreen extends StatefulWidget {
  final String studentId;
  final String examId;

  const ModernReportCardScreen({
    super.key,
    required this.studentId,
    required this.examId,
  });

  @override
  State<ModernReportCardScreen> createState() => _ModernReportCardScreenState();
}

class _ModernReportCardScreenState extends State<ModernReportCardScreen>
    with TickerProviderStateMixin {
  late Future<void> _fetchReportCardFuture;
  late AnimationController _fadeController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _fetchReportCardFuture = _fetchData();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id;

    if (schoolId != null) {
      await examProvider.getDetailedStudentReportCard(
        studentId: int.parse(widget.studentId),
        examId: widget.examId,
      );
      await examProvider.fetchGrades(schoolId.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: FutureBuilder(
          future: _fetchReportCardFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else {
              return Consumer<ExamProvider>(
                builder: (context, examProvider, child) {
                  if (examProvider.detailedReportCard.isEmpty) {
                    return _buildEmptyState();
                  }

                  final studentName = examProvider.detailedReportCard.first['student_name'] ?? 'Student';
                  final examName = examProvider.detailedReportCard.first['exam_name'] ?? 'Exam';
                  final grades = examProvider.grades;

                  return _buildReportCardContent(
                    studentName: studentName.toString(),
                    examName: examName.toString(),
                    examProvider: examProvider,
                    grades: grades,
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Report Card...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.shade100,
            ),
            child: Icon(
              Icons.error_outline,
              color: Colors.red.shade600,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error Loading Report Card',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.red.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _fetchReportCardFuture = _fetchData();
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: Icon(
              Icons.assignment_outlined,
              color: Colors.grey.shade600,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Report Card Data',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Report card data is not available yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCardContent({
    required String studentName,
    required String examName,
    required ExamProvider examProvider,
    required List<Grade> grades,
  }) {
    final subjectResults = _calculateSubjectResults(examProvider, grades);
    final overallResult = _calculateOverallResult(subjectResults, grades);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildHeader(studentName, examName, overallResult),
          const SizedBox(height: 16),
          _buildSubjectsCard(subjectResults),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader(String studentName, String examName, Map<String, dynamic> overallResult) {
    final percentage = overallResult['overallPercentage'] as double;
    final passed = overallResult['overallPassed'] as bool;
    final grade = overallResult['overallGrade'];
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20)],
      ),
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
                child: const Icon(Icons.person, color: Color(0xFF3498DB), size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      studentName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      examName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${overallResult['totalMarksObtained']}/${overallResult['totalMaxMarks']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3498DB),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Marks',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: passed ? const Color(0xFF2ECC71).withOpacity(0.1) : const Color(0xFFE74C3C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: passed ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Percentage',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF39C12).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        grade,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF39C12),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Grade',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: passed ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  passed ? Icons.check_circle : Icons.cancel,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  passed ? 'PASSED' : 'FAILED',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildSubjectsCard(List<Map<String, dynamic>> subjectResults) {
    final groupedSubjects = _groupSubjectsByParent(subjectResults);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subjects',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: groupedSubjects.length,
            itemBuilder: (context, index) {
              final group = groupedSubjects[index];
              return _buildSubjectGroup(group);
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _groupSubjectsByParent(List<Map<String, dynamic>> subjectResults) {
    final Map<String, Map<String, dynamic>> parentMap = {};

    for (var subject in subjectResults) {
      final parentId = subject['parent_subject_id'];
      final parentName = subject['parent_subject_name'];
      
      if (parentId == null) {
        if (!parentMap.containsKey(subject['subject_id'])) {
          parentMap[subject['subject_id']] = {
            'parent': subject,
            'parent_name': subject['subject_name'],
            'children': [],
          };
        }
      } else {
        if (!parentMap.containsKey(parentId)) {
          parentMap[parentId] = {
            'parent': null,
            'parent_name': parentName,
            'children': [],
          };
        }
        parentMap[parentId]!['children'].add(subject);
      }
    }

    return parentMap.values.toList();
  }

  Widget _buildSubjectGroup(Map<String, dynamic> group) {
    final parent = group['parent'] as Map<String, dynamic>?;
    final parentName = group['parent_name'] as String?;
    final children = (group['children'] as List).cast<Map<String, dynamic>>();
    
    if (children.isEmpty && parent != null) {
      return _buildSubjectItem(parent, false);
    }
    
    if (children.isEmpty) {
      return const SizedBox.shrink();
    }

    int totalMarks = 0;
    int totalMaxMarks = 0;
    bool allPassed = true;

    for (var child in children) {
      totalMarks += child['marks_obtained'] as int;
      totalMaxMarks += child['max_marks'] as int;
      if (!(child['passed'] as bool)) allPassed = false;
    }

    final percentage = totalMaxMarks > 0 ? (totalMarks / totalMaxMarks) * 100 : 0.0;
    
    String parentGrade = 'N/A';
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    if (examProvider.grades.isNotEmpty) {
      for (var grade in examProvider.grades) {
        if (percentage >= grade.minPercentage && percentage <= grade.maxPercentage) {
          parentGrade = grade.gradeName ?? 'N/A';
          break;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  allPassed ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
                  allPassed ? const Color(0xFF27AE60) : const Color(0xFFC0392B),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        parentName ?? 'N/A',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$totalMarks/$totalMaxMarks',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        parentGrade,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...children.asMap().entries.map((entry) {
            final index = entry.key;
            final child = entry.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                borderRadius: index == children.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(16))
                    : null,
              ),
              child: _buildSubjectItem(child, true),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubjectItem(Map<String, dynamic> subject, bool isChild) {
    final double percentage = subject['percentage'] as double;
    final bool passed = subject['passed'] as bool;

    return Row(
      children: [
        if (isChild)
          Container(
            margin: const EdgeInsets.only(right: 12),
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: passed ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subject['subject_name'] ?? 'Unknown Subject',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: passed ? const Color(0xFF2ECC71).withOpacity(0.1) : const Color(0xFFE74C3C).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${subject['marks_obtained']}/${subject['max_marks']}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: passed ? const Color(0xFF2ECC71) : const Color(0xFFE74C3C),
            ),
          ),
        ),
      ],
    );
  }



  List<Map<String, dynamic>> _calculateSubjectResults(
    ExamProvider examProvider,
    List<Grade> grades,
  ) {
    final examAnalyticsService = ExamAnalyticsService();
    List<Map<String, dynamic>> subjectResults = [];

    for (var report in examProvider.detailedReportCard) {
      final marksObtained = report['marks_obtained'] as int;
      final maxMarks = report['max_marks'] as int;
      final passingMarks = report['passing_marks'] as int;

      final subjectGradeAndStatus = examAnalyticsService.getSubjectGradeAndStatus(
        marksObtained: marksObtained,
        maxMarks: maxMarks,
        passingMarks: passingMarks,
        grades: grades,
      );

      subjectResults.add({
        ...report,
        'percentage': subjectGradeAndStatus['percentage'],
        'grade': subjectGradeAndStatus['grade'],
        'passed': subjectGradeAndStatus['passed'],
      });
    }

    return subjectResults;
  }

  Map<String, dynamic> _calculateOverallResult(
    List<Map<String, dynamic>> subjectResults,
    List<Grade> grades,
  ) {
    final examAnalyticsService = ExamAnalyticsService();

    final overallResult = examAnalyticsService.getOverallExamResult(
      subjectResults: subjectResults.map((e) => {
        'marksObtained': e['marks_obtained'],
        'maxMarks': e['max_marks'],
        'passed': e['passed'],
      }).toList(),
      grades: grades,
    );

    // Add total marks for display
    int totalMarksObtained = 0;
    int totalMaxMarks = 0;

    for (var result in subjectResults) {
      totalMarksObtained += result['marks_obtained'] as int;
      totalMaxMarks += result['max_marks'] as int;
    }

    return {
      ...overallResult,
      'totalMarksObtained': totalMarksObtained,
      'totalMaxMarks': totalMaxMarks,
    };
  }
}
