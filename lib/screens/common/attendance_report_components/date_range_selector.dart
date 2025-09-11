import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ReportType { Monthly, Custom }

class DateRangeSelector extends StatefulWidget {
  final Function(DateTimeRange?) onDateRangeChanged;
  final Function(ReportType) onReportTypeChanged;
  final ReportType reportType;

  const DateRangeSelector({
    super.key,
    required this.onDateRangeChanged,
    required this.onReportTypeChanged,
    required this.reportType,
  });

  @override
  State<DateRangeSelector> createState() => _DateRangeSelectorState();
}

class _DateRangeSelectorState extends State<DateRangeSelector> {
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setDefaultDateRange();
      }
    });
  }

  void _setDefaultDateRange() {
    final now = DateTime.now();
    if (widget.reportType == ReportType.Monthly) {
      _selectedDateRange = DateTimeRange(
        start: DateTime(now.year, now.month, 1),
        end: DateTime(now.year, now.month + 1, 0),
      );
    } else {
      _selectedDateRange = DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      );
    }
    widget.onDateRangeChanged(_selectedDateRange);
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now().subtract(const Duration(days: 7)),
          end: DateTime.now(),
        );
    final newDateRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: initialDateRange,
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
      widget.onDateRangeChanged(_selectedDateRange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ChoiceChip(
              label: const Text('Monthly'),
              selected: widget.reportType == ReportType.Monthly,
              onSelected: (selected) {
                if (selected) {
                  widget.onReportTypeChanged(ReportType.Monthly);
                  _setDefaultDateRange();
                }
              },
            ),
            const SizedBox(width: 16),
            ChoiceChip(
              label: const Text('Custom'),
              selected: widget.reportType == ReportType.Custom,
              onSelected: (selected) {
                if (selected) {
                  widget.onReportTypeChanged(ReportType.Custom);
                  _selectDateRange(context);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _selectedDateRange != null
              ? '${DateFormat.yMMMd().format(_selectedDateRange!.start)} - ${DateFormat.yMMMd().format(_selectedDateRange!.end)}'
              : 'No date range selected',
        ),
      ],
    );
  }
}
