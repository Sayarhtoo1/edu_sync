import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/exam_provider.dart';
import '../../../models/exam.dart';
import '../../../models/subject.dart';
import '../../../models/exam_subject.dart';
import '../../../l10n/gen/app_localizations.dart';

class ModernManageExamSubjectsScreen extends StatefulWidget {
  final Exam exam;

  const ModernManageExamSubjectsScreen({super.key, required this.exam});

  @override
  _ModernManageExamSubjectsScreenState createState() => _ModernManageExamSubjectsScreenState();
}

class _ModernManageExamSubjectsScreenState extends State<ModernManageExamSubjectsScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  final Map<String, TextEditingController> _maxMarksControllers = {};
  final Map<String, TextEditingController> _passingMarksControllers = {};
  final Map<String, String?> _examSubjectIds = {};

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _maxMarksControllers.forEach((key, controller) => controller.dispose());
    _passingMarksControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
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

      _maxMarksControllers[subject.id] = TextEditingController(
        text: existingExamSubject.maxMarks > 0 ? existingExamSubject.maxMarks.toString() : '',
      );
      _passingMarksControllers[subject.id] = TextEditingController(
        text: existingExamSubject.passingMarks > 0 ? existingExamSubject.passingMarks.toString() : '',
      );
      _examSubjectIds[subject.id] = existingExamSubject.id.isNotEmpty ? existingExamSubject.id : null;
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      _slideController.forward();
    }
  }

  Future<void> _saveExamSubjects() async {
    final examProvider = Provider.of<ExamProvider>(context, listen: false);

    for (var subject in examProvider.subjects) {
      final maxMarks = int.tryParse(_maxMarksControllers[subject.id]?.text ?? '0') ?? 0;
      final passingMarks = int.tryParse(_passingMarksControllers[subject.id]?.text ?? '0') ?? 0;

      if (maxMarks > 0 && passingMarks > 0) {
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
    }

    _showSuccessSnackBar('Exam subjects saved successfully');
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = Provider.of<ExamProvider>(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Exam Subjects',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
              onPressed: _saveExamSubjects,
              child: const Text(
                'Save All',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: _isLoading
            ? _buildLoadingState()
            : FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.1),
                    end: Offset.zero,
                  ).animate(_slideController),
                  child: examProvider.subjects.isEmpty
                      ? _buildEmptyState()
                      : _buildSubjectsList(examProvider.subjects),
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: const Icon(
              Icons.subject,
              color: Colors.white,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Subjects...',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade100,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.subject_outlined,
              color: Colors.grey.shade400,
              size: 60,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Subjects Found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add subjects to this class first',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(List<Subject> subjects) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildSubjectCard(subject);
      },
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shadowColor: Theme.of(context).primaryColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.book,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Configure exam settings for this subject',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMarksField(
                    controller: _maxMarksControllers[subject.id]!,
                    label: 'Maximum Marks',
                    hintText: 'Enter max marks',
                    icon: Icons.score,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMarksField(
                    controller: _passingMarksControllers[subject.id]!,
                    label: 'Passing Marks',
                    hintText: 'Enter passing marks',
                    icon: Icons.verified,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarksField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final marks = int.tryParse(value);
          if (marks == null || marks < 0) {
            return 'Enter valid marks';
          }
        }
        return null;
      },
    );
  }
}
