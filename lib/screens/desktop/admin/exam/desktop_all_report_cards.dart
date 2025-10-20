import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../providers/exam_provider.dart';
import '../../../../providers/class_provider.dart';
import '../../../../models/exam_class.dart';

class DesktopAllReportCards extends StatefulWidget {
  final String examId;
  final String examName;

  const DesktopAllReportCards({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<DesktopAllReportCards> createState() => _DesktopAllReportCardsState();
}

class _DesktopAllReportCardsState extends State<DesktopAllReportCards> {
  List<Map<String, dynamic>> _students = [];
  bool _isLoading = false;
  String _searchQuery = '';
  List<ExamClass> _examClasses = [];
  ExamClass? _selectedExamClass;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      
      await examProvider.fetchExamClasses(widget.examId);
      _examClasses = examProvider.examClasses;
      
      if (_examClasses.isEmpty) {
        throw Exception('No classes found for this exam');
      }
      
      _selectedExamClass ??= _examClasses.first;
      
      await examProvider.fetchStudentsByClassId(_selectedExamClass!.classId.toString());
      final students = examProvider.students;
      
      final studentData = <Map<String, dynamic>>[];
      for (var student in students) {
        try {
          final reportCard = await examProvider.getReportCard(
            studentId: student.id,
            examId: widget.examId,
          );
          final rank = await examProvider.getStudentRank(
            studentId: student.id,
            examId: widget.examId,
          );
          
          studentData.add({
            'student': student,
            'reportCard': reportCard,
            'rank': rank,
            'percentage': reportCard['overallPercentage'] ?? 0.0,
          });
        } catch (e) {
          studentData.add({
            'student': student,
            'reportCard': null,
            'rank': 0,
            'percentage': 0.0,
          });
        }
      }
      
      studentData.sort((a, b) => (a['rank'] as int).compareTo(b['rank'] as int));
      
      setState(() => _students = studentData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students.where((s) {
      final name = s['student'].fullName.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  Map<String, dynamic> _calculateStats() {
    if (_students.isEmpty) return {'total': 0, 'completed': 0, 'avgPercentage': 0.0, 'passRate': 0.0};
    
    int completed = 0;
    double totalPercentage = 0;
    int passed = 0;
    
    for (var data in _students) {
      if (data['reportCard'] != null) {
        completed++;
        final percentage = data['percentage'] as double;
        totalPercentage += percentage;
        if (data['reportCard']['result'] == 'Pass') passed++;
      }
    }
    
    return {
      'total': _students.length,
      'completed': completed,
      'avgPercentage': completed > 0 ? totalPercentage / completed : 0.0,
      'passRate': completed > 0 ? (passed / completed) * 100 : 0.0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('Report Cards - ${widget.examName}'),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: _loadStudents,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Colors.white,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Consumer<ClassProvider>(
                        builder: (context, classProvider, _) {
                          return DropdownButtonFormField<int>(
                            value: _selectedExamClass?.classId,
                            decoration: const InputDecoration(
                              labelText: 'Class',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: _examClasses.map((ec) {
                              final schoolClass = classProvider.classes
                                  .where((c) => c.id == ec.classId)
                                  .firstOrNull;
                              final className = schoolClass?.name ?? 'Class ${ec.classId}';
                              return DropdownMenuItem(value: ec.classId, child: Text(className));
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                final examClass = _examClasses.where((ec) => ec.classId == value).firstOrNull;
                                if (examClass != null) {
                                  setState(() => _selectedExamClass = examClass);
                                  _loadStudents();
                                }
                              }
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Search students...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_students.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Total Students', '${stats['total']}', Icons.people, const Color(0xFF3498DB)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Completed', '${stats['completed']}/${stats['total']}', Icons.check_circle, const Color(0xFF2ECC71)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Avg %', '${stats['avgPercentage'].toStringAsFixed(1)}%', Icons.analytics, const Color(0xFFF39C12)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Pass Rate', '${stats['passRate'].toStringAsFixed(1)}%', Icons.trending_up, const Color(0xFF2ECC71)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? const Center(child: Text('No students found'))
                    : Container(
                        margin: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF2C3E50),
                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(width: 60, child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                                  Expanded(flex: 2, child: Text('Student Name', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                                  Expanded(child: Text('Student ID', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                                  SizedBox(width: 120, child: Text('Percentage', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
                                  SizedBox(width: 100, child: Text('Result', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
                                  SizedBox(width: 150, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final data = _filteredStudents[index];
                                  final student = data['student'];
                                  final reportCard = data['reportCard'];
                                  final rank = data['rank'];
                                  final percentage = data['percentage'];
                                  
                                  return Container(
                                    decoration: BoxDecoration(
                                      border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                                      color: index % 2 == 0 ? Colors.grey[50] : Colors.white,
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 60,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: _getRankColor(rank).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              rank > 0 ? '#$rank' : '-',
                                              style: TextStyle(fontWeight: FontWeight.bold, color: _getRankColor(rank)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        Expanded(flex: 2, child: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w600))),
                                        Expanded(child: Text('${student.id}', style: TextStyle(color: Colors.grey[600]))),
                                        SizedBox(
                                          width: 120,
                                          child: Text(
                                            reportCard != null ? '${percentage.toStringAsFixed(1)}%' : '-',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: reportCard != null ? const Color(0xFF3498DB) : Colors.grey,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: reportCard != null
                                              ? Center(
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: reportCard['result'] == 'Pass'
                                                          ? const Color(0xFF2ECC71).withOpacity(0.1)
                                                          : const Color(0xFFE74C3C).withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Text(
                                                      reportCard['result'],
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.w600,
                                                        color: reportCard['result'] == 'Pass'
                                                            ? const Color(0xFF2ECC71)
                                                            : const Color(0xFFE74C3C),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : const Center(child: Text('-', style: TextStyle(color: Colors.grey))),
                                        ),
                                        SizedBox(
                                          width: 150,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              if (reportCard != null)
                                                IconButton(
                                                  icon: const Icon(Icons.visibility, size: 20),
                                                  onPressed: () => context.push('/parent/report-card/${student.id}/${widget.examId}'),
                                                  tooltip: 'View Report Card',
                                                  color: const Color(0xFF3498DB),
                                                ),
                                              IconButton(
                                                icon: const Icon(Icons.print, size: 20),
                                                onPressed: reportCard != null ? () {} : null,
                                                tooltip: 'Print',
                                                color: const Color(0xFF2ECC71),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 0) return Colors.grey;
    if (rank == 1) return const Color(0xFFF39C12);
    if (rank == 2) return Colors.grey[600]!;
    if (rank == 3) return Colors.brown;
    return const Color(0xFF3498DB);
  }
}
