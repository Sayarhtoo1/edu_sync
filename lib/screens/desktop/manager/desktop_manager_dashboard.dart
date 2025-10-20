import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/l10n/gen/app_localizations.dart';

class DesktopManagerDashboard extends StatelessWidget {
  const DesktopManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          Container(
            width: 260,
            color: const Color(0xFF2C3E50),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const Text('EduSync', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 48),
                _buildNavItem(context, Icons.dashboard, 'Dashboard', '/manager-dashboard'),
                _buildNavItem(context, Icons.analytics, 'Analytics', '/analytics-dashboard'),
                const Spacer(),
                _buildNavItem(context, Icons.settings, 'Settings', '/app-settings'),
                _buildNavItem(context, Icons.logout, 'Logout', null, onTap: () => _logout(context)),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(context, l10n),
                  const SizedBox(height: 32),
                  _buildQuickActionsGrid(context, l10n),
                  const SizedBox(height: 32),
                  _buildRecentActivitiesSection(context, l10n),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, AppLocalizations? l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('👔', style: TextStyle(fontSize: 40)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.managerDashboardWelcomeMessage ?? 'Welcome to Manager Dashboard',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Consumer<SchoolProvider>(
                      builder: (context, schoolProvider, child) {
                        return Text(
                          schoolProvider.currentSchool?.name ?? 'School Management',
                          style: const TextStyle(fontSize: 16, color: Colors.white70),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 24),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 1.2,
          children: [
            _buildActionCard(context, l10n?.manageTeachersAction ?? 'Manage Teachers', Icons.school, const Color(0xFF3498DB)),
            _buildActionCard(context, l10n?.manageParentsAction ?? 'Manage Parents', Icons.people, const Color(0xFF2ECC71)),
            _buildActionCard(context, l10n?.manageStudentsTitle ?? 'Manage Students', Icons.person_outline, const Color(0xFF9B59B6)),
            _buildActionCard(context, l10n?.manageClassesTitle ?? 'Manage Classes', Icons.class_, const Color(0xFFF39C12))
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesSection(BuildContext context, AppLocalizations? l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 24),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 5,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF9B59B6).withOpacity(0.1),
                  child: const Icon(Icons.event_note, color: Color(0xFF9B59B6)),
                ),
                title: Text('Activity ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('Activity details ${index + 1}'),
                trailing: const Text('Just now', style: TextStyle(fontSize: 12, color: Color(0xFF7F8C8D))),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, String? route, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
      onTap: onTap ?? (route != null ? () => context.push(route) : null),
    );
  }

  void _logout(BuildContext context) async {
    final authService = context.read<AuthService>();
    await authService.signOut();
    if (context.mounted) context.go('/login');
  }
}
