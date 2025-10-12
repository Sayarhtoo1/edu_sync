import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/class_service.dart'; // New import
import 'package:edu_sync/models/school_class.dart'; // New import
import 'add_edit_student_screen.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
// Import AppTheme
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  late final StudentService _studentService;
  late final AuthService _authService;
  late final ClassService _classService; // New variable
  List<Student> _students = [];
  List<SchoolClass> _availableClasses = []; // New variable
  int? _selectedClassId; // New variable
  bool _isLoading = true;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _studentService = Provider.of<StudentService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _classService = Provider.of<ClassService>(context, listen: false); // Initialize ClassService
    _fetchSchoolIdAndLoadData(); // Renamed method
  }

  Future<void> _fetchSchoolIdAndLoadData() async { // Renamed method
    setState(() => _isLoading = true);
    _currentSchoolId = await _authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      await _loadAvailableClasses(); // New call
      await _loadStudents();
    } else {
      // logger.w("School ID not found for current user. Cannot load students.");
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadAvailableClasses() async {
    if (_currentSchoolId == null) return;
    setState(() => _isLoading = true);
    _availableClasses = await _classService.getClasses(_currentSchoolId!);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadStudents() async {
    if (_currentSchoolId == null) return;
    setState(() => _isLoading = true);
    _students = (await _studentService.getStudentsBySchool(
      _currentSchoolId!,
      classId: _selectedClassId, // Pass selected class ID
    )).cast<Student>();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onClassFilterChanged(int? classId) {
    setState(() {
      _selectedClassId = classId;
    });
    _loadStudents();
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
        title: Text(l10n?.confirmDeleteTitle ?? 'Confirm Delete'),
        content: Text(l10n?.confirmDeleteStudentText ?? 'Are you sure you want to delete this student?'), 
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(l10n?.manageStudentsTitle ?? 'Manage Students', style: const TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: DropdownButton<int?>(
              value: _selectedClassId,
              hint: Text(l10n?.allClasses ?? 'All Classes'),
              onChanged: _onClassFilterChanged,
              underline: const SizedBox(),
              items: [
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(l10n?.allClasses ?? 'All Classes'),
                ),
                ..._availableClasses.map((schoolClass) => DropdownMenuItem<int?>(
                  value: schoolClass.id,
                  child: Text(schoolClass.name),
                )),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2196F3),
        onPressed: () => _navigateToAddEditStudentScreen(),
        child: const Icon(Icons.add_rounded),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStudents,
              child: _students.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(l10n?.noStudentsFound ?? 'No students found', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _students.length,
                      itemBuilder: (context, index) {
                        final student = _students[index];
                        return GestureDetector(
                          onTap: () => context.push('/student/profile', extra: student),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2196F3).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  image: student.profilePhotoUrl != null && student.profilePhotoUrl!.isNotEmpty
                                      ? DecorationImage(image: CachedNetworkImageProvider(student.profilePhotoUrl!), fit: BoxFit.cover)
                                      : null,
                                ),
                                child: student.profilePhotoUrl == null || student.profilePhotoUrl!.isEmpty
                                    ? const Icon(Icons.school_rounded, color: Color(0xFF2196F3))
                                    : null,
                              ),
                              title: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text('ID: ${student.id} - Class: ${student.classId ?? "N/A"}', style: TextStyle(color: Colors.grey[600])),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined, color: Colors.grey[700]),
                                    onPressed: () => _navigateToAddEditStudentScreen(student: student),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteStudent(student.id),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
