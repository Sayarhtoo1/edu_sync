import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/class_provider.dart';
import '../../../models/exam_class.dart';

class AllReportCardsScreen extends StatefulWidget {
  final String examId;
  final String examName;

  const AllReportCardsScreen({
    super.key,
    required this.examId,
    required this.examName,
  });

  @override
  State<AllReportCardsScreen> createState() => _AllReportCardsScreenState();
}

class _AllReportCardsScreenState extends State<AllReportCardsScreen> {
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
      
      // Get exam classes to find students
      await examProvider.fetchExamClasses(widget.examId);
      _examClasses = examProvider.examClasses;
      
      if (_examClasses.isEmpty) {
        throw Exception('No classes found for this exam');
      }
      
      // Set first class as default if not selected
      _selectedExamClass ??= _examClasses.first;
      
      // Get students from selected class
      await examProvider.fetchStudentsByClassId(_selectedExamClass!.classId.toString());
      final students = examProvider.students;
      
      // Get report card data for each student
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
          // Student has no marks yet
          studentData.add({
            'student': student,
            'reportCard': null,
            'rank': 0,
            'percentage': 0.0,
          });
        }
      }
      
      // Sort by rank
      studentData.sort((a, b) => (a['rank'] as int).compareTo(b['rank'] as int));
      
      setState(() => _students = studentData);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading students: $e')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examName),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Consumer<ClassProvider>(
                  builder: (context, classProvider, _) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                      ),
                      child: DropdownButtonFormField<int>(
                        value: _selectedExamClass?.classId,
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          prefixIcon: Icon(Icons.class_),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: _examClasses.map((ec) {
                          final schoolClass = classProvider.classes
                              .where((c) => c.id == ec.classId)
                              .firstOrNull;
                          final className = schoolClass?.name ?? 'Class ${ec.classId}';
                          return DropdownMenuItem(
                            value: ec.classId,
                            child: Text(className),
                          );
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
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
                  ),
                  child: TextField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: const InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('No students found', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final data = _filteredStudents[index];
                          final student = data['student'];
                          final reportCard = data['reportCard'];
                          final rank = data['rank'];
                          final percentage = data['percentage'];
                          final hasPassed = reportCard != null && reportCard['result'] == 'PASSED';
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: InkWell(
                              onTap: reportCard != null ? () => context.push('/report-card/${student.id}/${widget.examId}') : null,
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: _getRankColor(rank),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: rank == 1
                                            ? const Icon(Icons.emoji_events, color: Colors.white, size: 24)
                                            : Text(
                                                '${rank > 0 ? rank : '-'}',
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                                              ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            student.fullName,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          const SizedBox(height: 4),
                                          if (reportCard != null)
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: hasPassed ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    '${percentage.toStringAsFixed(1)}%',
                                                    style: TextStyle(
                                                      color: hasPassed ? Colors.green : Colors.red,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Icon(
                                                  hasPassed ? Icons.check_circle : Icons.cancel,
                                                  color: hasPassed ? Colors.green : Colors.red,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  reportCard['result'],
                                                  style: TextStyle(
                                                    color: hasPassed ? Colors.green : Colors.red,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            )
                                          else
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text(
                                                'No marks entered',
                                                style: TextStyle(color: Colors.grey, fontSize: 12),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    if (reportCard != null)
                                      Icon(Icons.chevron_right, color: Colors.grey[400]),
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

  Color _getRankColor(int rank) {
    if (rank == 0) return Colors.grey;
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey[400]!;
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }

  void _navigateToMarksEntry(int studentId) {
    // Navigate to marks entry for this student
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to marks entry for this student')),
    );
  }
}
