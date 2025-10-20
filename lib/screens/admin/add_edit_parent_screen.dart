import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/services/parent_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/utils/logger.dart';

class AddEditParentScreen extends StatefulWidget {
  final app_user.User? parent;
  final int schoolId;

  const AddEditParentScreen({super.key, this.parent, required this.schoolId});

  @override
  State<AddEditParentScreen> createState() => _AddEditParentScreenState();
}

class _AddEditParentScreenState extends State<AddEditParentScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ParentService _parentService;
  late final AuthService _authService;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;

  File? _profilePhotoFile;
  String? _currentProfilePhotoUrl;
  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.parent != null;

  @override
  void initState() {
    super.initState();
    _parentService = Provider.of<ParentService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _nameController = TextEditingController(text: widget.parent?.fullName ?? '');
    _emailController = TextEditingController(text: widget.parent?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.parent?.phoneNumber1 ?? '');
    _currentProfilePhotoUrl = widget.parent?.profilePhotoUrl;
  }

  Future<void> _pickProfilePhoto() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profilePhotoFile = File(pickedFile.path);
        _currentProfilePhotoUrl = null;
      });
    }
  }

  Future<void> _saveParent() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() { _isLoading = true; _errorMessage = ''; });

    String? photoUrl = _currentProfilePhotoUrl;

    try {
      if (_isEditing) {
        if (_profilePhotoFile != null) {
          final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          photoUrl = await _authService.uploadProfilePhoto(widget.parent!.id, _profilePhotoFile!.path, fileName);
        }
        final updatedUser = app_user.User(
          id: widget.parent!.id,
          fullName: _nameController.text,
          email: _emailController.text,
          role: 'Parent',
          profilePhotoUrl: photoUrl,
          schoolId: widget.parent!.schoolId,
          phoneNumber1: _phoneController.text.isEmpty ? null : _phoneController.text,
        );
        final success = await _parentService.updateParent(updatedUser);
        if (!success) throw Exception('Failed to update parent.');
      } else {
        if (_passwordController.text.isEmpty) {
          setState(() { _isLoading = false; _errorMessage = 'Password is required.'; });
          return;
        }

        final newParentId = await _parentService.createParent(
          email: _emailController.text,
          password: _passwordController.text,
          schoolId: widget.schoolId,
          fullName: _nameController.text,
          profilePhotoUrl: photoUrl,
          phoneNumber1: _phoneController.text.isEmpty ? null : _phoneController.text,
        );

        if (_profilePhotoFile != null) {
          final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          final uploadedUrl = await _authService.uploadProfilePhoto(newParentId, _profilePhotoFile!.path, fileName);
          if (uploadedUrl != null) {
            final updatedUser = app_user.User(
              id: newParentId,
              fullName: _nameController.text,
              email: _emailController.text,
              role: 'Parent',
              profilePhotoUrl: uploadedUrl,
              schoolId: widget.schoolId,
              phoneNumber1: _phoneController.text.isEmpty ? null : _phoneController.text,
            );
            await _parentService.updateParent(updatedUser);
          }
        }
      }

      setState(() => _isLoading = false);
      if (mounted) Navigator.of(context).pop(true);

    } catch (e) {
      logger.e('Error saving parent: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit Parent' : 'Add Parent')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) => (value == null || value.isEmpty) ? 'Full name is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value == null || value.isEmpty) ? 'Email is required.' : null,
                readOnly: _isEditing,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              if (!_isEditing)
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (!_isEditing && (value == null || value.isEmpty)) return 'Password is required.';
                    if (value != null && value.isNotEmpty && value.length < 6) return 'Password must be at least 6 characters.';
                    return null;
                  },
                ),
              if (!_isEditing) const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.withAlpha(50),
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey.withValues(alpha: 0.5))
                      ),
                      child: _profilePhotoFile != null
                          ? Image.file(_profilePhotoFile!, height: 90, fit: BoxFit.contain)
                          : (_currentProfilePhotoUrl != null && _currentProfilePhotoUrl!.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: _currentProfilePhotoUrl!,
                                  height: 90,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Text('Could not load image.'),
                                )
                              : const Text('No profile photo.', style: TextStyle(color: Colors.grey))),
                    )
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: const Color(0xFF3498DB)),
                    icon: const Icon(Icons.image),
                    label: const Text('Select Photo'),
                    onPressed: _pickProfilePhoto,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB))))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _saveParent,
                      child: Text(_isEditing ? 'Update Parent' : 'Add Parent'),
                    ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
