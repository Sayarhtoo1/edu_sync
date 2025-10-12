import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/models/school_class.dart';
import 'package:edu_sync/screens/admin/add_edit_student_screen.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class TeacherStudentManagementScreen extends StatefulWidget {
  const TeacherStudentManagementScreen({super.key});

  @override
  State<TeacherStudentManagementScreen> createState() => _TeacherStudentManagementScreenState();
}

class _TeacherStudentManagementScreenState extends State<TeacherStudentManagementScreen> {
  late final StudentService _studentService;
  late final AuthService _authService;
  late final ClassService _classService;
  List<Student> _students = [];
  List<SchoolClass> _availableClasses = [];
  int? _selectedClassId;
  bool _isLoading = true;
  int? _currentSchoolId;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _studentService = Provider.of<StudentService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _classService = Provider.of<ClassService>(context, listen: false);
    _fetchSchoolIdAndLoadData();
  }

  Future<void> _fetchSchoolIdAndLoadData() async {
    setState(() => _isLoading = true);
    _currentSchoolId = await _authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      await _loadAvailableClasses();
      await _loadStudents();
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadAvailableClasses() async {
    if (_currentSchoolId == null) return;
    _availableClasses = await _classService.getClasses(_currentSchoolId!);
  }

  Future<void> _loadStudents() async {
    if (_currentSchoolId == null) return;
    setState(() => _isLoading = true);
    _students = await _studentService.getStudentsBySchool(_currentSchoolId!, classId: _selectedClassId);
    if (mounted) setState(() => _isLoading = false);
  }

  void _onClassFilterChanged(int? classId) {
    setState(() => _selectedClassId = classId);
    _loadStudents();
  }

  void _navigateToAddEditStudentScreen({Student? student}) async {
    if (_currentSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('School ID not found')));
      return;
    }
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditStudentScreen(student: student, schoolId: _currentSchoolId!)),
    );
    if (result == true) _loadStudents();
  }

  Future<void> _deleteStudent(int studentId) async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.confirmDeleteTitle ?? 'Confirm Delete'),
        content: Text(l10n?.confirmDeleteStudentText ?? 'Delete this student?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n?.cancel ?? 'Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final success = await _studentService.deleteStudent(studentId);
      if (success) {
        _loadStudents();
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete')));
      }
    }
  }

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students.where((s) => s.fullName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accentColor = AppTheme.getAccentColorForContext('teachers');

    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        title: Text(l10n?.manageStudentsTitle ?? 'My Students'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddEditStudentScreen(),
        backgroundColor: accentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Student', style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(l10n, accentColor),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: accentColor))
                : _filteredStudents.isEmpty
                    ? _buildEmptyState(l10n, accentColor)
                    : RefreshIndicator(
                        onRefresh: _loadStudents,
                        color: accentColor,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                          itemCount: _filteredStudents.length,
                          itemBuilder: (context, index) => _buildStudentCard(_filteredStudents[index], accentColor),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(AppLocalizations? l10n, Color accentColor) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.withAlpha(20), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search students...',
                border: InputBorder.none,
                prefixIcon: Icon(Icons.search, color: accentColor),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchQuery = ''))
                    : null,
              ),
            ),
          ),
          if (_availableClasses.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: cardBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withAlpha(20), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: DropdownButtonFormField<int?>(
                value: _selectedClassId,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.class_, color: accentColor),
                  hintText: l10n?.allClasses ?? 'All Classes',
                ),
                items: [
                  DropdownMenuItem<int?>(value: null, child: Text(l10n?.allClasses ?? 'All Classes')),
                  ..._availableClasses.map((cls) => DropdownMenuItem<int?>(value: cls.id, child: Text(cls.name))),
                ],
                onChanged: _onClassFilterChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations? l10n, Color accentColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: accentColor.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(l10n?.noStudentsFound ?? 'No students found', style: TextStyle(fontSize: 16, color: textDarkGrey.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student, Color accentColor) {
    return GestureDetector(
      onTap: () => context.push('/student/profile', extra: student),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withAlpha(20), spreadRadius: 1, blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  image: student.profilePhotoUrl != null && student.profilePhotoUrl!.isNotEmpty
                      ? DecorationImage(image: CachedNetworkImageProvider(student.profilePhotoUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: student.profilePhotoUrl == null || student.profilePhotoUrl!.isEmpty
                    ? Icon(Icons.person, color: accentColor, size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.badge, size: 14, color: textDarkGrey.withOpacity(0.6)),
                        const SizedBox(width: 4),
                        Text('ID: ${student.id}', style: TextStyle(fontSize: 12, color: textDarkGrey.withOpacity(0.6))),
                        if (student.classId != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.class_, size: 14, color: textDarkGrey.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text('Class: ${student.classId}', style: TextStyle(fontSize: 12, color: textDarkGrey.withOpacity(0.6))),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.edit_outlined, color: accentColor),
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
  }
}
