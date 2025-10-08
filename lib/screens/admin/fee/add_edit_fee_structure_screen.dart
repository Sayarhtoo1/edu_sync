import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../models/fee_structure.dart';
import '../../../services/fee_structure_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/class_service.dart';
import '../../../models/school_class.dart';

class AddEditFeeStructureScreen extends StatefulWidget {
  final FeeStructure? feeStructure;

  const AddEditFeeStructureScreen({super.key, this.feeStructure});

  @override
  State<AddEditFeeStructureScreen> createState() => _AddEditFeeStructureScreenState();
}

class _AddEditFeeStructureScreenState extends State<AddEditFeeStructureScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _feeTypeController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _academicYearController;
  
  String _selectedFrequency = 'Monthly';
  int? _selectedClassId;
  bool _isMandatory = true;
  bool _isLoading = false;
  List<SchoolClass> _classes = [];

  @override
  void initState() {
    super.initState();
    _feeTypeController = TextEditingController(text: widget.feeStructure?.feeType ?? '');
    _amountController = TextEditingController(text: widget.feeStructure?.amount.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.feeStructure?.description ?? '');
    _academicYearController = TextEditingController(text: widget.feeStructure?.academicYear ?? DateTime.now().year.toString());
    _selectedFrequency = widget.feeStructure?.frequency ?? 'Monthly';
    _selectedClassId = widget.feeStructure?.classId;
    _isMandatory = widget.feeStructure?.isMandatory ?? true;
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    final authService = context.read<AuthService>();
    final classService = context.read<ClassService>();
    final schoolId = await authService.getCurrentUserSchoolId();
    
    if (schoolId != null) {
      final classes = await classService.getClassesBySchoolId(schoolId);
      setState(() => _classes = classes);
    }
  }

  Future<void> _saveFeeStructure() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final feeService = context.read<FeeStructureService>();
    final schoolId = await authService.getCurrentUserSchoolId();

    if (schoolId == null) return;

    final feeStructure = FeeStructure(
      id: widget.feeStructure?.id ?? const Uuid().v4(),
      schoolId: schoolId,
      classId: _selectedClassId,
      feeType: _feeTypeController.text,
      amount: double.parse(_amountController.text),
      frequency: _selectedFrequency,
      academicYear: _academicYearController.text,
      description: _descriptionController.text,
      isMandatory: _isMandatory,
      createdAt: widget.feeStructure?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = widget.feeStructure == null
        ? await feeService.createFeeStructure(feeStructure) != null
        : await feeService.updateFeeStructure(feeStructure);

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.feeStructure == null ? 'Add Fee Structure' : 'Edit Fee Structure'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _feeTypeController,
              decoration: const InputDecoration(labelText: 'Fee Type', hintText: 'e.g., Tuition, Transport'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedFrequency,
              decoration: const InputDecoration(labelText: 'Frequency'),
              items: ['Monthly', 'Quarterly', 'Yearly', 'One-time']
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedFrequency = v!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int?>(
              value: _selectedClassId,
              decoration: const InputDecoration(labelText: 'Class (Optional - Leave empty for all classes)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('All Classes')),
                ..._classes.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
              ],
              onChanged: (v) => setState(() => _selectedClassId = v),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _academicYearController,
              decoration: const InputDecoration(labelText: 'Academic Year'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Mandatory'),
              value: _isMandatory,
              onChanged: (v) => setState(() => _isMandatory = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveFeeStructure,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(widget.feeStructure == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feeTypeController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }
}
