import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:edu_sync/utils/logger.dart' as app_logger;

enum AttendanceStatus {
  notAtSchool,
  atSchoolReadyToClockIn,
  clockedIn,
  workDayComplete,
  loading,
  error,
}

class StaffAttendanceState {
  final AttendanceStatus status;
  final String message;
  final bool isLoading;
  final double? distanceToSchool;
  final DateTime? lastClockIn;
  final DateTime? lastClockOut;

  StaffAttendanceState({
    this.status = AttendanceStatus.loading,
    this.message = 'Loading attendance status...',
    this.isLoading = true,
    this.distanceToSchool,
    this.lastClockIn,
    this.lastClockOut,
  });

  StaffAttendanceState copyWith({
    AttendanceStatus? status,
    String? message,
    bool? isLoading,
    double? distanceToSchool,
    DateTime? lastClockIn,
    DateTime? lastClockOut,
  }) {
    return StaffAttendanceState(
      status: status ?? this.status,
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      distanceToSchool: distanceToSchool ?? this.distanceToSchool,
      lastClockIn: lastClockIn ?? this.lastClockIn,
      lastClockOut: lastClockOut ?? this.lastClockOut,
    );
  }
}

final staffAttendanceProvider = StateNotifierProvider<StaffAttendanceNotifier, StaffAttendanceState>((ref) {
  return StaffAttendanceNotifier();
});

class StaffAttendanceNotifier extends StateNotifier<StaffAttendanceState> {
  StaffAttendanceNotifier() : super(StaffAttendanceState()) {
    _initializeAttendance();
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  final double _geofenceBuffer = 50.0; // Additional buffer for geofence in meters

  double? _schoolLatitude;
  double? _schoolLongitude;
  double? _schoolRadius;

  Future<void> _initializeAttendance() async {
    state = state.copyWith(isLoading: true, message: 'Initializing attendance...');
    await _fetchSchoolGeofence();
    await _updateAttendanceStatus();
  }

  Future<void> _fetchSchoolGeofence() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(status: AttendanceStatus.error, message: 'User not logged in.', isLoading: false);
        return;
      }

      // Fetch the user's school_id from the 'users' table
      final userResponse = await _supabase
          .from('users')
          .select('school_id')
          .eq('id', userId)
          .single();

      final schoolIdString = userResponse['school_id']?.toString();
      if (schoolIdString == null) {
        state = state.copyWith(status: AttendanceStatus.error, message: 'User is not associated with a school.', isLoading: false);
        return;
      }
      final schoolId = int.tryParse(schoolIdString);
      if (schoolId == null) {
        state = state.copyWith(status: AttendanceStatus.error, message: 'Invalid School ID format for user.', isLoading: false);
        return;
      }

      final response = await _supabase
          .from('school_settings')
          .select('location_latitude, location_longitude, attendance_radius_meters')
          .eq('school_id', schoolId)
          .single();

      _schoolLatitude = response['location_latitude'];
      _schoolLongitude = response['location_longitude'];
      _schoolRadius = (response['attendance_radius_meters'] as num?)?.toDouble();

      if (_schoolLatitude == null || _schoolLongitude == null || _schoolRadius == null) {
        state = state.copyWith(
          status: AttendanceStatus.error,
          message: 'School geofence settings not configured.',
          isLoading: false,
        );
        app_logger.logger.e('School geofence settings are incomplete.');
      }
    } catch (e, stackTrace) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        message: 'Failed to fetch school geofence settings.',
        isLoading: false,
      );
      app_logger.logger.e('Error fetching school geofence: $e', stackTrace: stackTrace);
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        state = state.copyWith(
          status: AttendanceStatus.error,
          message: 'Location permissions are denied. Please enable them in settings.',
          isLoading: false,
        );
        return false;
      }
    }
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      return true;
    }
    return false;
  }

  Future<Position?> _getCurrentLocation() async {
    if (!await _checkLocationPermission()) {
      return null;
    }
    try {
      return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    } catch (e, stackTrace) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        message: 'Failed to get current location. Please ensure GPS is enabled.',
        isLoading: false,
      );
      app_logger.logger.e('Error getting current location: $e', stackTrace: stackTrace);
      return null;
    }
  }

  double? _calculateDistance(Position userLocation) {
    if (_schoolLatitude == null || _schoolLongitude == null) {
      return null;
    }
    return Geolocator.distanceBetween(
      _schoolLatitude!,
      _schoolLongitude!,
      userLocation.latitude,
      userLocation.longitude,
    );
  }

  Future<void> _updateAttendanceStatus() async {
    if (_schoolLatitude == null || _schoolLongitude == null || _schoolRadius == null) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        message: 'School geofence not set up.',
        isLoading: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true, message: 'Checking location...');
    final userLocation = await _getCurrentLocation();

    if (userLocation == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final distance = _calculateDistance(userLocation);
    if (distance == null) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        message: 'Could not calculate distance to school.',
        isLoading: false,
      );
      return;
    }

    final isInGeofence = distance <= (_schoolRadius! + _geofenceBuffer);

    state = state.copyWith(distanceToSchool: distance);

    // Fetch last attendance record for the current user
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          status: AttendanceStatus.error,
          message: 'User not logged in.',
          isLoading: false,
        );
        return;
      }

      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

      final attendanceRecords = await _supabase
          .from('staff_attendance')
          .select('check_in_timestamp, check_out_timestamp')
          .eq('staff_id', userId)
          .gte('check_in_timestamp', startOfDay.toIso8601String())
          .lte('check_in_timestamp', endOfDay.toIso8601String())
          .order('check_in_timestamp', ascending: false)
          .limit(1);

      DateTime? lastCheckIn;
      DateTime? lastCheckOut;

      if (attendanceRecords.isNotEmpty) {
        final record = attendanceRecords.first;
        if (record['check_in_timestamp'] != null) {
          lastCheckIn = DateTime.parse(record['check_in_timestamp']);
        }
        if (record['check_out_timestamp'] != null) {
          lastCheckOut = DateTime.parse(record['check_out_timestamp']);
        }
      }

      state = state.copyWith(lastClockIn: lastCheckIn, lastClockOut: lastCheckOut);

      if (lastCheckIn != null && lastCheckOut == null) {
        // User is clocked in
        state = state.copyWith(
          status: AttendanceStatus.clockedIn,
          message: 'Clocked In at ${lastCheckIn.toLocal().toIso8601String().substring(11, 16)}',
          isLoading: false,
        );
      } else if (lastCheckIn != null && lastCheckOut != null) {
        // User has clocked in and out for the day
        state = state.copyWith(
          status: AttendanceStatus.workDayComplete,
          message: 'Work Day Complete. Clocked In: ${lastCheckIn.toLocal().toIso8601String().substring(11, 16)}, Clocked Out: ${lastCheckOut.toLocal().toIso8601String().substring(11, 16)}',
          isLoading: false,
        );
      } else {
        // User is not clocked in
        if (isInGeofence) {
          state = state.copyWith(
            status: AttendanceStatus.atSchoolReadyToClockIn,
            message: 'You are at school. Ready to Clock In.',
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            status: AttendanceStatus.notAtSchool,
            message: 'You are not at school. Distance: ${distance.toStringAsFixed(2)}m',
            isLoading: false,
          );
        }
      }
    } catch (e, stackTrace) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        message: 'Failed to fetch attendance records.',
        isLoading: false,
      );
      app_logger.logger.e('Error fetching attendance records: $e', stackTrace: stackTrace);
    }
  }

  Future<void> markAttendance() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, message: 'Marking attendance...');

    if (_schoolLatitude == null || _schoolLongitude == null || _schoolRadius == null) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        message: 'School geofence not set up.',
        isLoading: false,
      );
      return;
    }

    final userLocation = await _getCurrentLocation();
    if (userLocation == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    final distance = _calculateDistance(userLocation);
    if (distance == null || distance > (_schoolRadius! + _geofenceBuffer)) {
      state = state.copyWith(
        status: AttendanceStatus.notAtSchool,
        message: 'You must be within the school premises to mark attendance. Distance: ${distance?.toStringAsFixed(2) ?? 'N/A'}m',
        isLoading: false,
      );
      return;
    }

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          status: AttendanceStatus.error,
          message: 'User not logged in.',
          isLoading: false,
        );
        return;
      }


      final schoolIdResponse = await _supabase
          .from('users')
          .select('school_id')
          .eq('id', userId)
          .single();

      final schoolIdString = schoolIdResponse['school_id']?.toString();
      if (schoolIdString == null) {
        state = state.copyWith(status: AttendanceStatus.error, message: 'School ID not found for user.', isLoading: false);
        return;
      }
      final schoolId = int.tryParse(schoolIdString);
      if (schoolId == null) {
        state = state.copyWith(status: AttendanceStatus.error, message: 'Invalid School ID format.', isLoading: false);
        return;
      }

      app_logger.logger.i('Marking attendance with staff_id: $userId (type: ${userId.runtimeType}) and school_id: $schoolId (type: ${schoolId.runtimeType})');

      final isCheckIn = state.status == AttendanceStatus.atSchoolReadyToClockIn;

      await _supabase.rpc(
        'upsert_attendance_record',
        params: {
          'p_is_check_in': isCheckIn,
          'p_staff_id': userId.toString(),
          'p_school_id': schoolId,
          'p_latitude': userLocation.latitude,
          'p_longitude': userLocation.longitude,
        },
      );

      // Since the RPC function returns void, no exception indicates success.
      state = state.copyWith(
        message: 'Attendance Marked Successfully!',
        isLoading: false,
      );
      await _updateAttendanceStatus(); // Refresh status after marking attendance
    } catch (e, stackTrace) {
      state = state.copyWith(
        status: AttendanceStatus.error,
        message: 'An error occurred while marking attendance.',
        isLoading: false,
      );
      app_logger.logger.e('Error marking attendance: $e', stackTrace: stackTrace);
    }
  }
}
