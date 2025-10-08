import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../providers/exam_provider.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/exam.dart';
import '../common/empty_state.dart';

class ExamOverviewDashboard extends StatefulWidget {
  const ExamOverviewDashboard({super.key});

  @override
  State<ExamOverviewDashboard> createState() => _ExamOverviewDashboardState();
}

class _ExamOverviewDashboardState extends State<ExamOverviewDashboard> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);

    if (schoolProvider.currentSchool != null) {
      await examProvider.fetchExams(schoolProvider.currentSchool!.id.toString());
      await examProvider.fetchSubjects(schoolProvider.currentSchool!.id.toString());
      await examProvider.fetchGrades(schoolProvider.currentSchool!.id.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context);
    final schoolProvider = Provider.of<SchoolProvider>(context);

    if (schoolProvider.currentSchool == null) {
      return const Scaffold(
        body: Center(
          child: Text('No school selected'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Management'),
        backgroundColor: appBackgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => context.push('/exam-analytics'),
            tooltip: 'Exam Analytics',
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/exam-settings'),
            tooltip: 'Exam Settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatisticsCards(),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 32),
              _buildRecentExams(),
              const SizedBox(height: 32),
              _buildUpcomingExams(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/exam-management/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create Exam'),
        backgroundColor: defaultAccentColor,
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            defaultAccentColor.withOpacity(0.8),
            defaultAccentColor.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 32,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Exam Management System',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Manage exams, subjects, marks, and reports',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Exams',
                examProvider.exams.length.toString(),
                Icons.assignment,
                accentStudents,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Subjects',
                examProvider.subjects.length.toString(),
                Icons.subject,
                accentTeachers,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Grade Levels',
                examProvider.grades.length.toString(),
                Icons.grade,
                accentEarnings,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: textLightGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Manage Exams',
                'Create and edit exams',
                Icons.edit_calendar,
                () => context.push('/exam-management'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Input Marks',
                'Enter student marks',
                Icons.grade_outlined,
                () => context.push('/input-marks'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Manage Subjects',
                'Add/edit subjects',
                Icons.subject,
                () => context.push('/subject-management'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Grade Settings',
                'Configure grading',
                Icons.settings,
                () => context.push('/grade-management'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: defaultAccentColor),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: textLightGrey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentExams() {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Exams',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            examProvider.exams.isEmpty
                ? const EmptyState(
                    icon: Icons.assignment_outlined,
                    message: 'No exams created yet',
                    description: 'Create your first exam to get started',
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: examProvider.exams.length > 3 ? 3 : examProvider.exams.length,
                    itemBuilder: (context, index) {
                      final exam = examProvider.exams[index];
                      return _buildExamCard(exam);
                    },
                  ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingExams() {
    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        final upcomingExams = examProvider.exams
            .where((exam) => exam.examDate.isAfter(DateTime.now()))
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upcoming Exams',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            upcomingExams.isEmpty
                ? const EmptyState(
                    icon: Icons.schedule,
                    message: 'No upcoming exams',
                    description: 'All exams are completed or none scheduled',
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: upcomingExams.length > 3 ? 3 : upcomingExams.length,
                    itemBuilder: (context, index) {
                      final exam = upcomingExams[index];
                      return _buildExamCard(exam, isUpcoming: true);
                    },
                  ),
          ],
        );
      },
    );
  }

  Widget _buildExamCard(Exam exam, {bool isUpcoming = false}) {
    final daysUntil = exam.examDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isUpcoming
              ? accentTeachers.withOpacity(0.2)
              : accentStudents.withOpacity(0.2),
          child: Icon(
            isUpcoming ? Icons.schedule : Icons.assignment,
            color: isUpcoming ? accentTeachers : accentStudents,
          ),
        ),
        title: Text(
          exam.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Examiner: ${exam.examinerName}'),
            Text(
              isUpcoming
                  ? 'In $daysUntil days (${exam.examDate.toString().split(' ')[0]})'
                  : 'Completed on ${exam.examDate.toString().split(' ')[0]}',
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () => context.push('/exam-management/edit/${exam.id}'),
        ),
        onTap: () => context.push('/exam-management/edit/${exam.id}'),
      ),
    );
  }
}