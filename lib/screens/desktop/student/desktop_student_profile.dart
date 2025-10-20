import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:edu_sync/models/student.dart';
import 'package:edu_sync/models/school_class.dart';
import 'package:edu_sync/models/attendance.dart' as app_attendance;
import 'package:edu_sync/models/grade.dart';
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/services/class_service.dart';
import 'package:edu_sync/services/attendance_service.dart';
import 'package:edu_sync/services/exam_service.dart';
import 'package:edu_sync/services/student_service.dart';
import 'package:edu_sync/services/parent_service.dart';

class _StudentProfileData {
  final Student student;
  final SchoolClass? schoolClass;
  final List<app_attendance.Attendance> attendanceRecords;
  final List<Grade>? grades;
  final Map<String, dynamic>? performanceData;

  _StudentProfileData({
    required this.student,
    this.schoolClass,
    required this.attendanceRecords,
    this.grades,
    this.performanceData,
  });
}

class DesktopStudentProfile extends StatefulWidget {
  final Student student;

  const DesktopStudentProfile({super.key, required this.student});

  @override
  State<DesktopStudentProfile> createState() => _DesktopStudentProfileState();
}

class _DesktopStudentProfileState extends State<DesktopStudentProfile> {
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

    final freshStudent = await studentService.getStudentById(widget.student.id, widget.student.schoolId) ?? widget.student;

    SchoolClass? schoolClass;
    if (freshStudent.classId != null) {
      schoolClass = await classService.getClassById(freshStudent.classId!);
    }

    final attendanceRecords = await attendanceService.getAttendanceForStudent(freshStudent.id);

    List<Grade>? grades;
    Map<String, dynamic>? performanceData;

    try {
      if (freshStudent.schoolId != 0) {
        grades = await examService.getGradesBySchoolId(freshStudent.schoolId);
      }
      performanceData = await examService.getStudentPerformance(freshStudent.id);
    } catch (e) {
      // Continue with basic data
    }

    return _StudentProfileData(
      student: freshStudent,
      schoolClass: schoolClass,
      attendanceRecords: attendanceRecords,
      grades: grades,
      performanceData: performanceData,
    );
  }

  Map<String, int> _calculateAttendanceSummary(List<app_attendance.Attendance> records) {
    int present = 0, absent = 0, leave = 0;
    for (var record in records) {
      if (record.status == 'Present') present++;
      else if (record.status == 'Absent') absent++;
      else if (record.status == 'Leave') leave++;
    }
    return {'Present': present, 'Absent': absent, 'Leave': leave};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(widget.student.fullName),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          ElevatedButton.icon(
            onPressed: () => _showLinkParentDialog(context),
            icon: const Icon(Icons.family_restroom, size: 18),
            label: const Text('Link Parent'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3498DB),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: FutureBuilder<_StudentProfileData>(
        future: _profileDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3498DB))));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Color(0xFFE74C3C))));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final profileData = snapshot.data!;
          final student = profileData.student;
          final attendanceSummary = _calculateAttendanceSummary(profileData.attendanceRecords);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column - Profile & Personal Info
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      _buildProfileCard(student),
                      const SizedBox(height: 32),
                      _buildPersonalInfoCard(student, profileData.schoolClass),
                      const SizedBox(height: 32),
                      _buildContactCard(student),
                      const SizedBox(height: 32),
                      _buildLinkedParentsCard(),
                    ],
                  ),
                ),
              ),
              // Right Column - Attendance & Performance
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      _buildAttendanceCard(attendanceSummary, profileData.attendanceRecords),
                      const SizedBox(height: 32),
                      _buildAcademicPerformanceCard(profileData),
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

  Widget _buildProfileCard(Student student) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3498DB), Color(0xFF2980B9)]),
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
              child: student.profilePhotoUrl != null
                  ? CachedNetworkImage(
                      imageUrl: student.profilePhotoUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      errorWidget: (context, url, error) => const Icon(Icons.person, size: 70, color: Colors.white),
                    )
                  : const Icon(Icons.person, size: 70, color: Colors.white),
            ),
          ),
          const SizedBox(height: 24),
          Text(student.fullName, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('Student ID: ${student.id}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard(Student student, SchoolClass? schoolClass) {
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
          _buildInfoRow('Class', schoolClass?.name ?? 'N/A', Icons.class_),
          _buildInfoRow('Date of Birth', student.dateOfBirth?.toLocal().toString().split(' ')[0] ?? 'N/A', Icons.cake),
          _buildInfoRow('Gender', student.gender ?? 'N/A', Icons.person_outline),
        ],
      ),
    );
  }

  Widget _buildContactCard(Student student) {
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
              Icon(Icons.phone, color: Color(0xFF2ECC71), size: 24),
              SizedBox(width: 12),
              Text('Contact Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          if (student.phoneNumber1 != null && student.phoneNumber1!.isNotEmpty)
            _buildPhoneRow('Phone 1', student.phoneNumber1!),
          if (student.phoneNumber2 != null && student.phoneNumber2!.isNotEmpty)
            _buildPhoneRow('Phone 2', student.phoneNumber2!),
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

  Widget _buildAttendanceCard(Map<String, int> summary, List<app_attendance.Attendance> records) {
    final total = summary.values.reduce((a, b) => a + b);
    final presentPercentage = total > 0 ? (summary['Present']! / total * 100) : 0.0;

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
              Icon(Icons.calendar_today, color: Color(0xFF2ECC71), size: 24),
              SizedBox(width: 12),
              Text('Attendance Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildAttendanceStat('Present', summary['Present'] ?? 0, const Color(0xFF2ECC71), Icons.check_circle)),
              Expanded(child: _buildAttendanceStat('Absent', summary['Absent'] ?? 0, const Color(0xFFE74C3C), Icons.cancel)),
              Expanded(child: _buildAttendanceStat('Leave', summary['Leave'] ?? 0, const Color(0xFFF39C12), Icons.event_note)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Attendance Rate: ${presentPercentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: presentPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(presentPercentage >= 80 ? const Color(0xFF2ECC71) : const Color(0xFFF39C12)),
            minHeight: 10,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, int count, Color color, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(count.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAcademicPerformanceCard(_StudentProfileData profileData) {
    final performanceData = profileData.performanceData;
    String overallGPA = 'N/A';
    String overallGrade = 'N/A';
    int totalExams = 0;
    double avgPercentage = 0.0;

    if (performanceData != null) {
      overallGPA = performanceData['overall_gpa']?.toString() ?? 'N/A';
      overallGrade = performanceData['overall_grade']?.toString() ?? 'N/A';
      totalExams = int.tryParse(performanceData['total_exams']?.toString() ?? '0') ?? 0;
      avgPercentage = double.tryParse(performanceData['average_percentage']?.toString() ?? '0') ?? 0.0;
    }

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
              Icon(Icons.school, color: Color(0xFF9B59B6), size: 24),
              SizedBox(width: 12),
              Text('Academic Performance', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildPerformanceStat('GPA', overallGPA, Icons.grade, const Color(0xFF9B59B6))),
              Expanded(child: _buildPerformanceStat('Grade', overallGrade, Icons.star, const Color(0xFFF39C12))),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildPerformanceStat('Exams', totalExams.toString(), Icons.assignment, const Color(0xFF3498DB))),
              Expanded(child: _buildPerformanceStat('Avg Score', '${avgPercentage.toStringAsFixed(1)}%', Icons.analytics, const Color(0xFF2ECC71))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildLinkedParentsCard() {
    return FutureBuilder<List<app_user.User>>(
      future: _fetchLinkedParents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final parents = snapshot.data!;
        
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
                  Icon(Icons.family_restroom, color: Color(0xFF3498DB), size: 24),
                  SizedBox(width: 12),
                  Text('Linked Parents', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
              if (parents.isEmpty)
                const Text('No parents linked yet', style: TextStyle(color: Colors.grey))
              else
                ...parents.map((parent) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: const Color(0xFF3498DB).withOpacity(0.1),
                        child: const Icon(Icons.person, color: Color(0xFF3498DB), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(parent.fullName ?? 'N/A', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            Text(parent.email ?? '', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
                        onPressed: () => _unlinkParent(context, parent.id),
                        tooltip: 'Unlink',
                      ),
                    ],
                  ),
                )),
            ],
          ),
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
        title: const Text('Link Parent to Student'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showCreateParentDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Create New Parent for This Student'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              if (availableParents.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text('Or link existing parent:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(height: 16),
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
                        trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF3498DB)),
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
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Password *',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (v) => (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phone1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number 1',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: phone2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number 2',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Creating parent...'), duration: Duration(seconds: 2)),
        );
      }

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

      await studentService.linkParentToStudent(parentId, widget.student.id, 'Parent');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Parent created and linked successfully'), backgroundColor: Color(0xFF2ECC71)),
        );
        setState(() {
          _profileDataFuture = _fetchProfileData();
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Color(0xFFE74C3C)),
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
          const SnackBar(content: Text('Parent linked successfully'), backgroundColor: Color(0xFF2ECC71)),
        );
        setState(() {
          _profileDataFuture = _fetchProfileData();
        });
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Color(0xFFE74C3C)),
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
            const SnackBar(content: Text('Parent unlinked successfully'), backgroundColor: Color(0xFF2ECC71)),
          );
          setState(() {
            _profileDataFuture = _fetchProfileData();
          });
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Color(0xFFE74C3C)),
          );
        }
      }
    }
  }
}
