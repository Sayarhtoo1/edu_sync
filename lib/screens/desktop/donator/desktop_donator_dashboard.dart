import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/donation_service.dart';
import 'package:edu_sync/models/donation.dart';
import 'package:edu_sync/providers/school_provider.dart';

class DesktopDonatorDashboard extends StatefulWidget {
  const DesktopDonatorDashboard({super.key});

  @override
  State<DesktopDonatorDashboard> createState() => _DesktopDonatorDashboardState();
}

class _DesktopDonatorDashboardState extends State<DesktopDonatorDashboard> {
  List<Donation> _donations = [];
  bool _isLoading = true;
  double _totalDonated = 0;
  String? _donatorName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final donationService = context.read<DonationService>();
    final user = authService.getCurrentUser();
    
    if (user != null) {
      final userDetails = await authService.getUserById(user.id);
      final donations = await donationService.getDonationsByDonator(user.id);
      double total = 0;
      for (var d in donations) {
        if (d.status == 'Received') total += d.amount;
      }
      setState(() {
        _donatorName = userDetails?.fullName ?? user.email?.split('@')[0];
        _donations = donations;
        _totalDonated = total;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _buildNavItem(context, Icons.dashboard, 'Dashboard', '/donator-dashboard'),
                _buildNavItem(context, Icons.volunteer_activism, 'Donations', '/donator-dashboard'),
                const Spacer(),
                _buildNavItem(context, Icons.settings, 'Settings', '/app-settings'),
                _buildNavItem(context, Icons.logout, 'Logout', null, onTap: () => _logout(context)),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildWelcomeCard(),
                        const SizedBox(height: 32),
                        _buildStatsRow(),
                        const SizedBox(height: 32),
                        _buildDonationsList(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF39C12), Color(0xFFE67E22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('💝', style: TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: const TextStyle(fontSize: 16, color: Colors.white70)),
                const SizedBox(height: 8),
                Text(_donatorName ?? 'Donator', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Consumer<SchoolProvider>(
                  builder: (context, schoolProvider, _) {
                    return Text(
                      schoolProvider.currentSchool?.name ?? 'Thank you for your support',
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                    );
                  },
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => context.push('/make-donation'),
            icon: const Icon(Icons.volunteer_activism),
            label: const Text('Make Donation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFF39C12),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.volunteer_activism, size: 48, color: Color(0xFFF39C12)),
                  const SizedBox(height: 16),
                  const Text('Total Donated', style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D))),
                  const SizedBox(height: 8),
                  Text('\$${_totalDonated.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.favorite, size: 48, color: Color(0xFFE74C3C)),
                  const SizedBox(height: 16),
                  const Text('Total Donations', style: TextStyle(fontSize: 16, color: Color(0xFF7F8C8D))),
                  const SizedBox(height: 8),
                  Text('${_donations.length}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDonationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Donation History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50))),
        const SizedBox(height: 24),
        if (_donations.isEmpty)
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('No donations yet', style: TextStyle(fontSize: 18, color: Color(0xFF7F8C8D))),
                  ],
                ),
              ),
            ),
          )
        else
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _donations.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final donation = _donations[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF39C12).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.favorite_rounded, color: Color(0xFFF39C12), size: 24),
                  ),
                  title: Text('\$${donation.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('${DateFormat('MMM dd, yyyy').format(donation.donationDate)}\n${donation.purpose ?? "General Support"}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: donation.status == 'Received' ? const Color(0xFF2ECC71).withOpacity(0.1) : const Color(0xFFF39C12).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      donation.status,
                      style: TextStyle(
                        color: donation.status == 'Received' ? const Color(0xFF2ECC71) : const Color(0xFFF39C12),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
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
