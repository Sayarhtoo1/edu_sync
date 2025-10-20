import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../providers/exam_provider.dart';
import '../../../../models/exam.dart';
import '../../../../widgets/common/desktop_scaffold.dart';

class DesktopExamCalendar extends StatefulWidget {
  final int schoolId;

  const DesktopExamCalendar({super.key, required this.schoolId});

  @override
  State<DesktopExamCalendar> createState() => _DesktopExamCalendarState();
}

class _DesktopExamCalendarState extends State<DesktopExamCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Exam>> _examsByDate = {};
  List<Exam> _allExams = [];
  String _viewMode = 'month';
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
      
      setState(() {
        _examsByDate = examsByDate;
        _allExams = exams;
      });
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

  List<Exam> _getUpcomingExams() {
    final now = DateTime.now();
    return _allExams.where((e) => e.examDate.isAfter(now)).toList()
      ..sort((a, b) => a.examDate.compareTo(b.examDate));
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Exam Calendar',
      actions: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'month', label: Text('Month'), icon: Icon(Icons.calendar_month)),
            ButtonSegment(value: 'list', label: Text('List'), icon: Icon(Icons.list)),
          ],
          selected: {_viewMode},
          onSelectionChanged: (Set<String> selection) {
            setState(() => _viewMode = selection.first);
          },
        ),
        const SizedBox(width: 16),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _viewMode == 'month' ? _buildMonthView() : _buildListView(),
    );
  }

  Widget _buildMonthView() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildStatsCards(),
              Expanded(
                child: Card(
                  margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: TableCalendar(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      eventLoader: _getExamsForDay,
                      calendarFormat: CalendarFormat.month,
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        markerDecoration: const BoxDecoration(
                          color: Color(0xFF3498DB),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF3498DB),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF3498DB).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        markerSize: 6,
                        markersMaxCount: 3,
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              if (_selectedDay != null) _buildDayExams(),
              Expanded(child: _buildUpcomingExams()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    final total = _allExams.length;
    final upcoming = _getUpcomingExams().length;
    final today = _getExamsForDay(DateTime.now()).length;
    final thisMonth = _allExams.where((e) => 
      e.examDate.year == DateTime.now().year && 
      e.examDate.month == DateTime.now().month
    ).length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total Exams', total.toString(), Icons.assignment, const Color(0xFF3498DB))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('Upcoming', upcoming.toString(), Icons.schedule, const Color(0xFF2ECC71))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('Today', today.toString(), Icons.today, const Color(0xFFF39C12))),
          const SizedBox(width: 16),
          Expanded(child: _buildStatCard('This Month', thisMonth.toString(), Icons.calendar_month, const Color(0xFF9B59B6))),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayExams() {
    final exams = _getExamsForDay(_selectedDay!);
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.event, color: Color(0xFF3498DB)),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text('${exams.length} exam(s)', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (exams.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text('No exams scheduled', style: TextStyle(color: Colors.grey))),
            )
          else
            ...exams.map((exam) => _buildExamTile(exam)),
        ],
      ),
    );
  }

  Widget _buildUpcomingExams() {
    final upcoming = _getUpcomingExams().take(10).toList();
    return Card(
      margin: const EdgeInsets.fromLTRB(0, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Icons.upcoming, color: Color(0xFF2ECC71)),
                SizedBox(width: 12),
                Text('Upcoming Exams', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: upcoming.isEmpty
                ? const Center(child: Text('No upcoming exams', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: upcoming.length,
                    itemBuilder: (context, index) => _buildExamTile(upcoming[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('All Exams', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  Text('${_allExams.length} total', style: const TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _allExams.length,
                itemBuilder: (context, index) => _buildExamTile(_allExams[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExamTile(Exam exam) {
    final isPast = exam.examDate.isBefore(DateTime.now());
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 50,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isPast ? Colors.grey : const Color(0xFF3498DB)).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exam.examDate.day.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPast ? Colors.grey : const Color(0xFF3498DB),
                ),
              ),
              Text(
                ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][exam.examDate.month - 1],
                style: TextStyle(fontSize: 9, color: isPast ? Colors.grey : const Color(0xFF3498DB)),
              ),
            ],
          ),
        ),
        title: Text(exam.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        subtitle: Text('Examiner: ${exam.examinerName}', style: const TextStyle(fontSize: 11)),
        trailing: SizedBox(
          width: 200,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPast)
                const Chip(
                  label: Text('Done', style: TextStyle(fontSize: 10)),
                  backgroundColor: Color(0xFFECF0F1),
                  padding: EdgeInsets.symmetric(horizontal: 6),
                  visualDensity: VisualDensity.compact,
                )
              else
                Chip(
                  label: Text('${exam.examDate.difference(DateTime.now()).inDays}d', style: const TextStyle(fontSize: 10)),
                  backgroundColor: const Color(0xFF2ECC71).withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  visualDensity: VisualDensity.compact,
                ),
              IconButton(
                icon: const Icon(Icons.analytics_outlined, size: 18, color: Color(0xFF3498DB)),
                tooltip: 'Analytics',
                onPressed: () => context.pushNamed('exam-analytics', pathParameters: {'examId': exam.id}, extra: {'examName': exam.name}),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3498DB)),
                tooltip: 'Edit',
                onPressed: () => context.push('/admin/edit-exam-basic', extra: exam),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
