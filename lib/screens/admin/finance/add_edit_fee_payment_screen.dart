import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../services/fee_payment_service.dart';
import '../../../services/student_service.dart';
import '../../../services/auth_service.dart';
import '../../../providers/school_provider.dart';
import '../../../models/fee_payment.dart';
import '../../../models/student.dart';

class AddEditFeePaymentScreen extends StatefulWidget {
  final FeePayment? payment;

  const AddEditFeePaymentScreen({super.key, this.payment});

  @override
  State<AddEditFeePaymentScreen> createState() => _AddEditFeePaymentScreenState();
}

class _AddEditFeePaymentScreenState extends State<AddEditFeePaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _transactionIdController;
  late TextEditingController _notesController;
  
  List<Student> _students = [];
  Student? _selectedStudent;
  String _paymentMethod = 'Cash';
  String _status = 'Paid';
  DateTime _paymentDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isLoadingStudents = true;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.payment?.amountPaid.toString() ?? '');
    _transactionIdController = TextEditingController(text: widget.payment?.transactionId ?? '');
    _notesController = TextEditingController(text: widget.payment?.notes ?? '');
    
    if (widget.payment != null) {
      _paymentMethod = widget.payment!.paymentMethod;
      _status = widget.payment!.status;
      _paymentDate = widget.payment!.paymentDate;
    }
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId != null) {
      final students = await context.read<StudentService>().getStudentsBySchool(schoolId);
      setState(() {
        _students = students;
        if (widget.payment != null) {
          _selectedStudent = students.firstWhere((s) => s.id == widget.payment!.studentId, orElse: () => students.first);
        }
        _isLoadingStudents = false;
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _transactionIdController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedStudent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a student')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final currentUser = context.read<AuthService>().getCurrentUser();
    if (currentUser == null) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not authenticated')),
        );
      }
      return;
    }

    final payment = FeePayment(
      id: widget.payment?.id ?? const Uuid().v4(),
      studentId: _selectedStudent!.id!,
      feeStructureId: widget.payment?.feeStructureId,
      amountPaid: double.parse(_amountController.text),
      paymentDate: _paymentDate,
      paymentMethod: _paymentMethod,
      transactionId: _transactionIdController.text.isEmpty ? null : _transactionIdController.text,
      status: _status,
      receiptNumber: widget.payment?.receiptNumber,
      receiptUrl: widget.payment?.receiptUrl,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      collectedBy: currentUser.id,
      createdAt: widget.payment?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final service = context.read<FeePaymentService>();
    final result = widget.payment == null
        ? await service.createPayment(payment)
        : await service.updatePayment(payment.id, payment.toJson());

    setState(() => _isSubmitting = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.payment == null ? 'Payment recorded successfully' : 'Payment updated successfully')),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save payment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(widget.payment == null ? 'Record Payment' : 'Edit Payment', 
          style: const TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Payment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  _isLoadingStudents
                      ? const Center(child: CircularProgressIndicator())
                      : DropdownButtonFormField<Student>(
                          value: _selectedStudent,
                          decoration: InputDecoration(
                            labelText: 'Select Student',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          items: _students.map((student) {
                            return DropdownMenuItem(
                              value: student,
                              child: Text('${student.fullName} (ID: ${student.id})'),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => _selectedStudent = value),
                          validator: (value) => value == null ? 'Please select a student' : null,
                        ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.payment),
                    ),
                    items: ['Cash', 'Bank Transfer', 'Check', 'Online', 'Card']
                        .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                        .toList(),
                    onChanged: (value) => setState(() => _paymentMethod = value!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.check_circle),
                    ),
                    items: ['Paid', 'Pending', 'Overdue', 'Partial']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (value) => setState(() => _status = value!),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_today),
                    title: const Text('Payment Date'),
                    subtitle: Text('${_paymentDate.day}/${_paymentDate.month}/${_paymentDate.year}'),
                    trailing: const Icon(Icons.edit),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _paymentDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) setState(() => _paymentDate = date);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _transactionIdController,
                    decoration: InputDecoration(
                      labelText: 'Transaction ID (Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.receipt_long),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      prefixIcon: const Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(widget.payment == null ? 'Record Payment' : 'Update Payment', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
