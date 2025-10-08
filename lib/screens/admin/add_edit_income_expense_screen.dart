import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/models/income.dart';
import 'package:edu_sync/models/expense.dart';
import 'package:edu_sync/services/finance_service.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart'; // Import AppLocalizations
import 'package:edu_sync/services/auth_service.dart'; // Import AuthService
import 'package:edu_sync/theme/app_theme.dart'; // Import AppTheme

class AddEditIncomeExpenseScreen extends StatefulWidget {
  final int schoolId;
  final String recordType; // 'income' or 'expense'
  final dynamic record; // Income or Expense object, or null if adding

  const AddEditIncomeExpenseScreen({
    super.key,
    required this.schoolId,
    required this.recordType,
    this.record,
  });

  @override
  State<AddEditIncomeExpenseScreen> createState() => _AddEditIncomeExpenseScreenState();
}

class _AddEditIncomeExpenseScreenState extends State<AddEditIncomeExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final FinanceService _financeService;
  late final AuthService _authService;

  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _categoryController;
  DateTime? _selectedDate;

  String _errorMessage = '';
  bool _isLoading = false;
  bool get _isEditing => widget.record != null;
  String? _adminUserId; // To store the admin's user ID

  @override
  void initState() {
    super.initState();
    _financeService = Provider.of<FinanceService>(context, listen: false);
    _authService = Provider.of<AuthService>(context, listen: false);
    _adminUserId = _authService.getCurrentUser()?.id; // Get admin user ID

    String initialDescription = '';
    String initialAmount = '';
    String initialCategory = '';
    DateTime initialDate = DateTime.now();

    if (_isEditing) {
      initialDescription = widget.record.description;
      initialAmount = widget.record.amount.toString();
      initialCategory = widget.record.category;
      initialDate = widget.record.date;
    }
    
    _descriptionController = TextEditingController(text: initialDescription);
    _amountController = TextEditingController(text: initialAmount);
    _categoryController = TextEditingController(text: initialCategory);
    _selectedDate = initialDate;
    _dateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(initialDate));
  }

  Future<void> _selectDate(BuildContext context) async {
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('finance');

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: contextualAccentColor,
              onPrimary: Colors.white,
              onSurface: textDarkGrey,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: contextualAccentColor,
              ),
            ), dialogTheme: DialogThemeData(backgroundColor: cardBackgroundColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveRecord() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() { _isLoading = true; _errorMessage = ''; });

    final double? amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      setState(() {
        _isLoading = false;
        _errorMessage = l10n?.invalidAmountError ?? 'Invalid amount'; 
      });
      return;
    }

    try {
      bool success = false;
      if (widget.recordType == 'income') {
        final incomeRecord = Income(
          id: _isEditing ? widget.record.id : 0,
          schoolId: widget.schoolId,
          description: _descriptionController.text,
          amount: amount,
          date: _selectedDate!,
          category: _categoryController.text,
          createdByUserId: _adminUserId, // Add createdByUserId
        );
        if (_isEditing) {
          success = await _financeService.updateIncomeRecord(incomeRecord);
        } else {
          final newRecord = await _financeService.createIncomeRecord(incomeRecord);
          success = newRecord != null;
        }
      } else { // expense
        final expenseRecord = Expense(
          id: _isEditing ? widget.record.id : 0,
          schoolId: widget.schoolId,
          description: _descriptionController.text,
          amount: amount,
          date: _selectedDate!,
          category: _categoryController.text,
          createdByUserId: _adminUserId, // Add createdByUserId
        );
        if (_isEditing) {
          success = await _financeService.updateExpenseRecord(expenseRecord);
        } else {
          final newRecord = await _financeService.createExpenseRecord(expenseRecord);
          success = newRecord != null;
        }
      }

      if (success) {
        setState(() => _isLoading = false);
        Navigator.of(context).pop(true); // Indicate success
      } else {
        throw Exception(l10n?.failedToSaveRecordError ?? 'Failed to save record'); 
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = '${l10n?.errorOccurredPrefix ?? 'Error'}: ${e.toString()}';
      });
    }
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final Color contextualAccentColor = AppTheme.getAccentColorForContext('finance');

    final String title = _isEditing 
        ? (widget.recordType == 'income' ? l10n?.editIncomeTitle ?? 'Edit Income' : l10n?.editExpenseTitle ?? 'Edit Expense') 
        : (widget.recordType == 'income' ? l10n?.addIncomeTitle ?? 'Add Income' : l10n?.addExpenseTitle ?? 'Add Expense'); 

    return Scaffold(
      appBar: AppBar(title: Text(title)), // Theme applied globally
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: l10n?.descriptionLabel ?? 'Description'),
                validator: (value) => (value == null || value.isEmpty) ? l10n?.descriptionValidator ?? 'Description cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: l10n?.categoryLabel ?? 'Category'),
                validator: (value) => (value == null || value.isEmpty) ? l10n?.categoryValidator ?? 'Category cannot be empty' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: l10n?.amountLabel ?? 'Amount'), 
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return l10n?.amountValidator ?? 'Amount cannot be empty'; 
                  if (double.tryParse(value) == null || double.parse(value) <= 0) return l10n?.invalidAmountError ?? 'Invalid amount'; 
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                decoration: InputDecoration(labelText: l10n?.recordDateLabel ?? 'Record Date', hintText: l10n?.dateOfBirthHint ?? 'YYYY-MM-DD'), // Using recordDateLabel
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) => (value == null || value.isEmpty) ? l10n?.dateValidator ?? 'Date cannot be empty' : null, 
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(contextualAccentColor)))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: contextualAccentColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _saveRecord,
                      child: Text(_isEditing ? l10n?.updateButton ?? 'Update' : l10n?.addButton ?? 'Add'), 
                    ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_errorMessage, style: TextStyle(color: theme.colorScheme.error)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
