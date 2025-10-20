import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/models/school_class.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_add_edit_class.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopClassManagement extends StatefulWidget {
  const DesktopClassManagement({super.key});

  @override
  State<DesktopClassManagement> createState() => _DesktopClassManagementState();
}

class _DesktopClassManagementState extends State<DesktopClassManagement> {
  List<SchoolClass> _classes = [];
  bool _isLoading = true;
  int? _currentSchoolId;
  String _searchQuery = '';
  String _viewMode = 'grid';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    _currentSchoolId = await authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      await _loadClasses();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadClasses() async {
    if (_currentSchoolId == null) return;
    final classService = context.read<ClassService>();
    _classes = await classService.getClasses(_currentSchoolId!);
    setState(() {});
  }

  List<SchoolClass> get _filteredClasses {
    if (_searchQuery.isEmpty) return _classes;
    return _classes.where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Class Management',
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
                MaterialPageRoute(builder: (_) => DesktopAddEditClass(schoolId: _currentSchoolId!)),
              );
              if (result == true) _loadClasses();
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Class'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9B59B6),
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
                    child: _filteredClasses.isEmpty
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
              hintText: 'Search classes...',
              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF9B59B6)),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        const SizedBox(width: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              const Icon(Icons.class_, size: 20, color: Color(0xFF9B59B6)),
              const SizedBox(width: 8),
              Text('${_filteredClasses.length} Classes', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
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
          Icon(Icons.class_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No classes found', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                const SizedBox(width: 60),
                const Expanded(flex: 2, child: Text('Class Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Class ID', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(width: 140, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredClasses.length,
              itemBuilder: (context, index) {
                final classItem = _filteredClasses[index];
                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                  child: InkWell(
                    onTap: () => context.push('/admin/class-profile', extra: classItem),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.class_, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: Text(classItem.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                          Expanded(child: Text('${classItem.id}', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF3498DB)),
                                  onPressed: () => context.push('/admin/class-profile', extra: classItem),
                                  tooltip: 'View',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2ECC71)),
                                  onPressed: () async {
                                    if (_currentSchoolId != null) {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => DesktopAddEditClass(classDetails: classItem, schoolId: _currentSchoolId!)),
                                      );
                                      if (result == true) _loadClasses();
                                    }
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  onPressed: () => _deleteClass(classItem),
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
        crossAxisCount: 5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.2,
      ),
      itemCount: _filteredClasses.length,
      itemBuilder: (context, index) {
        final classItem = _filteredClasses[index];
        return InkWell(
          onTap: () => context.push('/admin/class-profile', extra: classItem),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: const Color(0xFF9B59B6).withOpacity(0.3), blurRadius: 8)],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.class_rounded, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(classItem.name, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                      onPressed: () async {
                        if (_currentSchoolId != null) {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DesktopAddEditClass(classDetails: classItem, schoolId: _currentSchoolId!)),
                          );
                          if (result == true) _loadClasses();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                      onPressed: () => _deleteClass(classItem),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteClass(SchoolClass classItem) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${classItem.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true && classItem.id != null) {
      final classService = context.read<ClassService>();
      await classService.deleteClass(classItem.id!);
      _loadClasses();
    }
  }
}
