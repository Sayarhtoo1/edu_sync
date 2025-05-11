import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/models/class.dart' as app_class;
import 'package:edu_sync/models/lesson_plan.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/lesson_plan_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'add_edit_lesson_plan_screen.dart'; 
import 'package:edu_sync/theme/app_theme.dart'; // Ensure AppTheme is imported

class LessonPlanManagementScreen extends StatefulWidget {
  const LessonPlanManagementScreen({super.key});

  @override
  State<LessonPlanManagementScreen> createState() => _LessonPlanManagementScreenState();
}

class _LessonPlanManagementScreenState extends State<LessonPlanManagementScreen> {
  final ClassService _classService = ClassService();
  final LessonPlanService _lessonPlanService = LessonPlanService();
  final AuthService _authService = AuthService();

  List<app_class.Class> _teacherClasses = [];
  app_class.Class? _selectedClass;
  List<LessonPlan> _lessonPlans = [];
  
  bool _isLoadingClasses = true;
  bool _isLoadingLessonPlans = false;
  String? _currentUserId; // Changed from _currentTeacherId
  String? _currentUserRole;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingClasses = true);
    final currentUser = _authService.getCurrentUser();
    _currentUserRole = _authService.getUserRole();

    if (currentUser == null || _currentUserRole == null) {
      if (mounted) setState(() => _isLoadingClasses = false);
      return;
    }
    _currentUserId = currentUser.id;
    _currentSchoolId = await _authService.getCurrentUserSchoolId();

    if (_currentSchoolId != null && _currentUserId != null) {
      List<app_class.Class> allClassesInSchool = await _classService.getClassesBySchool(_currentSchoolId!);
      if (_currentUserRole == 'Teacher') {
        _teacherClasses = allClassesInSchool.where((c) => c.teacherId == _currentUserId).toList();
      } else if (_currentUserRole == 'Admin') {
        _teacherClasses = allClassesInSchool; // Admin sees all classes
      } else {
        _teacherClasses = [];
      }
      
      if (_teacherClasses.isNotEmpty) {
        // For Admins, don't auto-select a class. Let them choose.
        // For Teachers, could auto-select if desired, or also let them choose.
        // _selectedClass = _teacherClasses.first; 
        // await _loadLessonPlansForClass();
      }
    }
    if (mounted) {
      setState(() => _isLoadingClasses = false);
    }
  }

  Future<void> _loadLessonPlansForClass() async {
    if (_selectedClass == null) {
      setState(() => _lessonPlans = []);
      return;
    }
    setState(() => _isLoadingLessonPlans = true);
    // The getLessonPlans service method can take teacherId and subjectName,
    // but our current LessonPlan model doesn't store these directly.
    // For now, we fetch by classId only.
    // _selectedClass.id is int?, getLessonPlans expects int classId
    if (_selectedClass!.id == null) { // Guard against null id
      if (mounted) setState(() => _isLoadingLessonPlans = false);
      return;
    }
    _lessonPlans = await _lessonPlanService.getLessonPlans(classId: _selectedClass!.id!); 
    if (mounted) {
      setState(() => _isLoadingLessonPlans = false);
    }
  }

  void _navigateToAddEditScreen([LessonPlan? lessonPlan]) {
    if (_selectedClass == null || _currentUserId == null || _currentSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseSelectClass)), 
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditLessonPlanScreen(
          schoolId: _currentSchoolId!,
          teacherId: _currentUserId!, 
          lessonPlan: lessonPlan,
          initialClassId: _selectedClass!.id, // _selectedClass.id is int?
        ),
      ),
    ).then((result) {
      if (result == true) { // Assuming AddEdit screen pops with true on success
        _loadLessonPlansForClass();
      }
    });
  }

  Future<void> _deleteLessonPlan(int lessonPlanId) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( // DialogTheme applied globally
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteLessonPlanText),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true), 
            child: Text(l10n.delete)
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoadingLessonPlans = true);
      final success = await _lessonPlanService.deleteLessonPlan(lessonPlanId);
      if (success) {
        _loadLessonPlansForClass(); // Reload
      } else {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(AppLocalizations.of(context).errorDeletingLessonPlan)),
            );
            setState(() => _isLoadingLessonPlans = false);
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    return Scaffold( // Scaffold uses appBackgroundColor from theme
      appBar: AppBar( // AppBar uses appBarTheme from theme
        title: Text(l10n.manageLessonPlansTitle),
      ),
      body: _isLoadingClasses
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  child: DropdownButtonFormField<app_class.Class>(
                    value: _selectedClass,
                    hint: Text(l10n.selectClassHint, style: theme.textTheme.bodyLarge), 
                    items: _teacherClasses.map((app_class.Class cls) {
                      return DropdownMenuItem<app_class.Class>(
                        value: cls,
                        child: Text(cls.name, style: theme.textTheme.bodyLarge),
                      );
                    }).toList(),
                    onChanged: (app_class.Class? newValue) {
                      setState(() {
                        _selectedClass = newValue;
                        _lessonPlans = []; 
                      });
                      if (newValue != null) {
                        _loadLessonPlansForClass();
                      }
                    },
                    decoration: InputDecoration(labelText: l10n.selectClassHint), // Uses global inputDecorationTheme
                  ),
                ),
                Expanded(
                  child: _isLoadingLessonPlans
                      ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                      : _selectedClass == null
                          ? Center(child: Text(l10n.pleaseSelectClassToViewLessonPlans, style: theme.textTheme.bodyLarge))
                          : _lessonPlans.isEmpty
                              ? Center(child: Text(l10n.noLessonPlansFound, style: theme.textTheme.bodyLarge))
                              : ListView.builder(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Adjusted padding
                                  itemCount: _lessonPlans.length,
                                  itemBuilder: (context, index) {
                                    final plan = _lessonPlans[index];
                                    return Card( // CardTheme applied globally
                                      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
                                      child: ListTile(
                                        leading: Icon(Icons.book_outlined, color: contextualAccentColor, size: 30),
                                        title: Text(plan.title, style: theme.textTheme.titleMedium),
                                        subtitle: Text(
                                          '${l10n.subjectLabel}: ${plan.subjectName}\n${l10n.date}: ${DateFormat.yMMMd(l10n.localeName).format(plan.date)}',
                                          style: theme.textTheme.bodySmall
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit_outlined, color: theme.iconTheme.color ?? textDarkGrey), // Use top-level constant
                                              tooltip: l10n.editLessonPlanTitle,
                                              onPressed: () => _navigateToAddEditScreen(plan),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                              tooltip: l10n.delete,
                                              onPressed: () {
                                                if (plan.id != null) {
                                                  _deleteLessonPlan(plan.id!);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                        onTap: () => _navigateToAddEditScreen(plan), 
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
      floatingActionButton: _selectedClass != null 
        ? FloatingActionButton.extended(
            backgroundColor: contextualAccentColor, // Themed FAB
            foregroundColor: Colors.white,
            onPressed: () => _navigateToAddEditScreen(),
            tooltip: l10n.addLessonPlanTooltip,
            icon: const Icon(Icons.add),
            label: Text(l10n.addLessonPlanTooltip), 
          )
        : null,
    );
  }
}
