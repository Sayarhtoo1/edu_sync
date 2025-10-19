import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FinancialReportsScreen extends StatelessWidget {
  const FinancialReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Reports'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildReportCard(
              context,
              title: 'Profit & Loss',
              icon: Icons.trending_up,
              color: const Color(0xFF4CAF50),
              onTap: () => context.pushNamed('profit-loss-report'),
            ),
            _buildReportCard(
              context,
              title: 'Cash Flow',
              icon: Icons.account_balance,
              color: const Color(0xFF2196F3),
              onTap: () => context.pushNamed('cash-flow-report'),
            ),
            _buildReportCard(
              context,
              title: 'Fee Collection',
              icon: Icons.payment,
              color: const Color(0xFF9C27B0),
              onTap: () => context.pushNamed('fee-collection-report'),
            ),
            _buildReportCard(
              context,
              title: 'Salary Report',
              icon: Icons.payments,
              color: const Color(0xFFFF9800),
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 48, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
