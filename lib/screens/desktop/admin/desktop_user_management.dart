import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/screens/admin/add_edit_teacher_screen.dart';
import 'package:edu_sync/screens/admin/add_edit_parent_screen.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopUserManagement extends StatefulWidget {
  const DesktopUserManagement({super.key});

  @override
  State<DesktopUserManagement> createState() => _DesktopUserManagementState();
}

class _DesktopUserManagementState extends State<DesktopUserManagement> with SingleTickerProviderStateMixin {
  List<app_user.User> _users = [];
  bool _isLoading = true;
  int? _currentSchoolId;
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadUsers();
      }
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    _currentSchoolId = await authService.getCurrentUserSchoolId();
    if (_currentSchoolId != null) {
      await _loadUsers();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadUsers() async {
    if (_currentSchoolId == null) return;
    final authService = context.read<AuthService>();
    final role = _tabController.index == 0 ? UserRole.Teacher : UserRole.Parent;
    _users = await authService.getUsersByRole(role, _currentSchoolId!);
    setState(() {});
  }

  List<app_user.User> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((u) => u.fullName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false).toList();
  }

  String get _currentRole => _tabController.index == 0 ? 'Teacher' : 'Parent';
  Color get _currentColor => _tabController.index == 0 ? const Color(0xFF2ECC71) : const Color(0xFF9B59B6);

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'User Management',
      actions: [
        ElevatedButton.icon(
          onPressed: () => _navigateToAddEdit(),
          icon: const Icon(Icons.add, size: 18),
          label: Text('Add $_currentRole'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _currentColor,
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
                  _buildTabBar(),
                  const SizedBox(height: 24),
                  _buildFilters(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _filteredUsers.isEmpty ? _buildEmptyState() : _buildUserList(),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: _currentColor,
        labelColor: _currentColor,
        unselectedLabelColor: const Color(0xFF7F8C8D),
        tabs: const [
          Tab(text: 'Teachers', icon: Icon(Icons.school, size: 20)),
          Tab(text: 'Parents', icon: Icon(Icons.people, size: 20)),
        ],
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
              hintText: 'Search ${_currentRole.toLowerCase()}s...',
              prefixIcon: Icon(Icons.search, size: 20, color: _currentColor),
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
              Icon(Icons.people, size: 20, color: _currentColor),
              const SizedBox(width: 8),
              Text('${_filteredUsers.length} ${_currentRole}s', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50))),
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
          Text('No ${_currentRole.toLowerCase()}s found', style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: ListView.separated(
        itemCount: _filteredUsers.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _currentColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                image: user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty
                    ? DecorationImage(image: NetworkImage(user.profilePhotoUrl!), fit: BoxFit.cover)
                    : null,
              ),
              child: user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty
                  ? Icon(_tabController.index == 0 ? Icons.school : Icons.person, color: _currentColor)
                  : null,
            ),
            title: Text(user.fullName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(user.email ?? user.id, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF2ECC71)),
                  onPressed: () => _navigateToAddEdit(user: user),
                  tooltip: 'Edit',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFE74C3C)),
                  onPressed: () => _deleteUser(user),
                  tooltip: 'Delete',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToAddEdit({app_user.User? user}) async {
    if (_currentSchoolId == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _tabController.index == 0
            ? AddEditTeacherScreen(teacher: user, schoolId: _currentSchoolId!)
            : AddEditParentScreen(parent: user, schoolId: _currentSchoolId!),
      ),
    );
    if (result == true) _loadUsers();
  }

  Future<void> _deleteUser(app_user.User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete ${user.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Color(0xFFE74C3C)))),
        ],
      ),
    );
    if (confirm == true) {
      final authService = context.read<AuthService>();
      await authService.deleteUser(user.id);
      _loadUsers();
    }
  }
}
