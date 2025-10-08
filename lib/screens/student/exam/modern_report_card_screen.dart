import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../l10n/gen/app_localizations.dart';
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
        studentId: widget.studentId,
        examId: widget.examId,
        schoolId: schoolId,
      );
      await examProvider.fetchGrades(schoolId.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderCard(studentName, examName),
          const SizedBox(height: 24),
          _buildOverallSummaryCard(overallResult),
          const SizedBox(height: 24),
          _buildSubjectsCard(subjectResults),
          const SizedBox(height: 24),
          _buildPerformanceChart(overallResult),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(String studentName, String examName) {
    return Card(
      elevation: 8,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student Report Card',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                examName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallSummaryCard(Map<String, dynamic> overallResult) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Overall Summary',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Score',
                    '${overallResult['totalMarksObtained']}/${overallResult['totalMaxMarks']}',
                    Icons.score,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Percentage',
                    '${overallResult['overallPercentage'].toStringAsFixed(1)}%',
                    Icons.percent,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Grade',
                    overallResult['overallGrade'],
                    Icons.grade,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: (overallResult['overallPassed'] as bool)
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: (overallResult['overallPassed'] as bool)
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    (overallResult['overallPassed'] as bool)
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: (overallResult['overallPassed'] as bool)
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (overallResult['overallPassed'] as bool) ? 'PASSED' : 'FAILED',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: (overallResult['overallPassed'] as bool)
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsCard(List<Map<String, dynamic>> subjectResults) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.subject,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Subject-wise Performance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: subjectResults.length,
              itemBuilder: (context, index) {
                final subject = subjectResults[index];
                return _buildSubjectItem(subject);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectItem(Map<String, dynamic> subject) {
    final double percentage = subject['percentage'] as double;
    final bool passed = subject['passed'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: passed ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: passed ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject['subject_name'] ?? 'Unknown Subject',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green.shade800 : Colors.red.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${subject['marks_obtained']}/${subject['max_marks']} marks',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: passed ? Colors.green.shade600 : Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: passed ? Colors.green.shade100 : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  subject['grade'] ?? 'N/A',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart(Map<String, dynamic> overallResult) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Performance Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildPerformanceGauge(overallResult['overallPercentage'] as double),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceGauge(double percentage) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  percentage >= 80 ? Colors.green :
                  percentage >= 60 ? Colors.orange :
                  percentage >= 40 ? Colors.yellow : Colors.red,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  'Overall',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
