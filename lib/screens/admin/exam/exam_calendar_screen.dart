import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../providers/exam_provider.dart';
import '../../../models/exam.dart';

class ExamCalendarScreen extends StatefulWidget {
  final int schoolId;

  const ExamCalendarScreen({super.key, required this.schoolId});

  @override
  State<ExamCalendarScreen> createState() => _ExamCalendarScreenState();
}

class _ExamCalendarScreenState extends State<ExamCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Exam>> _examsByDate = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      await examProvider.fetchExams(widget.schoolId.toString());
      
      final exams = examProvider.exams;
      final examsByDate = <DateTime, List<Exam>>{};
      
      for (var exam in exams) {
        final date = DateTime(exam.examDate.year, exam.examDate.month, exam.examDate.day);
        examsByDate.putIfAbsent(date, () => []).add(exam);
      }
      
      setState(() => _examsByDate = examsByDate);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading exams: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Exam> _getExamsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _examsByDate[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Calendar')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: _getExamsForDay,
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    markerDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _selectedDay == null
                      ? const Center(child: Text('Select a date to view exams'))
                      : _buildExamList(_getExamsForDay(_selectedDay!)),
                ),
              ],
            ),
    );
  }

  Widget _buildExamList(List<Exam> exams) {
    if (exams.isEmpty) {
      return const Center(child: Text('No exams on this date'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: exams.length,
      itemBuilder: (context, index) {
        final exam = exams[index];
        return Card(
          child: ListTile(
            title: Text(exam.name),
            subtitle: Text('Examiner: ${exam.examinerName}'),
            trailing: IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showExamDetails(exam),
            ),
          ),
        );
      },
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
            Text('Date: ${exam.examDate.toString().split(' ')[0]}'),
            Text('Examiner: ${exam.examinerName}'),
            if (exam.description != null) Text('Description: ${exam.description}'),
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
}
