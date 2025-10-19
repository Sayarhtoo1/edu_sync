import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/services/financial_report_service.dart';
import 'package:edu_sync/utils/pdf_generator.dart';

class ProfitLossReportScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const ProfitLossReportScreen({super.key, this.startDate, this.endDate});

  @override
  State<ProfitLossReportScreen> createState() => _ProfitLossReportScreenState();
}

class _ProfitLossReportScreenState extends State<ProfitLossReportScreen> {
  final _service = FinancialReportService();
  bool _isLoading = true;
  Map<String, dynamic> _data = {};
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate ?? DateTime.now().subtract(const Duration(days: 30));
    _endDate = widget.endDate ?? DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId != null) {
      final data = await _service.getProfitLossData(schoolId, _startDate, _endDate);
      setState(() {
        _data = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss Report'),
        backgroundColor: const Color(0xFF4CAF50),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => PdfGenerator.generateProfitLossReport(_data, _startDate, _endDate),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: ListTile(
                      title: Text('${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: _selectDateRange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryCards(),
                  const SizedBox(height: 16),
                  _buildCategoryBreakdown('Income', _data['incomeByCategory'] ?? {}, const Color(0xFF4CAF50)),
                  const SizedBox(height: 16),
                  _buildCategoryBreakdown('Expenses', _data['expenseByCategory'] ?? {}, const Color(0xFFF44336)),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(child: _buildMetricCard('Income', _data['totalIncome'] ?? 0, const Color(0xFF4CAF50))),
        const SizedBox(width: 8),
        Expanded(child: _buildMetricCard('Expense', _data['totalExpense'] ?? 0, const Color(0xFFF44336))),
        const SizedBox(width: 8),
        Expanded(child: _buildMetricCard('Net', _data['netProfit'] ?? 0, const Color(0xFF2196F3))),
      ],
    );
  }

  Widget _buildMetricCard(String label, double value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(NumberFormat.currency(symbol: '\$').format(value), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdown(String title, Map<String, double> data, Color color) {
    if (data.isEmpty) return const SizedBox();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...data.entries.map((e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.key),
                  Text(NumberFormat.currency(symbol: '\$').format(e.value), style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
