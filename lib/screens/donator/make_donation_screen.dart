import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/donation.dart';
import '../../services/donation_service.dart';
import '../../services/auth_service.dart';

class MakeDonationScreen extends StatefulWidget {
  const MakeDonationScreen({super.key});

  @override
  State<MakeDonationScreen> createState() => _MakeDonationScreenState();
}

class _MakeDonationScreenState extends State<MakeDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  
  String _paymentMethod = 'Cash';
  bool _isAnonymous = false;
  bool _isLoading = false;

  Future<void> _submitDonation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final authService = context.read<AuthService>();
    final donationService = context.read<DonationService>();
    final user = authService.getCurrentUser();
    final schoolId = await authService.getCurrentUserSchoolId();

    if (user == null || schoolId == null) return;

    final donation = Donation(
      id: const Uuid().v4(),
      schoolId: schoolId,
      donatorId: user.id,
      donatorName: user.userMetadata?['full_name'] ?? 'Anonymous',
      donatorEmail: user.email,
      donatorPhone: user.userMetadata?['phone_number'],
      amount: double.parse(_amountController.text),
      donationDate: DateTime.now(),
      paymentMethod: _paymentMethod,
      purpose: _purposeController.text.isEmpty ? null : _purposeController.text,
      isAnonymous: _isAnonymous,
      status: 'Received',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await donationService.createDonation(donation);

    setState(() => _isLoading = false);

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thank you for your donation!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make a Donation'),
        backgroundColor: Colors.green.withOpacity(0.1),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.volunteer_activism, size: 48, color: Colors.green),
                  SizedBox(height: 8),
                  Text('Support Education', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Your donation helps provide quality education', textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Donation Amount',
                prefixText: '\$ ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v?.isEmpty ?? true) return 'Required';
                if (double.tryParse(v!) == null) return 'Invalid amount';
                if (double.parse(v) <= 0) return 'Amount must be greater than 0';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: ['Cash', 'Bank Transfer', 'Online', 'Cheque']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _paymentMethod = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(
                labelText: 'Purpose (Optional)',
                hintText: 'e.g., Library, Sports, Scholarships',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Make this donation anonymous'),
              subtitle: const Text('Your name will not be displayed'),
              value: _isAnonymous,
              onChanged: (v) => setState(() => _isAnonymous = v),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitDonation,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Donate Now', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }
}
