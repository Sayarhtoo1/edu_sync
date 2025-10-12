import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../providers/school_provider.dart';
import '../../../models/grade.dart';
import '../../../theme/app_theme.dart';

class GradeManagementScreen extends StatefulWidget {
  const GradeManagementScreen({super.key});

  @override
  State<GradeManagementScreen> createState() => _GradeManagementScreenState();
}

class _GradeManagementScreenState extends State<GradeManagementScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    setState(() => _isLoading = true);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    final examProvider = Provider.of<ExamProvider>(context, listen: false);
    
    if (schoolProvider.currentSchool != null) {
      await examProvider.fetchGrades(schoolProvider.currentSchool!.id.toString());
    }
    setState(() => _isLoading = false);
  }

  void _showAddGradeDialog() {
    final nameController = TextEditingController();
    final minController = TextEditingController();
    final maxController = TextEditingController();
    final remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Grade'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Grade Name (e.g., A, B, C)'),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: minController,
                decoration: const InputDecoration(labelText: 'Min Percentage'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxController,
                decoration: const InputDecoration(labelText: 'Max Percentage'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: remarksController,
                decoration: const InputDecoration(labelText: 'Remarks (e.g., Excellent)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || minController.text.isEmpty || maxController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all required fields')),
                );
                return;
              }

              Navigator.pop(context);
              final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
              await Provider.of<ExamProvider>(context, listen: false).addGrade(
                schoolId: schoolProvider.currentSchool!.id,
                gradeName: nameController.text,
                minPercentage: int.parse(minController.text),
                maxPercentage: int.parse(maxController.text),
                remarks: remarksController.text,
              );
              _loadGrades();
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditGradeDialog(Grade grade) {
    final nameController = TextEditingController(text: grade.gradeName);
    final minController = TextEditingController(text: grade.minPercentage.toString());
    final maxController = TextEditingController(text: grade.maxPercentage.toString());
    final remarksController = TextEditingController(text: grade.remarks);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Grade'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Grade Name'),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: minController,
                decoration: const InputDecoration(labelText: 'Min Percentage'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxController,
                decoration: const InputDecoration(labelText: 'Max Percentage'),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: remarksController,
                decoration: const InputDecoration(labelText: 'Remarks'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
              await Provider.of<ExamProvider>(context, listen: false).updateGrade(
                id: grade.id,
                schoolId: schoolProvider.currentSchool!.id,
                gradeName: nameController.text,
                minPercentage: int.parse(minController.text),
                maxPercentage: int.parse(maxController.text),
                remarks: remarksController.text,
              );
              _loadGrades();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _deleteGrade(Grade grade) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Grade'),
        content: Text('Delete grade "${grade.gradeName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
      await Provider.of<ExamProvider>(context, listen: false)
          .deleteGrade(grade.id, schoolProvider.currentSchool!.id.toString());
      _loadGrades();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Management'),
        backgroundColor: appBackgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Consumer<ExamProvider>(
              builder: (context, examProvider, child) {
                final grades = examProvider.grades;

                if (grades.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.grade, size: 64, color: Colors.grey.withOpacity(0.5)),
                        const SizedBox(height: 16),
                        const Text('No grades defined'),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: _showAddGradeDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Grade'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: grades.length,
                  itemBuilder: (context, index) {
                    final grade = grades[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getGradeColor(grade.minPercentage),
                          child: Text(
                            grade.gradeName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(grade.gradeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${grade.minPercentage}% - ${grade.maxPercentage}%\n${grade.remarks}'),
                        isThreeLine: true,
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditGradeDialog(grade);
                            } else if (value == 'delete') {
                              _deleteGrade(grade);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGradeDialog,
        backgroundColor: defaultAccentColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getGradeColor(int minPercentage) {
    if (minPercentage >= 90) return Colors.green;
    if (minPercentage >= 80) return Colors.blue;
    if (minPercentage >= 70) return Colors.orange;
    if (minPercentage >= 60) return Colors.yellow.shade700;
    return Colors.red;
  }
}
