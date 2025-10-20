import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/models/school_class.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_add_edit_student.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopStudentManagement extends StatefulWidget {
  const DesktopStudentManagement({super.key});

  @override
  State<DesktopStudentManagement> createState() => _DesktopStudentManagementState();
}

class _DesktopStudentManagementState extends State<DesktopStudentManagement> {
  List<Student> _students = [];
  List<SchoolClass> _availableClasses = [];
  int? _selectedClassId;
  bool _isLoading = true;
  int? _currentSchoolId;
  String _searchQuery = '';
  String _viewMode = 'table'; // 'table' or 'grid'

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final classService = context.read<ClassService>();
    
    _currentSchoolId = await authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      _availableClasses = await classService.getClasses(_currentSchoolId!);
      await _loadStudents();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadStudents() async {
    if (_currentSchoolId == null) return;
    final studentService = context.read<StudentService>();
    _students = (await studentService.getStudentsBySchool(_currentSchoolId!, classId: _selectedClassId)).cast<Student>();
    setState(() {});
  }

  List<Student> get _filteredStudents {
    if (_searchQuery.isEmpty) return _students;
    return _students.where((s) => s.fullName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Student Management',
      actions: [
        IconButton(
          icon: Icon(_viewMode == 'table' ? Icons.grid_view : Icons.table_rows),
          onPressed: () => setState(() => _viewMode = _viewMode == 'table' ? 'grid' : 'table'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () async {
            if (_currentSchoolId != null) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DesktopAddEditStudent(schoolId: _currentSchoolId!)),
              );
              if (result == true) _loadStudents();
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Student'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildFilters(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _filteredStudents.isEmpty
                        ? _buildEmptyState()
                        : _viewMode == 'table'
                            ? _buildTableView()
                            : _buildGridView(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search students by name...',
              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF3498DB)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(width: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<int?>(
            value: _selectedClassId,
            hint: const Text('All Classes'),
            underline: const SizedBox(),
            onChanged: (value) {
              setState(() => _selectedClassId = value);
              _loadStudents();
            },
            items: [
              const DropdownMenuItem<int?>(value: null, child: Text('All Classes')),
              ..._availableClasses.map((c) => DropdownMenuItem<int?>(value: c.id, child: Text(c.name))),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.people, size: 20, color: Color(0xFF3498DB)),
              const SizedBox(width: 8),
              Text(
                '${_filteredStudents.length} Students',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No students found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first student to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildTableView() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 60),
                const Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Student ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Class', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(width: 140, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredStudents.length,
              itemBuilder: (context, index) {
                final student = _filteredStudents[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                  ),
                  child: InkWell(
                    onTap: () => context.push('/student/profile', extra: student),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3498DB).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              image: student.profilePhotoUrl != null && student.profilePhotoUrl!.isNotEmpty
                                  ? DecorationImage(image: CachedNetworkImageProvider(student.profilePhotoUrl!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: student.profilePhotoUrl == null || student.profilePhotoUrl!.isEmpty
                                ? const Icon(Icons.person, color: Color(0xFF3498DB), size: 20)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 2,
                            child: Text(student.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                          Expanded(child: Text('${student.id}', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          Expanded(child: Text(student.classId?.toString() ?? 'N/A', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          Expanded(child: Text(student.gender ?? 'N/A', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          Expanded(child: Text(student.phoneNumber1 ?? 'N/A', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF3498DB)),
                                  onPressed: () => context.push('/student/profile', extra: student),
                                  tooltip: 'View',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2ECC71)),
                                  onPressed: () async {
                                    if (_currentSchoolId != null) {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => DesktopAddEditStudent(student: student, schoolId: _currentSchoolId!)),
                                      );
                                      if (result == true) _loadStudents();
                                    }
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  onPressed: () => _deleteStudent(student),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredStudents.length,
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Student student) {
    return InkWell(
      onTap: () => context.push('/student/profile', extra: student),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(25),
                image: student.profilePhotoUrl != null && student.profilePhotoUrl!.isNotEmpty
                    ? DecorationImage(image: CachedNetworkImageProvider(student.profilePhotoUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: student.profilePhotoUrl == null || student.profilePhotoUrl!.isEmpty
                  ? const Icon(Icons.person, color: Color(0xFF3498DB), size: 24)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              student.fullName,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'ID: ${student.id}',
              style: TextStyle(fontSize: 10, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteStudent(Student student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${student.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final studentService = context.read<StudentService>();
      await studentService.deleteStudent(student.id);
      _loadStudents();
    }
  }
}
