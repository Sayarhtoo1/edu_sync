import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/services/parent_service.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';
import 'package:edu_sync/utils/logger.dart';

class DesktopAddEditParent extends StatefulWidget {
  final app_user.User? parent;
  final int schoolId;

  const DesktopAddEditParent({super.key, this.parent, required this.schoolId});

  @override
  State<DesktopAddEditParent> createState() => _DesktopAddEditParentState();
}

class _DesktopAddEditParentState extends State<DesktopAddEditParent> {
  final _formKey = GlobalKey<FormState>();
  late final ParentService _parentService;
  late final AuthService _authService;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phone1Controller;
  late TextEditingController _phone2Controller;

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
    _phone1Controller = TextEditingController(text: widget.parent?.phoneNumber1 ?? '');
    _phone2Controller = TextEditingController(text: widget.parent?.phoneNumber2 ?? '');
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
          phoneNumber1: _phone1Controller.text.isEmpty ? null : _phone1Controller.text,
          phoneNumber2: _phone2Controller.text.isEmpty ? null : _phone2Controller.text,
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
          phoneNumber1: _phone1Controller.text.isEmpty ? null : _phone1Controller.text,
          phoneNumber2: _phone2Controller.text.isEmpty ? null : _phone2Controller.text,
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
              phoneNumber1: _phone1Controller.text.isEmpty ? null : _phone1Controller.text,
              phoneNumber2: _phone2Controller.text.isEmpty ? null : _phone2Controller.text,
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
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: _isEditing ? 'Edit Parent' : 'Add Parent',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          children: [
                            _buildBasicInfoCard(),
                            const SizedBox(height: 24),
                            _buildContactInfoCard(),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        flex: 1,
                        child: _buildProfilePhotoCard(),
                      ),
                    ],
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

  Widget _buildBasicInfoCard() {
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
          const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name *', border: OutlineInputBorder()),
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email *', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                  readOnly: _isEditing,
                ),
              ),
            ],
          ),
          if (!_isEditing) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password *', border: OutlineInputBorder()),
              obscureText: true,
              validator: (value) {
                if (!_isEditing && (value == null || value.isEmpty)) return 'Required';
                if (value != null && value.isNotEmpty && value.length < 6) return 'Min 6 characters';
                return null;
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactInfoCard() {
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
          const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _phone1Controller,
                  decoration: const InputDecoration(labelText: 'Phone Number 1', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _phone2Controller,
                  decoration: const InputDecoration(labelText: 'Phone Number 2', border: OutlineInputBorder()),
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoCard() {
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
          const Text('Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 24),
          Container(
            height: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.2)),
            ),
            child: _profilePhotoFile != null
                ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_profilePhotoFile!, height: 190, fit: BoxFit.cover))
                : (_currentProfilePhotoUrl != null && _currentProfilePhotoUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: _currentProfilePhotoUrl!,
                          height: 190,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => const CircularProgressIndicator(),
                          errorWidget: (context, url, error) => const Icon(Icons.person, size: 80, color: Color(0xFF3498DB)),
                        ),
                      )
                    : const Icon(Icons.person, size: 80, color: Color(0xFF3498DB))),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _pickProfilePhoto,
              icon: const Icon(Icons.image, color: Color(0xFF3498DB)),
              label: const Text('Select Photo', style: TextStyle(color: Color(0xFF3498DB))),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF3498DB)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
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
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _isLoading ? null : _saveParent,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(_isEditing ? 'Update Parent' : 'Create Parent'),
          ),
          if (_errorMessage.isNotEmpty) ...[
            const SizedBox(width: 16),
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    );
  }
}
