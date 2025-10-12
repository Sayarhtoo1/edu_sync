import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/salary_payment.dart';
import '../../services/salary_service.dart';
import '../../services/auth_service.dart';

class SalaryManagementScreen extends StatefulWidget {
  const SalaryManagementScreen({super.key});

  @override
  State<SalaryManagementScreen> createState() => _SalaryManagementScreenState();
}

class _SalaryManagementScreenState extends State<SalaryManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _allStaff = [];
  List<Map<String, dynamic>> _unpaidStaff = [];
  List<SalaryPayment> _payments = [];
  bool _isLoading = true;
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());
  double _totalPaid = 0;
  int _paidCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final salaryService = context.read<SalaryService>();
    final schoolId = await authService.getCurrentUserSchoolId();
    
    if (schoolId != null) {
      final staff = await salaryService.getStaffWithSalary(schoolId);
      final unpaid = await salaryService.getUnpaidStaff(schoolId, _selectedMonth);
      final payments = await salaryService.getSalaryPayments(schoolId, month: _selectedMonth);
      final summary = await salaryService.getSalarySummary(schoolId, _selectedMonth);
      
      setState(() {
        _allStaff = staff;
        _unpaidStaff = unpaid;
        _payments = payments;
        _totalPaid = summary['total_paid'];
        _paidCount = summary['staff_count'];
        _isLoading = false;
      });
    }
  }

  Future<void> _paySalary(Map<String, dynamic> staff) async {
    final authService = context.read<AuthService>();
    final salaryService = context.read<SalaryService>();
    final schoolId = await authService.getCurrentUserSchoolId();
    final currentUser = authService.getCurrentUser();
    
    if (schoolId == null || staff['salary'] == null) return;

    final payment = SalaryPayment(
      id: const Uuid().v4(),
      staffId: staff['id'],
      schoolId: schoolId,
      amount: (staff['salary'] as num).toDouble(),
      paymentDate: DateTime.now(),
      paymentMonth: _selectedMonth,
      paymentMethod: 'Cash',
      status: 'Paid',
      paidBy: currentUser?.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await salaryService.createSalaryPayment(payment);
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Salary paid to ${staff['full_name']}')),
      );
      _loadData();
    }
  }

  Future<void> _updateSalary(Map<String, dynamic> staff) async {
    final controller = TextEditingController(text: staff['salary']?.toString() ?? '');
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Salary - ${staff['full_name']}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Monthly Salary', prefixText: '\$ '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, double.tryParse(controller.text)),
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null) {
      final salaryService = context.read<SalaryService>();
      final success = await salaryService.updateStaffSalary(staff['id'], result);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salary updated successfully')),
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
        title: const Text('Salary Management', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF2196F3),
          labelColor: const Color(0xFF2196F3),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Unpaid'),
            Tab(text: 'Paid'),
            Tab(text: 'All Staff'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSummaryCard(),
          _buildMonthSelector(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildUnpaidList(),
                      _buildPaidList(),
                      _buildAllStaffList(),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text('Total Paid', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text('\$${_totalPaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50))),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Column(
            children: [
              const Text('Staff Paid', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text('$_paidCount / ${_allStaff.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.grey[300]),
          Column(
            children: [
              const Text('Pending', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 4),
              Text('${_unpaidStaff.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFF44336))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Text('Month: ', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<String>(
            value: _selectedMonth,
            items: List.generate(12, (i) {
              final date = DateTime(DateTime.now().year, DateTime.now().month - i);
              return DateFormat('yyyy-MM').format(date);
            }).map((m) => DropdownMenuItem(value: m, child: Text(DateFormat('MMMM yyyy').format(DateTime.parse('$m-01'))))).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _selectedMonth = v);
                _loadData();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildUnpaidList() {
    if (_unpaidStaff.isEmpty) {
      return const Center(child: Text('All staff salaries paid for this month!', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _unpaidStaff.length,
      itemBuilder: (context, index) {
        final staff = _unpaidStaff[index];
        return _buildStaffCard(staff, showPayButton: true);
      },
    );
  }

  Widget _buildPaidList() {
    if (_payments.isEmpty) {
      return const Center(child: Text('No salary payments yet', style: TextStyle(color: Colors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final payment = _payments[index];
        final staff = _allStaff.firstWhere((s) => s['id'] == payment.staffId, orElse: () => {'full_name': 'Unknown', 'role': ''});
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(backgroundColor: Color(0xFF4CAF50), child: Icon(Icons.check, color: Colors.white)),
            title: Text(staff['full_name'] ?? 'Unknown'),
            subtitle: Text('${staff['role']} • ${DateFormat('MMM dd, yyyy').format(payment.paymentDate)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$${payment.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.undo, color: Colors.orange),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Undo Payment'),
                        content: Text('Are you sure you want to undo the salary payment for ${staff['full_name']}?'),
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
                    if (confirm == true && mounted) {
                      final salaryService = context.read<SalaryService>();
                      final success = await salaryService.deleteSalaryPayment(payment.id);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Payment undone for ${staff['full_name']}')),
                        );
                        _loadData();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAllStaffList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _allStaff.length,
      itemBuilder: (context, index) => _buildStaffCard(_allStaff[index], showEditButton: true),
    );
  }

  Widget _buildStaffCard(Map<String, dynamic> staff, {bool showPayButton = false, bool showEditButton = false}) {
    final salary = staff['salary'];
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
          backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
          child: Text(staff['full_name']?[0] ?? '?', style: const TextStyle(color: Color(0xFF2196F3), fontWeight: FontWeight.bold)),
        ),
        title: Text(staff['full_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(staff['role'] ?? ''),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(salary != null ? '\$${salary.toStringAsFixed(2)}' : 'Not Set', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Monthly', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            if (showPayButton && salary != null) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _paySalary(staff),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
                child: const Text('Pay'),
              ),
            ],
            if (showEditButton) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: Color(0xFF2196F3)),
                onPressed: () => _updateSalary(staff),
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
    super.dispose();
  }
}
