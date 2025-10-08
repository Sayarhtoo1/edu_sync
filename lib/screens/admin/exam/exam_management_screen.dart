import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../models/exam.dart';
import '../../../providers/school_provider.dart';
import '../../../l10n/gen/app_localizations.dart';
import 'add_edit_exam_screen.dart';
import 'manage_exam_subjects_screen.dart';
import '../../../models/school_class.dart';
import '../../../providers/class_provider.dart';

class ExamManagementScreen extends StatefulWidget {
  const ExamManagementScreen({super.key});

  @override
  _ExamManagementScreenState createState() => _ExamManagementScreenState();
}

class _ExamManagementScreenState extends State<ExamManagementScreen> {
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final classProvider = Provider.of<ClassProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id.toString();

    if (schoolId != null) {
      await examProvider.fetchExams(schoolId);
      await classProvider.fetchClasses(schoolId);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteExam(Exam exam) async {
    final localizations = AppLocalizations.of(context);
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(localizations?.confirmDeleteTitle ?? 'Confirm Delete'),
            content: Text(localizations?.confirmDeleteExamText ??
                'Are you sure you want to delete this exam?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(localizations?.cancel ?? 'Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(localizations?.delete ?? 'Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final schoolProvider =
          Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id.toString();

      if (schoolId != null) {
        await examProvider.deleteExam(exam.id, schoolId);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  localizations?.error_school_not_found ?? 'School not found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context);
    final classProvider = Provider.of<ClassProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.manageExamsTitle ?? 'Manage Exams'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : examProvider.exams.isEmpty
              ? Center(
                  child: Text(localizations?.noExamsFound ?? 'No exams found'))
              : ListView.builder(
                  itemCount: examProvider.exams.length,
                  itemBuilder: (context, index) {
                    final exam = examProvider.exams[index];
                    final className = classProvider.classes
                        .firstWhere((c) => c.id == exam.classId,
                            orElse: () => SchoolClass(
                                id: 0,
                                name: 'Unknown',
                                schoolId: 0,
                                teacherId: ''))
                        .name;
                    return ListTile(
                      title: Text(exam.name),
                      subtitle: Text(
                          '${localizations?.classLabel ?? 'Class'}: $className - ${localizations?.dateLabel ?? 'Date'}: ${exam.examDate.toLocal().toString().split(' ')}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.assignment),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ManageExamSubjectsScreen(exam: exam),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AddEditExamScreen(exam: exam),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteExam(exam),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditExamScreen()),
          );
        },
        tooltip: localizations?.addExamTooltip ?? 'Add Exam',
        child: Icon(Icons.add),
      ),
    );
  }
}