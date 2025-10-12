import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../services/fee_payment_service.dart';
import '../../../providers/school_provider.dart';
import '../../../models/fee_payment.dart';

class FeePaymentManagementScreen extends StatefulWidget {
  const FeePaymentManagementScreen({super.key});

  @override
  State<FeePaymentManagementScreen> createState() => _FeePaymentManagementScreenState();
}

class _FeePaymentManagementScreenState extends State<FeePaymentManagementScreen> {
  bool _isLoading = true;
  List<FeePayment> _payments = [];
  List<FeePayment> _filteredPayments = [];
  String _searchQuery = '';
  String _statusFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  Future<void> _loadPayments() async {
    setState(() => _isLoading = true);
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId != null) {
      final payments = await context.read<FeePaymentService>().getAllPayments(schoolId);
      setState(() {
        _payments = payments;
        _filteredPayments = payments;
        _isLoading = false;
      });
    }
  }

  void _filterPayments() {
    setState(() {
      _filteredPayments = _payments.where((payment) {
        final matchesStatus = _statusFilter == 'All' || payment.status == _statusFilter;
        final matchesSearch = _searchQuery.isEmpty;
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalPaid = _filteredPayments.fold<double>(0, (sum, p) => sum + p.amountPaid);
    final paidToday = _filteredPayments.where((p) => 
      p.paymentDate.year == DateTime.now().year &&
      p.paymentDate.month == DateTime.now().month &&
      p.paymentDate.day == DateTime.now().day
    ).fold<double>(0, (sum, p) => sum + p.amountPaid);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Fee Payment Management', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildSummaryCard('Total Fees', '\$${totalPaid.toStringAsFixed(2)}', const Color(0xFF9C27B0)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSummaryCard('Paid Today', '\$${paidToday.toStringAsFixed(2)}', const Color(0xFF4CAF50)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _statusFilter,
                              decoration: InputDecoration(
                                labelText: 'Status',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                              items: ['All', 'Paid', 'Pending', 'Overdue', 'Partial']
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (value) {
                                setState(() => _statusFilter = value!);
                                _filterPayments();
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredPayments.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.payment, size: 80, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text('No fee payments found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPayments.length,
                          itemBuilder: (context, index) {
                            final payment = _filteredPayments[index];
                            return _buildPaymentCard(payment);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/admin/add-fee-payment');
          _loadPayments();
        },
        backgroundColor: const Color(0xFF9C27B0),
        icon: const Icon(Icons.add),
        label: const Text('Record Payment'),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(FeePayment payment) {
    Color statusColor;
    switch (payment.status) {
      case 'Paid':
        statusColor = const Color(0xFF4CAF50);
        break;
      case 'Pending':
        statusColor = const Color(0xFFFFC107);
        break;
      case 'Overdue':
        statusColor = const Color(0xFFF44336);
        break;
      case 'Partial':
        statusColor = const Color(0xFFFF9800);
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('Student ID: ${payment.studentId}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(payment.status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Amount', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text('\$${payment.amountPaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF9C27B0))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Date', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Text(DateFormat('MMM dd, yyyy').format(payment.paymentDate), style: const TextStyle(fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.payment, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(payment.paymentMethod, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              if (payment.receiptNumber != null) ...[
                const SizedBox(width: 16),
                Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(payment.receiptNumber!, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
