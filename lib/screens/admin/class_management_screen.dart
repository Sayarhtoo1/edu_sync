import 'package:flutter/material.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'add_edit_class_screen.dart'; 
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final ClassService _classService = ClassService();
  final AuthService _authService = AuthService();
  List<app_class.SchoolClass> _classes = [];
  bool _isLoading = true;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _fetchSchoolIdAndLoadClasses();
  }

  Future<void> _fetchSchoolIdAndLoadClasses() async {
    setState(() => _isLoading = true);
    _currentSchoolId = await _authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      await _loadClasses();
    } else {
      // print("School ID not found. Cannot load classes."); // Removed print
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
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteClassText), // Use specific key
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
      setState(() => _isLoading = true);
      final success = await _classService.deleteClass(classId);
      if (success) {
        _loadClasses(); // Refresh list
      } else {
         if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete class.')),
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
        title: Text(l10n.manageClassesTitle), 
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: contextualAccentColor),
            tooltip: l10n.addClassButton, 
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
                  ? Center(child: Text(l10n.noClassesFound, style: theme.textTheme.bodyLarge)) 
                  : ListView.builder(
                      itemCount: _classes.length,
                      itemBuilder: (context, index) {
                        final classItem = _classes[index];
                        // TODO: Fetch teacher name based on classItem.teacherId for a better display
                        String teacherDisplay = classItem.teacherId != null 
                            ? '${l10n.teacherLabel}: ${classItem.teacherId}' 
                            : l10n.noTeacherAssigned; 

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
                                  tooltip: l10n.editButton, 
                                  onPressed: () => _navigateToAddEditClassScreen(classDetails: classItem),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                  tooltip: l10n.deleteButton, 
                                  onPressed: () {
                                    if (classItem.id != null) {
                                      _deleteClass(classItem.id!); 
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(l10n.cannotDeleteMissingIdError)) 
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
