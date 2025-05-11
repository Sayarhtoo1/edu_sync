import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/announcement.dart';
import 'package:edu_sync/services/announcement_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'add_edit_announcement_screen.dart'; 
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class AdminAnnouncementsScreen extends StatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  State<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends State<AdminAnnouncementsScreen> {
  final AnnouncementService _announcementService = AnnouncementService();
  final AuthService _authService = AuthService();

  List<Announcement> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _schoolId;
  String? _adminUserId;

  @override
  void initState() {
    super.initState();
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
            _errorMessage = AppLocalizations.of(context).error_school_not_selected_or_found;
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
        setState(() => _errorMessage = "${AppLocalizations.of(context).errorOccurredPrefix}: ${e.toString()}");
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddEditScreen([Announcement? announcement]) {
    final l10n = AppLocalizations.of(context); // Get l10n instance
    if (_schoolId == null || _adminUserId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.actionRequiresSchoolAndAdminContext))
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
    final theme = Theme.of(context); 
    // final Color contextualAccentColor = AppTheme.getAccentColorForContext('announcement'); // Unused

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteAnnouncementText),
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
      final success = await _announcementService.deleteAnnouncement(announcementId);
      if (success) {
        _loadAnnouncements();
      } else {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.errorDeletingAnnouncement)),
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
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('announcement');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageAnnouncementsTitle), // Theme applied globally
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : _errorMessage != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error))))
              : _announcements.isEmpty
                  ? Center(child: Text(l10n.noAnnouncementsFound, style: theme.textTheme.bodyLarge))
                  : RefreshIndicator(
                      onRefresh: _loadAnnouncements,
                      color: contextualAccentColor,
                      child: ListView.builder(
                        itemCount: _announcements.length,
                        itemBuilder: (context, index) {
                          final announcement = _announcements[index];
                          return Card( // CardTheme applied globally
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              title: Text(announcement.title, style: theme.textTheme.titleMedium),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(announcement.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${l10n.postedOn} ${DateFormat.yMMMd(l10n.localeName).format(announcement.createdAt)}',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  if (announcement.targetRole != null && announcement.targetRole != 'All')
                                    Text(
                                      '${l10n.targetAudience}: ${_getLocalizedTargetRole(announcement.targetRole!, l10n)}${announcement.targetRole == 'SpecificClass' && announcement.targetClassId != null ? ' (ID: ${announcement.targetClassId})' : ''}',
                                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                                    )
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: theme.iconTheme.color ?? textDarkGrey), 
                                    tooltip: l10n.editButton, 
                                    onPressed: () => _navigateToAddEditScreen(announcement),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                                    tooltip: l10n.deleteButton, 
                                    onPressed: () => _deleteAnnouncement(announcement.id),
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(context: context, builder: (_) => AlertDialog( 
                                  title: Text(announcement.title, style: theme.textTheme.titleLarge),
                                  content: SingleChildScrollView(child: Text(announcement.content, style: theme.textTheme.bodyMedium)),
                                  actions: [TextButton(onPressed: ()=>Navigator.of(context).pop(), child: Text(l10n.closeButtonLabel))],
                                ));
                              },
                            ),
                          );
                        },
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: contextualAccentColor, 
        onPressed: () => _navigateToAddEditScreen(),
        tooltip: l10n.addAnnouncementTooltip,
        child: const Icon(Icons.add, color: Colors.white), 
      ),
    );
  }

  String _getLocalizedTargetRole(String roleKey, AppLocalizations l10n) {
    switch (roleKey.toLowerCase()) {
      case 'all':
        return l10n.allAudience; // Use specific key
      case 'teachers':
        return l10n.teachersAudience; // Use specific key
      case 'parents':
        return l10n.parentsAudience; // Use specific key
      case 'specificclass':
        return l10n.specificclass; 
      default:
        return roleKey; 
    }
  }
}
