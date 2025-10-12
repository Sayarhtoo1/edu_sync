import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/services/school_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/theme/app_theme.dart';
import 'package:edu_sync/utils/logger.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SchoolProfileScreen extends StatefulWidget {
  const SchoolProfileScreen({super.key});

  @override
  State<SchoolProfileScreen> createState() => _SchoolProfileScreenState();
}

class _SchoolProfileScreenState extends State<SchoolProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SchoolService _schoolService;
  late final AuthService _authService;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _academicYearController;
  late TextEditingController _contactController;
  late TextEditingController _hijriAdjustmentController;

  File? _logoFile;
  String? _currentLogoUrl;
  bool _isLoading = false;
  bool _isEditing = false;
  School? _school;
  int? _schoolId;

  @override
  void initState() {
    super.initState();
    _schoolService = Provider.of<SchoolService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _nameController = TextEditingController();
    _academicYearController = TextEditingController();
    _contactController = TextEditingController();
    _hijriAdjustmentController = TextEditingController();
    _loadSchoolData();
  }

  Future<void> _loadSchoolData() async {
    setState(() => _isLoading = true);
    try {
      _schoolId = await _authService.getCurrentUserSchoolId();
      if (_schoolId != null) {
        _school = await _schoolService.getSchoolById(_schoolId!);
        if (_school != null) {
          _nameController.text = _school!.name;
          _academicYearController.text = _school!.academicYear;
          _contactController.text = _school!.contact;
          _hijriAdjustmentController.text = _school!.hijriDayAdjustment?.toString() ?? '0';
          _currentLogoUrl = _school!.logoUrl;
        }
      }
    } catch (e) {
      logger.e('Error loading school data: $e');
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _pickLogo() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _logoFile = File(pickedFile.path);
        _currentLogoUrl = null;
      });
    }
  }

  Future<void> _saveSchool() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      String? logoUrl = _currentLogoUrl;

      if (_logoFile != null && _schoolId != null) {
        final fileName = 'logo.${_logoFile!.path.split('.').last}';
        logoUrl = await _schoolService.uploadSchoolLogo(_schoolId!, _logoFile!.path, fileName);
      }

      final updatedSchool = School(
        id: _schoolId!,
        name: _nameController.text,
        logoUrl: logoUrl ?? '',
        academicYear: _academicYearController.text,
        theme: _school?.theme ?? 'default',
        contact: _contactController.text,
        hijriDayAdjustment: int.tryParse(_hijriAdjustmentController.text),
      );

      final success = await _schoolService.updateSchool(updatedSchool);
      
      if (success && mounted) {
        await Provider.of<SchoolProvider>(context, listen: false).refreshSchoolData(_schoolId!);
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('School profile updated successfully')),
        );
        await _loadSchoolData();
      } else {
        throw Exception('Failed to update school');
      }
    } catch (e) {
      logger.e('Error saving school: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _academicYearController.dispose();
    _contactController.dispose();
    _hijriAdjustmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('School Profile', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _isEditing ? _pickLogo : null,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                              ),
                              child: _logoFile != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(_logoFile!, fit: BoxFit.cover),
                                    )
                                  : (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: CachedNetworkImage(
                                            imageUrl: _currentLogoUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                            errorWidget: (context, url, error) => const Icon(Icons.school, size: 48, color: Colors.grey),
                                          ),
                                        )
                                      : const Icon(Icons.school, size: 48, color: Colors.grey)),
                            ),
                          ),
                          if (_isEditing) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              icon: const Icon(Icons.image),
                              label: const Text('Change Logo'),
                              onPressed: _pickLogo,
                            ),
                          ],
                          const SizedBox(height: 24),
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'School Name',
                              prefixIcon: Icon(Icons.school),
                            ),
                            enabled: _isEditing,
                            validator: (value) => (value == null || value.isEmpty) ? 'School name is required' : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _academicYearController,
                            decoration: const InputDecoration(
                              labelText: 'Academic Year',
                              prefixIcon: Icon(Icons.calendar_today),
                            ),
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contactController,
                            decoration: const InputDecoration(
                              labelText: 'Contact Information',
                              prefixIcon: Icon(Icons.phone),
                            ),
                            enabled: _isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _hijriAdjustmentController,
                            decoration: const InputDecoration(
                              labelText: 'Hijri Day Adjustment',
                              prefixIcon: Icon(Icons.adjust),
                            ),
                            enabled: _isEditing,
                            keyboardType: TextInputType.number,
                          ),
                          if (_isEditing) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      setState(() => _isEditing = false);
                                      _loadSchoolData();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.getAccentColorForContext('admin'),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _saveSchool,
                                    child: const Text('Save'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
