import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';

class DesktopLayout extends StatelessWidget {
  final Widget child;
  final List<NavItem> navItems;
  final String role;

  const DesktopLayout({
    super.key,
    required this.child,
    required this.navItems,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Consumer<SchoolProvider>(
                        builder: (context, schoolProvider, _) {
                          final schoolLogo = schoolProvider.currentSchool?.logoUrl;
                          return Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: schoolLogo != null && schoolLogo.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(schoolLogo, fit: BoxFit.cover),
                                  )
                                : const Icon(Icons.school, color: Color(0xFF1E293B)),
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'EduSync',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Color(0xFF334155), height: 1),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: navItems.map((item) => _buildNavItem(context, item, currentRoute)).toList(),
                  ),
                ),
                const Divider(color: Color(0xFF334155), height: 1),
                _buildNavItem(
                  context,
                  NavItem(icon: Icons.settings_outlined, label: 'Settings', route: '/$role/settings'),
                  currentRoute,
                ),
                _buildNavItem(
                  context,
                  NavItem(icon: Icons.logout_outlined, label: 'Logout', onTap: () => _logout(context)),
                  currentRoute,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, NavItem item, String currentRoute) {
    final isActive = item.route != null && currentRoute == item.route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3B82F6) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        dense: true,
        leading: Icon(item.icon, color: Colors.white, size: 22),
        title: Text(item.label, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
        onTap: item.onTap ?? (item.route != null ? () => context.go(item.route!) : null),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _logout(BuildContext context) async {
    final authService = context.read<AuthService>();
    await authService.signOut();
    if (context.mounted) context.go('/login');
  }
}

class NavItem {
  final IconData icon;
  final String label;
  final String? route;
  final VoidCallback? onTap;

  NavItem({
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
  });
}
