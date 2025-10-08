import 'package:flutter/material.dart';
import '../../../../models/exam_status.dart';
import '../../../../theme/app_theme.dart';

class ExamFiltersWidget extends StatelessWidget {
  final TextEditingController searchController;
  final ExamStatus selectedStatus;
  final Function(ExamStatus) onStatusChanged;
  final VoidCallback onClearFilters;

  const ExamFiltersWidget({
    super.key,
    required this.searchController,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = AppTheme.getAccentColorForContext('form');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Field
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search exams, classes, or examiners...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: theme.inputDecorationTheme.fillColor,
            ),
          ),

          const SizedBox(height: 16),

          // Status Filter Chips
          Row(
            children: [
              Text(
                'Status:',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ExamStatus.values.map((status) {
                      final isSelected = selectedStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_getStatusText(status)),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) onStatusChanged(status);
                          },
                          backgroundColor: _getStatusColor(status).withOpacity(0.1),
                          selectedColor: _getStatusColor(status).withOpacity(0.2),
                          checkmarkColor: _getStatusColor(status),
                          labelStyle: TextStyle(
                            color: isSelected ? _getStatusColor(status) : theme.textTheme.bodyMedium?.color,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              IconButton(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off),
                tooltip: 'Clear Filters',
              ),
            ],
          ),
        ],
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
    }
  }
}