import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../providers/exam_provider.dart';
import '../../providers/school_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/exam.dart';
import '../common/empty_state.dart';

class ExamManagementScreen extends StatefulWidget {
  const ExamManagementScreen({super.key});

  @override
  State<ExamManagementScreen> createState() => _ExamManagementScreenState();
}

class _ExamManagementScreenState extends State<ExamManagementScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

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
    }
  }

  List<Exam> _getFilteredExams() {
    final examProvider = Provider.of<ExamProvider>(context);
    List<Exam> filteredExams = examProvider.exams;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredExams = filteredExams.where((exam) {
        return exam.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               exam.examinerName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by status
    if (_selectedFilter != 'All') {
      final now = DateTime.now();
      if (_selectedFilter == 'Upcoming') {
        filteredExams = filteredExams.where((exam) => exam.examDate.isAfter(now)).toList();
      } else if (_selectedFilter == 'Completed') {
        filteredExams = filteredExams.where((exam) => exam.examDate.isBefore(now)).toList();
      } else if (_selectedFilter == 'Today') {
        filteredExams = filteredExams.where((exam) {
          return exam.examDate.year == now.year &&
                 exam.examDate.month == now.month &&
                 exam.examDate.day == now.day;
        }).toList();
      }
    }

    // Sort by date (newest first)
    filteredExams.sort((a, b) => b.examDate.compareTo(a.examDate));
    return filteredExams;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Management'),
        backgroundColor: appBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/exam-management/create'),
            tooltip: 'Add Exam',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadData,
              child: Consumer<ExamProvider>(
                builder: (context, examProvider, child) {
                  if (examProvider.exams.isEmpty && !examProvider.examService.toString().contains('loading')) {
                    return _buildEmptyState();
                  }

                  final filteredExams = _getFilteredExams();

                  if (filteredExams.isEmpty) {
                    return _buildNoResultsState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredExams.length,
                    itemBuilder: (context, index) {
                      final exam = filteredExams[index];
                      return _buildExamCard(exam);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search exams...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: appBackgroundColor,
        ),
      ),
    );
  }

  Widget _buildExamCard(Exam exam) {
    final isUpcoming = exam.examDate.isAfter(DateTime.now());
    final daysUntil = exam.examDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/exam-management/edit/${exam.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Examiner: ${exam.examinerName}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: textLightGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isUpcoming
                          ? accentTeachers.withOpacity(0.2)
                          : accentStudents.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      isUpcoming ? 'Upcoming' : 'Completed',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isUpcoming ? accentTeachers : accentStudents,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: textLightGrey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(exam.examDate),
                    style: const TextStyle(
                      fontSize: 14,
                      color: textDarkGrey,
                    ),
                  ),
                  if (isUpcoming) ...[
                    const SizedBox(width: 16),
                    Icon(
                      Icons.schedule,
                      size: 16,
                      color: accentTeachers,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      daysUntil == 0
                          ? 'Today'
                          : daysUntil == 1
                              ? 'Tomorrow'
                              : 'In $daysUntil days',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: accentTeachers,
                      ),
                    ),
                  ],
                ],
              ),
              if (exam.description != null && exam.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  exam.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textLightGrey,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => context.push('/exam-management/edit/${exam.id}'),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: TextButton.styleFrom(
                      foregroundColor: defaultAccentColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showDeleteDialog(exam),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => context.push('/input-marks/${exam.id}'),
                    icon: const Icon(Icons.grade, size: 16),
                    label: const Text('Input Marks'),
                    style: TextButton.styleFrom(
                      foregroundColor: accentEarnings,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.assignment_outlined,
      message: 'No exams found',
      description: 'Create your first exam to get started with the exam management system.',
      action: ElevatedButton.icon(
        onPressed: () => context.push('/exam-management/create'),
        icon: const Icon(Icons.add),
        label: const Text('Create Exam'),
        style: ElevatedButton.styleFrom(
          backgroundColor: defaultAccentColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return EmptyState(
      icon: Icons.search_off,
      message: 'No exams match your search',
      description: 'Try adjusting your search terms or filters.',
      action: TextButton.icon(
        onPressed: () {
          setState(() {
            _searchQuery = '';
            _selectedFilter = 'All';
          });
        },
        icon: const Icon(Icons.clear),
        label: const Text('Clear Filters'),
        style: TextButton.styleFrom(
          foregroundColor: defaultAccentColor,
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Filter Exams'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('All Exams'),
                value: 'All',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Upcoming'),
                value: 'Upcoming',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Completed'),
                value: 'Completed',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('Today'),
                value: 'Today',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(Exam exam) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Exam'),
          content: Text('Are you sure you want to delete "${exam.name}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<ExamProvider>(context, listen: false)
                    .deleteExam(exam.id, context.read<SchoolProvider>().currentSchool!.id.toString());
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}