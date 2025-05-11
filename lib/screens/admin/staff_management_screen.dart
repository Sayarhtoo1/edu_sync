import 'package:flutter/material.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'add_edit_teacher_screen.dart'; 
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  final AuthService _authService = AuthService();
  // final SchoolService _schoolService = SchoolService(); // Unused
  List<app_user.User> _teachers = [];
  bool _isLoading = true;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _loadStaffData();
  }

  Future<void> _loadStaffData() async {
    setState(() => _isLoading = true);
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null && currentUser.userMetadata?['school_id'] != null) {
      _currentSchoolId = currentUser.userMetadata!['school_id'] as int;
      if (_currentSchoolId != null) {
        _teachers = await _authService.getUsersByRole('Teacher', _currentSchoolId!);
      }
    } else {
      // Handle user not having school_id or not being logged in
      // print("Admin's school ID not found."); // Removed print
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddEditTeacherScreen({app_user.User? teacher}) async {
    if (_currentSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot add/edit teacher: School ID not found.'))
      );
      return;
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditTeacherScreen(teacher: teacher, schoolId: _currentSchoolId!),
      ),
    );
    if (result == true) { // Check if a teacher was added/updated
      _loadStaffData(); // Refresh the list
    }
  }

  Future<void> _deleteTeacher(String teacherId) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteTeacherText), 
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
      final success = await _authService.deleteUser(teacherId);
      if (success) {
        _loadStaffData(); // Refresh list
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete teacher.')),
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
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('teachers');

    return Scaffold(
      appBar: AppBar( 
        title: Text(l10n.manageTeachersTitle), 
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: contextualAccentColor),
            tooltip: l10n.addTeacherButton,
            onPressed: () => _navigateToAddEditTeacherScreen(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : RefreshIndicator(
              onRefresh: _loadStaffData,
              color: contextualAccentColor,
              child: _teachers.isEmpty
                  ? Center(child: Text(l10n.noTeachersFound, style: theme.textTheme.bodyLarge)) 
                  : ListView.builder(
                      itemCount: _teachers.length,
                      itemBuilder: (context, index) {
                        final teacher = _teachers[index];
                        return Card( 
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: contextualAccentColor.withAlpha((255 * 0.2).round()), // Use withAlpha
                              backgroundImage: teacher.profilePhotoUrl != null && teacher.profilePhotoUrl!.isNotEmpty
                                  ? NetworkImage(teacher.profilePhotoUrl!)
                                  : null,
                              child: teacher.profilePhotoUrl == null || teacher.profilePhotoUrl!.isEmpty
                                  ? Icon(Icons.person_outline, color: contextualAccentColor)
                                  : null,
                            ),
                            title: Text(teacher.fullName ?? 'N/A', style: theme.textTheme.titleMedium),
                            subtitle: Text(teacher.id, style: theme.textTheme.bodySmall), 
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: theme.iconTheme.color ?? textDarkGrey), 
                                  tooltip: l10n.editButton, 
                                  onPressed: () => _navigateToAddEditTeacherScreen(teacher: teacher),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                  tooltip: l10n.deleteButton, 
                                  onPressed: () => _deleteTeacher(teacher.id),
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
