import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/providers/exam_provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/exam.dart';

class TeacherMarksEntrySelectionScreen extends StatefulWidget {
  const TeacherMarksEntrySelectionScreen({super.key});

  @override
  State<TeacherMarksEntrySelectionScreen> createState() => _TeacherMarksEntrySelectionScreenState();
}

class _TeacherMarksEntrySelectionScreenState extends State<TeacherMarksEntrySelectionScreen> {
  bool _isLoading = true;
  List<Exam> _exams = [];

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    setState(() => _isLoading = true);
    final schoolProvider = context.read<SchoolProvider>();
    final examProvider = context.read<ExamProvider>();
    final schoolId = schoolProvider.currentSchool?.id.toString();

    if (schoolId != null) {
      await examProvider.fetchExams(schoolId);
      setState(() {
        _exams = examProvider.exams;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Exam'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _exams.isEmpty
              ? const Center(child: Text('No exams available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _exams.length,
                  itemBuilder: (context, index) => _buildExamCard(_exams[index]),
                ),
    );
  }

  Widget _buildExamCard(Exam exam) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.edit_note, color: Colors.blue),
        ),
        title: Text(
          exam.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${exam.examDate.day}/${exam.examDate.month}/${exam.examDate.year}'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => context.pushNamed(
          'marks-entry',
          pathParameters: {'examId': exam.id},
          extra: {'examName': exam.name},
        ),
      ),
    );
  }
}
