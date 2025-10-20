import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/user_role.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/utils/logger.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopAddEditStudent extends StatefulWidget {
  final Student? student;
  final int schoolId;

  const DesktopAddEditStudent({super.key, this.student, required this.schoolId});

  @override
  State<DesktopAddEditStudent> createState() => _DesktopAddEditStudentState();
}

class _DesktopAddEditStudentState extends State<DesktopAddEditStudent> {
  final _formKey = GlobalKey<FormState>();
  late final StudentService _studentService;
  late final ClassService _classService;
  late final AuthService _authService;
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _dobController;
  late TextEditingController _phoneNumber1Controller;
  late TextEditingController _phoneNumber2Controller;

  File? _profilePhotoFile;
  String? _currentProfilePhotoUrl;
  DateTime? _selectedDateOfBirth;
  int? _selectedClassId;
  List<app_class.SchoolClass> _availableClasses = [];
  List<app_user.User> _availableParents = [];
  List<String> _linkedParentIds = [];
  List<String> _initialLinkedParentIds = [];
  String? _selectedGender;

  String _errorMessage = '';
  bool _isLoading = false;
  bool _isLoadingParents = false;
  bool get _isEditing => widget.student != null;

  @override
  void initState() {
    super.initState();
    _studentService = Provider.of<StudentService>(context, listen: false);
    _classService = Provider.of<ClassService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);

    _nameController = TextEditingController(text: widget.student?.fullName ?? '');
    _phoneNumber1Controller = TextEditingController(text: widget.student?.phoneNumber1 ?? '');
    _phoneNumber2Controller = TextEditingController(text: widget.student?.phoneNumber2 ?? '');
    _selectedDateOfBirth = widget.student?.dateOfBirth;
    _dobController = TextEditingController(
        text: _selectedDateOfBirth != null ? DateFormat('yyyy-MM-dd').format(_selectedDateOfBirth!) : '');
    _currentProfilePhotoUrl = widget.student?.profilePhotoUrl;
    _selectedClassId = widget.student?.classId;
    _selectedGender = widget.student?.gender;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    await _loadClasses();
    await _loadAvailableParents();
    if (_isEditing && widget.student != null) {
      await _loadLinkedParents(widget.student!.id);
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadClasses() async {
    try {
      _availableClasses = await _classService.getClasses(widget.schoolId);
    } catch (e) {
      logger.e("Error loading classes: $e");
    }
  }

  Future<void> _loadAvailableParents() async {
    setState(() => _isLoadingParents = true);
    try {
      _availableParents = await _authService.getUsersByRole(UserRole.Parent, widget.schoolId);
    } catch (e) {
      logger.e("Error loading parents: $e");
    }
    if (mounted) setState(() => _isLoadingParents = false);
  }

  Future<void> _loadLinkedParents(int studentId) async {
    try {
      _linkedParentIds = await _studentService.getParentIdsForStudent(studentId);
      _initialLinkedParentIds = List.from(_linkedParentIds);
    } catch (e) {
      logger.e("Error loading linked parents: $e");
    }
  }

  Future<void> _pickProfilePhoto() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _profilePhotoFile = File(pickedFile.path);
          _currentProfilePhotoUrl = null;
        });
      }
    } catch (e) {
      logger.e("Error picking profile photo: $e");
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 25),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _onParentChanged(String parentId, bool? selected) {
    setState(() {
      if (selected == true) {
        _linkedParentIds.add(parentId);
      } else {
        _linkedParentIds.remove(parentId);
      }
    });
  }

  Future<void> _updateParentLinks(int studentId) async {
    if (!_isEditing) return;
    
    // Unlink parents that were removed
    final parentsToUnlink = _initialLinkedParentIds.where((pid) => !_linkedParentIds.contains(pid)).toList();
    for (String parentId in parentsToUnlink) {
      await _studentService.unlinkParentFromStudent(parentId, studentId);
    }
    
    // Link new parents that were added
    final parentsToLink = _linkedParentIds.where((pid) => !_initialLinkedParentIds.contains(pid)).toList();
    for (String parentId in parentsToLink) {
      await _studentService.linkParentToStudent(parentId, studentId, UserRole.Parent.name);
    }
    
    _initialLinkedParentIds = List.from(_linkedParentIds);
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String? photoUrl = _currentProfilePhotoUrl;

    try {
      if (_isEditing) {
        final phone1Text = _phoneNumber1Controller.text.trim();
        final phone2Text = _phoneNumber2Controller.text.trim();
        Student studentData = widget.student!.copyWith(
          fullName: _nameController.text,
          dateOfBirth: _selectedDateOfBirth,
          classId: _selectedClassId,
          gender: _selectedGender,
          phoneNumber1: phone1Text.isEmpty ? null : phone1Text,
          clearPhoneNumber1: phone1Text.isEmpty,
          phoneNumber2: phone2Text.isEmpty ? null : phone2Text,
          clearPhoneNumber2: phone2Text.isEmpty,
        );

        if (_profilePhotoFile != null) {
          final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          photoUrl = await _studentService.uploadStudentProfilePhoto(widget.student!.id, _profilePhotoFile!.path, fileName);
          studentData = studentData.copyWith(profilePhotoUrl: photoUrl);
        }

        final success = await _studentService.updateStudent(studentData);
        if (!success) throw Exception('Failed to update student');
        await _updateParentLinks(widget.student!.id);
      } else {
        int? newStudentId;
        if (_linkedParentIds.isNotEmpty) {
          newStudentId = await _studentService.createStudentWithParent(
            studentName: _nameController.text,
            schoolId: widget.schoolId,
            classId: _selectedClassId,
            parentId: _linkedParentIds.first,
            relationType: UserRole.Parent.name,
            dateOfBirth: _selectedDateOfBirth,
            profilePhotoUrl: null,
            gender: _selectedGender,
            phoneNumber1: _phoneNumber1Controller.text.isEmpty ? null : _phoneNumber1Controller.text,
            phoneNumber2: _phoneNumber2Controller.text.isEmpty ? null : _phoneNumber2Controller.text,
          );
          
          // Link additional parents if more than one selected
          if (newStudentId != null && _linkedParentIds.length > 1) {
            for (int i = 1; i < _linkedParentIds.length; i++) {
              await _studentService.linkParentToStudent(_linkedParentIds[i], newStudentId, UserRole.Parent.name);
            }
          }
        } else {
          newStudentId = await _studentService.createStudent(
            studentName: _nameController.text,
            schoolId: widget.schoolId,
            classId: _selectedClassId,
            dateOfBirth: _selectedDateOfBirth,
            profilePhotoUrl: null,
            gender: _selectedGender,
            phoneNumber1: _phoneNumber1Controller.text.isEmpty ? null : _phoneNumber1Controller.text,
            phoneNumber2: _phoneNumber2Controller.text.isEmpty ? null : _phoneNumber2Controller.text,
          );
        }

        if (newStudentId == null) throw Exception('Failed to create student');

        if (_profilePhotoFile != null) {
          final fileName = 'profile.${_profilePhotoFile!.path.split('.').last}';
          photoUrl = await _studentService.uploadStudentProfilePhoto(newStudentId, _profilePhotoFile!.path, fileName);
          await _studentService.updateStudent(Student(
              id: newStudentId,
              schoolId: widget.schoolId,
              fullName: _nameController.text,
              profilePhotoUrl: photoUrl));
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'Student updated successfully' : 'Student added successfully'), backgroundColor: const Color(0xFF2ECC71)),
        );
      }
    } catch (e) {
      logger.e('Failed to save student', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = _isEditing ? 'Failed to update student' : 'Failed to create student';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _phoneNumber1Controller.dispose();
    _phoneNumber2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: _isEditing ? 'Edit Student' : 'Add Student',
      body: _isLoading && _availableClasses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Form(
                    key: _formKey,
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
                              child: Column(
                                children: [
                                  _buildPhotoCard(),
                                  const SizedBox(height: 24),
                                  _buildParentCard(),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        _buildActionButtons(),
                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(_errorMessage, style: const TextStyle(color: Color(0xFFE74C3C), fontSize: 14), textAlign: TextAlign.center),
                          ),
                      ],
                    ),
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
          const Row(
            children: [
              Icon(Icons.person, color: Color(0xFF3498DB), size: 20),
              SizedBox(width: 8),
              Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline, color: Color(0xFF3498DB)),
            ),
            validator: (value) => value?.isEmpty ?? true ? 'Name is required' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF3498DB)),
                  ),
                  onTap: () => _selectDateOfBirth(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.wc, color: Color(0xFF3498DB)),
                  ),
                  items: ['Male', 'Female', 'Other'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: _selectedClassId,
            decoration: const InputDecoration(
              labelText: 'Class *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.class_, color: Color(0xFF3498DB)),
            ),
            items: _availableClasses.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
            onChanged: (value) => setState(() => _selectedClassId = value),
            validator: (value) => value == null ? 'Class is required' : null,
          ),
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
          const Row(
            children: [
              Icon(Icons.phone, color: Color(0xFF3498DB), size: 20),
              SizedBox(width: 8),
              Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            ],
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _phoneNumber1Controller,
            decoration: const InputDecoration(
              labelText: 'Phone Number 1',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone_android, color: Color(0xFF3498DB)),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _phoneNumber2Controller,
            decoration: const InputDecoration(
              labelText: 'Phone Number 2',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone, color: Color(0xFF3498DB)),
            ),
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          const Text('Profile Photo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
          const SizedBox(height: 24),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFF3498DB).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              image: _profilePhotoFile != null
                  ? DecorationImage(image: FileImage(_profilePhotoFile!), fit: BoxFit.cover)
                  : _currentProfilePhotoUrl != null && _currentProfilePhotoUrl!.isNotEmpty
                      ? DecorationImage(image: NetworkImage(_currentProfilePhotoUrl!), fit: BoxFit.cover)
                      : null,
            ),
            child: _profilePhotoFile == null && (_currentProfilePhotoUrl == null || _currentProfilePhotoUrl!.isEmpty)
                ? const Icon(Icons.person, size: 64, color: Color(0xFF3498DB))
                : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _pickProfilePhoto,
            icon: const Icon(Icons.upload, size: 18),
            label: const Text('Upload Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParentCard() {
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
          const Row(
            children: [
              Icon(Icons.family_restroom, color: Color(0xFF3498DB), size: 20),
              SizedBox(width: 8),
              Text('Link Parents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingParents)
            const Center(child: CircularProgressIndicator())
          else if (_availableParents.isEmpty)
            const Text('No parents available', style: TextStyle(color: Color(0xFF7F8C8D)))
          else
            ..._availableParents.map((parent) => CheckboxListTile(
                  title: Text(parent.fullName ?? parent.email ?? 'Parent', style: const TextStyle(fontSize: 14)),
                  value: _linkedParentIds.contains(parent.id),
                  onChanged: (selected) => _onParentChanged(parent.id, selected),
                  activeColor: const Color(0xFF3498DB),
                  contentPadding: EdgeInsets.zero,
                )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            side: const BorderSide(color: Color(0xFF7F8C8D)),
          ),
          child: const Text('Cancel', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveStudent,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3498DB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            disabledBackgroundColor: const Color(0xFF7F8C8D),
          ),
          child: _isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
              : Text(_isEditing ? 'Update Student' : 'Add Student', style: const TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}
