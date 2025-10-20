import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/finance_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopFinanceOverview extends StatefulWidget {
  const DesktopFinanceOverview({super.key});

  @override
  State<DesktopFinanceOverview> createState() => _DesktopFinanceOverviewState();
}

class _DesktopFinanceOverviewState extends State<DesktopFinanceOverview> {
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
    
    return DesktopScaffold(
      title: 'Finance Management',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStats(netBalance),
                  const SizedBox(height: 32),
                  const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 32),
                  const Text('Recent Transactions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildRecentTransactions(),
                ],
              ),
            ),
    );
  }

  Widget _buildStats(double netBalance) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(Icons.account_balance_wallet, 'MMK ${netBalance.toStringAsFixed(0)}', 'Net Balance', netBalance >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(Icons.arrow_downward, '₹${_totalIncome.toStringAsFixed(0)}', 'Total Income', const Color(0xFF4CAF50))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard(Icons.arrow_upward, '₹${_totalExpenses.toStringAsFixed(0)}', 'Total Expenses', const Color(0xFFF44336))),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildActionCard('Fee Payments', Icons.payment, const Color(0xFF9C27B0), '/admin/fee-payment-management'),
        _buildActionCard('Income', Icons.trending_up, const Color(0xFF4CAF50), '/admin/income-management'),
        _buildActionCard('Expenses', Icons.trending_down, const Color(0xFFF44336), '/admin/expense-management'),
        _buildActionCard('Salaries', Icons.account_balance_wallet, const Color(0xFF2196F3), '/admin/salary-management'),
        _buildActionCard('Donations', Icons.volunteer_activism, const Color(0xFFFF9800), '/admin/donation-management'),
        _buildActionCard('Dashboard', Icons.bar_chart, const Color(0xFF00BCD4), '/admin/finance-dashboard'),
        _buildActionCard('Reports', Icons.assessment, const Color(0xFF2196F3), '/admin/financial-reports'),
        _buildActionCard('Categories', Icons.category, const Color(0xFF673AB7), '/admin/finance-categories'),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () async {
        await context.push(route);
        _loadSummary();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    if (_recentTransactions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: const Center(
          child: Text('No recent transactions', style: TextStyle(color: Colors.grey, fontSize: 14)),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
            child: Row(
              children: [
                const SizedBox(width: 60),
                const Expanded(flex: 2, child: Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Category', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                const SizedBox(width: 120, child: Text('Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.right)),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _recentTransactions.length,
            itemBuilder: (context, index) {
              final transaction = _recentTransactions[index];
              final isIncome = transaction['type'] == 'income';
              return Container(
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!))),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: (isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: Text(transaction['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                    Expanded(child: Text(transaction['category'], style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                    Expanded(child: Text(transaction['date'].toString().split(' ')[0], style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
                    SizedBox(
                      width: 120,
                      child: Text(
                        '${isIncome ? '+' : '-'}₹${transaction['amount'].toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
