import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user.dart' as app_user;
import '../../services/parent_service.dart';
import '../../services/auth_service.dart';
import 'add_edit_parent_screen.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';

class ParentManagementScreen extends StatefulWidget {
  const ParentManagementScreen({super.key});

  @override
  State<ParentManagementScreen> createState() => _ParentManagementScreenState();
}

class _ParentManagementScreenState extends State<ParentManagementScreen> {
  late final ParentService _parentService;
  late final AuthService _authService;
  List<app_user.User> _parentList = [];
  bool _isLoading = true;
  int? _currentSchoolId;

  @override
  void initState() {
    super.initState();
    _parentService = Provider.of<ParentService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _fetchSchoolIdAndLoadParents();
  }

  Future<void> _fetchSchoolIdAndLoadParents() async {
    try {
      final currentUser = _authService.getCurrentUser();
      if (currentUser != null) {
        _currentSchoolId = await _authService.getCurrentUserSchoolId();
      }
      if (_currentSchoolId != null) {
        await _loadParentData();
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.error_school_not_found ?? 'School ID not found.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.errorOccurredPrefix ?? 'Error'}: $e')),
        );
      }
    }
  }

  Future<void> _loadParentData() async {
    if (_currentSchoolId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      _parentList = await _parentService.getParentsBySchool(_currentSchoolId!);
      if (mounted) setState(() => _isLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)?.errorOccurredPrefix ?? 'Error'}: $e')),
        );
      }
    }
  }

  void _navigateToAddEditParentScreen({app_user.User? parent}) async {
    if (_currentSchoolId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.actionRequiresSchoolAndAdminContext ?? 'School ID not found.'))
      );
      return;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddEditParentScreen(
          parent: parent,
          schoolId: _currentSchoolId!,
        ),
      ),
    );

    if (result == true) _loadParentData();
  }

  Future<void> _deleteParent(String parentId) async {
    final l10n = AppLocalizations.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.confirmDeleteTitle ?? 'Confirm Delete'),
        content: Text('${l10n?.confirmDeleteUserTextPart1 ?? 'Are you sure you want to delete this'} parent?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n?.cancel ?? 'Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n?.delete ?? 'Delete')
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await _parentService.deleteParent(parentId);
      if (success) {
        _loadParentData();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)?.errorOccurredPrefix ?? 'Failed to delete parent.')),
          );
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Parent Management', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3498DB),
        onPressed: () => _navigateToAddEditParentScreen(),
        child: const Icon(Icons.add_rounded),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadParentData,
              child: _parentList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('No parents found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _parentList.length,
                      itemBuilder: (context, index) {
                        final parent = _parentList[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: parent.profilePhotoUrl != null && parent.profilePhotoUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: CachedNetworkImage(
                                      imageUrl: parent.profilePhotoUrl!,
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.people_rounded, color: Color(0xFF3498DB)),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.people_rounded, color: Color(0xFF3498DB)),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.people_rounded, color: Color(0xFF3498DB)),
                                  ),
                            title: Text(parent.fullName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            subtitle: Text(parent.email ?? 'No email', style: TextStyle(color: Colors.grey[600])),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_outlined, color: Colors.grey[700]),
                                  onPressed: () => _navigateToAddEditParentScreen(parent: parent),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                                  onPressed: () => _deleteParent(parent.id),
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
