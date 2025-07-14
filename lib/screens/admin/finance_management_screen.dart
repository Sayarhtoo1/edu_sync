import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/income.dart';
import 'package:edu_sync/models/expense.dart';
import 'package:edu_sync/services/finance_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
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
  final FinanceService _financeService = FinanceService();
  
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
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);
    _schoolId = schoolProvider.currentSchool?.id;
    _adminUserId = AuthService().getCurrentUser()?.id; // Get admin user ID

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final l10n = AppLocalizations.of(context);
      if (_schoolId != null && _adminUserId != null) {
        _loadFinanceData();
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = _schoolId == null 
                ? l10n.error_school_not_selected_or_found
                : l10n.error_user_not_found; 
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
        final l10n = AppLocalizations.of(context);
        setState(() => _errorMessage = "${l10n.errorOccurredPrefix}: ${e.toString()}");
      }
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddEditRecord(String type, [dynamic record]) {
    final l10n = AppLocalizations.of(context);
    if (_schoolId == null || _adminUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.actionRequiresSchoolAndAdminContext)), // Re-use existing key
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
    final l10n = AppLocalizations.of(context);
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
    final theme = Theme.of(context);
    if (records.isEmpty) {
      return Center(child: Text(type == 'income' ? l10n.noIncomeRecordsFound : l10n.noExpenseRecordsFound, style: theme.textTheme.bodyLarge)); 
    }
    final currencyFormat = NumberFormat.currency(locale: l10n.localeName, symbol: ''); 

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        String title = record.description;
        String amount = currencyFormat.format(record.amount);
        String date = DateFormat.yMMMd(l10n.localeName).format(record.date);

        return Card( // CardTheme applied globally
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Text(title, style: theme.textTheme.titleMedium),
            subtitle: Text('${l10n.categoryLabel}: ${record.category} • ${l10n.date}: $date', style: theme.textTheme.bodySmall),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(amount, style: TextStyle(color: type == 'income' ? iconColorEarnings : theme.colorScheme.error, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.edit, size: 20, color: theme.iconTheme.color ?? textDarkGrey),
                  tooltip: l10n.editButton, 
                  onPressed: () => _navigateToAddEditRecord(type, record),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: theme.colorScheme.error, size: 20),
                  tooltip: l10n.deleteButton, 
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
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(locale: l10n.localeName, symbol: ''); 
    return Card( // CardTheme applied globally
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.financialSummaryTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l10n.totalIncomeLabel, style: theme.textTheme.bodyMedium), Text(currencyFormat.format(_totalIncome), style: TextStyle(color: iconColorEarnings, fontWeight: FontWeight.w600))]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l10n.totalExpensesLabel, style: theme.textTheme.bodyMedium), Text(currencyFormat.format(_totalExpenses), style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w600))]),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(l10n.netBalanceLabel, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)), Text(currencyFormat.format(_netBalance), style: TextStyle(fontWeight: FontWeight.bold, color: _netBalance >= 0 ? iconColorEarnings : theme.colorScheme.error, fontSize: theme.textTheme.titleMedium?.fontSize))]),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('finance');

    return Scaffold(
      appBar: AppBar( // Theme applied globally
        title: Text(l10n.financeManagementTitle), 
        bottom: TabBar( 
          controller: _tabController,
          indicatorColor: contextualAccentColor, 
          labelColor: contextualAccentColor, 
          unselectedLabelColor: textLightGrey, // Use top-level constant
          tabs: [
            Tab(text: l10n.incomeTabLabel), 
            Tab(text: l10n.expensesTabLabel), 
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
          : _errorMessage != null 
              ? Center(child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error))))
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
      floatingActionButton: FloatingActionButton( // FABTheme applied globally, can override here
        backgroundColor: contextualAccentColor,
        onPressed: () {
          final type = _tabController.index == 0 ? 'income' : 'expense';
          _navigateToAddEditRecord(type);
        },
        tooltip: _tabController.index == 0 ? l10n.addIncomeTooltip : l10n.addExpenseTooltip, 
        child: const Icon(Icons.add, color: Colors.white), // Ensure icon contrasts
      ),
    );
  }
}
