import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/expense.dart';
import '../../../services/finance_service.dart';
import '../../../providers/school_provider.dart';
import '../add_edit_income_expense_screen.dart';

class ExpenseManagementScreen extends StatefulWidget {
  const ExpenseManagementScreen({super.key});

  @override
  State<ExpenseManagementScreen> createState() => _ExpenseManagementScreenState();
}

class _ExpenseManagementScreenState extends State<ExpenseManagementScreen> {
  List<Expense> _expenses = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId != null) {
      final expenses = await context.read<FinanceService>().getExpenses(schoolId);
      setState(() {
        _expenses = expenses;
        _isLoading = false;
      });
    }
  }

  List<Expense> get _filteredExpenses {
    final filtered = _searchQuery.isEmpty 
      ? _expenses 
      : _expenses.where((e) => 
          e.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (e.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
        ).toList();
    return filtered.reversed.toList();
  }

  double get _totalExpense => _filteredExpenses.fold(0, (sum, e) => sum + e.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Expense Management', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
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
                      colors: [Color(0xFFF44336), Color(0xFFE57373)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: const Color(0xFFF44336).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.trending_down, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Expenses', style: TextStyle(color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text('\$${_totalExpense.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                            Text('${_filteredExpenses.length} transactions', style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                    hintText: 'Search expenses...',
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
                : _filteredExpenses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(_searchQuery.isEmpty ? 'No expense records yet' : 'No results found', style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                            const SizedBox(height: 8),
                            Text('Tap + to add your first expense', style: TextStyle(color: Colors.grey[500])),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredExpenses.length,
                        itemBuilder: (context, index) {
                          final expense = _filteredExpenses[index];
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
                                        color: const Color(0xFFF44336).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.arrow_upward, color: Color(0xFFF44336), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(expense.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          const SizedBox(height: 4),
                                          Text(expense.category ?? 'Uncategorized', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Text('\$${expense.amount.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFF44336), fontWeight: FontWeight.bold, fontSize: 16)),
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
                                        Text(DateFormat('MMM dd, yyyy').format(expense.date), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        InkWell(
                                          onTap: () => _editExpense(expense),
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
                                          onTap: () => _deleteExpense(expense),
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
        onPressed: _addExpense,
        backgroundColor: const Color(0xFFF44336),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }

  void _addExpense() async {
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditIncomeExpenseScreen(schoolId: schoolId, recordType: 'expense')),
    );
    if (result == true) _loadData();
  }

  void _editExpense(Expense expense) async {
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId == null) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditIncomeExpenseScreen(schoolId: schoolId, recordType: 'expense', record: expense)),
    );
    if (result == true) _loadData();
  }

  Future<void> _deleteExpense(Expense expense) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense record?'),
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
    if (confirm == true && expense.id != null) {
      await context.read<FinanceService>().deleteExpenseRecord(expense.id!);
      _loadData();
    }
  }
}
