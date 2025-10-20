import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/providers/school_provider.dart';

class DesktopParentDashboard extends StatefulWidget {
  const DesktopParentDashboard({super.key});

  @override
  State<DesktopParentDashboard> createState() => _DesktopParentDashboardState();
}

class _DesktopParentDashboardState extends State<DesktopParentDashboard> {
  String? _parentName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final user = authService.getCurrentUser();
    if (user != null) {
      final userDetails = await authService.getUserById(user.id);
      setState(() {
        _parentName = userDetails?.fullName ?? user.email?.split('@')[0];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB))))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeCard(),
                  const SizedBox(height: 32),
                  _buildQuickActions(),
                ],
              ),
            ),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';
    
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3498DB), Color(0xFF2980B9)]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$greeting! 👋', style: const TextStyle(color: Colors.white70, fontSize: 16)),
                const SizedBox(height: 8),
                Text(_parentName ?? 'Parent', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Consumer<SchoolProvider>(
                  builder: (context, schoolProvider, _) {
                    final schoolName = schoolProvider.currentSchool?.name;
                    return Text(
                      schoolName ?? 'School',
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.family_restroom, color: Colors.white, size: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'title': 'Child Attendance', 'icon': Icons.calendar_today_outlined, 'color': const Color(0xFF3498DB), 'route': '/parent/child-attendance'},
      {'title': 'Child Schedule', 'icon': Icons.schedule_outlined, 'color': const Color(0xFFF39C12), 'route': '/parent/child-schedule'},
      {'title': 'Announcements', 'icon': Icons.campaign_outlined, 'color': const Color(0xFF2ECC71), 'route': '/parent/announcements'},
      {'title': 'Exam Schedule', 'icon': Icons.assignment_outlined, 'color': const Color(0xFF9B59B6), 'route': '/parent/child-schedule'},
      {'title': 'Report Cards', 'icon': Icons.assessment_outlined, 'color': const Color(0xFFE74C3C), 'route': '/parent/child-attendance'},
      {'title': 'Daily Reports', 'icon': Icons.description_outlined, 'color': const Color(0xFF3498DB), 'route': '/parent/daily-report'},
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.3,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                onTap: () => context.push(action['route'] as String),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: (action['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (action['color'] as Color).withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action['icon'] as IconData, color: action['color'] as Color, size: 40),
                      const SizedBox(height: 12),
                      Text(
                        action['title'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
