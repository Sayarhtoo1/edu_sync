import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/finance_service.dart';
import 'package:edu_sync/models/school.dart';
import 'package:edu_sync/providers/school_provider.dart';

class FinanceOverviewScreen extends StatefulWidget {
  const FinanceOverviewScreen({super.key});

  @override
  State<FinanceOverviewScreen> createState() => _FinanceOverviewScreenState();
}

class _FinanceOverviewScreenState extends State<FinanceOverviewScreen> {
  final FinanceService _financeService = FinanceService();
  late School _school;

  DateTimeRange? _selectedDateRange;
  String _selectedMonth = DateFormat('MMMM yyyy').format(DateTime.now());

  FinancialSummary _financialSummary = FinancialSummary(totalIncome: 0, totalOutcome: 0);
  List<FinancialDataPoint> _chartData = [];
  Map<String, double> _categorizedIncome = {};
  Map<String, double> _categorizedExpenses = {};
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _school = Provider.of<SchoolProvider>(context, listen: false).currentSchool!;
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    DateTime startDate;
    DateTime endDate;

    if (_selectedDateRange != null) {
      startDate = _selectedDateRange!.start;
      endDate = _selectedDateRange!.end;
    } else {
      final now = DateTime.now();
      final month = DateFormat('MMMM yyyy').parse(_selectedMonth);
      startDate = DateTime(month.year, month.month, 1);
      endDate = DateTime(month.year, month.month + 1, 0);
    }

    final summary = await _financeService.getFinancialSummaryWithComparison(_school.id, startDate, endDate);
    final chartData = await _financeService.getFinancialChartData(_school.id, startDate, endDate);
    final categorizedIncome = await _financeService.getCategorizedIncome(_school.id, startDate, endDate);
    final categorizedExpenses = await _financeService.getCategorizedExpenses(_school.id, startDate, endDate);

    setState(() {
      _financialSummary = summary;
      _chartData = chartData;
      _categorizedIncome = categorizedIncome;
      _categorizedExpenses = categorizedExpenses;
      _isLoading = false;
    });
  }

  void _selectMonth(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedMonth = newValue;
        _selectedDateRange = null;
      });
      _fetchData();
    }
  }

  Future<void> _selectCustomDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
      _fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Overview'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildFilterSection(),
                  const SizedBox(height: 24),
                  _buildFinancialFlow(),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        DropdownButton<String>(
          value: _selectedMonth,
          onChanged: _selectMonth,
          items: List.generate(12, (index) {
            final date = DateTime(DateTime.now().year, DateTime.now().month - index, 1);
            return DateFormat('MMMM yyyy').format(date);
          }).map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        ElevatedButton(
          onPressed: _selectCustomDateRange,
          child: const Text('Custom Range'),
        ),
      ],
    );
  }

  Widget _buildFinancialFlow() {
    final netProfit = _financialSummary.totalIncome - _financialSummary.totalOutcome;

    return Column(
      children: [
        _buildMetricCard(
          title: 'Total Income',
          amount: _financialSummary.totalIncome,
          percentageChange: _financialSummary.incomePercentageChange,
          color: Colors.green,
          icon: Icons.arrow_downward_rounded,
          categorizedData: _categorizedIncome,
        ),
        const SizedBox(height: 16),
        _buildMetricCard(
          title: 'Total Expenses',
          amount: _financialSummary.totalOutcome,
          percentageChange: _financialSummary.expensePercentageChange,
          color: Colors.orange,
          icon: Icons.arrow_upward_rounded,
          categorizedData: _categorizedExpenses,
        ),
        const SizedBox(height: 16),
        _buildNetProfitCard(netProfit, _financialSummary.netProfitPercentageChange),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required double amount,
    required double percentageChange,
    required Color color,
    required IconData icon,
    required Map<String, double> categorizedData,
  }) {
    final changeText = '${percentageChange.toStringAsFixed(1)}% vs last month';
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: '\$').format(amount),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(changeText, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 16),
          _buildMicroBarChart(categorizedData, color),
        ],
      ),
    );
  }

  Widget _buildNetProfitCard(double netProfit, double percentageChange) {
    final color = netProfit >= 0 ? Colors.green : Colors.red;
    final changeText = '${percentageChange.toStringAsFixed(1)}% vs last month';
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Net Profit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            NumberFormat.currency(symbol: '\$').format(netProfit),
            style: TextStyle(color: color, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(changeText, style: TextStyle(color: color, fontSize: 12)),
          const SizedBox(height: 16),
          SizedBox(
            height: 50,
            child: _chartData.isNotEmpty ? _buildSparkline(netProfit >= 0) : const Center(child: Text("No trend data")),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroBarChart(Map<String, double> data, Color color) {
    if (data.isEmpty) {
      return const Text('No category data');
    }
    final total = data.values.fold(0.0, (sum, item) => sum + item);
    final sortedData = data.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    
    return Column(
      children: sortedData.take(3).map((entry) {
        final percentage = total > 0 ? (entry.value / total) * 100 : 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            children: [
              Expanded(child: Text(entry.key, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
              const SizedBox(width: 8),
              Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSparkline(bool isProfit) {
    final spots = _chartData.asMap().entries.map((entry) {
      final value = entry.value.totalIncome - entry.value.totalOutcome;
      return FlSpot(entry.key.toDouble(), value);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: isProfit ? const Color(0xFF48BB78) : const Color(0xFFF6AD55),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: (isProfit ? const Color(0xFF48BB78) : const Color(0xFFF6AD55)).withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }
}
