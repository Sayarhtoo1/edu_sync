import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/donation.dart';
import '../../services/donation_service.dart';
import '../../services/auth_service.dart';
import 'make_donation_screen.dart';

class DonatorDashboardScreen extends StatefulWidget {
  const DonatorDashboardScreen({super.key});

  @override
  State<DonatorDashboardScreen> createState() => _DonatorDashboardScreenState();
}

class _DonatorDashboardScreenState extends State<DonatorDashboardScreen> {
  List<Donation> _myDonations = [];
  bool _isLoading = true;
  double _totalDonated = 0;

  @override
  void initState() {
    super.initState();
    _loadMyDonations();
  }

  Future<void> _loadMyDonations() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final donationService = context.read<DonationService>();
    final user = authService.getCurrentUser();
    
    if (user != null) {
      final donations = await donationService.getDonationsByDonator(user.id);
      double total = 0;
      for (var d in donations) {
        if (d.status == 'Received') total += d.amount;
      }
      setState(() {
        _myDonations = donations;
        _totalDonated = total;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
        backgroundColor: Colors.green.withOpacity(0.1),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MakeDonationScreen()),
          );
          if (result == true) _loadMyDonations();
        },
        icon: const Icon(Icons.volunteer_activism),
        label: const Text('Donate'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text('Total Donated', style: TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 8),
                Text(
                  '\$${_totalDonated.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('${_myDonations.length} donations', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _myDonations.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.volunteer_activism, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text('No donations yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            const SizedBox(height: 8),
                            const Text('Make your first donation to support education!'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _myDonations.length,
                        itemBuilder: (context, index) {
                          final donation = _myDonations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: const Icon(Icons.favorite, color: Colors.white),
                              ),
                              title: Text('\$${donation.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${DateFormat('MMM dd, yyyy').format(donation.donationDate)}\n${donation.purpose ?? "General Support"}'),
                              trailing: Chip(
                                label: Text(donation.status),
                                backgroundColor: donation.status == 'Received' 
                                    ? Colors.green.withOpacity(0.2) 
                                    : Colors.orange.withOpacity(0.2),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
