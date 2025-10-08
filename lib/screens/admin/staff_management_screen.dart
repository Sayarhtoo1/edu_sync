import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/staff.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart' as app_user;
import 'add_edit_staff_screen_corrected.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'package:edu_sync/theme/app_theme.dart';

class StaffManagementScreen extends StatefulWidget {
  const StaffManagementScreen({super.key});

  @override
  State<StaffManagementScreen> createState() => _StaffManagementScreenState();
}

class _StaffManagementScreenState extends State<StaffManagementScreen> {
  late final AuthService _authService;
  List<app_user.User> _staffList = [];
  bool _isLoading = true;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _fetchSchoolIdAndLoadStaff();
  }

  Future<void> _fetchSchoolIdAndLoadStaff() async {
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        _currentSchoolId = await _authService.getCurrentUserSchoolId();
      }
      if (_currentSchoolId != null) {
        await _loadStaffData();
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.error_school_not_found ?? 'School ID not found. Cannot load staff.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.errorOccurredPrefix ?? 'Error loading staff'}: $e')),
        );
      }
    }
  }

  Future<void> _loadStaffData() async {
    if (_currentSchoolId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      _staffList = await _authService.getStaffBySchool(_currentSchoolId!);

      if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.errorOccurredPrefix ?? 'Error loading staff'}: $e')),
        );
      }
    }
  }

  void _navigateToAddEditStaffScreen({app_user.User? staff}) async {
    if (_currentSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.actionRequiresSchoolAndAdminContext ?? 'Cannot add/edit staff: School ID not found.'))
      );
      return;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditStaffScreen(
          staff: staff != null ? Staff(
            id: staff.id,
            role: staff.role ?? 'Staff',
            profilePhotoUrl: staff.profilePhotoUrl,
            fullName: staff.fullName,
            schoolId: staff.schoolId,
            email: staff.email,
            phoneNumber: staff.phoneNumber,
            salary: staff.salary,
          ) : null,
          schoolId: _currentSchoolId!,
        ),
      ),
    );

    if (result == true) _loadStaffData();
  }

  Future<void> _deleteStaff(String userId) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.confirmDeleteTitle ?? 'Confirm Delete'),
        content: Text('${l10n?.confirmDeleteUserTextPart1 ?? 'Are you sure you want to delete this'} staff member?'),
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
            SnackBar(content: Text(AppLocalizations.of(context)?.errorOccurredPrefix ?? 'Failed to delete staff member.')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color accentColor = AppTheme.getAccentColorForContext('staff');

    return Scaffold(
      appBar: AppBar(
        title: Text('Staff Management'),
        backgroundColor: accentColor.withAlpha((255 * 0.1).round()),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: accentColor),
            onPressed: () => _navigateToAddEditStaffScreen(),
            tooltip: 'Add Staff',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: accentColor),
            onPressed: _isLoading ? null : _loadStaffData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(accentColor)))
          : RefreshIndicator(
              onRefresh: _loadStaffData,
              color: accentColor,
              child: _staffList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: accentColor.withAlpha((255 * 0.5).round()),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${l10n?.noUsersFoundTextPart1 ?? 'No'} staff ${l10n?.noUsersFoundTextPart2 ?? 'found.'}',
                            style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add your first staff member to get started.',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.textTheme.bodySmall?.color),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToAddEditStaffScreen(),
                            icon: Icon(Icons.add, color: theme.colorScheme.onPrimary),
                            label: Text('Add Staff'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              foregroundColor: theme.colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _staffList.length,
                      itemBuilder: (context, index) {
                        final staff = _staffList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: accentColor.withAlpha((255 * 0.2).round()),
                              backgroundImage: staff.profilePhotoUrl != null
                                  ? NetworkImage(staff.profilePhotoUrl!)
                                  : null,
                              child: staff.profilePhotoUrl == null
                                  ? Icon(Icons.person, color: accentColor)
                                  : null,
                            ),
                            title: Text(staff.fullName ?? 'N/A', style: theme.textTheme.titleMedium),
                            subtitle: Text(staff.role ?? 'No role assigned'),
                            onTap: () => context.push('/staff/profile', extra: Staff(
                              id: staff.id,
                              role: staff.role ?? 'Staff',
                              profilePhotoUrl: staff.profilePhotoUrl,
                              fullName: staff.fullName,
                              schoolId: staff.schoolId,
                              email: staff.email,
                              phoneNumber: staff.phoneNumber,
                              salary: staff.salary,
                            )),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: accentColor),
                                  tooltip: l10n?.editButton ?? 'Edit',
                                  onPressed: () => _navigateToAddEditStaffScreen(staff: staff),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                  tooltip: l10n?.deleteButton ?? 'Delete',
                                  onPressed: () => _deleteStaff(staff.id),
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