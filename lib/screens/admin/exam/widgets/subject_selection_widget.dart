import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../models/subject.dart';
import '../../../../providers/exam_provider.dart';
import '../../../../theme/app_theme.dart';

class SubjectSelectionWidget extends StatefulWidget {
  final String examId;
  final List<String> selectedSubjectIds;
  final Function(List<String>) onSelectionChanged;
  final bool allowMultiSelection;

  const SubjectSelectionWidget({
    super.key,
    required this.examId,
    required this.selectedSubjectIds,
    required this.onSelectionChanged,
    this.allowMultiSelection = true,
  });

  @override
  State<SubjectSelectionWidget> createState() => _SubjectSelectionWidgetState();
}

class _SubjectSelectionWidgetState extends State<SubjectSelectionWidget> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedClassId = '';
  final bool _showClassFilter = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSubjects);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSubjects() {
    setState(() {});
  }

  List<Subject> get _filteredSubjects {
    final examProvider = Provider.of<ExamProvider>(context);
    final subjects = examProvider.subjects;
    final query = _searchController.text.toLowerCase();

    return subjects.where((subject) {
      // Search filter
      if (query.isNotEmpty && !subject.name.toLowerCase().contains(query)) {
        return false;
      }

      // Class filter
      if (_selectedClassId.isNotEmpty && subject.classId != _selectedClassId) {
        return false;
      }

      return true;
    }).toList();
  }

  void _toggleSubjectSelection(String subjectId) {
    if (!widget.allowMultiSelection && widget.selectedSubjectIds.isNotEmpty) {
      // Single selection mode - replace current selection
      widget.onSelectionChanged([subjectId]);
    } else {
      // Multi-selection mode
      final updatedSelection = List<String>.from(widget.selectedSubjectIds);
      if (updatedSelection.contains(subjectId)) {
        updatedSelection.remove(subjectId);
      } else {
        updatedSelection.add(subjectId);
      }
      widget.onSelectionChanged(updatedSelection);
    }
  }

  Widget _buildClassFilter() {
    final examProvider = Provider.of<ExamProvider>(context);
    final subjects = examProvider.subjects;
    final classIds = subjects.map((s) => s.classId).toSet().toList();

    if (classIds.length <= 1) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        children: [
          FilterChip(
            label: const Text('All Classes'),
            selected: _selectedClassId.isEmpty,
            onSelected: (selected) {
              setState(() => _selectedClassId = '');
            },
          ),
          ...classIds.map((classId) {
            final className = _getClassName(classId);
            return FilterChip(
              label: Text(className),
              selected: _selectedClassId == classId,
              onSelected: (selected) {
                setState(() => _selectedClassId = selected ? classId : '');
              },
            );
          }),
        ],
      ),
    );
  }

  String _getClassName(String classId) {
    // This should ideally come from ClassProvider
    return 'Class $classId';
  }

  Widget _buildSubjectGrid() {
    final filteredSubjects = _filteredSubjects;

    if (filteredSubjects.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subject,
              size: 64,
              color: textLightGrey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No subjects found',
              style: TextStyle(
                color: textLightGrey,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: filteredSubjects.length,
      itemBuilder: (context, index) {
        final subject = filteredSubjects[index];
        final isSelected = widget.selectedSubjectIds.contains(subject.id);

        return _buildSubjectItem(subject, isSelected);
      },
    );
  }

  Widget _buildSubjectItem(Subject subject, bool isSelected) {
    return InkWell(
      onTap: () => _toggleSubjectSelection(subject.id),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getAccentColorForContext('form').withOpacity(0.1)
              : cardBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.getAccentColorForContext('form')
                : textLightGrey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subject name and selection indicator
            Row(
              children: [
                Expanded(
                  child: Text(
                    subject.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.getAccentColorForContext('form') : textDarkGrey,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppTheme.getAccentColorForContext('form'),
                    size: 16,
                  ),
              ],
            ),

            const Spacer(),

            // Subject info
            if (subject.maxMarks != null)
              Text(
                'Max: ${subject.maxMarks}',
                style: TextStyle(
                  color: textLightGrey,
                  fontSize: 10,
                ),
              ),

            if (subject.passingMarks != null)
              Text(
                'Pass: ${subject.passingMarks}',
                style: TextStyle(
                  color: textLightGrey,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with search
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search subjects...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.getAccentColorForContext('form')),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: textLightGrey.withOpacity(0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: textLightGrey.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.getAccentColorForContext('form'), width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.selectedSubjectIds.length} selected',
              style: TextStyle(
                color: AppTheme.getAccentColorForContext('form'),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),

        // Class filter
        _buildClassFilter(),

        const SizedBox(height: 16),

        // Subject grid
        Expanded(
          child: _buildSubjectGrid(),
        ),

        // Selection summary
        if (widget.selectedSubjectIds.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.getAccentColorForContext('form').withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Subjects:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textDarkGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: widget.selectedSubjectIds.map((subjectId) {
                    final subject = Provider.of<ExamProvider>(context)
                        .subjects
                        .where((s) => s.id == subjectId)
                        .firstOrNull;

                    if (subject == null) return const SizedBox.shrink();

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.getAccentColorForContext('form').withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        subject.name,
                        style: TextStyle(
                          color: AppTheme.getAccentColorForContext('form'),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}