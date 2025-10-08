import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/exam_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../theme/app_theme.dart';
import '../../common/loading_skeleton.dart';
import '../../common/error_display.dart';
import '../../common/empty_state.dart';
import 'widgets/statistics_cards_widget.dart';
import 'widgets/recent_activity_widget.dart';
import 'widgets/performance_overview_widget.dart';
import 'widgets/quick_actions_widget.dart';

class ExamOverviewScreen extends StatefulWidget {
  const ExamOverviewScreen({super.key});

  @override
  State<ExamOverviewScreen> createState() => _ExamOverviewScreenState();
}

class _ExamOverviewScreenState extends State<ExamOverviewScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);

      if (schoolProvider.currentSchool != null) {
        await examProvider.fetchExams(schoolProvider.currentSchool!.id.toString());
        await examProvider.fetchSubjects(schoolProvider.currentSchool!.id.toString());
        await examProvider.fetchGrades(schoolProvider.currentSchool!.id.toString());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: ErrorDisplay(
          message: 'Failed to load exam data',
          description: _error!,
          onRetry: _loadData,
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _isLoading ? _buildLoadingView() : _buildDashboardContent(),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Exam Overview'),
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
                      'Comprehensive exam tracking and analysis',
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

  Widget _buildLoadingView() {
    return Column(
      children: [
        LoadingSkeleton(height: 120),
        const SizedBox(height: 24),
        LoadingSkeleton(height: 200),
        const SizedBox(height: 24),
        LoadingSkeleton(height: 150),
        const SizedBox(height: 24),
        LoadingSkeleton(height: 120),
      ],
    );
  }

  Widget _buildDashboardContent() {
    final schoolProvider = Provider.of<SchoolProvider>(context);
    if (schoolProvider.currentSchool == null) {
      return const EmptyState(
        icon: Icons.school_outlined,
        message: 'No school selected',
        description: 'Please select a school to view exam data',
      );
    }

    return Consumer<ExamProvider>(
      builder: (context, examProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatisticsCardsWidget(examProvider: examProvider),
            const SizedBox(height: 32),
            QuickActionsWidget(),
            const SizedBox(height: 32),
            RecentActivityWidget(examProvider: examProvider),
            const SizedBox(height: 32),
            PerformanceOverviewWidget(examProvider: examProvider),
          ],
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () => context.push('/exam-management/create'),
      icon: const Icon(Icons.add),
      label: const Text('Create Exam'),
      backgroundColor: defaultAccentColor,
    );
  }
}