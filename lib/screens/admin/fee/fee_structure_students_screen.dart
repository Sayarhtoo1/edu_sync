import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../models/fee_structure.dart';
import '../../../models/fee_payment.dart';
import '../../../services/student_service.dart';
import '../../../services/fee_payment_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/class_service.dart';

class FeeStructureStudentsScreen extends StatefulWidget {
  final FeeStructure feeStructure;

  const FeeStructureStudentsScreen({super.key, required this.feeStructure});

  @override
  State<FeeStructureStudentsScreen> createState() => _FeeStructureStudentsScreenState();
}

class _FeeStructureStudentsScreenState extends State<FeeStructureStudentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _unpaidStudents = [];
  List<Map<String, dynamic>> _filteredUnpaidStudents = [];
  List<FeePayment> _payments = [];
  List<Map<String, dynamic>> _classes = [];
  bool _isLoading = true;
  double _totalCollected = 0;
  int _paidCount = 0;
  final TextEditingController _searchController = TextEditingController();
  int? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final studentService = context.read<StudentService>();
    final feePaymentService = context.read<FeePaymentService>();
    final authService = context.read<AuthService>();
    final classService = context.read<ClassService>();
    final schoolId = await authService.getCurrentUserSchoolId();
    
    if (schoolId != null) {
      final classes = await classService.getClassesBySchoolId(schoolId);
      final classesData = classes.map((c) => {'id': c.id, 'name': c.name}).toList();
      
      List<dynamic> students;
      if (widget.feeStructure.classId != null) {
        students = await studentService.getStudentsByClass(widget.feeStructure.classId!);
      } else {
        students = await studentService.getStudentsBySchool(schoolId);
      }

      final allStudents = students.map((s) => {
        'id': s.id,
        'full_name': s.fullName,
        'class_id': s.classId,
      }).toList();

      final payments = await feePaymentService.getAllPayments(schoolId);
      final paidStudentIds = payments
          .where((p) => p.feeStructureId == widget.feeStructure.id && p.status == 'Paid')
          .map((p) => p.studentId)
          .toSet();

      final unpaid = allStudents.where((s) => !paidStudentIds.contains(s['id'])).toList();
      final paidPayments = payments.where((p) => p.feeStructureId == widget.feeStructure.id && p.status == 'Paid').toList();
      final total = paidPayments.fold<double>(0, (sum, p) => sum + p.amountPaid);

      setState(() {
        _allStudents = allStudents;
        _unpaidStudents = unpaid;
        _filteredUnpaidStudents = unpaid;
        _payments = paidPayments;
        _classes = classesData;
        _totalCollected = total;
        _paidCount = paidStudentIds.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _recordPayment(Map<String, dynamic> student, {double? customAmount, String? notes}) async {
    final authService = context.read<AuthService>();
    final feePaymentService = context.read<FeePaymentService>();
    final currentUser = authService.getCurrentUser();
    
    if (currentUser == null) return;

    final payment = FeePayment(
      id: const Uuid().v4(),
      studentId: student['id'],
      feeStructureId: widget.feeStructure.id,
      amountPaid: customAmount ?? widget.feeStructure.amount,
      paymentDate: DateTime.now(),
      paymentMethod: 'Cash',
      status: 'Paid',
      notes: notes,
      collectedBy: currentUser.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await feePaymentService.createPayment(payment, feeType: widget.feeStructure.feeType);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment recorded for ${student['full_name']}')),
      );
      _loadData();
    }
  }

  Future<void> _showPaymentOptions(Map<String, dynamic> student) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _PaymentOptionsDialog(
        studentName: student['full_name'],
        feeAmount: widget.feeStructure.amount,
      ),
    );

    if (result != null) {
      if (result['action'] == 'full') {
        _recordPayment(student);
      } else if (result['action'] == 'discount') {
        _recordPayment(student, customAmount: result['amount'], notes: 'Discount applied');
      } else if (result['action'] == 'waiver') {
        _recordPayment(student, customAmount: 0, notes: 'Fee waived');
      }
    }
  }

  Future<void> _undoPayment(FeePayment payment, String studentName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Undo Payment'),
        content: Text('Undo payment for $studentName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Undo'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final feePaymentService = context.read<FeePaymentService>();
      final success = await feePaymentService.deletePayment(payment.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment undone for $studentName')),
        );
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(widget.feeStructure.feeType, style: const TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF9C27B0),
          labelColor: const Color(0xFF9C27B0),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Unpaid'),
            Tab(text: 'Paid'),
            Tab(text: 'All Students'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUnpaidList(),
                      _buildPaidList(),
                      _buildAllStudentsList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fee Amount:', style: TextStyle(color: Colors.grey)),
              Text('\$${widget.feeStructure.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const Text('Total Collected', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('\$${_totalCollected.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
                ],
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Column(
                children: [
                  const Text('Students Paid', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('$_paidCount / ${_allStudents.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Column(
                children: [
                  const Text('Pending', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${_unpaidStudents.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF44336))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _filterStudents(String query) {
    setState(() {
      var filtered = _unpaidStudents;
      
      if (_selectedClassId != null) {
        filtered = filtered.where((s) => s['class_id'] == _selectedClassId).toList();
      }
      
      if (query.isNotEmpty) {
        final q = query.toLowerCase();
        filtered = filtered.where((s) {
          final name = (s['full_name'] ?? '').toLowerCase();
          final id = s['id'].toString();
          return name.contains(q) || id.contains(q);
        }).toList();
      }
      
      _filteredUnpaidStudents = filtered;
    });
  }

  Widget _buildUnpaidList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name or ID',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _filterStudents('');
                          },
                        )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: _filterStudents,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int?>(
                value: _selectedClassId,
                decoration: InputDecoration(
                  labelText: 'Filter by Class',
                  prefixIcon: const Icon(Icons.class_),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('All Classes')),
                  ..._classes.map((c) => DropdownMenuItem(
                    value: c['id'],
                    child: Text(c['name']),
                  )),
                ],
                onChanged: (value) {
                  setState(() => _selectedClassId = value);
                  _filterStudents(_searchController.text);
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredUnpaidStudents.isEmpty
              ? Center(
                  child: Text(
                    _searchController.text.isEmpty ? 'All students have paid!' : 'No students found',
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _filteredUnpaidStudents.length,
                  itemBuilder: (context, index) {
                    final student = _filteredUnpaidStudents[index];
                    return _buildStudentCard(student, showPayButton: true);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPaidList() {
    if (_payments.isEmpty) {
      return const Center(child: Text('No payments yet', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        final student = _allStudents.firstWhere((s) => s['id'] == payment.studentId, orElse: () => {'full_name': 'Unknown'});
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: payment.amountPaid == 0 ? Colors.blue : const Color(0xFF4CAF50),
              child: Icon(payment.amountPaid == 0 ? Icons.card_giftcard : Icons.check, color: Colors.white),
            ),
            title: Text(student['full_name'] ?? 'Unknown'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat('MMM dd, yyyy').format(payment.paymentDate)),
                if (payment.notes != null) Text(payment.notes!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$${payment.amountPaid.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.undo, color: Colors.orange),
                  onPressed: () => _undoPayment(payment, student['full_name']),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllStudentsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allStudents.length,
      itemBuilder: (context, index) {
        final student = _allStudents[index];
        final isPaid = _payments.any((p) => p.studentId == student['id']);
        return _buildStudentCard(student, showPayButton: !isPaid, isPaid: isPaid);
      },
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, {bool showPayButton = false, bool isPaid = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isPaid ? const Color(0xFF4CAF50).withOpacity(0.1) : const Color(0xFF9C27B0).withOpacity(0.1),
          child: Text(
            student['full_name']?[0] ?? '?',
            style: TextStyle(
              color: isPaid ? const Color(0xFF4CAF50) : const Color(0xFF9C27B0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(student['full_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('ID: ${student['id']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPaid)
              const Chip(
                label: Text('Paid', style: TextStyle(color: Colors.white, fontSize: 12)),
                backgroundColor: Color(0xFF4CAF50),
                padding: EdgeInsets.symmetric(horizontal: 8),
              ),
            if (showPayButton) ...[
              Text('\$${widget.feeStructure.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showPaymentOptions(student),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9C27B0)),
                child: const Text('Pay'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}


class _PaymentOptionsDialog extends StatefulWidget {
  final String studentName;
  final double feeAmount;

  const _PaymentOptionsDialog({required this.studentName, required this.feeAmount});

  @override
  State<_PaymentOptionsDialog> createState() => _PaymentOptionsDialogState();
}

class _PaymentOptionsDialogState extends State<_PaymentOptionsDialog> {
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Payment for ${widget.studentName}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Fee Amount: \$${widget.feeAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.payment, color: Color(0xFF4CAF50)),
            title: const Text('Full Payment'),
            onTap: () => Navigator.pop(context, {'action': 'full'}),
          ),
          ListTile(
            leading: const Icon(Icons.discount, color: Color(0xFFFF9800)),
            title: const Text('With Discount'),
            onTap: () async {
              final amount = await _showAmountDialog('Enter discounted amount');
              if (amount != null && mounted) {
                Navigator.pop(context, {'action': 'discount', 'amount': amount});
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_giftcard, color: Color(0xFF2196F3)),
            title: const Text('Fee Waiver / Exemption'),
            onTap: () => Navigator.pop(context, {'action': 'waiver'}),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ],
    );
  }

  Future<double?> _showAmountDialog(String title) async {
    return showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Amount', prefixText: '\$ '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, double.tryParse(_amountController.text)),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
