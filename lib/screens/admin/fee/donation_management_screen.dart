import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../models/donation.dart';
import '../../../services/donation_service.dart';
import '../../../services/auth_service.dart';

class DonationManagementScreen extends StatefulWidget {
  const DonationManagementScreen({super.key});

  @override
  State<DonationManagementScreen> createState() => _DonationManagementScreenState();
}

class _DonationManagementScreenState extends State<DonationManagementScreen> {
  List<Donation> _donations = [];
  bool _isLoading = true;
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() => _isLoading = true);
    final authService = context.read<AuthService>();
    final donationService = context.read<DonationService>();
    final schoolId = await authService.getCurrentUserSchoolId();
    
    if (schoolId != null) {
      final donations = await donationService.getDonationsBySchool(schoolId);
      final summary = await donationService.getDonationSummary(schoolId);
      setState(() {
        _donations = donations;
        _totalAmount = summary['total_amount'];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donation Management'),
        backgroundColor: Colors.green.withOpacity(0.1),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.green.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Total Donations', style: TextStyle(fontSize: 12)),
                    Text('${_donations.length}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  children: [
                    const Text('Total Amount', style: TextStyle(fontSize: 12)),
                    Text('\$${_totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _donations.isEmpty
                    ? const Center(child: Text('No donations yet'))
                    : ListView.builder(
                        itemCount: _donations.length,
                        itemBuilder: (context, index) {
                          final donation = _donations[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Text('\$${donation.amount.toInt()}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                              ),
                              title: Text(donation.isAnonymous ? 'Anonymous' : donation.donatorName),
                              subtitle: Text('${DateFormat('MMM dd, yyyy').format(donation.donationDate)}\n${donation.purpose ?? "General"}'),
                              trailing: Chip(
                                label: Text(donation.status),
                                backgroundColor: donation.status == 'Received' ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
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
