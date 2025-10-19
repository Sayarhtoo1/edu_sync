import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../models/exam.dart';
import '../../../models/school_class.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/exam_status.dart';
import 'edit_exam_basic_screen.dart';
import 'edit_exam_classes_screen.dart';
import 'edit_exam_subjects_screen.dart';


class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
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
        if (_selectedStatus != null && _getExamStatus(exam) != _selectedStatus) {
          return false;
        }
        if (query.isEmpty) return true;
        return exam.name.toLowerCase().contains(query) ||
               exam.examinerName.toLowerCase().contains(query);
      }).toList()
        ..sort((a, b) => b.examDate.compareTo(a.examDate));
    });
  }

  ExamStatus _getExamStatus(Exam exam) {
    final now = DateTime.now();
    if (exam.examDate.isAfter(now.add(const Duration(days: 1)))) {
      return ExamStatus.upcoming;
    } else if (exam.examDate.isBefore(now.subtract(const Duration(days: 1)))) {
      return ExamStatus.completed;
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exams'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: defaultAccentColor.withOpacity(0.05),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search exams...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterExams();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', null),
                      const SizedBox(width: 8),
                      _buildFilterChip('Upcoming', ExamStatus.upcoming),
                      const SizedBox(width: 8),
                      _buildFilterChip('Ongoing', ExamStatus.ongoing),
                      const SizedBox(width: 8),
                      _buildFilterChip('Completed', ExamStatus.completed),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  '${_filteredExams.length} ${_filteredExams.length == 1 ? 'exam' : 'exams'}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),

          // Exam List
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
                            if (_searchController.text.isEmpty && _selectedStatus == null) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Create your first exam',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredExams.length,
                        itemBuilder: (context, index) => _buildExamCard(_filteredExams[index]),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed('/admin/exams/create').then((_) => _loadData()),
        icon: const Icon(Icons.add),
        label: const Text('Create Exam'),
        backgroundColor: defaultAccentColor,
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
      selectedColor: defaultAccentColor.withOpacity(0.2),
      checkmarkColor: defaultAccentColor,
    );
  }

  Widget _buildExamCard(Exam exam) {
    final status = _getExamStatus(exam);
    final statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

          // Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.class_, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(_getClassInfo(exam)),
                    const Spacer(),
                    Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text('${exam.examDate.day}/${exam.examDate.month}/${exam.examDate.year}'),
                  ],
                ),
                if (exam.description != null && exam.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    exam.description!,
                    style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.edit_note,
                  label: 'Marks',
                  color: Colors.blue,
                  onTap: () => context.pushNamed('marks-entry', pathParameters: {'examId': exam.id}),
                ),
                _buildActionButton(
                  icon: Icons.assessment,
                  label: 'Reports',
                  color: Colors.green,
                  onTap: () => context.pushNamed('all-report-cards', pathParameters: {'examId': exam.id}),
                ),
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'Edit',
                  color: Colors.orange,
                  onTap: () => _showEditOptions(exam),
                ),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Delete',
                  color: Colors.red,
                  onTap: () => _deleteExam(exam),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditOptions(Exam exam) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Edit ${exam.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text('Basic Information'),
              subtitle: const Text('Name, date, examiner'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditExamBasicScreen(exam: exam),
                  ),
                ).then((_) => _loadData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.class_, color: Colors.orange),
              title: const Text('Classes'),
              subtitle: const Text('Manage exam classes'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditExamClassesScreen(exam: exam),
                  ),
                ).then((_) => _loadData());
              },
            ),
            ListTile(
              leading: const Icon(Icons.subject, color: Colors.green),
              title: const Text('Subjects'),
              subtitle: const Text('Manage exam subjects'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditExamSubjectsScreen(exam: exam),
                  ),
                ).then((_) => _loadData());
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
        content: Text('Are you sure you want to delete "${exam.name}"? This action cannot be undone.'),
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
        return Colors.blue;
      case ExamStatus.ongoing:
        return Colors.orange;
      case ExamStatus.completed:
        return Colors.green;
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

