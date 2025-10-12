import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/announcement.dart';
import 'package:edu_sync/services/announcement_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'add_edit_announcement_screen.dart'; 
// Import AppTheme

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  late final AnnouncementService _announcementService;
  late final AuthService _authService;

  List<Announcement> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _schoolId;
  String? _adminUserId;

  @override
  void initState() {
    super.initState();
    _announcementService = Provider.of<AnnouncementService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    _schoolId = schoolProvider.currentSchool?.id;
    _adminUserId = _authService.getCurrentUser()?.id;

    if (_schoolId != null) {
      _loadAnnouncements();
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = AppLocalizations.of(context)?.error_school_not_selected_or_found ?? 'Error: School not selected or found';
          });
        }
      });
    }
  }

  Future<void> _loadAnnouncements() async {
    if (_schoolId == null) return;
    setState(() => _isLoading = true);
    try {
      // Admin should see all announcements for their school.
      // The existing getAnnouncements(schoolId) should work if RLS allows admin full view for their school.
      _announcements = await _announcementService.getAnnouncements(_schoolId!);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = "${AppLocalizations.of(context)?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}");
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddEditScreen([Announcement? announcement]) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return; // Or handle the null case appropriately
    }
    if (_schoolId == null || _adminUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.actionRequiresSchoolAndAdminContext ?? 'Action requires school and admin context'))
        );
        return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditAnnouncementScreen(
          schoolId: _schoolId!,
          adminUserId: _adminUserId!,
          announcement: announcement,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadAnnouncements();
      }
    });
  }

  Future<void> _deleteAnnouncement(int announcementId) async {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return; // Or handle the null case appropriately
    }
    final theme = Theme.of(context); 
    // final Color contextualAccentColor = AppTheme.getAccentColorForContext('announcement'); // Unused

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(l10n.confirmDeleteTitle ?? 'Confirm Delete'),
        content: Text(l10n.confirmDeleteAnnouncementText ?? 'Are you sure you want to delete this announcement?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel ?? 'Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error), 
            onPressed: () => Navigator.of(context).pop(true), 
            child: Text(l10n.delete ?? 'Delete')
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await _announcementService.deleteAnnouncement(announcementId);
      if (success) {
        _loadAnnouncements();
      } else {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.errorDeletingAnnouncement ?? 'Error deleting announcement')),
            );
            setState(() => _isLoading = false);
         }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(l10n.manageAnnouncementsTitle ?? 'Announcements', style: const TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))))
              : _announcements.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(l10n.noAnnouncementsFound ?? 'No announcements found', style: const TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadAnnouncements,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _announcements.length,
                        itemBuilder: (context, index) {
                          final announcement = _announcements[index];
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: Text(announcement.title),
                                  content: SingleChildScrollView(child: Text(announcement.content)),
                                  actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2196F3).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.campaign_rounded, color: Color(0xFF2196F3)),
                                ),
                                title: Text(announcement.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(announcement.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600])),
                                    const SizedBox(height: 4),
                                    Text(DateFormat.yMMMd().format(announcement.createdAt), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.edit_outlined, color: Colors.grey[700]),
                                      onPressed: () => _navigateToAddEditScreen(announcement),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _deleteAnnouncement(announcement.id),
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

  String _getLocalizedTargetRole(String roleKey, AppLocalizations l10n) {
    switch (roleKey.toLowerCase()) {
      case 'all':
        return l10n.allAudience ?? 'All'; // Use specific key
      case 'teachers':
        return l10n.teachersAudience ?? 'Teachers'; // Use specific key
      case 'parents':
        return l10n.parentsAudience ?? 'Parents'; // Use specific key
      case 'specificclass':
        return l10n.specificclass ?? 'Specific Class';
      default:
        return roleKey; 
    }
  }
}
