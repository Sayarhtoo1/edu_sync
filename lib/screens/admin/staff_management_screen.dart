import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/staff.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart' as app_user;
import 'add_edit_staff_screen_corrected.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';

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
            phoneNumber: staff.phoneNumber1,
            salary: staff.salary,
          ) : null,
          schoolId: _currentSchoolId!,
        ),
      ),
    );

    if (result == true) _loadStaffData();
  }

  Future<void> _deleteStaff(String userId) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Staff Management', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF9800),
        onPressed: () => _navigateToAddEditStaffScreen(),
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
                          Icon(Icons.badge_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text('No staff found', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _staffList.length,
                      itemBuilder: (context, index) {
                        final staff = _staffList[index];
                        return GestureDetector(
                          onTap: () => context.push('/staff/profile', extra: Staff(
                            id: staff.id,
                            role: staff.role ?? 'Staff',
                            profilePhotoUrl: staff.profilePhotoUrl,
                            fullName: staff.fullName,
                            schoolId: staff.schoolId,
                            email: staff.email,
                            phoneNumber: staff.phoneNumber1,
                            salary: staff.salary,
                          )),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: staff.profilePhotoUrl != null && staff.profilePhotoUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: CachedNetworkImage(
                                        imageUrl: staff.profilePhotoUrl!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.badge_rounded, color: Color(0xFFFF9800)),
                                        ),
                                        errorWidget: (context, url, error) => Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.badge_rounded, color: Color(0xFFFF9800)),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF9800).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.badge_rounded, color: Color(0xFFFF9800)),
                                    ),
                              title: Text(staff.fullName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Text(staff.role ?? 'Staff', style: TextStyle(color: Colors.grey[600])),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit_outlined, color: Colors.grey[700]),
                                    onPressed: () => _navigateToAddEditStaffScreen(staff: staff),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _deleteStaff(staff.id),
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