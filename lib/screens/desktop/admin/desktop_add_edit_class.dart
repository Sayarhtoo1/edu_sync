import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';
import 'package:edu_sync/utils/logger.dart';

class DesktopAddEditClass extends StatefulWidget {
  final app_class.SchoolClass? classDetails;
  final int schoolId;

  const DesktopAddEditClass({super.key, this.classDetails, required this.schoolId});

  @override
  State<DesktopAddEditClass> createState() => _DesktopAddEditClassState();
}

class _DesktopAddEditClassState extends State<DesktopAddEditClass> {
  final _formKey = GlobalKey<FormState>();
  late final ClassService _classService;
  late final AuthService _authService;

  late TextEditingController _nameController;
  late TextEditingController _sectionController;
  String? _selectedTeacherId;
  List<app_user.User> _availableTeachers = [];

  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.classDetails != null;

  @override
  void initState() {
    super.initState();
    _classService = Provider.of<ClassService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _nameController = TextEditingController(text: widget.classDetails?.name ?? '');
    _sectionController = TextEditingController(text: widget.classDetails?.section ?? '');
    _selectedTeacherId = widget.classDetails?.teacherId;
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() => _isLoading = true);
    try {
      _availableTeachers = await _authService.getUsersByRole(UserRole.Teacher, widget.schoolId);
    } catch (e) {
      logger.e("Error loading teachers: $e");
      if (mounted) setState(() => _errorMessage = 'Failed to load teachers');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveClass() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() { _isLoading = true; _errorMessage = ''; });

    try {
      if (_isEditing) {
        await _classService.updateClass(
          widget.classDetails!.id!,
          _nameController.text,
          _selectedTeacherId,
        );
      } else {
        await _classService.createClass(
          _nameController.text,
          widget.schoolId,
          _selectedTeacherId,
        );
      }

      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: _isEditing ? 'Edit Class' : 'Add Class',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildFormCard(),
                  ),
                ),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Class Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Class Name *', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _sectionController,
                  decoration: const InputDecoration(labelText: 'Section', hintText: 'e.g., A, B', border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedTeacherId,
            decoration: const InputDecoration(labelText: 'Class Teacher', border: OutlineInputBorder()),
            hint: const Text('Select Class Teacher'),
            items: _availableTeachers.map((teacher) {
              return DropdownMenuItem<String>(
                value: teacher.id,
                child: Text(teacher.fullName ?? 'Unnamed Teacher'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedTeacherId = value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveClass,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isEditing ? 'Update Class' : 'Create Class'),
          ),
          if (_errorMessage.isNotEmpty)           const SizedBox(width: 16),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
      ),
    );
  }
}
