import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:edu_sync/providers/staff_attendance_provider.dart';

class StaffAttendanceScreen extends ConsumerStatefulWidget {
  static const route = '/staff_attendance';
  const StaffAttendanceScreen({super.key});

  @override
  ConsumerState<StaffAttendanceScreen> createState() => _StaffAttendanceScreenState();
}

class _StaffAttendanceScreenState extends ConsumerState<StaffAttendanceScreen> {
  @override
  void initState() {
    super.initState();
    // Optionally refresh attendance status when the screen is initialized
    // ref.read(staffAttendanceProvider.notifier)._initializeAttendance();
  }

  String _getButtonText(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.atSchoolReadyToClockIn:
        return 'Clock In';
      case AttendanceStatus.clockedIn:
        return 'Clock Out';
      case AttendanceStatus.workDayComplete:
        return 'Work Day Complete';
      case AttendanceStatus.notAtSchool:
        return 'Not at School';
      case AttendanceStatus.loading:
        return 'Loading...';
      case AttendanceStatus.error:
        return 'Error';
    }
  }

  bool _isButtonEnabled(AttendanceStatus status, bool isLoading) {
    if (isLoading) return false;
    return status == AttendanceStatus.atSchoolReadyToClockIn ||
           status == AttendanceStatus.clockedIn;
  }

  Color _getButtonColor(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.atSchoolReadyToClockIn:
        return Colors.green;
      case AttendanceStatus.clockedIn:
        return Colors.red;
      case AttendanceStatus.workDayComplete:
        return Colors.grey;
      case AttendanceStatus.notAtSchool:
        return Colors.orange;
      case AttendanceStatus.loading:
        return Colors.blueGrey;
      case AttendanceStatus.error:
        return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final attendanceState = ref.watch(staffAttendanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Attendance'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      attendanceState.message,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: attendanceState.status == AttendanceStatus.error
                                ? Colors.red
                                : null,
                          ),
                    ),
                    if (attendanceState.isLoading)
                      const Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: CircularProgressIndicator(),
                      ),
                    if (attendanceState.distanceToSchool != null &&
                        attendanceState.status == AttendanceStatus.notAtSchool)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Distance to school: ${attendanceState.distanceToSchool!.toStringAsFixed(2)} meters',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isButtonEnabled(attendanceState.status, attendanceState.isLoading)
                  ? () => ref.read(staffAttendanceProvider.notifier).markAttendance()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getButtonColor(attendanceState.status),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                _getButtonText(attendanceState.status),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            if (attendanceState.lastClockIn != null)
              Text(
                'Last Clock In: ${attendanceState.lastClockIn!.toLocal().toIso8601String().substring(0, 10)} ${attendanceState.lastClockIn!.toLocal().toIso8601String().substring(11, 16)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            if (attendanceState.lastClockOut != null)
              Text(
                'Last Clock Out: ${attendanceState.lastClockOut!.toLocal().toIso8601String().substring(0, 10)} ${attendanceState.lastClockOut!.toLocal().toIso8601String().substring(11, 16)}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}