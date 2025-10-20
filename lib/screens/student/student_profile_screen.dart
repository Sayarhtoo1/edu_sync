import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../models/student.dart';
import '../../models/school_class.dart';
import '../../models/attendance.dart' as app_attendance;
import '../../models/grade.dart';
import '../../models/user.dart' as app_user;
import '../../services/class_service.dart';
import '../../services/attendance_service.dart';
import '../../services/exam_service.dart';
import '../../services/student_service.dart';
import '../../services/parent_service.dart';

class _StudentProfileData {
  final Student student;
  final SchoolClass? schoolClass;
  final List<app_attendance.Attendance> attendanceRecords;
  final List<Grade>? grades;
  final Map<String, dynamic>? performanceData;
  final List<dynamic>? recentExams;

  _StudentProfileData({
    required this.student,
    this.schoolClass,
    required this.attendanceRecords,
    this.grades,
    this.performanceData,
    this.recentExams,
  });
}

class StudentProfileScreen extends StatefulWidget {
  final Student student;

  const StudentProfileScreen({super.key, required this.student});

  @override
  _StudentProfileScreenState createState() {
    return _StudentProfileScreenState();
  }
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  late Future<_StudentProfileData> _profileDataFuture;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData();
  }

  Future<_StudentProfileData> _fetchProfileData() async {
    final studentService = provider.Provider.of<StudentService>(context, listen: false);
    final classService = provider.Provider.of<ClassService>(context, listen: false);
    final attendanceService = provider.Provider.of<AttendanceService>(context, listen: false);
    final examService = ExamService();

    // Fetch fresh student data from backend
    final freshStudent = await studentService.getStudentById(widget.student.id, widget.student.schoolId) ?? widget.student;

    SchoolClass? schoolClass;
    if (freshStudent.classId != null) {
      schoolClass = await classService.getClassById(freshStudent.classId!);
    }

    final attendanceRecords = await attendanceService.getAttendanceForStudent(freshStudent.id);

    // Fetch additional data for enhanced profile
    List<Grade>? grades;
    Map<String, dynamic>? performanceData;
    List<dynamic>? recentExams;

    try {
      // Get grades for the school
      if (freshStudent.schoolId != 0) {
        grades = await examService.getGradesBySchoolId(freshStudent.schoolId);
      }

      // Get student performance data
      performanceData = await examService.getStudentPerformance(freshStudent.id);

      // Get recent exams (you might need to implement this method in ExamService)
      // For now, we'll use a placeholder
      recentExams = [];
    } catch (e) {
      // If additional data fails to load, continue with basic data
      // ignore: avoid_print
      print('Error loading additional profile data: $e');
    }

    return _StudentProfileData(
      student: freshStudent,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLinkParentDialog(context),
        backgroundColor: const Color(0xFF3498DB),
        icon: const Icon(Icons.family_restroom),
        label: const Text('Link Parent'),
      ),
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
          final student = profileData.student;
          final attendanceSummary = _calculateAttendanceSummary(profileData.attendanceRecords);
          final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final todayAttendance = profileData.attendanceRecords.firstWhere(
            (record) => DateFormat('yyyy-MM-dd').format(record.date) == today,
            orElse: () => app_attendance.Attendance(id: null, studentId: student.id, classId: student.classId ?? 0, date: DateTime.now(), status: 'N/A'),
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(student.fullName),
                  background: student.profilePhotoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: student.profilePhotoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[200],
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.person, size: 100, color: Colors.grey),
                          ),
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
                          _buildInfoRow(Icons.cake, 'Date of Birth', student.dateOfBirth?.toLocal().toString().split(' ')[0] ?? 'N/A'),
                          _buildInfoRow(Icons.person_outline, 'Gender', student.gender ?? 'N/A'),
                          if (student.phoneNumber1 != null && student.phoneNumber1!.isNotEmpty)
                            _buildPhoneRow('Phone 1', student.phoneNumber1!),
                          if (student.phoneNumber2 != null && student.phoneNumber2!.isNotEmpty)
                            _buildPhoneRow('Phone 2', student.phoneNumber2!),
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
                      _buildPerformanceDashboardButton(),
                      const SizedBox(height: 16),
                      _buildAdditionalInfoCard(),
                      const SizedBox(height: 16),
                      _buildLinkedParentsCard(),
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

  Widget _buildLinkedParentsCard() {
    return FutureBuilder<List<app_user.User>>(
      future: _fetchLinkedParents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final parents = snapshot.data!;
        
        return _buildInfoCard(
          title: 'Linked Parents',
          icon: Icons.family_restroom,
          color: Colors.indigo,
          children: parents.isEmpty
              ? [const Text('No parents linked yet', style: TextStyle(color: Colors.grey))]
              : parents.map((parent) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: const Color(0xFF3498DB).withOpacity(0.1),
                        child: const Icon(Icons.person, color: Color(0xFF3498DB), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(parent.fullName ?? 'N/A', style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(parent.email ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                        onPressed: () => _unlinkParent(context, parent.id),
                        tooltip: 'Unlink',
                      ),
                    ],
                  ),
                )).toList(),
        );
      },
    );
  }

  Future<List<app_user.User>> _fetchLinkedParents() async {
    final studentService = provider.Provider.of<StudentService>(context, listen: false);
    final parentService = provider.Provider.of<ParentService>(context, listen: false);
    
    final parentIds = await studentService.getParentIdsForStudent(widget.student.id);
    final allParents = await parentService.getParentsBySchool(widget.student.schoolId);
    
    return allParents.where((p) => parentIds.contains(p.id)).toList();
  }

  void _showLinkParentDialog(BuildContext context) async {
    final parentService = provider.Provider.of<ParentService>(context, listen: false);
    final studentService = provider.Provider.of<StudentService>(context, listen: false);
    
    final allParents = await parentService.getParentsBySchool(widget.student.schoolId);
    final linkedParentIds = await studentService.getParentIdsForStudent(widget.student.id);
    final availableParents = allParents.where((p) => !linkedParentIds.contains(p.id)).toList();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Link Parent'),
        content: SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _showCreateParentDialog(context);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create New Parent for This Student'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              if (availableParents.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Or link existing parent:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableParents.length,
                    itemBuilder: (context, index) {
                      final parent = availableParents[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF3498DB),
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        title: Text(parent.fullName ?? 'N/A'),
                        subtitle: Text(parent.email ?? ''),
                        onTap: () async {
                          Navigator.pop(context);
                          await _linkParent(context, parent.id);
                        },
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showCreateParentDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phone1Controller = TextEditingController();
    final phone2Controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Parent for Student'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phone1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number 1',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: phone2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number 2',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                await _createAndLinkParent(
                  context,
                  nameController.text,
                  emailController.text,
                  passwordController.text,
                  phone1Controller.text,
                  phone2Controller.text,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2ECC71)),
            child: const Text('Create & Link'),
          ),
        ],
      ),
    );
  }

  Future<void> _createAndLinkParent(
    BuildContext context,
    String fullName,
    String email,
    String password,
    String phone1,
    String phone2,
  ) async {
    final parentService = provider.Provider.of<ParentService>(context, listen: false);
    final studentService = provider.Provider.of<StudentService>(context, listen: false);

    try {
      // Show loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creating parent...'), duration: Duration(seconds: 2)),
        );
      }

      // Create parent
      final parentId = await parentService.createParent(
        fullName: fullName,
        email: email,
        password: password,
        phoneNumber1: phone1.isEmpty ? null : phone1,
        phoneNumber2: phone2.isEmpty ? null : phone2,
        schoolId: widget.student.schoolId,
      );

      // Update phone_number_2 if provided
      if (phone2.isNotEmpty) {
        final updatedUser = app_user.User(
          id: parentId,
          fullName: fullName,
          email: email,
          role: 'Parent',
          schoolId: widget.student.schoolId,
          phoneNumber1: phone1.isEmpty ? null : phone1,
          phoneNumber2: phone2,
        );
        await parentService.updateParent(updatedUser);
      }

      // Link to student
      await studentService.linkParentToStudent(parentId, widget.student.id, 'Parent');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parent created and linked successfully')),
        );
        setState(() {
          _profileDataFuture = _fetchProfileData();
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _linkParent(BuildContext context, String parentId) async {
    final studentService = provider.Provider.of<StudentService>(context, listen: false);
    
    try {
      await studentService.linkParentToStudent(parentId, widget.student.id, 'Parent');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parent linked successfully')),
        );
        setState(() {
          _profileDataFuture = _fetchProfileData();
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error linking parent: $e')),
        );
      }
    }
  }

  Future<void> _unlinkParent(BuildContext context, String parentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Parent'),
        content: const Text('Are you sure you want to unlink this parent?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unlink', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirm == true && context.mounted) {
      final studentService = provider.Provider.of<StudentService>(context, listen: false);
      try {
        await studentService.unlinkParentFromStudent(parentId, widget.student.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Parent unlinked successfully')),
          );
          setState(() {
            _profileDataFuture = _fetchProfileData();
          });
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error unlinking parent: $e')),
          );
        }
      }
    }
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
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
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
                    color: color.withOpacity(0.8),
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
              color: Colors.grey.withOpacity(0.1),
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

  Widget _buildPhoneRow(String label, String phoneNumber) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.phone, size: 20, color: Colors.grey[600]),
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
                  phoneNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Colors.green),
            onPressed: () => _makePhoneCall(phoneNumber),
            tooltip: 'Call',
          ),
          IconButton(
            icon: const Icon(Icons.message, color: Colors.blue),
            onPressed: () => _sendMessage(phoneNumber),
            tooltip: 'Message',
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone dialer: $e')),
        );
      }
    }
  }

  Future<void> _sendMessage(String phoneNumber) async {
    final uri = Uri(scheme: 'sms', path: phoneNumber);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch messaging app: $e')),
        );
      }
    }
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

    if (performanceData != null) {
      overallGPA = performanceData['overall_gpa']?.toString() ?? 'N/A';
      overallGrade = performanceData['overall_grade']?.toString() ?? 'N/A';
      totalExams = (performanceData['total_exams'] ?? 0) is int ? performanceData['total_exams'] : int.tryParse(performanceData['total_exams']?.toString() ?? '0') ?? 0;
      avgPercentage = (performanceData['average_percentage'] ?? 0.0) is double ? performanceData['average_percentage'] : double.tryParse(performanceData['average_percentage']?.toString() ?? '0') ?? 0.0;
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

  Widget _buildPerformanceDashboardButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B4FC4), Color(0xFF7B68EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B4FC4).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            context.pushNamed('student-performance');
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.analytics_outlined, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                const Text(
                  'View Performance Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoCard() {
    return FutureBuilder<_StudentProfileData>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final profileData = snapshot.data!;
        return _buildInfoCard(
          title: 'Additional Information',
          icon: Icons.info,
          color: Colors.teal,
          children: [
            _buildInfoRow(Icons.school, 'Student ID', profileData.student.id.toString()),
            _buildInfoRow(Icons.business, 'School ID', profileData.student.schoolId.toString()),
            _buildInfoRow(Icons.badge, 'Enrollment Status', 'Active'),
            _buildInfoRow(Icons.date_range, 'Member Since', 'Jan 2024'),
            if (profileData.student.profilePhotoUrl != null)
              _buildInfoRow(Icons.photo, 'Profile Photo', 'Uploaded'),
          ],
        );
      },
    );
  }


}
