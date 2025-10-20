import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/services/parent_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_add_edit_parent.dart';

class DesktopParentManagement extends StatefulWidget {
  const DesktopParentManagement({super.key});

  @override
  State<DesktopParentManagement> createState() => _DesktopParentManagementState();
}

class _DesktopParentManagementState extends State<DesktopParentManagement> {
  List<app_user.User> _parents = [];
  bool _isLoading = true;
  int? _currentSchoolId;
  String _searchQuery = '';
  String _viewMode = 'table';

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
      await _loadParents();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadParents() async {
    if (_currentSchoolId == null) return;
    final parentService = context.read<ParentService>();
    _parents = await parentService.getParentsBySchool(_currentSchoolId!);
    setState(() {});
  }

  List<app_user.User> get _filteredParents {
    if (_searchQuery.isEmpty) return _parents;
    return _parents.where((p) => p.fullName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Parent Management',
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
                MaterialPageRoute(
                  builder: (context) => DesktopAddEditParent(schoolId: _currentSchoolId!),
                ),
              );
              if (result == true) _loadParents();
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Parent'),
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
                    child: _filteredParents.isEmpty
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
              hintText: 'Search parents by name...',
              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF3498DB)),
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
              const Icon(Icons.people, size: 20, color: Color(0xFF3498DB)),
              const SizedBox(width: 8),
              Text('${_filteredParents.length} Parents', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
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
          Icon(Icons.people_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No parents found', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
                const Expanded(flex: 2, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(width: 100, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredParents.length,
              itemBuilder: (context, index) {
                final parent = _filteredParents[index];
                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
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
                            image: parent.profilePhotoUrl != null && parent.profilePhotoUrl!.isNotEmpty
                                ? DecorationImage(image: CachedNetworkImageProvider(parent.profilePhotoUrl!), fit: BoxFit.cover)
                                : null,
                          ),
                          child: parent.profilePhotoUrl == null || parent.profilePhotoUrl!.isEmpty
                              ? const Icon(Icons.person, color: Color(0xFF3498DB), size: 20)
                              : null,
                        ),
                        const SizedBox(width: 20),
                        Expanded(flex: 2, child: Text(parent.fullName ?? 'Parent', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                        Expanded(child: Text(parent.email ?? 'N/A', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                        Expanded(child: Text(parent.phoneNumber1 ?? 'N/A', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                        SizedBox(
                          width: 100,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF3498DB)),
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DesktopAddEditParent(parent: parent, schoolId: parent.schoolId!),
                                    ),
                                  );
                                  if (result == true) _loadParents();
                                },
                                tooltip: 'Edit',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                onPressed: () => _deleteParent(parent),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        ),
                      ],
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
      itemCount: _filteredParents.length,
      itemBuilder: (context, index) {
        final parent = _filteredParents[index];
        return Container(
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
                  image: parent.profilePhotoUrl != null && parent.profilePhotoUrl!.isNotEmpty
                      ? DecorationImage(image: CachedNetworkImageProvider(parent.profilePhotoUrl!), fit: BoxFit.cover)
                      : null,
                ),
                child: parent.profilePhotoUrl == null || parent.profilePhotoUrl!.isEmpty
                    ? const Icon(Icons.person, color: Color(0xFF3498DB), size: 24)
                    : null,
              ),
              const SizedBox(height: 8),
              Text(parent.fullName ?? 'Parent', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 2),
              Text(parent.email ?? 'No email', style: TextStyle(fontSize: 10, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        );
      },
    );
  }

  Future<void> _deleteParent(app_user.User parent) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${parent.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final parentService = context.read<ParentService>();
      await parentService.deleteParent(parent.id);
      _loadParents();
    }
  }
}
