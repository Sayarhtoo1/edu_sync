import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../services/finance_service.dart';
import '../../../providers/school_provider.dart';

class EnhancedFinanceOverviewScreen extends StatefulWidget {
  const EnhancedFinanceOverviewScreen({super.key});

  @override
  State<EnhancedFinanceOverviewScreen> createState() => _EnhancedFinanceOverviewScreenState();
}

class _EnhancedFinanceOverviewScreenState extends State<EnhancedFinanceOverviewScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  double _totalIncome = 0;
  double _totalExpenses = 0;
  List<FinancialDataPoint> _chartData = [];
  Map<String, double> _categoryBreakdown = {};
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId != null) {
      final service = context.read<FinanceService>();
      final incomes = await service.getIncomes(schoolId);
      final expenses = await service.getExpenses(schoolId);
      final chartData = await service.getFinancialChartData(schoolId, _dateRange.start, _dateRange.end);
      final breakdown = await service.getCategoryBreakdown(schoolId);
      
      setState(() {
        _totalIncome = incomes.fold(0, (sum, i) => sum + i.amount);
        _totalExpenses = expenses.fold(0, (sum, e) => sum + e.amount);
        _chartData = chartData;
        _categoryBreakdown = breakdown;
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
    );
    if (picked != null) {
      setState(() => _dateRange = picked);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Finance Dashboard', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment),
            onPressed: () => context.pushNamed('financial-reports'),
            tooltip: 'Financial Reports',
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2196F3),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2196F3),
          tabs: const [
            Tab(icon: Icon(Icons.pie_chart), text: 'Breakdown'),
            Tab(icon: Icon(Icons.trending_up), text: 'Trends'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBreakdownTab(),
                _buildTrendsTab(),
              ],
            ),
    );
  }



  Widget _buildBreakdownTab() {
    if (_categoryBreakdown.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final total = _categoryBreakdown.values.fold<double>(0, (sum, v) => sum + v);
    final colors = [
      const Color(0xFF4CAF50), const Color(0xFFF44336), const Color(0xFF2196F3),
      const Color(0xFFFF9800), const Color(0xFF9C27B0), const Color(0xFF00BCD4),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: PieChart(
              PieChartData(
                sections: _categoryBreakdown.entries.toList().asMap().entries.map((entry) {
                  final index = entry.key;
                  final category = entry.value;
                  final percentage = (category.value / total) * 100;
                  return PieChartSectionData(
                    value: category.value,
                    title: '${percentage.toStringAsFixed(1)}%',
                    color: colors[index % colors.length],
                    radius: 80,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ..._categoryBreakdown.entries.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[index % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(category.key, style: const TextStyle(fontWeight: FontWeight.w500))),
                  Text('\$${category.value.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    if (_chartData.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            height: 300,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < _chartData.length) {
                          return Text(DateFormat('MM/dd').format(_chartData[value.toInt()].date), style: const TextStyle(fontSize: 10));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalIncome)).toList(),
                    isCurved: true,
                    color: const Color(0xFF4CAF50),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                  LineChartBarData(
                    spots: _chartData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalOutcome)).toList(),
                    isCurved: true,
                    color: const Color(0xFFF44336),
                    barWidth: 3,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend('Income', const Color(0xFF4CAF50)),
              const SizedBox(width: 24),
              _buildLegend('Expenses', const Color(0xFFF44336)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 3, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
