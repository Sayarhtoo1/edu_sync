import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../models/grade.dart';
import '../../../providers/school_provider.dart';
import '../../../l10n/gen/app_localizations.dart';

class GradeManagementScreen extends StatefulWidget {
  const GradeManagementScreen({super.key});

  @override
  _GradeManagementScreenState createState() => _GradeManagementScreenState();
}

class _GradeManagementScreenState extends State<GradeManagementScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final schoolId = schoolProvider.currentSchool?.id.toString();

    if (schoolId != null) {
      await examProvider.fetchGrades(schoolId);
    }
  }

  Future<void> _addEditGrade({Grade? grade}) async {
    final localizations = AppLocalizations.of(context);
    final TextEditingController gradeNameController = TextEditingController(text: grade?.gradeName ?? '');
    final TextEditingController minPercentageController = TextEditingController(text: grade?.minPercentage.toString() ?? '');
    final TextEditingController maxPercentageController = TextEditingController(text: grade?.maxPercentage.toString() ?? '');
    final TextEditingController remarksController = TextEditingController(text: grade?.remarks ?? '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(grade == null ? localizations!.addGradeTitle : localizations!.editGradeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: gradeNameController,
              decoration: InputDecoration(labelText: localizations.gradeNameLabel),
            ),
            TextField(
              controller: minPercentageController,
              decoration: InputDecoration(labelText: localizations.minPercentageLabel),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: maxPercentageController,
              decoration: InputDecoration(labelText: localizations.maxPercentageLabel),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: remarksController,
              decoration: InputDecoration(labelText: localizations.remarksLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (gradeNameController.text.isEmpty ||
                  minPercentageController.text.isEmpty ||
                  maxPercentageController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.fillAllRequiredFields)),
                );
                return;
              }

              final minPercentage = int.tryParse(minPercentageController.text);
              final maxPercentage = int.tryParse(maxPercentageController.text);

              if (minPercentage == null || maxPercentage == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.error_invalid_number)),
                );
                return;
              }

              final examProvider = Provider.of<ExamProvider>(context, listen: false);
              final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
              final schoolId = schoolProvider.currentSchool?.id.toString();

              final schoolIdInt = schoolProvider.currentSchool?.id;

              if (schoolIdInt != null) {
                if (grade == null) {
                  await examProvider.addGrade(
                    schoolId: schoolIdInt,
                    gradeName: gradeNameController.text,
                    minPercentage: minPercentage,
                    maxPercentage: maxPercentage,
                    remarks: remarksController.text,
                  );
                } else {
                  await examProvider.updateGrade(
                    id: grade.id,
                    gradeName: gradeNameController.text,
                    minPercentage: minPercentage,
                    maxPercentage: maxPercentage,
                    remarks: remarksController.text,
                    schoolId: schoolIdInt,
                  );
                }
                _fetchGrades();
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(localizations.error_school_not_found ?? 'School not found')),
                );
              }
            },
            child: Text(localizations.saveButton),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGrade(Grade grade) async {
    final localizations = AppLocalizations.of(context);
    final bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations!.confirmDeleteTitle),
        content: Text(localizations.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localizations.delete),
          ),
        ],
      ),
    ) ?? false;

    if (confirm) {
      final examProvider = Provider.of<ExamProvider>(context, listen: false);
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      final schoolId = schoolProvider.currentSchool?.id.toString();

      if (schoolId != null) {
        await examProvider.deleteGrade(grade.id, schoolId);
        _fetchGrades();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.error_school_not_found ?? 'School not found')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations!.manageGradesTitle),
      ),
      body: examProvider.grades.isEmpty
          ? Center(child: Text(localizations.noGradesFound))
          : ListView.builder(
              itemCount: examProvider.grades.length,
              itemBuilder: (context, index) {
                final grade = examProvider.grades[index];
                return ListTile(
                  title: Text(grade.gradeName),
                  subtitle: Text(
                      '${localizations.minPercentageLabel}: ${grade.minPercentage}% - ${localizations.maxPercentageLabel}: ${grade.maxPercentage}%'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _addEditGrade(grade: grade),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteGrade(grade),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEditGrade(),
        tooltip: localizations.addGradeTooltip,
        child: Icon(Icons.add),
      ),
    );
  }
}
