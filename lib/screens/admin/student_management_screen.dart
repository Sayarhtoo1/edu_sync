import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/theme/app_theme.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'add_edit_student_screen.dart';
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
// Import AppTheme
import 'package:provider/provider.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  late final StudentService _studentService;
  late final AuthService _authService;
  List<Student> _students = [];
  bool _isLoading = true;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _studentService = Provider.of<StudentService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _fetchSchoolIdAndLoadStudents();
  }

  Future<void> _fetchSchoolIdAndLoadStudents() async {
    setState(() => _isLoading = true);
    _currentSchoolId = await _authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      await _loadStudents();
    } else {
      // logger.w("School ID not found for current user. Cannot load students.");
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStudents() async {
    if (_currentSchoolId == null) return;
    setState(() => _isLoading = true);
    _students = (await _studentService.getStudentsBySchool(_currentSchoolId!)).cast<Student>();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddEditStudentScreen({Student? student}) async {
    if (_currentSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot add/edit student: School ID not found.'))
      );
      return;
    }
    // final result = await Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (_) => AddEditStudentScreen(student: student, schoolId: _currentSchoolId!),
    //   ),
    // );
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditStudentScreen(student: student, schoolId: _currentSchoolId!),
      ),
    );
    if (result == true) {
      _loadStudents();
    }
  }

  Future<void> _deleteStudent(int studentId) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteStudentText), 
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
      final success = await _studentService.deleteStudent(studentId);
      if (success) {
        _loadStudents(); // Refresh list
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete student.')),
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
        title: Text(l10n.manageStudentsTitle), 
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: contextualAccentColor),
            tooltip: l10n.addStudentButton,
            onPressed: () => _navigateToAddEditStudentScreen(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : RefreshIndicator(
              onRefresh: _loadStudents,
              color: contextualAccentColor,
              child: _students.isEmpty
                  ? Center(child: Text(l10n.noStudentsFound, style: theme.textTheme.bodyLarge))
                  : ListView.builder(
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundColor: contextualAccentColor
                                  .withAlpha((255 * 0.2).round()),
                              child: student.profilePhotoUrl != null &&
                                      student.profilePhotoUrl!.isNotEmpty
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: student.profilePhotoUrl!,
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  contextualAccentColor),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.school_outlined,
                                                color: contextualAccentColor),
                                        fit: BoxFit.cover,
                                        width: 60,
                                        height: 60,
                                      ),
                                    )
                                  : Icon(Icons.school_outlined,
                                      color: contextualAccentColor),
                            ),
                            title: Text(student.fullName,
                                style: theme.textTheme.titleLarge),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                  'ID: ${student.id} - ${l10n.classLabel} ID: ${student.classId ?? l10n.not_specified}',
                                  style: theme.textTheme.bodyMedium),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit,
                                      color: theme.colorScheme.primary),
                                  tooltip: l10n.editButton,
                                  onPressed: () =>
                                      _navigateToAddEditStudentScreen(
                                          student: student),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: theme.colorScheme.error),
                                  tooltip: l10n.deleteButton,
                                  onPressed: () => _deleteStudent(student.id),
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
