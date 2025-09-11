import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/providers/admin_panel_provider.dart';
import 'package:edu_sync/l10n/app_localizations.dart'; // Corrected import path
import 'package:edu_sync/models/timetable.dart' as timetable_model;
import 'package:edu_sync/models/user.dart' as app_user;
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/providers/school_provider.dart';
import 'package:edu_sync/services/auth_service.dart';
import 'package:edu_sync/utils/logger.dart';

class WholeSchoolScheduleScreen extends StatefulWidget {
  const WholeSchoolScheduleScreen({super.key});

  @override
  State<WholeSchoolScheduleScreen> createState() => _WholeSchoolScheduleScreenState();
}

class _WholeSchoolScheduleScreenState extends State<WholeSchoolScheduleScreen> {
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = Provider.of<AuthService>(context, listen: false);
    _loadScheduleData();
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
      logger.e("Could not load school ID for WholeSchoolScheduleScreen.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).errorLoadingSchoolData)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.wholeSchoolScheduleTitle),
      ),
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
              child: Text(
                appLocalizations.noScheduleDataAvailable,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }

          final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
          final List<String> timeSlots = _generateTimeSlots(timetableEntries);

          // Group entries by day, then time, then teacher
          final Map<String, Map<String, Map<String, timetable_model.Timetable>>> scheduleByDay = {};
          for (var entry in timetableEntries) {
            scheduleByDay.putIfAbsent(entry.dayOfWeek, () => {});
            scheduleByDay[entry.dayOfWeek]!.putIfAbsent(entry.startTimeString, () => {});
            if (entry.teacherId != null) {
              scheduleByDay[entry.dayOfWeek]![entry.startTimeString]![entry.teacherId!] = entry;
            }
          }

          return DefaultTabController(
            length: daysOfWeek.length,
            child: Column(
              children: [
                TabBar(
                  isScrollable: true,
                  tabs: daysOfWeek.map((day) => Tab(text: day)).toList(),
                ),
                Expanded(
                  child: TabBarView(
                    children: daysOfWeek.map((day) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: [
                              DataColumn(label: Text(appLocalizations.timeLabel)),
                              ...teachers.map((teacher) => DataColumn(label: Text(teacher.fullName ?? ''))),
                            ],
                            rows: timeSlots.map((time) {
                              return DataRow(
                                cells: [
                                  DataCell(Text(time)),
                                  ...teachers.map((teacher) {
                                    final entry = scheduleByDay[day]?[time]?[teacher.id];
                                    if (entry != null) {
                                      final schoolClass = schoolClasses.firstWhere(
                                        (c) => c.id == entry.classId,
                                        orElse: () => app_class.SchoolClass(id: 0, name: appLocalizations.unknown_class, schoolId: 0),
                                      );
                                      return DataCell(
                                        Text('${entry.subjectName}\n(${schoolClass.name})'),
                                      );
                                    }
                                    return DataCell(Text(appLocalizations.noClass));
                                  }).toList(),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<String> _generateTimeSlots(List<timetable_model.Timetable> entries) {
    final Set<String> uniqueTimes = {};
    for (var entry in entries) {
      uniqueTimes.add(entry.startTimeString);
    }
    final List<String> sortedTimes = uniqueTimes.toList();
    sortedTimes.sort((a, b) {
      return a.compareTo(b);
    });
    return sortedTimes;
  }
}
