import 'package:flutter/material.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'add_edit_class_screen.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:go_router/go_router.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  late final ClassService _classService;
  late final AuthService _authService;
  List<app_class.SchoolClass> _classes = [];
  Map<String, app_user.User> _teachers = {};
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
    
    // Load teacher names
    for (var classItem in _classes) {
      if (classItem.teacherId != null && !_teachers.containsKey(classItem.teacherId)) {
        final teacher = await _authService.getUserById(classItem.teacherId!);
        if (teacher != null) {
          _teachers[classItem.teacherId!] = teacher;
        }
      }
    }
    
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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(l10n?.manageClassesTitle ?? 'Manage Classes', style: const TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9C27B0),
        onPressed: () => _navigateToAddEditClassScreen(),
        child: const Icon(Icons.add_rounded),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadClasses,
              child: _classes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.class_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(l10n?.noClassesFound ?? 'No classes found', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _classes.length,
                      itemBuilder: (context, index) {
                        final classItem = _classes[index];
                        final teacher = classItem.teacherId != null ? _teachers[classItem.teacherId] : null;
                        String teacherDisplay = teacher?.fullName ?? 'No Teacher Assigned';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
                          ),
                          child: InkWell(
                            onTap: () => context.push('/admin/class-profile', extra: classItem),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [BoxShadow(color: const Color(0xFF9C27B0).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))],
                                    ),
                                    child: const Icon(Icons.class_rounded, color: Colors.white, size: 28),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(classItem.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                teacherDisplay,
                                                style: TextStyle(color: teacher != null ? Colors.green : Colors.orange, fontSize: 13, fontWeight: FontWeight.w500),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    onSelected: (value) {
                                      if (value == 'edit') {
                                        _navigateToAddEditClassScreen(classDetails: classItem);
                                      } else if (value == 'delete' && classItem.id != null) {
                                        _deleteClass(classItem.id!);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
                                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                                    ],
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
