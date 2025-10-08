import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/exam.dart';
import '../../../models/school_class.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../exam/widgets/exam_filters_widget.dart';
import '../../common/error_display.dart';
import '../../../models/exam_status.dart';

enum SortColumn { name, className, date, status, examiner }
enum SortOrder { ascending, descending }

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedExams = {};
  final ScrollController _scrollController = ScrollController();

  ExamStatus _selectedStatus = ExamStatus.upcoming;
  SortColumn _sortColumn = SortColumn.date;
  SortOrder _sortOrder = SortOrder.descending;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  final int _itemsPerPage = 10;

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
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id.toString();

      if (schoolId != null) {
        // Load exams and classes
        await Future.wait([
          Provider.of<ExamProvider>(context, listen: false).fetchExams(schoolId),
          Provider.of<ClassProvider>(context, listen: false).fetchClasses(schoolId),
        ]);

        _classes = Provider.of<ClassProvider>(context, listen: false).classes;
        _filterExams();
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterExams() {
    final exams = Provider.of<ExamProvider>(context, listen: false).exams;
    final query = _searchController.text.toLowerCase();

    final filtered = exams.where((exam) {
      // Status filter
      final status = _getExamStatus(exam);
      if (_selectedStatus != status) return false;

      // Search filter
      if (query.isEmpty) return true;

      final className = _getClassName(exam.classId);
      return exam.name.toLowerCase().contains(query) ||
             className.toLowerCase().contains(query) ||
             exam.examinerName.toLowerCase().contains(query);
    }).toList();

    // Sort exams
    _filteredExams = _sortExams(filtered);
    _currentPage = 1; // Reset to first page when filtering
  }

  void _sortExamsBy(SortColumn column) {
    if (_sortColumn == column) {
      _sortOrder = _sortOrder == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending;
    } else {
      _sortColumn = column;
      _sortOrder = SortOrder.ascending;
    }
    _filterExams();
  }

  List<Exam> _sortExams(List<Exam> exams) {
    exams.sort((a, b) {
      int comparison = 0;

      switch (_sortColumn) {
        case SortColumn.name:
          comparison = a.name.compareTo(b.name);
          break;
        case SortColumn.className:
          comparison = _getClassName(a.classId).compareTo(_getClassName(b.classId));
          break;
        case SortColumn.date:
          comparison = a.examDate.compareTo(b.examDate);
          break;
        case SortColumn.status:
          comparison = _getExamStatus(a).index.compareTo(_getExamStatus(b).index);
          break;
        case SortColumn.examiner:
          comparison = a.examinerName.compareTo(b.examinerName);
          break;
      }

      return _sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return exams;
  }

  ExamStatus _getExamStatus(Exam exam) {
    final now = DateTime.now();
    final examDate = exam.examDate;

    if (examDate.isAfter(now.add(const Duration(days: 1)))) {
      return ExamStatus.upcoming;
    } else if (examDate.isBefore(now.subtract(const Duration(days: 1)))) {
      return ExamStatus.completed;
    } else {
      return ExamStatus.ongoing;
    }
  }

  String _getClassName(int classId) {
    final schoolClass = _classes.where((c) => c.id == classId).firstOrNull;
    return schoolClass?.name ?? 'Class $classId';
  }

  Widget _buildSortButton(String label, SortColumn column) {
    final isActive = _sortColumn == column;
    final icon = isActive
        ? (_sortOrder == SortOrder.ascending ? Icons.arrow_upward : Icons.arrow_downward)
        : Icons.sort;

    return TextButton.icon(
      onPressed: () => _sortExamsBy(column),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: TextButton.styleFrom(
        foregroundColor: isActive ? AppTheme.getAccentColorForContext('form') : null,
      ),
    );
  }

  Widget _buildStatusBadge(Exam exam) {
    final status = _getExamStatus(exam);
    final color = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        _getStatusText(status),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
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

  List<Exam> _getCurrentPageExams() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _filteredExams.length);
    return _filteredExams.sublist(startIndex, endIndex);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accentColor = AppTheme.getAccentColorForContext('form');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Management'),
        actions: [
          if (_selectedExams.isNotEmpty)
            TextButton.icon(
              onPressed: _deleteSelectedExams,
              icon: const Icon(Icons.delete),
              label: Text('Delete (${_selectedExams.length})'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          ExamFiltersWidget(
            searchController: _searchController,
            selectedStatus: _selectedStatus,
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
              _filterExams();
            },
            onClearFilters: () {
              _searchController.clear();
              setState(() => _selectedStatus = ExamStatus.upcoming);
              _filterExams();
            },
          ),

          // Results Summary
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Showing ${_filteredExams.length} exams',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                if (_selectedExams.isNotEmpty)
                  Text(
                    '${_selectedExams.length} selected',
                    style: TextStyle(color: accentColor),
                  ),
              ],
            ),
          ),

          // Loading/Error States
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            Expanded(
              child: ErrorDisplay(
                message: _errorMessage!,
                onRetry: _loadData,
              ),
            )
          else
            // Data Table
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: DataTable(
                    columns: [
                      DataColumn(
                        label: Checkbox(
                          value: _selectedExams.length == _filteredExams.length &&
                                 _filteredExams.isNotEmpty,
                          onChanged: (value) => _toggleSelectAll(value ?? false),
                        ),
                      ),
                      DataColumn(
                        label: _buildSortButton('Name', SortColumn.name),
                      ),
                      DataColumn(
                        label: _buildSortButton('Class', SortColumn.className),
                      ),
                      DataColumn(
                        label: _buildSortButton('Date', SortColumn.date),
                      ),
                      DataColumn(
                        label: _buildSortButton('Status', SortColumn.status),
                      ),
                      DataColumn(
                        label: _buildSortButton('Examiner', SortColumn.examiner),
                      ),
                      const DataColumn(label: Text('Actions')),
                    ],
                    rows: _getCurrentPageExams().map((exam) {
                      return DataRow(
                        selected: _selectedExams.contains(exam.id),
                        cells: [
                          DataCell(
                            Checkbox(
                              value: _selectedExams.contains(exam.id),
                              onChanged: (value) => _toggleExamSelection(exam.id, value ?? false),
                            ),
                          ),
                          DataCell(Text(exam.name)),
                          DataCell(Text(_getClassName(exam.classId))),
                          DataCell(Text(
                            '${exam.examDate.day}/${exam.examDate.month}/${exam.examDate.year}',
                          )),
                          DataCell(_buildStatusBadge(exam)),
                          DataCell(Text(exam.examinerName)),
                          DataCell(
                            PopupMenuButton<String>(
                              onSelected: (action) => _handleExamAction(action, exam),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Text('View Details'),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

          // Pagination
          if (_filteredExams.length > _itemsPerPage)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    'Page $_currentPage of ${(_filteredExams.length / _itemsPerPage).ceil()}',
                  ),
                  IconButton(
                    onPressed: _currentPage < (_filteredExams.length / _itemsPerPage).ceil()
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateExam,
        backgroundColor: accentColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _toggleSelectAll(bool selected) {
    setState(() {
      if (selected) {
        _selectedExams.addAll(_filteredExams.map((e) => e.id));
      } else {
        _selectedExams.clear();
      }
    });
  }

  void _toggleExamSelection(String examId, bool selected) {
    setState(() {
      if (selected) {
        _selectedExams.add(examId);
      } else {
        _selectedExams.remove(examId);
      }
    });
  }

  void _handleExamAction(String action, Exam exam) {
    switch (action) {
      case 'edit':
        _navigateToEditExam(exam);
        break;
      case 'view':
        _showExamDetails(exam);
        break;
      case 'delete':
        _deleteExam(exam);
        break;
    }
  }

  Future<void> _deleteSelectedExams() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Exams'),
        content: Text('Are you sure you want to delete ${_selectedExams.length} exams?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
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
          for (final examId in _selectedExams) {
            await examProvider.deleteExam(examId, schoolId);
          }
          _selectedExams.clear();
          _loadData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting exams: $e')),
        );
      }
    }
  }

  void _navigateToCreateExam() {
    Navigator.of(context).pushNamed('/admin/exams/create');
  }

  void _navigateToEditExam(Exam exam) {
    Navigator.of(context).pushNamed('/admin/exams/edit', arguments: exam);
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
            Text('Class: ${_getClassName(exam.classId)}'),
            Text('Date: ${exam.examDate.day}/${exam.examDate.month}/${exam.examDate.year}'),
            Text('Examiner: ${exam.examinerName}'),
            if (exam.description != null) Text('Description: ${exam.description}'),
            if (exam.maxMarks != null) Text('Max Marks: ${exam.maxMarks}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
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
          _loadData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting exam: $e')),
        );
      }
    }
  }
}