import 'package:flutter/material.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'add_edit_class_screen.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  late final ClassService _classService;
  late final AuthService _authService;
  List<app_class.SchoolClass> _classes = [];
  bool _isLoading = true;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _classService = Provider.of<ClassService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _fetchSchoolIdAndLoadClasses();
  }

  Future<void> _fetchSchoolIdAndLoadClasses() async {
    setState(() => _isLoading = true);
    _currentSchoolId = await _authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      await _loadClasses();
    } else {
      // logger.w("School ID not found. Cannot load classes.");
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadClasses() async {
    if (_currentSchoolId == null) return;
    setState(() => _isLoading = true);
    _classes = await _classService.getClasses(_currentSchoolId!);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddEditClassScreen({app_class.SchoolClass? classDetails}) async {
     if (_currentSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot add/edit class: School ID not found.'))
      );
      return;
    }
    // final result = await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => AddEditClassScreen(classDetails: classDetails, schoolId: _currentSchoolId!),
    //   ),
    // );
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditClassScreen(classDetails: classDetails, schoolId: _currentSchoolId!),
      ),
    );
    if (result == true) {
      _loadClasses();
    }
  }

  Future<void> _deleteClass(int classId) async { 
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(l10n?.confirmDeleteTitle ?? 'Confirm Delete'),
        content: Text(l10n?.confirmDeleteClassText ?? 'Are you sure you want to delete this class?'), // Use specific key
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
      setState(() => _isLoading = true);
      try {
        await _classService.deleteClass(classId);
        _loadClasses(); // Refresh list
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete class: ${e.toString()}')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('students');

    return Scaffold(
      appBar: AppBar( 
        title: Text(l10n?.manageClassesTitle ?? 'Manage Classes'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: contextualAccentColor),
            tooltip: l10n?.addClassButton ?? 'Add Class',
            onPressed: () => _navigateToAddEditClassScreen(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : RefreshIndicator(
              onRefresh: _loadClasses,
              color: contextualAccentColor,
              child: _classes.isEmpty
                  ? Center(child: Text(l10n?.noClassesFound ?? 'No classes found', style: theme.textTheme.bodyLarge))
                  : ListView.builder(
                      itemCount: _classes.length,
                      itemBuilder: (context, index) {
                        final classItem = _classes[index];
                        // TODO: Fetch teacher name based on classItem.teacherId for a better display
                        String teacherDisplay = classItem.teacherId != null
                            ? '${l10n?.teacherLabel ?? 'Teacher'}: ${classItem.teacherId}'
                            : l10n?.noTeacherAssigned ?? 'No Teacher Assigned';

                        return Card( 
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: Icon(Icons.class_outlined, color: theme.iconTheme.color),
                            title: Text(classItem.name, style: theme.textTheme.titleMedium),
                            subtitle: Text(teacherDisplay, style: theme.textTheme.bodySmall), 
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: theme.iconTheme.color ?? textDarkGrey), 
                                  tooltip: l10n?.editButton ?? 'Edit',
                                  onPressed: () => _navigateToAddEditClassScreen(classDetails: classItem),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                  tooltip: l10n?.deleteButton ?? 'Delete',
                                  onPressed: () {
                                    if (classItem.id != null) {
                                      _deleteClass(classItem.id!); 
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n?.cannotDeleteMissingIdError ?? 'Cannot delete class: ID is missing'))
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
