import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/models/exam.dart';
import 'package:edu_sync/services/exam_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopExamOverview extends StatefulWidget {
  const DesktopExamOverview({super.key});

  @override
  State<DesktopExamOverview> createState() => _DesktopExamOverviewState();
}

class _DesktopExamOverviewState extends State<DesktopExamOverview> {
  List<Exam> _exams = [];
  bool _isLoading = true;
  int? _currentSchoolId;
  String _searchQuery = '';
  String _viewMode = 'grid';
  String _filterStatus = 'all'; // all, upcoming, completed

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    _currentSchoolId = await authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      final examService = context.read<ExamService>();
      _exams = await examService.getExamsBySchoolId(_currentSchoolId!);
    }
    setState(() => _isLoading = false);
  }

  List<Exam> get _filteredExams {
    var filtered = _exams;
    
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((e) => e.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    
    if (_filterStatus == 'upcoming') {
      filtered = filtered.where((e) => e.examClasses?.any((ec) => ec.examDate.isAfter(DateTime.now())) ?? false).toList();
    } else if (_filterStatus == 'completed') {
      filtered = filtered.where((e) => e.examClasses?.every((ec) => ec.examDate.isBefore(DateTime.now())) ?? false).toList();
    }
    
    return filtered;
  }

  int get _upcomingCount => _exams.where((e) => e.examClasses?.any((ec) => ec.examDate.isAfter(DateTime.now())) ?? false).length;
  int get _completedCount => _exams.where((e) => e.examClasses?.every((ec) => ec.examDate.isBefore(DateTime.now())) ?? false).length;

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Exam Management',
      actions: [
        OutlinedButton.icon(
          onPressed: () => context.pushNamed('exam-management'),
          icon: const Icon(Icons.list, size: 18),
          label: const Text('Exam List'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(_viewMode == 'table' ? Icons.grid_view : Icons.table_rows),
          onPressed: () => setState(() => _viewMode = _viewMode == 'table' ? 'grid' : 'table'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => context.pushNamed('exam-form'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Create Exam'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildStats(),
                  const SizedBox(height: 24),
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _filteredExams.isEmpty
                        ? _buildEmptyState()
                        : _viewMode == 'table'
                            ? _buildTableView()
                            : _buildGridView(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.assignment_outlined, _exams.length.toString(), 'Total Exams', const Color(0xFF3498DB))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(Icons.schedule_outlined, _upcomingCount.toString(), 'Upcoming', const Color(0xFFF39C12))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(Icons.check_circle_outline, _completedCount.toString(), 'Completed', const Color(0xFF2ECC71))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(Icons.pending_actions, (_exams.length - _completedCount).toString(), 'In Progress', const Color(0xFF9B59B6))),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search exams...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: DropdownButton<String>(
            value: _filterStatus,
            underline: const SizedBox(),
            onChanged: (value) => setState(() => _filterStatus = value!),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Exams')),
              DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.assignment, size: 20, color: Color(0xFF673AB7)),
              const SizedBox(width: 8),
              Text('${_filteredExams.length} Exams', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(child: _buildActionButton(Icons.subject, 'Manage Subjects', const Color(0xFF3498DB), () => context.push('/admin/subject-management'))),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(Icons.grade, 'Manage Grades', const Color(0xFF9B59B6), () => context.push('/admin/grade-management'))),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(Icons.calendar_month, 'Exam Calendar', const Color(0xFF2ECC71), () {
          if (_currentSchoolId != null) {
            context.pushNamed('exam-calendar', pathParameters: {'schoolId': _currentSchoolId.toString()});
          }
        })),
        const SizedBox(width: 12),
        Expanded(child: _buildActionButton(Icons.analytics, 'Analytics', const Color(0xFFF39C12), () {
          if (_exams.isNotEmpty) {
            context.pushNamed('exam-analytics', pathParameters: {'examId': _exams.first.id}, extra: <String, String>{'examName': _exams.first.name});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No exams available. Please create an exam first.')),
            );
          }
        })),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No exams found', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTableView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                const SizedBox(width: 60, child: Text('#', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                const Expanded(flex: 2, child: Text('Exam Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                const Expanded(child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                const Expanded(child: Text('Classes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                const Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                const Expanded(child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                const SizedBox(width: 180, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredExams.length,
              itemBuilder: (context, index) {
                final exam = _filteredExams[index];
                final isUpcoming = exam.examClasses?.any((ec) => ec.examDate.isAfter(DateTime.now())) ?? false;
                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                  child: InkWell(
                    onTap: () => context.pushNamed('marks-entry', pathParameters: {'examId': exam.id}, extra: {'examName': exam.name}),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text('#${index + 1}', style: TextStyle(fontSize: 13, color: Colors.grey[600]), textAlign: TextAlign.center),
                          ),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: Text(exam.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                          Expanded(child: Text(exam.examType ?? 'Exam', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          Expanded(child: Text('${exam.examClasses?.length ?? 0} classes', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          Expanded(child: Text(exam.examClasses?.isNotEmpty == true ? exam.examClasses!.first.examDate.toString().split(' ')[0] : 'N/A', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isUpcoming ? const Color(0xFFF39C12).withOpacity(0.1) : const Color(0xFF2ECC71).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                isUpcoming ? 'Upcoming' : 'Completed',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isUpcoming ? const Color(0xFFF39C12) : const Color(0xFF2ECC71)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 180,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.info_outlined, size: 18, color: Color(0xFF9B59B6)),
                                  onPressed: () => context.pushNamed('edit-exam-basic', extra: exam),
                                  tooltip: 'Edit Basic Info',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2ECC71)),
                                  onPressed: () => context.pushNamed('marks-entry', pathParameters: {'examId': exam.id}, extra: {'examName': exam.name}),
                                  tooltip: 'Enter Marks',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF3498DB)),
                                  onPressed: () => context.pushNamed('marks-entry', pathParameters: {'examId': exam.id}, extra: {'examName': exam.name}),
                                  tooltip: 'View',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.3,
      ),
      itemCount: _filteredExams.length,
      itemBuilder: (context, index) {
        final exam = _filteredExams[index];
        final isUpcoming = exam.examClasses?.any((ec) => ec.examDate.isAfter(DateTime.now())) ?? false;
        return InkWell(
          onTap: () => context.pushNamed('marks-entry', pathParameters: {'examId': exam.id}, extra: {'examName': exam.name}),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3498DB).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.assignment, color: Color(0xFF3498DB), size: 20),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isUpcoming ? const Color(0xFFF39C12).withOpacity(0.1) : const Color(0xFF2ECC71).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isUpcoming ? 'Upcoming' : 'Completed',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: isUpcoming ? const Color(0xFFF39C12) : const Color(0xFF2ECC71)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(exam.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Text(exam.examType ?? 'Exam', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                const SizedBox(height: 4),
                Text(
                  exam.examClasses?.isNotEmpty == true ? exam.examClasses!.first.examDate.toString().split(' ')[0] : 'No date',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
