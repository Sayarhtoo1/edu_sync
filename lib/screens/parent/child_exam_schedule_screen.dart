import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/exam_provider.dart';
import '../../models/exam.dart';

class ChildExamScheduleScreen extends StatefulWidget {
  final int classId;

  const ChildExamScheduleScreen({super.key, required this.classId});

  @override
  State<ChildExamScheduleScreen> createState() => _ChildExamScheduleScreenState();
}

class _ChildExamScheduleScreenState extends State<ChildExamScheduleScreen> {
  List<Exam> _exams = [];
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
      await examProvider.fetchExams(widget.classId.toString());
      setState(() => _exams = examProvider.exams.where((e) => e.classId == widget.classId).toList());
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Schedule')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
              ? const Center(child: Text('No upcoming exams'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) {
                    final exam = _exams[index];
                    return Card(
                      child: ListTile(
                        title: Text(exam.name),
                        subtitle: Text('Date: ${exam.examDate.toString().split(' ')[0]}'),
                        trailing: Text('Examiner: ${exam.examinerName}'),
                      ),
                    );
                  },
                ),
    );
  }
}
