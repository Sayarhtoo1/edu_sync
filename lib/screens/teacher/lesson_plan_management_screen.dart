import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/models/lesson_plan.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/services/lesson_plan_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import 'add_edit_lesson_plan_screen.dart';
import 'package:edu_sync/theme/app_theme.dart'; // Ensure AppTheme is imported
import 'package:provider/provider.dart';

class LessonPlanManagementScreen extends StatefulWidget {
  const LessonPlanManagementScreen({super.key});

  @override
  State<LessonPlanManagementScreen> createState() => _LessonPlanManagementScreenState();
}

class _LessonPlanManagementScreenState extends State<LessonPlanManagementScreen> {
  late final ClassService _classService;
  late final LessonPlanService _lessonPlanService;
  late final AuthService _authService;

  List<app_class.SchoolClass> _teacherClasses = [];
  app_class.SchoolClass? _selectedClass;
  List<LessonPlan> _lessonPlans = [];
  
  bool _isLoadingClasses = true;
  bool _isLoadingLessonPlans = false;
  String? _currentUserId; // Changed from _currentTeacherId
  String? _currentUserRole;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _classService = Provider.of<ClassService>(context, listen: false);
    _lessonPlanService = Provider.of<LessonPlanService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoadingClasses = true);
    final currentUser = _authService.getCurrentUser();
    _currentUserRole = await _authService.getUserRole();

    if (currentUser == null || _currentUserRole == null) {
      if (mounted) setState(() => _isLoadingClasses = false);
      return;
    }
    _currentUserId = currentUser.id;
    _currentSchoolId = await _authService.getCurrentUserSchoolId();

    if (_currentSchoolId != null && _currentUserId != null) {
      print('Fetching classes for school: $_currentSchoolId');
      List<app_class.SchoolClass> allClassesInSchool = await _classService.getClasses(_currentSchoolId!);
      print('Fetched ${allClassesInSchool.length} classes');
      if (_currentUserRole == UserRole.Teacher.name) {
        _teacherClasses = allClassesInSchool.where((c) => c.teacherId == _currentUserId).toList();
      } else if (_currentUserRole == UserRole.Admin.name) {
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
    final l10n = AppLocalizations.of(context);
    if (_selectedClass == null || _currentUserId == null || _currentSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.pleaseSelectClass ?? 'Please select a class.')), 
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
        title: Text(l10n?.confirmDeleteTitle ?? 'Confirm Delete'),
        content: Text(l10n?.confirmDeleteLessonPlanText ?? 'Are you sure you want to delete this lesson plan?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n?.cancel ?? 'Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true), 
            child: Text(l10n?.delete ?? 'Delete')
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
              SnackBar(content: Text(AppLocalizations.of(context)?.errorDeletingLessonPlan ?? 'Error deleting lesson plan.')),
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
        title: Text(l10n?.manageLessonPlansTitle ?? 'Manage Lesson Plans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
          ),
        ],
      ),
      body: _isLoadingClasses
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0), // Increased padding
                  child: DropdownButtonFormField<app_class.SchoolClass>(
                    value: _selectedClass,
                    hint: Text(l10n?.selectClassHint ?? 'Select Class', style: theme.textTheme.bodyLarge), 
                    items: _teacherClasses.map((app_class.SchoolClass cls) {
                      return DropdownMenuItem<app_class.SchoolClass>(
                        value: cls,
                        child: Text(cls.name, style: theme.textTheme.bodyLarge),
                      );
                    }).toList(),
                    onChanged: (app_class.SchoolClass? newValue) {
                      setState(() {
                        _selectedClass = newValue;
                        _lessonPlans = []; 
                      });
                      if (newValue != null) {
                        _loadLessonPlansForClass();
                      }
                    },
                    decoration: InputDecoration(labelText: l10n?.selectClassHint ?? 'Select Class'), // Uses global inputDecorationTheme
                  ),
                ),
                Expanded(
                  child: _isLoadingLessonPlans
                      ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                      : _selectedClass == null
                          ? Center(child: Text(l10n?.pleaseSelectClassToViewLessonPlans ?? 'Please select a class to view lesson plans.', style: theme.textTheme.bodyLarge))
                          : _lessonPlans.isEmpty
                              ? Center(child: Text(l10n?.noLessonPlansFound ?? 'No lesson plans found.', style: theme.textTheme.bodyLarge))
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
                                          '${l10n?.subjectLabel ?? 'Subject'}: ${plan.subjectName}\n${l10n?.date ?? 'Date'}: ${DateFormat.yMMMd(l10n?.localeName ?? 'en').format(plan.date)}',
                                          style: theme.textTheme.bodySmall
                                        ),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit_outlined, color: theme.iconTheme.color ?? textDarkGrey), // Use top-level constant
                                              tooltip: l10n?.editLessonPlanTitle ?? 'Edit Lesson Plan',
                                              onPressed: () => _navigateToAddEditScreen(plan),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                              tooltip: l10n?.delete ?? 'Delete',
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
            tooltip: l10n?.addLessonPlanTooltip ?? 'Add Lesson Plan',
            icon: const Icon(Icons.add),
            label: Text(l10n?.addLessonPlanTooltip ?? 'Add Lesson Plan'), 
          )
        : null,
    );
  }
}
