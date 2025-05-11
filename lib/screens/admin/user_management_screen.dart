import 'package:flutter/material.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'add_edit_teacher_screen.dart';
import 'add_edit_parent_screen.dart'; 
import 'package:edu_sync/l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class UserManagementScreen extends StatefulWidget {
  final int initialTabIndex;
  const UserManagementScreen({super.key, this.initialTabIndex = 0});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  List<app_user.User> _staffList = [];
  bool _isLoading = true;
  int? _currentSchoolId;
  late TabController _tabController;
  String _currentRoleView = 'Teacher'; // To switch between Teacher and Parent views

  @override
  void initState() {
    super.initState();
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
      // print("Admin's school ID not found. Cannot load staff."); // Removed print
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
    _staffList = await _authService.getUsersByRole(_currentRoleView, _currentSchoolId!);
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
    // TODO: Navigate to specific Add/Edit screen based on _currentRoleView
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
        title: Text(l10n.confirmDeleteTitle),
        content: Text('${l10n.confirmDeleteUserTextPart1} ${_currentRoleView.toLowerCase()}?'), 
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
    final theme = Theme.of(context);
    final Color teacherAccent = AppTheme.getAccentColorForContext('teachers');
    final Color parentAccent = AppTheme.getAccentColorForContext('parents');
    final Color currentAccent = _currentRoleView == 'Teacher' ? teacherAccent : parentAccent;

    return Scaffold(
      appBar: AppBar( 
        title: Text('${l10n.manageUsersTitle} (${_currentRoleView == 'Teacher' ? l10n.teachers : l10n.parents})'), 
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: currentAccent,
          labelColor: currentAccent,
          unselectedLabelColor: textLightGrey, 
          tabs: [
            Tab(text: l10n.teachers), 
            Tab(text: l10n.parents), 
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: currentAccent),
            tooltip: _currentRoleView == 'Teacher' ? l10n.addTeacherButton : l10n.addParentButton, 
            onPressed: () => _navigateToAddEditUserScreen(),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(currentAccent)))
          : RefreshIndicator(
              onRefresh: _loadStaffData,
              color: currentAccent,
              child: _staffList.isEmpty
                  ? Center(child: Text('${l10n.noUsersFoundTextPart1} ${_currentRoleView.toLowerCase()}s ${l10n.noUsersFoundTextPart2}', style: theme.textTheme.bodyLarge)) 
                  : ListView.builder(
                      itemCount: _staffList.length,
                      itemBuilder: (context, index) {
                        final user = _staffList[index];
                        IconData leadingIconData = _currentRoleView == 'Teacher' ? Icons.school_outlined : Icons.person_outline;
                        return Card( 
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: currentAccent.withAlpha((255 * 0.2).round()), // Use withAlpha
                              backgroundImage: user.profilePhotoUrl != null && user.profilePhotoUrl!.isNotEmpty
                                  ? NetworkImage(user.profilePhotoUrl!)
                                  : null,
                              child: user.profilePhotoUrl == null || user.profilePhotoUrl!.isEmpty
                                  ? Icon(leadingIconData, color: currentAccent)
                                  : null,
                            ),
                            title: Text(user.fullName ?? 'N/A', style: theme.textTheme.titleMedium),
                            subtitle: Text(user.id, style: theme.textTheme.bodySmall), 
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: theme.iconTheme.color ?? textDarkGrey), 
                                  tooltip: l10n.editButton, 
                                  onPressed: () => _navigateToAddEditUserScreen(user: user),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                  tooltip: l10n.deleteButton, 
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
