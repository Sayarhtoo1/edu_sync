import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/exam.dart';
import '../../../providers/exam_provider.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../models/exam_subject.dart'; // Import ExamSubject model

class ManageExamSubjectsScreen extends StatefulWidget {
  final Exam exam;

  const ManageExamSubjectsScreen({super.key, required this.exam});

  @override
  _ManageExamSubjectsScreenState createState() => _ManageExamSubjectsScreenState();
}

class _ManageExamSubjectsScreenState extends State<ManageExamSubjectsScreen> {
  late Future<void> _fetchDataFuture;
  final Map<String, TextEditingController> _maxMarksControllers = {};
  final Map<String, TextEditingController> _passingMarksControllers = {};
  final Map<String, String?> _examSubjectIds = {};

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    await examProvider.fetchSubjectsByClassId(widget.exam.classId.toString());
    await examProvider.fetchExamSubjectsForExam(widget.exam.id);

    // Initialize controllers and populate with existing data
    for (var subject in examProvider.subjects) {
      final existingExamSubject = examProvider.examSubjects.firstWhere(
        (es) => es.subjectId == subject.id,
        orElse: () => ExamSubject(
          id: '',
          examId: widget.exam.id,
          subjectId: subject.id,
          maxMarks: 0,
          passingMarks: 0,
          createdAt: DateTime.now(),
        ),
      );

      _maxMarksControllers[subject.id] =
          TextEditingController(text: existingExamSubject.maxMarks > 0 ? existingExamSubject.maxMarks.toString() : '');
      _passingMarksControllers[subject.id] =
          TextEditingController(text: existingExamSubject.passingMarks > 0 ? existingExamSubject.passingMarks.toString() : '');
      _examSubjectIds[subject.id] = existingExamSubject.id.isNotEmpty ? existingExamSubject.id : null;
    }
  }

  @override
  void dispose() {
    for (var controller in _maxMarksControllers.values) {
      controller.dispose();
    }
    for (var controller in _passingMarksControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final examProvider = Provider.of<ExamProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.manageExamSubjectsTitle ?? 'Manage Exam Subjects'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await _saveExamSubjects();
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: examProvider.subjects.length,
              itemBuilder: (context, index) {
                final subject = examProvider.subjects[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(child: Text(subject.name)),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _maxMarksControllers[subject.id],
                          decoration: InputDecoration(labelText: 'Max Marks'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _passingMarksControllers[subject.id],
                          decoration: InputDecoration(labelText: 'Passing Marks'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<void> _saveExamSubjects() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    for (var subject in examProvider.subjects) {
      final maxMarks = int.tryParse(_maxMarksControllers[subject.id]?.text ?? '0') ?? 0;
      final passingMarks = int.tryParse(_passingMarksControllers[subject.id]?.text ?? '0') ?? 0;
      final examSubjectId = _examSubjectIds[subject.id];

      final examSubject = ExamSubject(
        id: examSubjectId ?? '',
        examId: widget.exam.id,
        subjectId: subject.id,
        maxMarks: maxMarks,
        passingMarks: passingMarks,
        createdAt: DateTime.now(),
      );
      await examProvider.upsertExamSubject(examSubject);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exam subjects saved successfully!')),
    );
  }
}
