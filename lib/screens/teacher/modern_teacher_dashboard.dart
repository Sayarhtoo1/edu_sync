import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/services/schedule_summary_service.dart';
import 'package:edu_sync/models/schedule_summary.dart';
import 'package:edu_sync/widgets/admin/animated_metric_card.dart';
import 'package:edu_sync/widgets/teacher/teacher_drawer.dart';
import 'package:edu_sync/screens/teacher/attendance_marking_screen.dart';
import 'package:edu_sync/screens/teacher/exam/input_marks_screen.dart';
import 'package:edu_sync/screens/teacher/teacher_timetable_screen.dart';
import 'package:edu_sync/screens/common/attendance_report_screen.dart';

class ModernTeacherDashboard extends StatefulWidget {
  const ModernTeacherDashboard({super.key});

  @override
  State<ModernTeacherDashboard> createState() => _ModernTeacherDashboardState();
}

class _ModernTeacherDashboardState extends State<ModernTeacherDashboard> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  ScheduleSummary? _scheduleSummary;
  Timer? _timer;
  String? _teacherName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _fadeController.forward();
    });
  }

  Future<void> _loadData() async {
    final authService = context.read<AuthService>();
    final scheduleSummaryService = context.read<ScheduleSummaryService>();
    final user = authService.getCurrentUser();
    
    if (user != null) {
      final summary = await scheduleSummaryService.getDailyScheduleSummary(user.id, DateTime.now());
      setState(() {
        _teacherName = user.email?.split('@')[0];
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
    _fadeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('Teacher Dashboard', style: TextStyle(color: Color(0xFF2C2C2C), fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Color(0xFF2C2C2C)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {}),
          const SizedBox(width: 8),
        ],
      ),
      drawer: const TeacherDrawer(),
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
                      _buildScheduleCard(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
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
        gradient: const LinearGradient(colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)]),
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
                Text(_teacherName ?? 'Teacher', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 32),
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
      color = const Color(0xFF4CAF50);
      title = 'You are free now';
    } else if (_scheduleSummary!.currentEntry != null) {
      final entry = _scheduleSummary!.currentEntry!;
      icon = Icons.school_rounded;
      color = const Color(0xFF2196F3);
      title = '${entry.subjectName} - ${entry.className}';
      subtitle = '${entry.startTimeString} - ${entry.endTimeString}';
    } else if (_scheduleSummary!.nextEntry != null) {
      final entry = _scheduleSummary!.nextEntry!;
      icon = Icons.schedule_rounded;
      color = const Color(0xFFFF9800);
      title = 'Next: ${entry.subjectName} - ${entry.className}';
      subtitle = '${entry.startTimeString} - ${entry.endTimeString}';
    } else {
      icon = Icons.event_busy;
      color = Colors.grey;
      title = 'No schedule today';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
                if (subtitle.isNotEmpty) Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'title': 'Mark Attendance', 'icon': Icons.how_to_reg_outlined, 'color': const Color(0xFF4CAF50), 'screen': const AttendanceMarkingScreen()},
      {'title': 'Input Marks', 'icon': Icons.edit_note_outlined, 'color': const Color(0xFF2196F3), 'screen': InputMarksScreen()},
      {'title': 'Timetable', 'icon': Icons.schedule_outlined, 'color': const Color(0xFF9C27B0), 'screen': const TeacherTimetableScreen()},
      {'title': 'Reports', 'icon': Icons.assessment_outlined, 'color': const Color(0xFFFF9800), 'screen': const AttendanceReportScreen()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C2C2C))),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => action['screen'] as Widget)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action['icon'] as IconData, color: action['color'] as Color, size: 32),
                      const SizedBox(height: 8),
                      Text(action['title'] as String, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
