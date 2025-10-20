import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/exam.dart';
import 'package:edu_sync/models/school_class.dart';
import 'package:edu_sync/models/exam_status.dart';
import 'package:edu_sync/providers/exam_provider.dart';
import 'package:edu_sync/providers/class_provider.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopExamList extends StatefulWidget {
  const DesktopExamList({super.key});

  @override
  State<DesktopExamList> createState() => _DesktopExamListState();
}

class _DesktopExamListState extends State<DesktopExamList> {
  final TextEditingController _searchController = TextEditingController();
  ExamStatus? _selectedStatus;
  bool _isLoading = false;
  List<Exam> _filteredExams = [];
  List<SchoolClass> _classes = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterExams);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id.toString();

      if (schoolId != null) {
        await Future.wait([
          Provider.of<ExamProvider>(context, listen: false).fetchExams(schoolId),
          Provider.of<ClassProvider>(context, listen: false).fetchClasses(schoolId),
        ]);
        _classes = Provider.of<ClassProvider>(context, listen: false).classes;
        _filterExams();
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

  void _filterExams() {
    final exams = Provider.of<ExamProvider>(context, listen: false).exams;
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredExams = exams.where((exam) {
        if (_selectedStatus != null && _getExamStatus(exam) != _selectedStatus) return false;
        if (query.isEmpty) return true;
        return exam.name.toLowerCase().contains(query) || exam.examinerName.toLowerCase().contains(query);
      }).toList()..sort((a, b) => b.examDate.compareTo(a.examDate));
    });
  }

  ExamStatus _getExamStatus(Exam exam) {
    final now = DateTime.now();
    if (exam.examDate.isAfter(now.add(const Duration(days: 1)))) return ExamStatus.upcoming;
    if (exam.examDate.isBefore(now.subtract(const Duration(days: 1)))) return ExamStatus.completed;
    return ExamStatus.ongoing;
  }

  String _getClassInfo(Exam exam) {
    if (exam.examClasses != null && exam.examClasses!.isNotEmpty) {
      if (exam.examClasses!.length == 1) {
        final schoolClass = _classes.where((c) => c.id == exam.examClasses!.first.classId).firstOrNull;
        return schoolClass?.name ?? 'Class ${exam.examClasses!.first.classId}';
      }
      return '${exam.examClasses!.length} Classes';
    }
    final schoolClass = _classes.where((c) => c.id == exam.classId).firstOrNull;
    return schoolClass?.name ?? 'Class ${exam.classId}';
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Exam List',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadData,
          tooltip: 'Refresh',
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => context.pushNamed('exam-form').then((_) => _loadData()),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Create Exam'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search exams...',
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF3498DB)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _filterExams();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                _buildFilterChip('All', null),
                const SizedBox(width: 12),
                _buildFilterChip('Upcoming', ExamStatus.upcoming),
                const SizedBox(width: 12),
                _buildFilterChip('Ongoing', ExamStatus.ongoing),
                const SizedBox(width: 12),
                _buildFilterChip('Completed', ExamStatus.completed),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_filteredExams.length} ${_filteredExams.length == 1 ? 'exam' : 'exams'}',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF3498DB)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredExams.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty || _selectedStatus != null
                                  ? 'No exams found'
                                  : 'No exams yet',
                              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 380,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: _filteredExams.length,
                        itemBuilder: (context, index) => _buildExamCard(_filteredExams[index]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ExamStatus? status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedStatus = selected ? status : null);
        _filterExams();
      },
      selectedColor: const Color(0xFF3498DB).withOpacity(0.2),
      checkmarkColor: const Color(0xFF3498DB),
    );
  }

  Widget _buildExamCard(Exam exam) {
    final status = _getExamStatus(exam);
    final statusColor = _getStatusColor(status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showExamDetails(exam),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment, color: statusColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _getStatusText(status),
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.class_, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(_getClassInfo(exam), style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text('${exam.examDate.day}/${exam.examDate.month}/${exam.examDate.year}', style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note, size: 20),
                          onPressed: () => context.pushNamed('marks-entry', pathParameters: {'examId': exam.id}).then((_) => _loadData()),
                          tooltip: 'Marks',
                          color: Colors.blue,
                        ),
                        IconButton(
                          icon: const Icon(Icons.assessment, size: 20),
                          onPressed: () => context.pushNamed('all-report-cards', pathParameters: {'examId': exam.id}),
                          tooltip: 'Reports',
                          color: Colors.green,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => _showEditOptions(exam),
                          tooltip: 'Edit',
                          color: Colors.orange,
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => _deleteExam(exam),
                          tooltip: 'Delete',
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExamDetails(Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exam.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Class: ${_getClassInfo(exam)}'),
            Text('Date: ${exam.examDate.day}/${exam.examDate.month}/${exam.examDate.year}'),
            Text('Examiner: ${exam.examinerName}'),
            if (exam.description != null && exam.description!.isNotEmpty)
              const SizedBox(height: 8),
              Text('Description: ${exam.description}'),
            ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditOptions(Exam exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${exam.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info, color: Color(0xFF3498DB)),
              title: const Text('Basic Information'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('edit-exam-basic', extra: exam).then((_) => _loadData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.class_, color: Color(0xFF9B59B6)),
              title: const Text('Classes & Schedule'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('edit-exam-classes', extra: exam).then((_) => _loadData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.subject, color: Color(0xFF2ECC71)),
              title: const Text('Subjects'),
              onTap: () {
                Navigator.pop(context);
                context.pushNamed('edit-exam-subjects', extra: exam).then((_) => _loadData());
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteExam(Exam exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exam'),
        content: Text('Are you sure you want to delete "${exam.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final examProvider = Provider.of<ExamProvider>(context, listen: false);
        final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
        final schoolId = schoolProvider.currentSchool?.id.toString();

        if (schoolId != null) {
          await examProvider.deleteExam(exam.id, schoolId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exam deleted successfully')),
            );
          }
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Color _getStatusColor(ExamStatus status) {
    switch (status) {
      case ExamStatus.upcoming:
        return const Color(0xFF3498DB);
      case ExamStatus.ongoing:
        return const Color(0xFFF39C12);
      case ExamStatus.completed:
        return const Color(0xFF2ECC71);
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(ExamStatus status) {
    switch (status) {
      case ExamStatus.upcoming:
        return 'Upcoming';
      case ExamStatus.ongoing:
        return 'Ongoing';
      case ExamStatus.completed:
        return 'Completed';
      default:
        return 'Unknown';
    }
  }
}
