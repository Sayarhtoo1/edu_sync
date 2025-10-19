import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/services/financial_report_service.dart';
import 'package:edu_sync/utils/pdf_generator.dart';

class CashFlowReportScreen extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;

  const CashFlowReportScreen({super.key, this.startDate, this.endDate});

  @override
  State<CashFlowReportScreen> createState() => _CashFlowReportScreenState();
}

class _CashFlowReportScreenState extends State<CashFlowReportScreen> {
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
      final data = await _service.getCashFlowData(schoolId, _startDate, _endDate);
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
        title: const Text('Cash Flow Report'),
        backgroundColor: const Color(0xFF2196F3),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => PdfGenerator.generateCashFlowReport(_data, _startDate, _endDate),
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
                  Card(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Final Balance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text(
                            NumberFormat.currency(symbol: '\$').format(_data['finalBalance'] ?? 0),
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2196F3)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCashFlowChart(),
                ],
              ),
            ),
    );
  }

  Widget _buildCashFlowChart() {
    final cashFlow = _data['cashFlow'] as List<Map<String, dynamic>>? ?? [];
    if (cashFlow.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No data available')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cash Flow Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: cashFlow.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value['balance'])).toList(),
                      color: const Color(0xFF2196F3),
                      barWidth: 3,
                    ),
                  ],
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
