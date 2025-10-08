import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/subject.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../common/error_display.dart';
import 'widgets/subject_card_widget.dart';
import 'widgets/subject_form_dialog.dart';

enum SortOption { name, className, maxMarks, passingMarks, created }
enum SortDirection { ascending, descending }

class SubjectManagementScreen extends StatefulWidget {
  const SubjectManagementScreen({super.key});

  @override
  State<SubjectManagementScreen> createState() => _SubjectManagementScreenState();
}

class _SubjectManagementScreenState extends State<SubjectManagementScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  SortOption _sortOption = SortOption.name;
  SortDirection _sortDirection = SortDirection.ascending;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showSearch = false;
  String _selectedClassId = '';
  final Set<String> _selectedSubjects = {};

  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterSubjects);

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _fabAnimationController.dispose();
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
        await Future.wait([
          Provider.of<ExamProvider>(context, listen: false).fetchSubjects(schoolId),
          Provider.of<ClassProvider>(context, listen: false).fetchClasses(schoolId),
        ]);
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterSubjects() {
    setState(() {});
  }

  List<Subject> get _filteredSubjects {
    final subjects = Provider.of<ExamProvider>(context).subjects;
    final query = _searchController.text.toLowerCase();

    var filtered = subjects.where((subject) {
      // Search filter
      if (query.isNotEmpty) {
        if (!subject.name.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Class filter
      if (_selectedClassId.isNotEmpty && subject.classId != _selectedClassId) {
        return false;
      }

      return true;
    }).toList();

    // Sort subjects
    filtered.sort((a, b) {
      int comparison = 0;

      switch (_sortOption) {
        case SortOption.name:
          comparison = a.name.compareTo(b.name);
          break;
        case SortOption.className:
          comparison = _getClassName(a.classId).compareTo(_getClassName(b.classId));
          break;
        case SortOption.maxMarks:
          comparison = (a.maxMarks ?? 0).compareTo(b.maxMarks ?? 0);
          break;
        case SortOption.passingMarks:
          comparison = (a.passingMarks ?? 0).compareTo(b.passingMarks ?? 0);
          break;
        case SortOption.created:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
      }

      return _sortDirection == SortDirection.ascending ? comparison : -comparison;
    });

    return filtered;
  }

  void _sortBy(SortOption option) {
    if (_sortOption == option) {
      _sortDirection = _sortDirection == SortDirection.ascending
          ? SortDirection.descending
          : SortDirection.ascending;
    } else {
      _sortOption = option;
      _sortDirection = SortDirection.ascending;
    }
    setState(() {});
  }

  String _getClassName(String classId) {
    final classProvider = Provider.of<ClassProvider>(context);
    final schoolClass = classProvider.classes.where((c) => c.id.toString() == classId).firstOrNull;
    return schoolClass?.name ?? 'Class $classId';
  }

  int get crossAxisCount {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) {
      return 4; // Large screens
    } else if (screenWidth >= 900) {
      return 3; // Medium screens
    } else if (screenWidth >= 600) {
      return 2; // Small screens
    } else {
      return 1; // Extra small screens
    }
  }

  Widget _buildSearchBar() {
    final theme = Theme.of(context);
    final accentColor = AppTheme.getAccentColorForContext('form');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search subjects...',
                    prefixIcon: Icon(Icons.search, color: accentColor),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: accentColor),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: accentColor, width: 2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => setState(() => _showSearch = !_showSearch),
                icon: Icon(
                  _showSearch ? Icons.filter_list_off : Icons.filter_list,
                  color: accentColor,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: accentColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          if (_showSearch) ...[
            const SizedBox(height: 16),
            _buildFilterChips(),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final classProvider = Provider.of<ClassProvider>(context);
    final classes = classProvider.classes;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // All Classes Filter
        FilterChip(
          label: const Text('All Classes'),
          selected: _selectedClassId.isEmpty,
          onSelected: (selected) {
            setState(() => _selectedClassId = '');
          },
          backgroundColor: accentStudents.withOpacity(0.1),
          selectedColor: accentStudents.withOpacity(0.2),
          checkmarkColor: iconColorStudents,
        ),
        // Class-specific filters
        ...classes.map((classItem) => FilterChip(
          label: Text(classItem.name),
          selected: _selectedClassId == classItem.id.toString(),
          onSelected: (selected) {
            setState(() => _selectedClassId = selected ? classItem.id.toString() : '');
          },
          backgroundColor: accentTeachers.withOpacity(0.1),
          selectedColor: accentTeachers.withOpacity(0.2),
          checkmarkColor: iconColorTeachers,
        )),
      ],
    );
  }

  Widget _buildSortBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: textLightGrey,
            ),
          ),
          const SizedBox(width: 8),
          _buildSortButton('Name', SortOption.name),
          _buildSortButton('Class', SortOption.className),
          _buildSortButton('Max Marks', SortOption.maxMarks),
          _buildSortButton('Passing', SortOption.passingMarks),
        ],
      ),
    );
  }

  Widget _buildSortButton(String label, SortOption option) {
    final isActive = _sortOption == option;
    final accentColor = AppTheme.getAccentColorForContext('form');

    return TextButton(
      onPressed: () => _sortBy(option),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isActive ? accentColor : textLightGrey,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          if (isActive) ...[
            const SizedBox(width: 4),
            Icon(
              _sortDirection == SortDirection.ascending
                  ? Icons.arrow_upward
                  : Icons.arrow_downward,
              size: 14,
              color: accentColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubjectGrid() {
    final filteredSubjects = _filteredSubjects;

    if (filteredSubjects.isEmpty) {
      return _buildEmptyState();
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredSubjects.length,
      itemBuilder: (context, index) {
        final subject = filteredSubjects[index];
        return SubjectCardWidget(
          subject: subject,
          className: _getClassName(subject.classId),
          isSelected: _selectedSubjects.contains(subject.id),
          onTap: () => _toggleSubjectSelection(subject.id),
          onEdit: () => _showEditSubjectDialog(subject),
          onDelete: () => _deleteSubject(subject),
          onToggleSelection: () => _toggleSubjectSelection(subject.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.subject,
            size: 80,
            color: textLightGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty || _selectedClassId.isNotEmpty
                ? 'No subjects match your filters'
                : 'No subjects found',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: textLightGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty || _selectedClassId.isNotEmpty
                ? 'Try adjusting your search or filters'
                : 'Add your first subject to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textLightGrey,
            ),
          ),
          if (_searchController.text.isEmpty && _selectedClassId.isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddSubjectDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Subject'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.getAccentColorForContext('form'),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _toggleSubjectSelection(String subjectId) {
    setState(() {
      if (_selectedSubjects.contains(subjectId)) {
        _selectedSubjects.remove(subjectId);
      } else {
        _selectedSubjects.add(subjectId);
      }
    });
  }

  void _showAddSubjectDialog() {
    showDialog(
      context: context,
      builder: (context) => SubjectFormDialog(
        onSave: _handleSubjectSave,
      ),
    );
  }

  void _showEditSubjectDialog(Subject subject) {
    showDialog(
      context: context,
      builder: (context) => SubjectFormDialog(
        subject: subject,
        onSave: _handleSubjectSave,
      ),
    );
  }

  Future<void> _handleSubjectSave(Subject subject) async {
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id;

      if (schoolId != null) {
        if (subject.id.isEmpty) {
          // Adding new subject
          await examProvider.addSubject(
            name: subject.name,
            classId: int.parse(subject.classId),
            schoolId: schoolId,
          );
        } else {
          // Updating existing subject
          await examProvider.updateSubject(
            id: subject.id,
            name: subject.name,
            classId: int.parse(subject.classId),
            schoolId: schoolId,
          );
        }
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving subject: $e')),
      );
    }
  }

  Future<void> _deleteSubject(Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${subject.name}"? This action cannot be undone.'),
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
          await examProvider.deleteSubject(subject.id, schoolId);
          _loadData();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting subject: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accentColor = AppTheme.getAccentColorForContext('form');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subject Management'),
        backgroundColor: appBackgroundColor,
        elevation: 0,
        actions: [
          if (_selectedSubjects.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentColor.withOpacity(0.3)),
              ),
              child: Text(
                '${_selectedSubjects.length} selected',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        color: appBackgroundColor,
        child: Column(
          children: [
            _buildSearchBar(),
            _buildSortBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? ErrorDisplay(
                          message: _errorMessage!,
                          onRetry: _loadData,
                        )
                      : _buildSubjectGrid(),
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: FloatingActionButton.extended(
          onPressed: _showAddSubjectDialog,
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add),
          label: const Text('Add Subject'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

