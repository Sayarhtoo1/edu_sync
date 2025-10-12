import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/attendance_report.dart';
import '../models/attendance.dart' as app_attendance;

class AttendanceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<app_attendance.Attendance>> getAttendanceForClassByDate(int classId, DateTime date) async {
    final response = await _supabase
        .from('attendance')
        .select('id, class_id, student_id, date, status, marked_by_teacher_id, updated_at')
        .eq('class_id', classId)
        .eq('date', DateFormat('yyyy-MM-dd').format(date));

    final List<dynamic> data = response;
    return data.map((item) => app_attendance.Attendance.fromMap(item)).toList();
  }

  Future<bool> saveAttendanceBatch(List<app_attendance.Attendance> attendanceBatch) async {
    final List<Map<String, dynamic>> recordsToInsert = [];
    final List<Map<String, dynamic>> recordsToUpdate = [];

    for (var attendance in attendanceBatch) {
      if (attendance.id == null) {
        recordsToInsert.add(attendance.toMap());
      } else {
        recordsToUpdate.add(attendance.toMapWithId());
      }
    }

    if (recordsToInsert.isNotEmpty) {
      await _supabase.from('attendance').insert(recordsToInsert);
    }

    if (recordsToUpdate.isNotEmpty) {
      for (var record in recordsToUpdate) {
        await _supabase.from('attendance').update(record).eq('id', record['id']);
      }
    }

    return true;
  }

  Future<List<app_attendance.Attendance>> getAttendanceForStudent(int studentId) async {
    final response = await _supabase
        .from('attendance')
        .select()
        .eq('student_id', studentId)
        .order('date', ascending: false);

    final List<dynamic> data = response;
    return data.map((item) => app_attendance.Attendance.fromMap(item)).toList();
  }

  /// Fetches attendance data for all students in a school for a given date range.
  ///
  /// This method is intended for Admin users.
  Future<List<AttendanceReport>> getAttendanceForAdmin(int schoolId, DateTime startDate, DateTime endDate, {int? classId, List<int>? studentIds}) async {
    var query = _supabase
        .from('attendance')
        .select('date, status, students!inner(full_name, class_id, school_id, classes!inner(name))')
        .eq('students.school_id', schoolId)
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String());

    if (classId != null) {
      query = query.eq('students.class_id', classId);
    }
    if (studentIds != null && studentIds.isNotEmpty) {
      query = query.filter('student_id', 'in', '(${studentIds.join(',')})');
    }

    final response = await query.order('date', ascending: false);

    final List<dynamic> data = response;
    return data.map((item) {
      return AttendanceReport(
        studentName: item['students']['full_name'] ?? 'N/A',
        date: DateTime.parse(item['date']),
        status: item['status'] ?? 'N/A',
        className: item['students']['classes']['name'] ?? 'N/A',
      );
    }).toList();
  }

  /// Fetches attendance data for all students in a teacher's classes for a given date range.
  ///
  /// This method is intended for Teacher users.
  Future<List<AttendanceReport>> getAttendanceForTeacher(String teacherId, DateTime startDate, DateTime endDate, {int? classId, List<int>? studentIds}) async {
    var query = _supabase
        .from('attendance')
        .select('date, status, students!inner(full_name, classes!inner(name, teacher_id))')
        .eq('students.classes.teacher_id', teacherId)
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String());

    if (classId != null) {
      query = query.eq('students.class_id', classId);
    }
    if (studentIds != null && studentIds.isNotEmpty) {
      query = query.filter('student_id', 'in', '(${studentIds.join(',')})');
    }

    final response = await query.order('date', ascending: false);

    final List<dynamic> data = response;
    return data.map((item) {
      return AttendanceReport(
        studentName: item['students']['full_name'] ?? 'N/A',
        date: DateTime.parse(item['date']),
        status: item['status'] ?? 'N/A',
        className: item['students']['classes']['name'] ?? 'N/A',
      );
    }).toList();
  }

  /// Fetches attendance data for a parent's children for a given date range.
  ///
  /// This method is intended for Parent users.
  Future<List<AttendanceReport>> getAttendanceForParent(String parentId, DateTime startDate, DateTime endDate) async {
    final response = await _supabase
        .from('attendance')
        .select('date, status, students!inner(full_name, classes!inner(name), parent_student_relations!inner(parent_id))')
        .eq('students.parent_student_relations.parent_id', parentId)
        .gte('date', startDate.toIso8601String())
        .lte('date', endDate.toIso8601String())
        .order('date', ascending: false);

    final List<dynamic> data = response;
    return data.map((item) {
      return AttendanceReport(
        studentName: item['students']['full_name'] ?? 'N/A',
        date: DateTime.parse(item['date']),
        status: item['status'] ?? 'N/A',
        className: item['students']['classes']['name'] ?? 'N/A',
      );
    }).toList();
  }

  /// Fetches staff attendance summary for a school within a date range
  Future<List<Map<String, dynamic>>> getStaffAttendanceSummary({
    required int schoolId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from('staff_attendance')
          .select('staff_id, clock_in_time, clock_out_time, date, staff!inner(full_name, role, school_id)')
          .eq('staff.school_id', schoolId)
          .gte('date', DateFormat('yyyy-MM-dd').format(startDate))
          .lte('date', DateFormat('yyyy-MM-dd').format(endDate))
          .order('date', ascending: false);

      final List<dynamic> data = response;
      
      // Group by staff
      final Map<String, Map<String, dynamic>> staffMap = {};
      
      for (var record in data) {
        final staffId = record['staff_id']?.toString() ?? '';
        if (!staffMap.containsKey(staffId)) {
          staffMap[staffId] = {
            'staff_id': staffId,
            'full_name': record['staff']?['full_name'] ?? 'Unknown',
            'role': record['staff']?['role'] ?? 'Staff',
            'present_days': 0,
            'absent_days': 0,
            'late_days': 0,
          };
        }
        
        if (record['clock_in_time'] != null) {
          staffMap[staffId]!['present_days'] = (staffMap[staffId]!['present_days'] as int) + 1;
          
          // Check if late (after 9 AM)
          final clockIn = DateTime.parse(record['clock_in_time']);
          final lateTime = DateTime(clockIn.year, clockIn.month, clockIn.day, 9, 0);
          if (clockIn.isAfter(lateTime)) {
            staffMap[staffId]!['late_days'] = (staffMap[staffId]!['late_days'] as int) + 1;
          }
        }
      }
      
      return staffMap.values.toList();
    } catch (e) {
      // If the query fails, return empty list
      return [];
    }
  }
}
