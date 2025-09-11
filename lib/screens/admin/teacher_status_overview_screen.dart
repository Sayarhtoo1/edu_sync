import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:edu_sync/l10n/app_localizations.dart';
import 'package:edu_sync/models/timetable.dart' as timetable_model;
import 'package:edu_sync/utils/timetable_status_helper.dart';
import 'package:edu_sync/screens/admin/admin_panel_constants.dart';
import 'package:edu_sync/screens/admin/admin_panel_state.dart';
import 'package:edu_sync/screens/admin/whole_school_schedule_screen.dart'; // Import the new screen

class TeacherStatusOverviewScreen extends StatefulWidget {
  const TeacherStatusOverviewScreen({super.key});

  @override
  State<TeacherStatusOverviewScreen> createState() => _TeacherStatusOverviewScreenState();
}

class _TeacherStatusOverviewScreenState extends State<TeacherStatusOverviewScreen> with AdminPanelStateMixin<TeacherStatusOverviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    initializeServices(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadDashboardData(context); // This will load allTeachers and teacherTimetables
      startScheduleTimer();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    cancelScheduleTimer();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;

    final filteredTeachers = allTeachers.where((teacher) {
      final fullName = teacher.fullName?.toLowerCase() ?? '';
      return fullName.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: appBackgroundColor,
      appBar: AppBar(
        backgroundColor: appBackgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: textDarkGrey),
        title: Text(
          l10n.teacherStatusOverviewTitle,
          style: textTheme.titleLarge?.copyWith(color: textDarkGrey, fontWeight: FontWeight.w600),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(iconColorStudents)))
          : RefreshIndicator(
              onRefresh: () => loadDashboardData(context),
              color: iconColorStudents,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: l10n.searchTeacherHint,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WholeSchoolScheduleScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50), // Make button full width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.viewWholeSchoolScheduleButton),
                    ),
                  ),
                  Expanded(
                    child: filteredTeachers.isEmpty && _searchQuery.isEmpty
                        ? Center(child: Text(l10n.noTeachersFoundText, style: textTheme.bodyMedium))
                        : filteredTeachers.isEmpty && _searchQuery.isNotEmpty
                            ? Center(child: Text(l10n.noTeachersMatchingSearch, style: textTheme.bodyMedium))
                            : ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                itemCount: filteredTeachers.length,
                                separatorBuilder: (context, index) => const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final teacher = filteredTeachers[index];
                                  final teacherSpecificTimetables = teacherTimetables[teacher.id] ?? [];
                                  final now = DateTime.now();

                                  timetable_model.Timetable? currentEntry;
                                  TimetableStatus overallStatus = TimetableStatus.done;

                                  final todayEntries = teacherSpecificTimetables
                                      .where((entry) => TimetableStatusHelper.convertDayOfWeekStringToInt(entry.dayOfWeek) == now.weekday)
                                      .toList();
                                  todayEntries.sort((a, b) => a.startTimeString.compareTo(b.startTimeString));

                                  for (var entry in todayEntries) {
                                    final status = TimetableStatusHelper.getStatusForTimetableEntry(entry, now);
                                    if (status == TimetableStatus.inProcess) {
                                      currentEntry = entry;
                                      overallStatus = TimetableStatus.inProcess;
                                      break;
                                    }
                                  }

                                  if (currentEntry == null && todayEntries.isNotEmpty) {
                                    overallStatus = TimetableStatus.done;
                                  } else if (currentEntry == null && todayEntries.isEmpty) {
                                    overallStatus = TimetableStatus.done;
                                  }

                                  String statusText;
                                  Color statusColor;
                                  String detailsText = '';
                                  timetable_model.Timetable? nextUpcomingEntry;

                                  if (overallStatus == TimetableStatus.inProcess) {
                                    statusText = l10n.teachingNowStatus;
                                    statusColor = Colors.green;
                                    if (currentEntry != null) {
                                      final className = classMap[currentEntry.classId]?.name ?? l10n.not_specified;
                                      detailsText = '${l10n.classLabel}: $className, ${l10n.subjectLabel}: ${currentEntry.subjectName}';
                                    }
                                  } else {
                                    statusText = l10n.freeStatus;
                                    statusColor = Colors.grey;

                                    // Find the next upcoming class for today
                                    final nowTime = TimeOfDay.fromDateTime(now);
                                    final upcomingEntries = todayEntries.where((entry) {
                                      final entryStartTime = TimeOfDay(hour: int.parse(entry.startTimeString.split(':')[0]), minute: int.parse(entry.startTimeString.split(':')[1]));
                                      return TimetableStatusHelper.isTimeAfter(entryStartTime, nowTime);
                                    }).toList();

                                    if (upcomingEntries.isNotEmpty) {
                                      nextUpcomingEntry = upcomingEntries.first;
                                      final className = classMap[nextUpcomingEntry.classId]?.name ?? l10n.not_specified;
                                      detailsText = '${l10n.nextLabel}: $className, ${l10n.subjectLabel}: ${nextUpcomingEntry.subjectName} at ${nextUpcomingEntry.startTimeString}';
                                    } else {
                                      detailsText = l10n.noScheduledClassesToday;
                                    }
                                  }

                                  return Card(
                                    margin: EdgeInsets.zero,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage: teacher.profilePhotoUrl != null && teacher.profilePhotoUrl!.isNotEmpty
                                                ? NetworkImage(teacher.profilePhotoUrl!)
                                                : null,
                                            child: (teacher.profilePhotoUrl == null || teacher.profilePhotoUrl!.isEmpty)
                                                ? const Icon(Icons.person, size: 30)
                                                : null,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  teacher.fullName ?? l10n.unknownTeacher,
                                                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      overallStatus == TimetableStatus.inProcess ? Icons.play_circle_fill : Icons.check_circle_outline,
                                                      color: statusColor,
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      statusText,
                                                      style: textTheme.bodyLarge?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                if (detailsText.isNotEmpty) ...[
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    detailsText,
                                                    style: textTheme.bodyMedium,
                                                    maxLines: 2,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                  ),
                ],
              ),
            ),
    );
  }
}
