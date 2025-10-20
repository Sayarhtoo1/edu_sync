import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/providers/admin_panel_provider.dart';
import 'package:edu_sync/models/timetable.dart' as timetable_model;
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/widgets/common/desktop_scaffold.dart';
import 'package:edu_sync/utils/logger.dart';

class DesktopWholeSchoolSchedule extends StatefulWidget {
  const DesktopWholeSchoolSchedule({super.key});

  @override
  State<DesktopWholeSchoolSchedule> createState() => _DesktopWholeSchoolScheduleState();
}

class _DesktopWholeSchoolScheduleState extends State<DesktopWholeSchoolSchedule> {
  String _selectedDay = 'Monday';
  String _viewMode = 'teacher'; // 'teacher' or 'class'
  final List<String> _daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduleData();
    });
  }

  Future<void> _loadScheduleData() async {
    final adminProvider = Provider.of<AdminPanelProvider>(context, listen: false);
    final schoolProvider = Provider.of<SchoolProvider>(context, listen: false);

    if (schoolProvider.currentSchool == null) {
      await schoolProvider.fetchCurrentSchool();
    }

    final int? schoolId = schoolProvider.currentSchool?.id;

    if (schoolId != null) {
      adminProvider.setCurrentSchoolId(schoolId);
      await adminProvider.fetchTimetableEntries();
      await adminProvider.fetchTeachers();
      await adminProvider.fetchSchoolClasses();
    } else {
      logger.e("Could not load school ID");
    }
  }

  List<String> _generateTimeSlots(List<timetable_model.Timetable> entries) {
    final Set<String> uniqueTimes = {};
    for (var entry in entries) {
      uniqueTimes.add(entry.startTimeString);
    }
    final List<String> sortedTimes = uniqueTimes.toList();
    sortedTimes.sort();
    return sortedTimes;
  }

  @override
  Widget build(BuildContext context) {
    return DesktopScaffold(
      title: 'Whole School Schedule',
      body: Consumer<AdminPanelProvider>(
        builder: (context, adminProvider, child) {
          if (adminProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<timetable_model.Timetable> timetableEntries = adminProvider.timetableEntries;
          final List<app_user.User> teachers = adminProvider.teachers;
          final List<app_class.SchoolClass> schoolClasses = adminProvider.schoolClasses;

          if (timetableEntries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No schedule data available', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                ],
              ),
            );
          }

          final List<String> timeSlots = _generateTimeSlots(timetableEntries);
          final Map<String, Map<String, Map<String, timetable_model.Timetable>>> scheduleByDay = {};
          
          for (var entry in timetableEntries) {
            scheduleByDay.putIfAbsent(entry.dayOfWeek, () => {});
            scheduleByDay[entry.dayOfWeek]!.putIfAbsent(entry.startTimeString, () => {});
            if (entry.teacherId != null) {
              scheduleByDay[entry.dayOfWeek]![entry.startTimeString]![entry.teacherId!] = entry;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(timetableEntries.length),
                const SizedBox(height: 24),
                _buildControls(),
                const SizedBox(height: 24),
                Expanded(
                  child: _viewMode == 'teacher'
                      ? _buildTeacherView(scheduleByDay, timeSlots, teachers, schoolClasses)
                      : _buildClassView(scheduleByDay, timeSlots, teachers, schoolClasses),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(int totalEntries) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF3498DB).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.calendar_view_week, color: Color(0xFF3498DB), size: 32),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Whole School Schedule', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('$totalEntries total entries', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(child: _buildDaySelector()),
        const SizedBox(width: 16),
        _buildViewModeToggle(),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: _daysOfWeek.map((day) {
          final isSelected = _selectedDay == day;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedDay = day),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF3498DB) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  day.substring(0, 3),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildViewModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewModeButton('teacher', Icons.person, 'By Teacher'),
          const SizedBox(width: 4),
          _buildViewModeButton('class', Icons.class_, 'By Class'),
        ],
      ),
    );
  }

  Widget _buildViewModeButton(String mode, IconData icon, String label) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () => setState(() => _viewMode = mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3498DB) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherView(
    Map<String, Map<String, Map<String, timetable_model.Timetable>>> scheduleByDay,
    List<String> timeSlots,
    List<app_user.User> teachers,
    List<app_class.SchoolClass> schoolClasses,
  ) {
    final daySchedule = scheduleByDay[_selectedDay] ?? {};
    if (daySchedule.isEmpty) {
      return _buildEmptyState('No classes scheduled for $_selectedDay');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 100, child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                ...teachers.map((teacher) => Expanded(
                  child: Text(
                    teacher.fullName ?? 'Teacher',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: timeSlots.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final time = timeSlots[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(time, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                      ...teachers.map((teacher) {
                        final entry = daySchedule[time]?[teacher.id];
                        return Expanded(
                          child: entry != null
                              ? _buildScheduleCard(entry, schoolClasses)
                              : const SizedBox(),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassView(
    Map<String, Map<String, Map<String, timetable_model.Timetable>>> scheduleByDay,
    List<String> timeSlots,
    List<app_user.User> teachers,
    List<app_class.SchoolClass> schoolClasses,
  ) {
    final daySchedule = scheduleByDay[_selectedDay] ?? {};
    if (daySchedule.isEmpty) {
      return _buildEmptyState('No classes scheduled for $_selectedDay');
    }

    final Map<String, Map<String, timetable_model.Timetable>> scheduleByClass = {};
    for (var timeSlot in daySchedule.entries) {
      for (var entry in timeSlot.value.values) {
        final classId = entry.classId.toString();
        scheduleByClass.putIfAbsent(classId, () => {});
        scheduleByClass[classId]![timeSlot.key] = entry;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 100, child: Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                ...schoolClasses.map((schoolClass) => Expanded(
                  child: Text(
                    schoolClass.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: timeSlots.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final time = timeSlots[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(time, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      ),
                      ...schoolClasses.map((schoolClass) {
                        final entry = scheduleByClass[schoolClass.id.toString()]?[time];
                        return Expanded(
                          child: entry != null
                              ? _buildScheduleCardWithTeacher(entry, teachers)
                              : const SizedBox(),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(timetable_model.Timetable entry, List<app_class.SchoolClass> schoolClasses) {
    final schoolClass = schoolClasses.firstWhere(
      (c) => c.id == entry.classId,
      orElse: () => app_class.SchoolClass(id: 0, name: 'Unknown', schoolId: 0),
    );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3498DB).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.subjectName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3498DB)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            schoolClass.name,
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.startTimeString} - ${entry.endTimeString}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCardWithTeacher(timetable_model.Timetable entry, List<app_user.User> teachers) {
    final teacher = teachers.firstWhere(
      (t) => t.id == entry.teacherId,
      orElse: () => app_user.User(id: '', role: '', fullName: 'Unknown'),
    );
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            entry.subjectName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF2ECC71)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            teacher.fullName ?? 'Unknown',
            style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.startTimeString} - ${entry.endTimeString}',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }
}
