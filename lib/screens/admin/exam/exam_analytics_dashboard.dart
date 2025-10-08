import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../models/exam.dart';
import '../../../l10n/gen/app_localizations.dart';

class ExamAnalyticsDashboard extends StatefulWidget {
  const ExamAnalyticsDashboard({super.key});

  @override
  _ExamAnalyticsDashboardState createState() => _ExamAnalyticsDashboardState();
}

class _ExamAnalyticsDashboardState extends State<ExamAnalyticsDashboard>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  Exam? _selectedExam;
  Map<String, dynamic> _schoolPerformance = {};
  Map<String, dynamic> _classPerformance = {};
  List<dynamic> _subjectPerformance = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id;

    if (schoolId != null) {
      await examProvider.fetchExams(schoolId.toString());
      await classProvider.fetchClasses(schoolId.toString());

      if (examProvider.exams.isNotEmpty) {
        _selectedExam = examProvider.exams.first;
        await _fetchPerformanceData();
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _slideController.forward();
    }
  }

  Future<void> _fetchPerformanceData() async {
    if (_selectedExam == null) return;

    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id;

    if (schoolId != null) {
      _schoolPerformance = await examProvider.examService.getSchoolPerformanceOverview(schoolId);
      _classPerformance = await examProvider.examService.getClassPerformanceOverview(_selectedExam!.classId);
      _subjectPerformance = await examProvider.examService.getSubjectPerformance(
        schoolId: schoolId,
        classId: _selectedExam!.classId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exam Analytics',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? _buildLoadingState()
            : FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_slideController),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildExamSelector(examProvider.exams),
                        if (_selectedExam != null) ...[
                          const SizedBox(height: 24),
                          _buildOverviewCards(),
                          const SizedBox(height: 24),
                          _buildPerformanceChart(),
                          const SizedBox(height: 24),
                          _buildSubjectPerformanceChart(),
                        ],
                      ],
                    ),
                  ),
                ),
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
            width: 100,
            height: 100,
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
              Icons.analytics,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Analytics...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamSelector(List<Exam> exams) {
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
                  Icons.assignment,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Select Exam',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Exam>(
              value: _selectedExam,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: exams.map((exam) {
                return DropdownMenuItem(
                  value: exam,
                  child: Text('${exam.name} - ${exam.examDate.toLocal().toString().split(' ')[0]}'),
                );
              }).toList(),
              onChanged: (exam) {
                setState(() {
                  _selectedExam = exam;
                  if (exam != null) {
                    _fetchPerformanceData();
                  }
                });
              },
              hint: const Text('Select an exam to view analytics'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Average Score',
            '${_classPerformance['average_score']?.toStringAsFixed(1) ?? '0'}%',
            Icons.score,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Pass Rate',
            '${_classPerformance['pass_rate']?.toStringAsFixed(1) ?? '0'}%',
            Icons.verified,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Total Students',
            '${_classPerformance['total_students'] ?? 0}',
            Icons.people,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
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
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
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
                  'Grade Distribution',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: _buildGradeDistributionChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeDistributionChart() {
    final gradeData = _getGradeDistributionData();

    if (gradeData.isEmpty) {
      return const Center(
        child: Text('No grade distribution data available'),
      );
    }

    return Column(
      children: [
        Row(
          children: gradeData.entries.map((entry) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Column(
                  children: [
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: _getGradeColor(entry.key).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getGradeColor(entry.key),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            flex: (100 - (entry.value * 10)).toInt(),
                            child: Container(),
                          ),
                          Expanded(
                            flex: (entry.value * 10).toInt(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _getGradeColor(entry.key),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.key,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getGradeColor(entry.key),
                      ),
                    ),
                    Text(
                      '${entry.value} students',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSubjectPerformanceChart() {
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
                  'Subject Performance',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: _buildSubjectPerformanceChartData(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectPerformanceChartData() {
    if (_subjectPerformance.isEmpty) {
      return const Center(
        child: Text('No subject performance data available'),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: _subjectPerformance.length,
      itemBuilder: (context, index) {
        final subject = _subjectPerformance[index];
        final averageScore = (subject['average_score'] ?? 0).toDouble();

        return Container(
          width: 200,
          margin: const EdgeInsets.only(right: 16),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    subject['subject_name'] ?? 'Unknown',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: CircularProgressIndicator(
                            value: averageScore / 100,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              averageScore >= 80 ? Colors.green :
                              averageScore >= 60 ? Colors.orange : Colors.red,
                            ),
                          ),
                        ),
                        Text(
                          '${averageScore.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Avg Score',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Map<String, int> _getGradeDistributionData() {
    final Map<String, int> gradeDistribution = {};

    if (_classPerformance['grade_distribution'] != null) {
      final distribution = _classPerformance['grade_distribution'] as Map;
      distribution.forEach((grade, count) {
        gradeDistribution[grade] = count as int;
      });
    }

    return gradeDistribution;
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.orange;
      case 'D':
        return Colors.yellow;
      case 'F':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
