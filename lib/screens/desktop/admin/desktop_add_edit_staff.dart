import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:edu_sync/models/staff.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopAddEditStaff extends StatefulWidget {
  final Staff? staff;
  final int schoolId;

  const DesktopAddEditStaff({super.key, this.staff, required this.schoolId});

  @override
  State<DesktopAddEditStaff> createState() => _DesktopAddEditStaffState();
}

class _DesktopAddEditStaffState extends State<DesktopAddEditStaff> {
  final _formKey = GlobalKey<FormState>();
  late final AuthService _authService;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  late TextEditingController _salaryController;
  late UserRole _selectedRole;

  File? _profilePhotoFile;
  String? _currentProfilePhotoUrl;
  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.staff != null;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _nameController = TextEditingController(text: widget.staff?.fullName ?? '');
    _emailController = TextEditingController(text: widget.staff?.email ?? '');
    _passwordController = TextEditingController();
    _phoneController = TextEditingController(text: widget.staff?.phoneNumber ?? '');
    _salaryController = TextEditingController(text: widget.staff?.salary?.toString() ?? '');
    _selectedRole = UserRole.fromString(widget.staff?.role) ?? UserRole.Teacher;
    _currentProfilePhotoUrl = widget.staff?.profilePhotoUrl;
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

  Future<void> _saveStaff() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() { _isLoading = true; _errorMessage = ''; });

    String? photoUrl = _currentProfilePhotoUrl;

    try {
      app_user.User? resultUser;

      if (_isEditing) {
        if (_profilePhotoFile != null) {
          final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          photoUrl = await _authService.uploadProfilePhoto(widget.staff!.id, _profilePhotoFile!.path, fileName);
        }
        final updatedUser = app_user.User(
          id: widget.staff!.id,
          fullName: _nameController.text,
          email: _emailController.text,
          role: _selectedRole.name,
          profilePhotoUrl: photoUrl,
          schoolId: widget.staff!.schoolId,
          phoneNumber1: _phoneController.text.isEmpty ? null : _phoneController.text,
          salary: _salaryController.text.isEmpty ? null : double.tryParse(_salaryController.text),
        );
        final success = await _authService.updateUser(updatedUser);
        if (!success) throw Exception('Failed to update staff.');
        resultUser = updatedUser;
      } else {
        if (_passwordController.text.isEmpty) {
           setState(() { _isLoading = false; _errorMessage = 'Password is required for a new staff member.'; });
           return;
        }

        logger.i('Creating staff user with role: ${_selectedRole.name} for schoolId: ${widget.schoolId}');

        final newUser = await _authService.createStaffByAdmin(
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole.name,
          schoolId: widget.schoolId,
          fullName: _nameController.text,
          profilePhotoUrl: photoUrl,
          phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
          salary: _salaryController.text.isEmpty ? null : double.tryParse(_salaryController.text),
        );

        logger.i('Staff user created successfully');

        if (newUser == null) {
          throw Exception('Failed to create staff member.');
        }
        resultUser = newUser;

        if (_profilePhotoFile != null) {
          final correctFileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          final correctPhotoUrl = await _authService.uploadProfilePhoto(resultUser.id, _profilePhotoFile!.path, correctFileName);
          if (correctPhotoUrl != null) {
            final updatedUser = app_user.User(
              id: resultUser.id,
              fullName: resultUser.fullName,
              email: resultUser.email,
              role: resultUser.role,
              profilePhotoUrl: correctPhotoUrl,
              schoolId: resultUser.schoolId,
              phoneNumber1: resultUser.phoneNumber1,
              salary: resultUser.salary,
            );
            await _authService.updateUser(updatedUser);
          }
        }
      }

      setState(() => _isLoading = false);
      if (mounted) Navigator.of(context).pop(true);

    } catch (e) {
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
    _salaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: _isEditing ? 'Edit Staff' : 'Add Staff',
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE74C3C)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFE74C3C)),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_errorMessage, style: const TextStyle(color: Color(0xFFE74C3C)))),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24),
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
                    decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
                    validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<UserRole>(
                    value: _selectedRole,
                    decoration: const InputDecoration(labelText: 'Role', border: OutlineInputBorder()),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem<UserRole>(value: role, child: Text(role.name));
                    }).toList(),
                    onChanged: (UserRole? newValue) {
                      if (newValue != null) setState(() => _selectedRole = newValue);
                    },
                    validator: (value) => value == null ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                    readOnly: _isEditing,
                  ),
                ),
                const SizedBox(width: 16),
                if (!_isEditing)
                  Expanded(
                    child: TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (value) {
                        if (!_isEditing && (value == null || value.isEmpty)) return 'Required';
                        if (value != null && value.isNotEmpty && value.length < 6) return 'Too short';
                        return null;
                      },
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contact & Salary', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _salaryController,
                    decoration: const InputDecoration(labelText: 'Salary', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePhotoCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            const SizedBox(height: 24),
            Container(
              height: 200,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _profilePhotoFile != null
                  ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_profilePhotoFile!, height: 200, fit: BoxFit.cover))
                  : (_currentProfilePhotoUrl != null && _currentProfilePhotoUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: _currentProfilePhotoUrl!,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const CircularProgressIndicator(),
                            errorWidget: (context, url, error) => const Text('Could not load image.'),
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_outline, size: 64, color: Colors.grey),
                            SizedBox(height: 8),
                            Text('No photo', style: TextStyle(color: Colors.grey)),
                          ],
                        )),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2ECC71),
                  side: const BorderSide(color: Color(0xFF2ECC71)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.image),
                label: const Text('Select Photo'),
                onPressed: _pickProfilePhoto,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            side: BorderSide(color: Colors.grey.shade400),
          ),
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2ECC71),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            elevation: 0,
          ),
          onPressed: _isLoading ? null : _saveStaff,
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : Text(_isEditing ? 'Update Staff' : 'Add Staff'),
        ),
      ],
    );
  }
}
