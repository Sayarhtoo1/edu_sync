import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../models/donation.dart';
import '../../../services/donation_service.dart';
import '../../../providers/school_provider.dart';

class DonationManagementScreen extends StatefulWidget {
  const DonationManagementScreen({super.key});

  @override
  State<DonationManagementScreen> createState() => _DonationManagementScreenState();
}

class _DonationManagementScreenState extends State<DonationManagementScreen> {
  List<Donation> _donations = [];
  List<Donation> _filteredDonations = [];
  bool _isLoading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() => _isLoading = true);
    final schoolId = context.read<SchoolProvider>().currentSchool?.id;
    if (schoolId != null) {
      final donations = await context.read<DonationService>().getDonationsBySchool(schoolId);
      setState(() {
        _donations = donations;
        _filteredDonations = donations;
        _isLoading = false;
      });
    }
  }

  void _filterDonations(String query) {
    setState(() {
      _filteredDonations = _donations.where((d) =>
        d.donatorName.toLowerCase().contains(query.toLowerCase()) ||
        (d.purpose?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    });
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final purposeController = TextEditingController();
    String paymentMethod = 'Cash';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Donation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Donator Name')),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email (Optional)')),
                TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone (Optional)')),
                TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
                TextField(controller: purposeController, decoration: const InputDecoration(labelText: 'Purpose (Optional)')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  decoration: const InputDecoration(labelText: 'Payment Method'),
                  items: ['Cash', 'Bank Transfer', 'Check', 'Online'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setDialogState(() => paymentMethod = v!),
                ),
                ListTile(
                  title: Text('Date: ${selectedDate.toString().split(' ')[0]}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                    if (date != null) setDialogState(() => selectedDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || amountController.text.isEmpty) return;
                final schoolId = context.read<SchoolProvider>().currentSchool?.id;
                if (schoolId == null) return;

                final donation = Donation(
                  id: const Uuid().v4(),
                  schoolId: schoolId,
                  donatorName: nameController.text,
                  donatorEmail: emailController.text.isEmpty ? null : emailController.text,
                  donatorPhone: phoneController.text.isEmpty ? null : phoneController.text,
                  amount: double.parse(amountController.text),
                  donationDate: selectedDate,
                  paymentMethod: paymentMethod,
                  purpose: purposeController.text.isEmpty ? null : purposeController.text,
                  status: 'Received',
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                final result = await context.read<DonationService>().createDonation(donation);
                if (result != null && mounted) {
                  Navigator.pop(context);
                  _loadDonations();
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donation added successfully')));
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFF9800), Color(0xFFFFB74D)])),
        ),
        title: const Text('Donation Management', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterDonations,
                    decoration: InputDecoration(
                      hintText: 'Search donations...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredDonations.isEmpty
                      ? const Center(child: Text('No donations found'))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredDonations.length,
                          itemBuilder: (context, index) {
                            final donation = _filteredDonations[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF9800).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(Icons.volunteer_activism, color: Color(0xFFFF9800), size: 24),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(donation.donatorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                                            if (donation.purpose != null) Text(donation.purpose!, style: TextStyle(color: Colors.grey[600], fontSize: 13), overflow: TextOverflow.ellipsis),
                                          ],
                                        ),
                                      ),
                                      Text('\$${donation.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF9800))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(donation.donationDate.toString().split(' ')[0], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: donation.status == 'Received' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(donation.status, style: TextStyle(color: donation.status == 'Received' ? Colors.green : Colors.orange, fontSize: 11, fontWeight: FontWeight.w600)),
                                          ),
                                          const SizedBox(width: 8),
                                          InkWell(
                                            onTap: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Delete Donation'),
                                                  content: const Text('Are you sure you want to delete this donation?'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.pop(context, true),
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                      child: const Text('Delete'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true && mounted) {
                                                final success = await context.read<DonationService>().deleteDonation(donation.id);
                                                if (success && mounted) {
                                                  _loadDonations();
                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Donation deleted successfully')));
                                                }
                                              }
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: const Icon(Icons.delete, color: Colors.red, size: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFFF9800),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
