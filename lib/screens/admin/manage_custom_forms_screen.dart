import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/custom_form.dart';
import 'package:edu_sync/services/custom_form_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:intl/intl.dart'; 
import 'add_edit_custom_form_screen.dart'; 
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class ManageCustomFormsScreen extends StatefulWidget {
  const ManageCustomFormsScreen({super.key});

  @override
  State<ManageCustomFormsScreen> createState() => _ManageCustomFormsScreenState();
}

class _ManageCustomFormsScreenState extends State<ManageCustomFormsScreen> {
  final CustomFormService _customFormService = CustomFormService();
  final AuthService _authService = AuthService();
  
  List<CustomForm> _forms = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _userId;
  String? _userRole;
  int? _schoolId;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    _userId = _authService.getCurrentUser()?.id;
    _userRole = await _authService.getUserRole();
    if (!mounted) return;
    _schoolId = Provider.of<SchoolProvider>(context, listen: false).currentSchool?.id;

    if (_userId == null || _userRole == null || _schoolId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context).actionRequiresSchoolAndAdminContext;
      });
      return;
    }
    await _fetchForms();
    if(mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchForms() async {
    try {
      // Assuming the first role is the primary one for this context.
      _forms = await _customFormService.getManageableForms(_userId!, _userRole!, _schoolId!);
    } catch (e) {
      if(mounted) {
        setState(() => _errorMessage = AppLocalizations.of(context).errorOccurredPrefix + e.toString());
      }
    }
  }

  void _navigateToAddEditForm([CustomForm? form]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditCustomFormScreen(
          schoolId: _schoolId!,
          userId: _userId!, // For created_by_user_id
          form: form,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadInitialData(); // Refresh list if a form was saved
      }
    });
  }

  Future<void> _deleteForm(String formId) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( 
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteCustomFormText),
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
      final success = await _customFormService.deleteCustomForm(formId);
      if (success) {
        await _fetchForms();
      } else {
        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorDeletingCustomFormText)), 
          );
        }
      }
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('form');

    return Scaffold(
      appBar: AppBar( 
        title: Text(l10n.manageDailyReportFormsTitle), 
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : _errorMessage != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error))))
              : _forms.isEmpty
                  ? Center(child: Text(l10n.noCustomFormsFoundText, style: theme.textTheme.bodyLarge))
                  : ListView.builder(
                      itemCount: _forms.length,
                      itemBuilder: (context, index) {
                        final form = _forms[index];
                        return Card( 
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            title: Text(form.title, style: theme.textTheme.titleMedium),
                            subtitle: Text(
                                "${l10n.activeFrom}: ${DateFormat.yMMMd(l10n.localeName).format(form.activeFrom)} - ${l10n.activeTo}: ${DateFormat.yMMMd(l10n.localeName).format(form.activeTo)}\n"
                                "${l10n.daily}: ${form.isDaily ? l10n.yes : l10n.no}",
                                style: theme.textTheme.bodySmall
                            ),
                            isThreeLine: true,
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: theme.colorScheme.error),
                              tooltip: l10n.deleteButton, 
                              onPressed: () => _deleteForm(form.id),
                            ),
                            onTap: () => _navigateToAddEditForm(form),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton( 
        backgroundColor: contextualAccentColor,
        onPressed: () => _navigateToAddEditForm(),
        tooltip: l10n.addCustomFormTooltip, 
        child: const Icon(Icons.add, color: Colors.white), 
      ),
    );
  }
}
