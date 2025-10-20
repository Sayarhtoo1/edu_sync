import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/models/staff.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';
import 'package:edu_sync/screens/desktop/admin/desktop_add_edit_staff.dart';

class DesktopStaffManagement extends StatefulWidget {
  const DesktopStaffManagement({super.key});

  @override
  State<DesktopStaffManagement> createState() => _DesktopStaffManagementState();
}

class _DesktopStaffManagementState extends State<DesktopStaffManagement> {
  List<app_user.User> _staff = [];
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
      await _loadStaff();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadStaff() async {
    if (_currentSchoolId == null) return;
    final authService = context.read<AuthService>();
    _staff = await authService.getStaffBySchool(_currentSchoolId!);
    setState(() {});
  }

  List<app_user.User> get _filteredStaff {
    if (_searchQuery.isEmpty) return _staff;
    return _staff.where((s) => s.fullName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Staff Management',
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
                  builder: (context) => DesktopAddEditStaff(schoolId: _currentSchoolId!),
                ),
              );
              if (result == true) _loadStaff();
            }
          },
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Staff'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
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
                    child: _filteredStaff.isEmpty
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
              hintText: 'Search staff by name...',
              prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF2ECC71)),
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
              const Icon(Icons.people, size: 20, color: Color(0xFF2ECC71)),
              const SizedBox(width: 8),
              Text('${_filteredStaff.length} Staff', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
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
          Text('No staff found', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
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
                const Expanded(child: Text('Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(width: 140, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredStaff.length,
              itemBuilder: (context, index) {
                final staffUser = _filteredStaff[index];
                final staff = Staff(
                  id: staffUser.id,
                  role: staffUser.role ?? 'Staff',
                  profilePhotoUrl: staffUser.profilePhotoUrl,
                  fullName: staffUser.fullName,
                  schoolId: staffUser.schoolId,
                  email: staffUser.email,
                  phoneNumber: staffUser.phoneNumber1,
                  salary: staffUser.salary,
                );
                return Container(
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                  child: InkWell(
                    onTap: () => context.push('/staff/profile', extra: staff),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              image: staffUser.profilePhotoUrl != null && staffUser.profilePhotoUrl!.isNotEmpty
                                  ? DecorationImage(image: CachedNetworkImageProvider(staffUser.profilePhotoUrl!), fit: BoxFit.cover)
                                  : null,
                            ),
                            child: staffUser.profilePhotoUrl == null || staffUser.profilePhotoUrl!.isEmpty
                                ? const Icon(Icons.person, color: Color(0xFF2ECC71), size: 20)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Expanded(flex: 2, child: Text(staffUser.fullName ?? 'Staff', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                          Expanded(child: Text(staffUser.role ?? 'Staff', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          Expanded(child: Text(staffUser.email ?? 'N/A', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          Expanded(child: Text(staffUser.phoneNumber1 ?? 'N/A', style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                          SizedBox(
                            width: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF3498DB)),
                                  onPressed: () => context.push('/staff/profile', extra: staff),
                                  tooltip: 'View',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2ECC71)),
                                  onPressed: () async {
                                    if (staff.schoolId != null) {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DesktopAddEditStaff(staff: staff, schoolId: staff.schoolId!),
                                        ),
                                      );
                                      if (result == true) _loadStaff();
                                    }
                                  },
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  onPressed: () => _deleteStaff(staffUser),
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
      itemCount: _filteredStaff.length,
      itemBuilder: (context, index) {
        final staffUser = _filteredStaff[index];
        final staff = Staff(
          id: staffUser.id,
          role: staffUser.role ?? 'Staff',
          profilePhotoUrl: staffUser.profilePhotoUrl,
          fullName: staffUser.fullName,
          schoolId: staffUser.schoolId,
          email: staffUser.email,
          phoneNumber: staffUser.phoneNumber1,
          salary: staffUser.salary,
        );
        return InkWell(
          onTap: () => context.push('/staff/profile', extra: staff),
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
                    color: const Color(0xFF2ECC71).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    image: staffUser.profilePhotoUrl != null && staffUser.profilePhotoUrl!.isNotEmpty
                        ? DecorationImage(image: CachedNetworkImageProvider(staffUser.profilePhotoUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: staffUser.profilePhotoUrl == null || staffUser.profilePhotoUrl!.isEmpty
                      ? const Icon(Icons.person, color: Color(0xFF2ECC71), size: 24)
                      : null,
                ),
                const SizedBox(height: 8),
                Text(staffUser.fullName ?? 'Staff', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(staffUser.role ?? 'Staff', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteStaff(app_user.User staffUser) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${staffUser.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      final authService = context.read<AuthService>();
      await authService.deleteUser(staffUser.id);
      _loadStaff();
    }
  }
}
