import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/schedule_summary_service.dart';
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/models/schedule_summary.dart';
import 'package:edu_sync/models/school_class.dart';
import 'package:edu_sync/providers/school_provider.dart';

class DesktopTeacherDashboard extends StatefulWidget {
  const DesktopTeacherDashboard({super.key});

  @override
  State<DesktopTeacherDashboard> createState() => _DesktopTeacherDashboardState();
}

class _DesktopTeacherDashboardState extends State<DesktopTeacherDashboard> {
  ScheduleSummary? _scheduleSummary;
  Timer? _timer;
  String? _teacherName;
  SchoolClass? _teacherClass;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final scheduleSummaryService = context.read<ScheduleSummaryService>();
    final classService = context.read<ClassService>();
    final schoolProvider = context.read<SchoolProvider>();
    final user = authService.getCurrentUser();
    
    if (user != null) {
      final userDetails = await authService.getUserById(user.id);
      final summary = await scheduleSummaryService.getDailyScheduleSummary(user.id, DateTime.now());
      
      final schoolId = schoolProvider.currentSchool?.id;
      if (schoolId != null) {
        final classes = await classService.getClasses(schoolId);
        _teacherClass = classes.where((c) => c.teacherId == user.id).firstOrNull;
      }
      
      setState(() {
        _teacherName = userDetails?.fullName ?? user.email?.split('@')[0];
        _scheduleSummary = summary;
        _isLoading = false;
      });
      
      _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
        final newSummary = await scheduleSummaryService.getDailyScheduleSummary(user.id, DateTime.now());
        if (mounted) setState(() => _scheduleSummary = newSummary);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Teacher Dashboard'),
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
                  if (_teacherClass != null) _buildMyClassCard(),
                  if (_teacherClass != null) const SizedBox(height: 32),
                  _buildScheduleCard(),
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
                Text(_teacherName ?? 'Teacher', style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Teacher Dashboard', style: TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 48),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    if (_scheduleSummary == null) return const SizedBox();
    
    IconData icon;
    Color color;
    String title;
    String subtitle = '';

    if (_scheduleSummary!.isFree) {
      icon = Icons.check_circle_outline;
      color = const Color(0xFF2ECC71);
      title = 'You are free now';
    } else if (_scheduleSummary!.currentEntry != null) {
      final entry = _scheduleSummary!.currentEntry!;
      icon = Icons.school_rounded;
      color = const Color(0xFF3498DB);
      title = '${entry.subjectName} - ${entry.className}';
      subtitle = '${entry.startTimeString} - ${entry.endTimeString}';
    } else if (_scheduleSummary!.nextEntry != null) {
      final entry = _scheduleSummary!.nextEntry!;
      icon = Icons.schedule_rounded;
      color = const Color(0xFFF39C12);
      title = 'Next: ${entry.subjectName} - ${entry.className}';
      subtitle = '${entry.startTimeString} - ${entry.endTimeString}';
    } else {
      icon = Icons.event_busy;
      color = Colors.grey;
      title = 'No schedule today';
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 36),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (subtitle.isNotEmpty) const SizedBox(height: 4),
                if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyClassCard() {
    return InkWell(
      onTap: () => context.push('/admin/class-profile', extra: _teacherClass),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: const Color(0xFF9B59B6).withOpacity(0.3), blurRadius: 12)],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.class_rounded, color: Colors.white, size: 36),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Class', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(_teacherClass!.name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'title': 'My Students', 'icon': Icons.school_outlined, 'color': const Color(0xFF3498DB), 'route': '/teacher/students'},
      {'title': 'Mark Attendance', 'icon': Icons.how_to_reg_outlined, 'color': const Color(0xFF2ECC71), 'route': '/teacher/attendance-marking'},
      {'title': 'Input Marks', 'icon': Icons.edit_note_outlined, 'color': const Color(0xFF9B59B6), 'route': 'teacher-marks-entry-selection'},
      {'title': 'Timetable', 'icon': Icons.schedule_outlined, 'color': const Color(0xFFF39C12), 'route': '/teacher/timetable'},
      {'title': 'Lesson Plans', 'icon': Icons.book_outlined, 'color': const Color(0xFFE74C3C), 'route': '/teacher/lesson-plan-management'},
      {'title': 'Reports', 'icon': Icons.assessment_outlined, 'color': const Color(0xFF3498DB), 'route': '/teacher/students'},
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
                onTap: () {
                  if (action['route'].toString().contains('/')) {
                    context.push(action['route'] as String);
                  } else {
                    context.pushNamed(action['route'] as String);
                  }
                },
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
