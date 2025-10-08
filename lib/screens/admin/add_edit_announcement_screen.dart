import 'package:flutter/material.dart';
import 'package:edu_sync/models/announcement.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/services/announcement_service.dart';
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // For localization
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme
// Import AppDatabase
// import 'package:provider/provider.dart'; // Removed unused import
// import 'package:edu_sync/database/app_database.dart'; // Removed unused import

class AddEditAnnouncementScreen extends StatefulWidget {
  final int schoolId;
  final String adminUserId; // ID of the admin creating/editing
  final Announcement? announcement; // Existing announcement for editing

  const AddEditAnnouncementScreen({
    super.key,
    required this.schoolId,
    required this.adminUserId,
    this.announcement,
  });

  @override
  State<AddEditAnnouncementScreen> createState() => _AddEditAnnouncementScreenState();
}

class _AddEditAnnouncementScreenState extends State<AddEditAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final AnnouncementService _announcementService = AnnouncementService();
  late final ClassService _classService;

  late TextEditingController _titleController;
  late TextEditingController _contentController;
  
  String? _selectedTargetRole;
  int? _selectedTargetClassId; // Corrected to int?
  List<app_class.SchoolClass> _availableClasses = [];

  bool _isLoading = false;
  bool _isLoadingClasses = false; // For loading classes dropdown
  String _errorMessage = '';
  bool get _isEditing => widget.announcement != null;

  // Define target roles based on your schema
  // These will be localized in the DropdownButtonFormField
  final List<String> _targetRoleValues = ['All', UserRole.Teacher.name, UserRole.Parent.name, 'SpecificClass'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.announcement?.title ?? '');
    _contentController = TextEditingController(text: widget.announcement?.content ?? '');
    _selectedTargetRole = widget.announcement?.targetRole ?? 'All'; 
    _selectedTargetClassId = widget.announcement?.targetClassId; // Announcement.targetClassId is int?
    _classService = ClassService(); // Initialize _classService

 // schoolId should always be provided
    _loadClasses();
    }

  Future<void> _loadClasses() async {
    setState(() => _isLoadingClasses = true);
    try {
      _availableClasses = await _classService.getClasses(widget.schoolId);
    } catch (e) {
      if(mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() => _errorMessage = l10n?.failedToLoadClassesError ?? 'Failed to load classes');
      }
    }
    if(mounted) setState(() => _isLoadingClasses = false);
  }

  Future<void> _saveAnnouncement() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedTargetRole == 'SpecificClass' && _selectedTargetClassId == null) {
      setState(() => _errorMessage = l10n?.pleaseSelectClassForAnnouncement ?? 'Please select a class for the announcement');
      return;
    }
    _formKey.currentState!.save();
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      final announcementData = Announcement(
        id: _isEditing ? widget.announcement!.id : 0, // DB handles ID for new records
        schoolId: widget.schoolId,
        title: _titleController.text,
        content: _contentController.text,
        createdByUserId: widget.adminUserId,
        targetRole: _selectedTargetRole,
        targetClassId: _selectedTargetRole == 'SpecificClass' ? _selectedTargetClassId : null,
        createdAt: _isEditing ? widget.announcement!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (_isEditing) {
        success = await _announcementService.updateAnnouncement(announcementData);
      } else {
        final newAnnouncement = await _announcementService.createAnnouncement(announcementData);
        success = newAnnouncement != null;
      }

      if (success) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true); // Indicate success to refresh previous screen
      } else {
        throw Exception(l10n?.failedToSaveAnnouncementError ?? 'Failed to save announcement');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${l10n?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}';
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  String _getLocalizedTargetRoleDisplay(String roleKey, AppLocalizations? l10n) {
    switch (roleKey) {
      case 'All': return l10n?.all ?? 'All';
      case 'Teacher': return l10n?.teachers ?? 'Teachers';
      case 'Parent': return l10n?.parents ?? 'Parents';
      case 'SpecificClass': return l10n?.specificclass ?? 'Specific Class';
      default: return roleKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final String appBarTitle = _isEditing 
        ? (l10n?.editAnnouncementTitle ?? 'Edit Announcement')
        : (l10n?.addAnnouncementTitle ?? 'Add Announcement');
    
    // Contextual color for announcements - using 'earnings' as a general positive/notification color
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('announcement');

    return Scaffold(
      appBar: AppBar(title: Text(appBarTitle)), // AppBar theme applied globally
      body: _isLoadingClasses 
        ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: l10n?.titleLabel ?? 'Title'),
                    validator: (value) => (value == null || value.isEmpty) ? (l10n?.titleValidator ?? 'Title cannot be empty') : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    decoration: InputDecoration(labelText: l10n?.contentLabel ?? 'Content'),
                    maxLines: 5,
                    validator: (value) => (value == null || value.isEmpty) ? (l10n?.contentValidator ?? 'Content cannot be empty') : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedTargetRole,
                    hint: Text(l10n?.selectTargetAudienceHint ?? 'Select Target Audience'),
                    items: _targetRoleValues.map((String roleValue) {
                      return DropdownMenuItem<String>(
                        value: roleValue,
                        child: Text(_getLocalizedTargetRoleDisplay(roleValue, l10n)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTargetRole = value;
                        if (value != 'SpecificClass') {
                          _selectedTargetClassId = null; 
                        }
                      });
                    },
                    validator: (value) => value == null ? (l10n?.targetAudienceValidator ?? 'Please select a target audience') : null,
                    decoration: InputDecoration(labelText: l10n?.targetAudience ?? 'Target Audience'),
                  ),
                  if (_selectedTargetRole == 'SpecificClass') ...[
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>( // Corrected to int 
                      value: _selectedTargetClassId, // This is int?
                      hint: Text(l10n?.selectClassHint ?? 'Select Class'),
                      items: _availableClasses.map((app_class.SchoolClass cls) {
                        return DropdownMenuItem<int>( // Corrected to int
                          value: cls.id, // Class.id is int
                          child: Text(cls.name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedTargetClassId = value),
                      validator: (value) => _selectedTargetRole == 'SpecificClass' && value == null ? (l10n?.pleaseSelectClassForAnnouncement ?? 'Please select a class') : null,
                      decoration: InputDecoration(labelText: l10n?.classLabel ?? 'Class'),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _isLoading
                      ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: contextualAccentColor,
                            foregroundColor: Colors.white, // Assuming white text on this accent
                          ),
                          onPressed: _saveAnnouncement,
                          child: Text(_isEditing ? (l10n?.updateButton ?? 'Update') : (l10n?.addButton ?? 'Add')),
                        ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_errorMessage, style: TextStyle(color: theme.colorScheme.error)),
                    ),
                ],
              ),
            ),
          ),
    );
  }
}
