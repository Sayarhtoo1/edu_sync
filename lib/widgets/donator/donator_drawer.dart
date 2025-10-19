import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';

class DonatorDrawer extends StatefulWidget {
  const DonatorDrawer({super.key});

  @override
  State<DonatorDrawer> createState() => _DonatorDrawerState();
}

class _DonatorDrawerState extends State<DonatorDrawer> {
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final authService = context.read<AuthService>();
    final user = authService.getCurrentUser();
    if (user != null) {
      final userDetails = await authService.getUserById(user.id);
      if (mounted) {
        setState(() {
          _userName = userDetails?.fullName ?? user.email?.split('@')[0];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final schoolProvider = context.watch<SchoolProvider>();
    final user = authService.getCurrentUser();

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Column(
          children: [
            _buildHeader(context, _userName ?? user?.email?.split('@')[0], schoolProvider.currentSchool?.name),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildMenuItem(context, 'Dashboard', Icons.dashboard_rounded, '/donator'),
                  const SizedBox(height: 4),
                  _buildMenuItem(context, 'My Donations', Icons.volunteer_activism_rounded, '/donator/donations'),
                  const SizedBox(height: 4),
                  _buildMenuItem(context, 'App Settings', Icons.settings_applications_rounded, '/app-settings'),
                ],
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String? userName, String? schoolName) {
    final schoolProvider = context.watch<SchoolProvider>();
    final schoolLogo = schoolProvider.currentSchool?.logoUrl;
    
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFFB74D)]),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3), width: 2)),
            child: (schoolLogo != null && schoolLogo.isNotEmpty)
                ? CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: schoolLogo,
                        fit: BoxFit.cover,
                        width: 72,
                        height: 72,
                        placeholder: (context, url) => const Icon(Icons.school_rounded, size: 36, color: Colors.white),
                        errorWidget: (context, url, error) => const Icon(Icons.school_rounded, size: 36, color: Colors.white),
                      ),
                    ),
                  )
                : CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: const Icon(Icons.school_rounded, size: 36, color: Colors.white),
                  ),
          ),
          const SizedBox(height: 16),
          Text(userName?.toUpperCase() ?? 'DONATOR', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: Text(schoolName ?? 'School Supporter', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, String title, IconData icon, String route) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFFF9800).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: const Color(0xFFFF9800), size: 20),
        ),
        title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF2C2C2C))),
        onTap: () {
          Navigator.pop(context);
          if (route == '/donator') {
            context.go(route);
          } else {
            context.push(route);
          }
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2))]),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final authService = context.read<AuthService>();
                await authService.signOut();
                if (context.mounted) context.go('/login');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text('EduSync v3.2.0', style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
