import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';

class DesktopFinancialReports extends StatelessWidget {
  const DesktopFinancialReports({super.key});

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Financial Reports',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Reports', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildReportCard(
                  context,
                  title: 'Profit & Loss',
                  subtitle: 'View income vs expenses',
                  icon: Icons.trending_up,
                  color: const Color(0xFF4CAF50),
                  onTap: () => context.pushNamed('profit-loss-report'),
                ),
                _buildReportCard(
                  context,
                  title: 'Cash Flow',
                  subtitle: 'Track money movement',
                  icon: Icons.account_balance,
                  color: const Color(0xFF2196F3),
                  onTap: () => context.pushNamed('cash-flow-report'),
                ),
                _buildReportCard(
                  context,
                  title: 'Fee Collection',
                  subtitle: 'Student fee reports',
                  icon: Icons.payment,
                  color: const Color(0xFF9C27B0),
                  onTap: () => context.pushNamed('fee-collection-report'),
                ),
                _buildReportCard(
                  context,
                  title: 'Salary Report',
                  subtitle: 'Staff salary overview',
                  icon: Icons.payments,
                  color: const Color(0xFFFF9800),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
                _buildReportCard(
                  context,
                  title: 'Donation Report',
                  subtitle: 'Track donations',
                  icon: Icons.volunteer_activism,
                  color: const Color(0xFFE91E63),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
                _buildReportCard(
                  context,
                  title: 'Expense Report',
                  subtitle: 'Expense breakdown',
                  icon: Icons.trending_down,
                  color: const Color(0xFFF44336),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
                _buildReportCard(
                  context,
                  title: 'Income Report',
                  subtitle: 'Income breakdown',
                  icon: Icons.attach_money,
                  color: const Color(0xFF00BCD4),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
                _buildReportCard(
                  context,
                  title: 'Custom Report',
                  subtitle: 'Create custom report',
                  icon: Icons.assessment,
                  color: const Color(0xFF673AB7),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Coming soon')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Quick Stats', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildStatCard(Icons.calendar_today, 'This Month', 'View current month reports', const Color(0xFF2196F3))),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.date_range, 'This Quarter', 'View quarterly reports', const Color(0xFF4CAF50))),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.calendar_view_month, 'This Year', 'View annual reports', const Color(0xFF9C27B0))),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard(Icons.history, 'Custom Range', 'Select date range', const Color(0xFFFF9800))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
