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
        title: Text('Report Cards - ${widget.examName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Consumer<ClassProvider>(
                  builder: (context, classProvider, _) {
                    return DropdownButtonFormField<int>(
                      value: _selectedExamClass?.classId,
                      decoration: InputDecoration(
                        labelText: 'Filter by Class',
                        prefixIcon: const Icon(Icons.class_),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                    );
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search students...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? const Center(child: Text('No students found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final data = _filteredStudents[index];
                          final student = data['student'];
                          final reportCard = data['reportCard'];
                          final rank = data['rank'];
                          final percentage = data['percentage'];
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getRankColor(rank),
                                child: Text('${rank > 0 ? rank : '-'}'),
                              ),
                              title: Text(student.fullName),
                              subtitle: reportCard != null
                                  ? Text('${percentage.toStringAsFixed(1)}% - ${reportCard['result']}')
                                  : const Text('No marks entered'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (reportCard != null)
                                    IconButton(
                                      icon: const Icon(Icons.visibility),
                                      onPressed: () => context.push(
                                        '/report-card/${student.id}/${widget.examId}',
                                      ),
                                      tooltip: 'View Report Card',
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _navigateToMarksEntry(student.id),
                                    tooltip: 'Edit Marks',
                                  ),
                                ],
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
