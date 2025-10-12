import 'package:flutter/material.dart';
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:provider/provider.dart';
import 'add_edit_teacher_screen.dart';
import 'add_edit_parent_screen.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';

class UserManagementScreen extends StatefulWidget {
  final int initialTabIndex;
  const UserManagementScreen({super.key, this.initialTabIndex = 0});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  late final AuthService _authService;
  List<app_user.User> _staffList = [];
  bool _isLoading = true;
  int? _currentSchoolId;
  late TabController _tabController;
  String _currentRoleView = 'Teacher'; // To switch between Teacher and Parent views

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    // Update currentRoleView based on initialTabIndex
    _currentRoleView = widget.initialTabIndex == 0 ? 'Teacher' : 'Parent';
    
    _tabController.addListener(() {
      // Only update and reload if the tab actually changes to a new index
      if (_tabController.index != _tabController.previousIndex) {
        setState(() {
          _currentRoleView = _tabController.index == 0 ? 'Teacher' : 'Parent';
        });
        _loadStaffData();
      } else if (!_tabController.indexIsChanging && _tabController.index == 0 && _currentRoleView != 'Teacher') {
         setState(() { _currentRoleView = 'Teacher'; });
        _loadStaffData();
      } else if (!_tabController.indexIsChanging && _tabController.index == 1 && _currentRoleView != 'Parent') {
         setState(() { _currentRoleView = 'Parent'; });
        _loadStaffData();
      }
    });
    _fetchSchoolIdAndLoadStaff();
  }

  Future<void> _fetchSchoolIdAndLoadStaff() async {
    final currentUser = _authService.getCurrentUser();
    if (currentUser != null) {
      _currentSchoolId = await _authService.getCurrentUserSchoolId();
    }
    if (_currentSchoolId != null) {
      _loadStaffData();
    } else {
      //logger.w("Admin's school ID not found. Cannot load staff.");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadStaffData() async {
    if (_currentSchoolId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    setState(() => _isLoading = true);
    _staffList = await _authService.getUsersByRole(
        _currentRoleView == 'Teacher' ? UserRole.Teacher : UserRole.Parent,
        _currentSchoolId!);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddEditUserScreen({app_user.User? user}) async {
    if (_currentSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot add/edit $_currentRoleView: School ID not found.'))
      );
      return;
    }
    if (_currentRoleView == 'Teacher') {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddEditTeacherScreen(teacher: user, schoolId: _currentSchoolId!),
        ),
      );
      if (result == true) _loadStaffData();
    } else if (_currentRoleView == 'Parent') {
      // final result = await Navigator.of(context).push(
      //   MaterialPageRoute(
      //     builder: (_) => AddEditParentScreen(parent: user, schoolId: _currentSchoolId!), // To be created
      //   ),
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AddEditParentScreen(parent: user, schoolId: _currentSchoolId!),
        ),
      );
      if (result == true) _loadStaffData();
    }
  }

  Future<void> _deleteUser(String userId) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(l10n?.confirmDeleteTitle ?? 'Confirm Delete'),
        content: Text('${l10n?.confirmDeleteUserTextPart1 ?? 'Are you sure you want to delete this'} ${_currentRoleView.toLowerCase()}?'), 
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
      final success = await _authService.deleteUser(userId);
      if (success) {
        _loadStaffData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete $_currentRoleView.')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final Color currentAccent = _currentRoleView == 'Teacher' ? const Color(0xFF4CAF50) : const Color(0xFF9C27B0);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(_currentRoleView == 'Teacher' ? l10n?.teachers ?? 'Teachers' : l10n?.parents ?? 'Parents', style: const TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: currentAccent,
          labelColor: currentAccent,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: l10n?.teachers ?? 'Teachers'),
            Tab(text: l10n?.parents ?? 'Parents'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: currentAccent,
        onPressed: () => _navigateToAddEditUserScreen(),
        child: const Icon(Icons.add_rounded),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStaffData,
              child: _staffList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No ${_currentRoleView.toLowerCase()}s found', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _staffList.length,
                      itemBuilder: (context, index) {
                        final user = _staffList[index];
                        return Container(
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
                                color: currentAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                image: user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty
                                    ? DecorationImage(image: NetworkImage(user.profilePhotoUrl!), fit: BoxFit.cover)
                                    : null,
                              ),
                              child: user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty
                                  ? Icon(_currentRoleView == 'Teacher' ? Icons.school_rounded : Icons.person_rounded, color: currentAccent)
                                  : null,
                            ),
                            title: Text(user.fullName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text(user.email ?? user.id, style: TextStyle(color: Colors.grey[600])),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_outlined, color: Colors.grey[700]),
                                  onPressed: () => _navigateToAddEditUserScreen(user: user),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteUser(user.id),
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
