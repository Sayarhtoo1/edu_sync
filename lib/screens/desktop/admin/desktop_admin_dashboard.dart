import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/screens/admin/admin_panel_state.dart';
import 'package:go_router/go_router.dart';

class DesktopAdminDashboard extends StatefulWidget {
  const DesktopAdminDashboard({super.key});

  @override
  State<DesktopAdminDashboard> createState() => _DesktopAdminDashboardState();
}

class _DesktopAdminDashboardState extends State<DesktopAdminDashboard>
    with AdminPanelStateMixin<DesktopAdminDashboard> {
  
  @override
  void initState() {
    super.initState();
    initializeServices(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDashboardData(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Sidebar Navigation
          Container(
            width: 250,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'EduSync',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                _buildNavItem(Icons.dashboard, 'Dashboard', true),
                _buildNavItem(Icons.school, 'Students', false, 
                  onTap: () => context.push('/admin/student-management')),
                _buildNavItem(Icons.people, 'Teachers', false,
                  onTap: () => context.push('/admin/staff-management')),
                _buildNavItem(Icons.class_, 'Classes', false,
                  onTap: () => context.push('/admin/class-management')),
                _buildNavItem(Icons.assignment, 'Exams', false,
                  onTap: () => context.pushNamed('exam-overview')),
                _buildNavItem(Icons.account_balance_wallet, 'Finance', false,
                  onTap: () => context.push('/admin/finance-management')),
                const Spacer(),
                _buildNavItem(Icons.settings, 'Settings', false),
                _buildNavItem(Icons.logout, 'Logout', false, onTap: _logout),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 70,
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      const Text(
                        'Dashboard',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.notifications), onPressed: () {}),
                      const SizedBox(width: 16),
                      const CircleAvatar(child: Icon(Icons.person)),
                    ],
                  ),
                ),
                // Content Area
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Metrics Grid
                              GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: 4,
                                childAspectRatio: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                children: [
                                  _buildMetricCard('Students', 
                                    summaryData.isNotEmpty ? summaryData[0].count : '0',
                                    Icons.school, Colors.blue),
                                  _buildMetricCard('Teachers',
                                    summaryData.length > 1 ? summaryData[1].count : '0',
                                    Icons.people, Colors.green),
                                  _buildMetricCard('Classes',
                                    studentCountsByClass.length.toString(),
                                    Icons.class_, Colors.purple),
                                  _buildMetricCard('Balance',
                                    '\$${netBalance.round()}',
                                    Icons.account_balance_wallet, Colors.orange),
                                ],
                              ),
                              const SizedBox(height: 24),
                              // Additional content here
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.blue : Colors.grey),
      title: Text(label, style: TextStyle(
        color: isActive ? Colors.blue : Colors.grey,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      )),
      tileColor: isActive ? Colors.blue.withOpacity(0.1) : null,
      onTap: onTap,
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey)),
              Icon(icon, color: color),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _logout() async {
    final authService = context.read<AuthService>();
    await authService.signOut();
    if (mounted) context.go('/login');
  }
}
