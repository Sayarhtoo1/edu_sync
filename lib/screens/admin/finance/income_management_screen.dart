import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/income.dart';
import '../../../services/finance_service.dart';
import '../../../providers/school_provider.dart';
import '../add_edit_income_expense_screen.dart';

class IncomeManagementScreen extends StatefulWidget {
  const IncomeManagementScreen({super.key});

  @override
  State<IncomeManagementScreen> createState() => _IncomeManagementScreenState();
}

class _IncomeManagementScreenState extends State<IncomeManagementScreen> with RouteAware {
  List<Income> _incomes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId != null) {
      final incomes = await context.read<FinanceService>().getIncomes(schoolId);
      setState(() {
        _incomes = incomes;
        _isLoading = false;
      });
    }
  }

  List<Income> get _filteredIncomes {
    final filtered = _searchQuery.isEmpty 
      ? _incomes 
      : _incomes.where((i) => 
          i.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (i.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
        ).toList();
    return filtered.reversed.toList();
  }

  double get _totalIncome => _filteredIncomes.fold(0, (sum, i) => sum + i.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Income Management', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: const Color(0xFF4CAF50).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.trending_up, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Income', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('\$${_totalIncome.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            Text('${_filteredIncomes.length} transactions', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search income...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xFFF5F7FA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredIncomes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(_searchQuery.isEmpty ? 'No income records yet' : 'No results found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text('Tap + to add your first income', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredIncomes.length,
                        itemBuilder: (context, index) {
                          final income = _filteredIncomes[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.arrow_downward, color: Color(0xFF4CAF50), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(income.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Text(income.category ?? 'Uncategorized', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Text('\$${income.amount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                                        const SizedBox(width: 4),
                                        Text(DateFormat('MMM dd, yyyy').format(income.date), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => _editIncome(income),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.edit, size: 16, color: Colors.blue),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        InkWell(
                                          onTap: () => _deleteIncome(income),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: const Icon(Icons.delete, size: 16, color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addIncome,
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add),
        label: const Text('Add Income'),
      ),
    );
  }

  void _addIncome() async {
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditIncomeExpenseScreen(schoolId: schoolId, recordType: 'income')),
    );
    if (result == true) _loadData();
  }

  void _editIncome(Income income) async {
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditIncomeExpenseScreen(schoolId: schoolId, recordType: 'income', record: income)),
    );
    if (result == true) _loadData();
  }

  Future<void> _deleteIncome(Income income) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Income'),
        content: const Text('Are you sure you want to delete this income record?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true && income.id != null) {
      await context.read<FinanceService>().deleteIncomeRecord(income.id!);
      _loadData();
    }
  }
}
