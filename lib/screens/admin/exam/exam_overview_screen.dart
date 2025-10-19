import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../theme/app_theme.dart';

class ExamOverviewScreen extends StatefulWidget {
  const ExamOverviewScreen({super.key});

  @override
  State<ExamOverviewScreen> createState() => _ExamOverviewScreenState();
}

class _ExamOverviewScreenState extends State<ExamOverviewScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);

      if (schoolProvider.currentSchool != null) {
        await examProvider.fetchExams(schoolProvider.currentSchool!.id.toString());
        await examProvider.fetchGrades(schoolProvider.currentSchool!.id.toString());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Management'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ExamProvider>(
              builder: (context, examProvider, _) {
                final exams = examProvider.exams;
                final upcomingCount = exams.where((e) => e.examDate.isAfter(DateTime.now())).length;
                final completedCount = exams.where((e) => e.examDate.isBefore(DateTime.now())).length;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Total Exams',
                              exams.length.toString(),
                              Icons.assignment,
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Upcoming',
                              upcomingCount.toString(),
                              Icons.schedule,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Completed',
                              completedCount.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              'Grades',
                              examProvider.grades.length.toString(),
                              Icons.grade,
                              Colors.purple,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Main Actions
                      const Text(
                        'Quick Actions',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      _buildActionCard(
                        title: 'Manage Exams',
                        subtitle: 'View, create, and edit exams',
                        icon: Icons.list_alt,
                        color: Colors.blue,
                        onTap: () => context.push('/admin/exam-management'),
                      ),
                      const SizedBox(height: 12),

                      _buildActionCard(
                        title: 'Create New Exam',
                        subtitle: 'Set up a new exam',
                        icon: Icons.add_circle,
                        color: Colors.green,
                        onTap: () => context.push('/admin/exam-form'),
                      ),
                      const SizedBox(height: 12),

                      _buildActionCard(
                        title: 'Manage Subjects',
                        subtitle: 'Add or edit subjects',
                        icon: Icons.subject,
                        color: Colors.orange,
                        onTap: () => context.push('/admin/subject-management'),
                      ),
                      const SizedBox(height: 12),

                      _buildActionCard(
                        title: 'Manage Grades',
                        subtitle: 'Configure grading system',
                        icon: Icons.grade,
                        color: Colors.purple,
                        onTap: () => context.push('/admin/grade-management'),
                      ),
                      const SizedBox(height: 12),

                      _buildActionCard(
                        title: 'Exam Calendar',
                        subtitle: 'View exam schedule',
                        icon: Icons.calendar_month,
                        color: Colors.teal,
                        onTap: () => context.push('/admin/exam-calendar'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
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
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
