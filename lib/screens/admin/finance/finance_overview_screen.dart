import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../services/finance_service.dart';
import '../../../providers/school_provider.dart';

class FinanceOverviewScreen extends StatefulWidget {
  const FinanceOverviewScreen({super.key});

  @override
  State<FinanceOverviewScreen> createState() => _FinanceOverviewScreenState();
}

class _FinanceOverviewScreenState extends State<FinanceOverviewScreen> {
  double _totalIncome = 0;
  double _totalExpenses = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId != null) {
      final incomes = await context.read<FinanceService>().getIncomes(schoolId);
      final expenses = await context.read<FinanceService>().getExpenses(schoolId);
      
      final allTransactions = <Map<String, dynamic>>[];
      for (var income in incomes) {
        allTransactions.add({
          'title': income.description,
          'amount': income.amount,
          'date': income.date,
          'type': 'income',
          'category': income.category,
        });
      }
      for (var expense in expenses) {
        allTransactions.add({
          'title': expense.description,
          'amount': expense.amount,
          'date': expense.date,
          'type': 'expense',
          'category': expense.category,
        });
      }
      allTransactions.sort((a, b) => b['date'].compareTo(a['date']));
      
      setState(() {
        _totalIncome = incomes.fold(0, (sum, i) => sum + i.amount);
        _totalExpenses = expenses.fold(0, (sum, e) => sum + e.amount);
        _recentTransactions = allTransactions.take(10).toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final netBalance = _totalIncome - _totalExpenses;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF5F7FA),
        title: const Text('Money Book', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'MMK ${netBalance.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.arrow_downward, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text('Income', style: TextStyle(color: Colors.white, fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${_totalIncome.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF44336),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.arrow_upward, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text('Expenses', style: TextStyle(color: Colors.white, fontSize: 14)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '₹${_totalExpenses.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _buildQuickActionCard('Fee Payments', Icons.payment, const Color(0xFF9C27B0), '/admin/fee-payment-management'),
                              const SizedBox(height: 12),
                              _buildQuickActionCard('Income', Icons.trending_up, const Color(0xFF4CAF50), '/admin/income-management'),
                              const SizedBox(height: 12),
                              _buildQuickActionCard('Expenses', Icons.trending_down, const Color(0xFFF44336), '/admin/expense-management'),
                              const SizedBox(height: 12),
                              _buildQuickActionCard('Salaries', Icons.account_balance_wallet, const Color(0xFF2196F3), '/admin/salary-management'),
                              const SizedBox(height: 12),
                              _buildQuickActionCard('Donations', Icons.volunteer_activism, const Color(0xFFFF9800), '/admin/donation-management'),
                              const SizedBox(height: 12),
                              _buildQuickActionCard('Dashboard', Icons.bar_chart, const Color(0xFF00BCD4), '/admin/finance-dashboard'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                          ),
                          child: Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'RECENT TRANSACTIONS',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              _buildRecentTransactions(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () async {
        await context.push(route);
        _loadSummary();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2C2C2C),
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'No recent transactions',
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
      );
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _recentTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _recentTransactions[index];
        final isIncome = transaction['type'] == 'income';
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336)).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C2C2C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      transaction['category'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${isIncome ? '+' : '-'}₹${transaction['amount'].toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
