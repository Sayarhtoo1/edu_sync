import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../models/exam.dart';
import '../../../models/subject.dart';
import '../../../models/student.dart';
import '../../../models/exam_subject.dart'; // Import ExamSubject model
import '../../../providers/school_provider.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';

class InputMarksScreen extends StatefulWidget {
  const InputMarksScreen({super.key});

  @override
  _InputMarksScreenState createState() => _InputMarksScreenState();
}

class _InputMarksScreenState extends State<InputMarksScreen> {
  Exam? _selectedExam;
  Subject? _selectedSubject;
  ExamSubject? _selectedExamSubject; // Add selected ExamSubject
  List<Student> _students = [];
  final Map<String, TextEditingController> _marksControllers = {}; // Change key to String for student.id

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id.toString();

    if (schoolId != null) {
      await examProvider.fetchExams(schoolId);
      await examProvider.fetchSubjects(schoolId);
    }
  }

  Future<void> _fetchExamSubjectDetails() async {
    if (_selectedExam != null && _selectedSubject != null) {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      await examProvider.fetchExamSubjectsForExam(_selectedExam!.id);
      setState(() {
        _selectedExamSubject = examProvider.examSubjects.firstWhere(
          (es) => es.subjectId == _selectedSubject!.id,
          orElse: () => ExamSubject(
            id: '',
            examId: _selectedExam!.id,
            subjectId: _selectedSubject!.id,
            maxMarks: 0,
            passingMarks: 0,
            createdAt: DateTime.now(),
          ),
        );
      });
    }
  }

  Future<void> _fetchStudentsForSelectedClass(String classId) async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    await examProvider.fetchStudentsByClassId(classId);
    setState(() {
      _students = examProvider.students;
      _marksControllers.clear();
      for (var student in _students) {
        _marksControllers[student.id.toString()] = TextEditingController();
      }
    });
  }

  Future<void> _saveMarks() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final localizations = AppLocalizations.of(context);

    if (_selectedExam == null || _selectedSubject == null || _selectedExamSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations!.selectExamAndSubject)),
      );
      return;
    }

    final maxMarks = _selectedExamSubject!.maxMarks;
    final passingMarks = _selectedExamSubject!.passingMarks;

    for (var student in _students) {
      final marksController = _marksControllers[student.id];
      if (marksController != null && marksController.text.isNotEmpty) {
        final marks = int.tryParse(marksController.text);
        if (marks != null) {
          if (marks > maxMarks) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(localizations!.marksExceedMax(student.fullName, maxMarks))),
            );
            return;
          }
          await examProvider.upsertStudentExamMark(
            examId: _selectedExam!.id,
            studentId: student.id.toString(),
            subjectId: _selectedSubject!.id,
            marksObtained: marks,
          );
        }
      }
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(localizations!.marksSavedSuccessfully)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.inputMarks),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButtonFormField<Exam>(
              value: _selectedExam,
              decoration: InputDecoration(labelText: localizations.selectExam),
              items: examProvider.exams.map((exam) {
                return DropdownMenuItem(
                  value: exam,
                  child: Text(exam.name),
                );
              }).toList(),
              onChanged: (exam) {
                setState(() {
                  _selectedExam = exam;
                  _selectedSubject = null; // Reset subject when exam changes
                  _selectedExamSubject = null; // Reset exam subject
                  if (_selectedExam != null) {
                    _fetchStudentsForSelectedClass(_selectedExam!.classId.toString());
                  } else {
                    _students = [];
                    _marksControllers.clear();
                  }
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<Subject>(
              value: _selectedSubject,
              decoration: InputDecoration(labelText: localizations.selectSubject),
              items: examProvider.subjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject.name),
                );
              }).toList(),
              onChanged: (subject) {
                setState(() {
                  _selectedSubject = subject;
                  _fetchExamSubjectDetails();
                });
              },
            ),
            SizedBox(height: 16),
            if (_selectedExamSubject != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Max Marks: ${_selectedExamSubject!.maxMarks}, Passing Marks: ${_selectedExamSubject!.passingMarks}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  _marksControllers.putIfAbsent(student.id.toString(), () => TextEditingController());
                  return ListTile(
                    title: Text(student.fullName),
                    trailing: SizedBox(
                      width: 100,
                      child: TextFormField(
                        controller: _marksControllers[student.id.toString()],
                        decoration: InputDecoration(labelText: localizations.marks),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _saveMarks,
              child: Text(localizations.saveMarks),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _marksControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }
}
