import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_sync/models/staff.dart';

class DesktopStaffProfile extends StatelessWidget {
  final Staff staff;

  const DesktopStaffProfile({super.key, required this.staff});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(staff.fullName ?? 'Staff Profile'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Profile & Personal Info
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 32),
                  _buildPersonalInfoCard(),
                ],
              ),
            ),
          ),
          // Right Column - Employment Details
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  _buildEmploymentCard(),
                  const SizedBox(height: 32),
                  _buildContactCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2ECC71), Color(0xFF27AE60)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: ClipOval(
              child: staff.profilePhotoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: staff.profilePhotoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      errorWidget: (context, url, error) => const Icon(Icons.person, size: 70, color: Colors.white),
                    )
                  : const Icon(Icons.person, size: 70, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(staff.fullName ?? 'N/A', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(staff.role, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person, color: Color(0xFF3498DB), size: 24),
              SizedBox(width: 12),
              Text('Personal Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('Role', staff.role, Icons.badge),
          _buildInfoRow('Email', staff.email ?? 'N/A', Icons.email),
          _buildInfoRow('School ID', staff.schoolId?.toString() ?? 'N/A', Icons.school),
        ],
      ),
    );
  }

  Widget _buildEmploymentCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.work, color: Color(0xFF2ECC71), size: 24),
              SizedBox(width: 12),
              Text('Employment Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow(
            'Salary',
            staff.salary != null
                ? NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(staff.salary)
                : 'N/A',
            Icons.attach_money,
          ),
          _buildInfoRow('Employment Status', 'Active', Icons.check_circle),
          _buildInfoRow('Department', staff.role, Icons.business),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.phone, color: Color(0xFF9B59B6), size: 24),
              SizedBox(width: 12),
              Text('Contact Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          if (staff.phoneNumber != null && staff.phoneNumber!.isNotEmpty)
            _buildPhoneRow('Phone', staff.phoneNumber!),
          if (staff.email != null && staff.email!.isNotEmpty)
            _buildEmailRow('Email', staff.email!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneRow(String label, String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(Icons.phone, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(phoneNumber, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.call, color: Colors.green, size: 20),
            onPressed: () => launchUrl(Uri(scheme: 'tel', path: phoneNumber)),
            tooltip: 'Call',
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.blue, size: 20),
            onPressed: () => launchUrl(Uri(scheme: 'sms', path: phoneNumber)),
            tooltip: 'Message',
          ),
        ],
      ),
    );
  }

  Widget _buildEmailRow(String label, String email) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(Icons.email, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(email, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.email_outlined, color: Colors.blue, size: 20),
            onPressed: () => launchUrl(Uri(scheme: 'mailto', path: email)),
            tooltip: 'Send Email',
          ),
        ],
      ),
    );
  }
}
