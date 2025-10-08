import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/income.dart';
import 'package:edu_sync/models/expense.dart';
import 'package:edu_sync/services/finance_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';
import 'add_edit_income_expense_screen.dart'; 
import 'package:edu_sync/services/auth_service.dart'; 
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class FinanceManagementScreen extends StatefulWidget {
  const FinanceManagementScreen({super.key});

  @override
  State<FinanceManagementScreen> createState() => _FinanceManagementScreenState();
}

class _FinanceManagementScreenState extends State<FinanceManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final FinanceService _financeService;
  late final AuthService _authService;
  
  List<Income> _incomeRecords = [];
  List<Expense> _expenseRecords = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _schoolId;
  String? _adminUserId; // To store the admin's user ID

  double get _totalIncome => _incomeRecords.fold(0, (sum, item) => sum + item.amount);
  double get _totalExpenses => _expenseRecords.fold(0, (sum, item) => sum + item.amount);
  double get _netBalance => _totalIncome - _totalExpenses;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _financeService = Provider.of<FinanceService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    _schoolId = schoolProvider.currentSchool?.id;
    _adminUserId = _authService.getCurrentUser()?.id; // Get admin user ID

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context)!; // Assert non-null
      if (_schoolId != null && _adminUserId != null) {
        _loadFinanceData();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = _schoolId == null 
                ? (l10n.error_school_not_selected_or_found)
                : (l10n.error_user_not_found);
          });
        }
      }
    });
  }

  Future<void> _loadFinanceData() async {
    if (_schoolId == null) return;
    setState(() => _isLoading = true);
    try {
      _incomeRecords = await _financeService.getIncomes(_schoolId!);
      _expenseRecords = await _financeService.getExpenses(_schoolId!);
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!; // Assert non-null
        setState(() => _errorMessage = "${l10n.errorOccurredPrefix}: ${e.toString()}");
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddEditRecord(String type, [dynamic record]) {
    final l10n = AppLocalizations.of(context)!; // Assert non-null
    if (_schoolId == null || _adminUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.actionRequiresSchoolAndAdminContext)),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditIncomeExpenseScreen(
          schoolId: _schoolId!,
          // adminUserId: _adminUserId!, // adminUserId will be fetched within AddEditIncomeExpenseScreen
          recordType: type, 
          record: record, 
        ),
      ),
    ).then((result) {
      if (result == true) { // Assuming AddEdit screen pops with true on success
         _loadFinanceData();
      }
    });
  }

  Future<void> _deleteRecord(String type, int recordId) async {
    final l10n = AppLocalizations.of(context)!; // Assert non-null
    final theme = Theme.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog( // DialogTheme applied globally
        title: Text(l10n.confirmDeleteTitle),
        content: Text(type == 'income' ? l10n.confirmDeleteIncomeText : l10n.confirmDeleteExpenseText),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: theme.colorScheme.error),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete)
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      bool success = false;
      if (type == 'income') {
        success = await _financeService.deleteIncomeRecord(recordId);
      } else {
        success = await _financeService.deleteExpenseRecord(recordId);
      }
      
      if (success) {
        _loadFinanceData(); // Reload
      } else {
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(type == 'income' ? l10n.errorDeletingIncome : l10n.errorDeletingExpense)),
            );
            setState(() => _isLoading = false);
         }
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildFinancialList(String type, List<dynamic> records, AppLocalizations l10n) {
    if (records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(type == 'income' ? Icons.trending_up_outlined : Icons.trending_down_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(type == 'income' ? l10n.noIncomeRecordsFound : l10n.noExpenseRecordsFound, style: const TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      );
    }
    final currencyFormat = NumberFormat.currency(locale: l10n.localeName, symbol: '');

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        String title = record.description;
        String amount = currencyFormat.format(record.amount);
        String date = DateFormat.yMMMd(l10n.localeName).format(record.date);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (type == 'income' ? const Color(0xFF4CAF50) : const Color(0xFFF44336)).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(type == 'income' ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded, color: type == 'income' ? const Color(0xFF4CAF50) : const Color(0xFFF44336)),
            ),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Text('${record.category} • $date', style: TextStyle(color: Colors.grey[600])),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(amount, style: TextStyle(color: type == 'income' ? const Color(0xFF4CAF50) : const Color(0xFFF44336), fontWeight: FontWeight.bold, fontSize: 16)),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: Colors.grey[700]),
                  onPressed: () => _navigateToAddEditRecord(type, record),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _deleteRecord(type, record.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildSummaryCard(AppLocalizations l10n) {
    final currencyFormat = NumberFormat.currency(locale: l10n.localeName, symbol: '');
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.financialSummaryTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Income'), Text(currencyFormat.format(_totalIncome), style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.w600, fontSize: 16))]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total Expenses'), Text(currencyFormat.format(_totalExpenses), style: const TextStyle(color: Color(0xFFF44336), fontWeight: FontWeight.w600, fontSize: 16))]),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Net Balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(currencyFormat.format(_netBalance), style: TextStyle(fontWeight: FontWeight.bold, color: _netBalance >= 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336), fontSize: 20))]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(l10n.financeManagementTitle, style: const TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF4CAF50),
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: l10n.incomeTabLabel),
            Tab(text: l10n.expensesTabLabel),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: const TextStyle(color: Colors.red))))
              : Column(
                  children: [
                    _buildSummaryCard(l10n),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildFinancialList('income', _incomeRecords, l10n),
                          _buildFinancialList('expense', _expenseRecords, l10n),
                        ],
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _tabController.index == 0 ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
        onPressed: () {
          final type = _tabController.index == 0 ? 'income' : 'expense';
          _navigateToAddEditRecord(type);
        },
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}
