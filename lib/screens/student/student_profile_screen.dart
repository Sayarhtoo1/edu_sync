import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/student.dart';
import '../../models/school_class.dart';
import '../../models/attendance.dart' as app_attendance;
import '../../models/grade.dart';
import '../../services/class_service.dart';
import '../../services/attendance_service.dart';
import '../../services/exam_service.dart';

class _StudentProfileData {
  final SchoolClass? schoolClass;
  final List<app_attendance.Attendance> attendanceRecords;
  final List<Grade>? grades;
  final Map<String, dynamic>? performanceData;
  final List<dynamic>? recentExams;

  _StudentProfileData({
    this.schoolClass,
    required this.attendanceRecords,
    this.grades,
    this.performanceData,
    this.recentExams,
  });
}

class StudentProfileScreen extends ConsumerStatefulWidget {
  final Student student;

  const StudentProfileScreen({super.key, required this.student});

  @override
  _StudentProfileScreenState createState() {
    return _StudentProfileScreenState();
  }
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  late Future<_StudentProfileData> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData();
  }

  Future<_StudentProfileData> _fetchProfileData() async {
    final classService = ref.read(classServiceProvider);
    final attendanceService = ref.read(attendanceServiceProvider);
    final examService = ref.read(examServiceProvider);

    SchoolClass? schoolClass;
    if (widget.student.classId != null) {
      schoolClass = await classService.getClassById(widget.student.classId!);
    }

    final attendanceRecords = await attendanceService.getAttendanceForStudent(widget.student.id);

    // Fetch additional data for enhanced profile
    List<Grade>? grades;
    Map<String, dynamic>? performanceData;
    List<dynamic>? recentExams;

    try {
      // Get grades for the school
      if (widget.student.schoolId != 0) {
        grades = await examService.getGradesBySchoolId(widget.student.schoolId);
      }

      // Get student performance data
      performanceData = await examService.getStudentPerformance(widget.student.id);

      // Get recent exams (you might need to implement this method in ExamService)
      // For now, we'll use a placeholder
      recentExams = [];
    } catch (e) {
      // If additional data fails to load, continue with basic data
      // ignore: avoid_print
      print('Error loading additional profile data: $e');
    }

    return _StudentProfileData(
      schoolClass: schoolClass,
      attendanceRecords: attendanceRecords,
      grades: grades,
      performanceData: performanceData,
      recentExams: recentExams,
    );
  }

  Map<String, int> _calculateAttendanceSummary(List<app_attendance.Attendance> records) {
    int present = 0;
    int absent = 0;
    int leave = 0;

    for (var record in records) {
      if (record.status == 'Present') {
        present++;
      } else if (record.status == 'Absent') {
        absent++;
      } else if (record.status == 'Leave') {
        leave++;
      }
    }

    return {
      'Present': present,
      'Absent': absent,
      'Leave': leave,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<_StudentProfileData>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final profileData = snapshot.data!;
          final attendanceSummary = _calculateAttendanceSummary(profileData.attendanceRecords);
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final todayAttendance = profileData.attendanceRecords.firstWhere(
            (record) => DateFormat('yyyy-MM-dd').format(record.date) == today,
            orElse: () => app_attendance.Attendance(id: null, studentId: widget.student.id, classId: widget.student.classId ?? 0, date: DateTime.now(), status: 'N/A'),
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(widget.student.fullName),
                  background: widget.student.profilePhotoUrl != null
                      ? Image.network(
                          widget.student.profilePhotoUrl!,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.person, size: 100, color: Colors.grey),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoCard(
                        title: 'Personal Information',
                        icon: Icons.person,
                        color: Colors.blue,
                        children: [
                          _buildInfoRow(Icons.class_, 'Class', profileData.schoolClass?.name ?? 'N/A'),
                          _buildInfoRow(Icons.cake, 'Date of Birth', widget.student.dateOfBirth?.toLocal().toString().split(' ')[0] ?? 'N/A'),
                          _buildInfoRow(Icons.person_outline, 'Gender', widget.student.gender ?? 'N/A'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildAttendanceCard(
                        todayStatus: todayAttendance.status,
                        attendanceSummary: attendanceSummary,
                      ),
                      const SizedBox(height: 16),
                      _buildAcademicPerformanceCard(profileData),
                      const SizedBox(height: 16),
                      _buildAdditionalInfoCard(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard({
    required String todayStatus,
    required Map<String, int> attendanceSummary,
  }) {
    return _buildInfoCard(
      title: 'Attendance Summary',
      icon: Icons.calendar_today,
      color: Colors.green,
      children: [
        _buildInfoRow(Icons.today, 'Today\'s Status', todayStatus),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAttendanceStat(
                'Present',
                attendanceSummary['Present'] ?? 0,
                Colors.green,
                Icons.check_circle,
              ),
            ),
            Expanded(
              child: _buildAttendanceStat(
                'Absent',
                attendanceSummary['Absent'] ?? 0,
                Colors.red,
                Icons.cancel,
              ),
            ),
            Expanded(
              child: _buildAttendanceStat(
                'Leave',
                attendanceSummary['Leave'] ?? 0,
                Colors.orange,
                Icons.event_note,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAttendanceProgress(attendanceSummary),
      ],
    );
  }

  Widget _buildAttendanceStat(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceProgress(Map<String, int> attendanceSummary) {
    final total = attendanceSummary.values.reduce((a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final presentPercentage = (attendanceSummary['Present'] ?? 0) / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attendance Rate',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${(presentPercentage * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: presentPercentage,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation<Color>(
            presentPercentage >= 0.8 ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildAcademicPerformanceCard(_StudentProfileData profileData) {
    // Extract performance data
    final performanceData = profileData.performanceData;
    final grades = profileData.grades ?? [];

    String overallGPA = 'N/A';
    String overallGrade = 'N/A';
    int totalExams = 0;
    double avgPercentage = 0.0;

    if (performanceData != null && performanceData.isNotEmpty) {
      overallGPA = performanceData['overall_gpa']?.toString() ?? 'N/A';
      overallGrade = performanceData['overall_grade']?.toString() ?? 'N/A';
      totalExams = performanceData['total_exams'] ?? 0;
      avgPercentage = (performanceData['average_percentage'] ?? 0.0).toDouble();
    }

    return _buildInfoCard(
      title: 'Academic Performance',
      icon: Icons.school,
      color: Colors.purple,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPerformanceStat(
                'Overall GPA',
                overallGPA,
                Icons.grade,
                Colors.purple,
              ),
            ),
            Expanded(
              child: _buildPerformanceStat(
                'Grade',
                overallGrade,
                Icons.star,
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildPerformanceStat(
                'Exams',
                totalExams.toString(),
                Icons.assignment,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildPerformanceStat(
                'Avg Score',
                '${avgPercentage.toStringAsFixed(1)}%',
                Icons.analytics,
                Colors.green,
              ),
            ),
          ],
        ),
        if (grades.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            'Grade Scale',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          _buildGradeScale(grades),
        ],
      ],
    );
  }

  Widget _buildPerformanceStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildGradeScale(List<Grade> grades) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: grades.take(5).map((grade) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                grade.gradeName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${grade.minPercentage}% - ${grade.maxPercentage}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return _buildInfoCard(
      title: 'Additional Information',
      icon: Icons.info,
      color: Colors.teal,
      children: [
        _buildInfoRow(Icons.school, 'Student ID', widget.student.id.toString()),
        _buildInfoRow(Icons.business, 'School ID', widget.student.schoolId.toString()),
        _buildInfoRow(Icons.badge, 'Enrollment Status', 'Active'),
        _buildInfoRow(Icons.date_range, 'Member Since', 'Jan 2024'), // You can calculate this from created date if available
        if (widget.student.profilePhotoUrl != null)
          _buildInfoRow(Icons.photo, 'Profile Photo', 'Uploaded'),
      ],
    );
  }


}

final classServiceProvider = Provider<ClassService>((ref) {
  return ClassService();
});

final attendanceServiceProvider = Provider<AttendanceService>((ref) {
  return AttendanceService();
});

final examServiceProvider = Provider<ExamService>((ref) {
  return ExamService();
});
