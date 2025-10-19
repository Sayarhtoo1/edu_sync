import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/donation_service.dart';
import 'package:edu_sync/services/notification_service.dart';
import 'package:edu_sync/models/donation.dart';
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/widgets/donator/donator_drawer.dart';
import 'package:edu_sync/widgets/announcement_popup_dialog.dart';
import 'package:edu_sync/screens/donator/make_donation_screen.dart';

class ModernDonatorDashboard extends StatefulWidget {
  const ModernDonatorDashboard({super.key});

  @override
  State<ModernDonatorDashboard> createState() => _ModernDonatorDashboardState();
}

class _ModernDonatorDashboardState extends State<ModernDonatorDashboard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  List<Donation> _donations = [];
  bool _isLoading = true;
  double _totalDonated = 0;
  String? _donatorName;
  StreamSubscription? _announcementSubscription;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    _announcementSubscription = notificationService.inAppAnnouncements.listen((announcement) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AnnouncementPopupDialog(
            announcement: announcement,
            onDismiss: () => Navigator.of(context).pop(),
          ),
        );
      }
    });
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _fadeController.forward();
    });
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
  void dispose() {
    _fadeController.dispose();
    _announcementSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Row(
          children: [
            Consumer<SchoolProvider>(
              builder: (context, schoolProvider, _) {
                final schoolLogo = schoolProvider.currentSchool?.logoUrl;
                return Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                  ),
                  child: schoolLogo != null && schoolLogo.isNotEmpty
                      ? Image.network(schoolLogo, fit: BoxFit.contain)
                      : const Icon(Icons.school, size: 20, color: Colors.grey),
                );
              },
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Donator Dashboard',
                style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
      ),
      drawer: const DonatorDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const MakeDonationScreen()));
          if (result == true) _loadData();
        },
        backgroundColor: const Color(0xFFFF9800),
        child: const Icon(Icons.volunteer_activism_rounded),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeCard(),
                      const SizedBox(height: 24),
                      _buildStatsCard(),
                      const SizedBox(height: 24),
                      _buildDonationsList(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFFB74D)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 4),
                Text(_donatorName ?? 'Donator', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Consumer<SchoolProvider>(
            builder: (context, schoolProvider, _) {
              final schoolLogo = schoolProvider.currentSchool?.logoUrl;
              return Container(
                width: 56,
                height: 56,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: schoolLogo != null && schoolLogo.isNotEmpty
                    ? Image.network(schoolLogo, fit: BoxFit.contain)
                    : const Icon(Icons.school_rounded, color: Colors.white, size: 32),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          const Text('Total Donated', style: TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('\$${_totalDonated.toStringAsFixed(2)}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFFFF9800))),
          const SizedBox(height: 8),
          Text('${_donations.length} donations', style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildDonationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Donation History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
        const SizedBox(height: 16),
        if (_donations.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.volunteer_activism_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No donations yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _donations.length,
            itemBuilder: (context, index) {
              final donation = _donations[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFFF9800).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.favorite_rounded, color: Color(0xFFFF9800)),
                  ),
                  title: Text('\$${donation.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('${DateFormat('MMM dd, yyyy').format(donation.donationDate)}\n${donation.purpose ?? "General Support"}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: donation.status == 'Received' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(donation.status, style: TextStyle(color: donation.status == 'Received' ? Colors.green : Colors.orange, fontWeight: FontWeight.w600)),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
