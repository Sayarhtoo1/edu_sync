import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/student.dart' as model;
import '../models/user.dart' as model;
import '../models/attendance.dart' as model;
import '../models/school_class.dart' as model;
import '../models/school.dart' as model;
import '../models/timetable.dart' as model;
import '../models/announcement.dart' as model;
import '../models/donation.dart' as model;
import '../utils/logger.dart';

class CacheService {
  final AppDatabase _db;
  
  CacheService(this._db);
  
  // Students
  Future<void> cacheStudents(List<model.Student> students) async {
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.students,
          students.map((s) => StudentsCompanion.insert(
            id: Value(s.id),
            schoolId: s.schoolId,
            classId: Value(s.classId),
            fullName: s.fullName,
            dateOfBirth: Value(s.dateOfBirth),
            gender: Value(s.gender),
            profilePhotoUrl: Value(s.profilePhotoUrl),
            phoneNumber1: Value(s.phoneNumber1),
            phoneNumber2: Value(s.phoneNumber2),
          )),
        );
      });
    } catch (e) {
      logger.e('Error caching students: $e');
    }
  }
  
  Future<List<model.Student>> getCachedStudents(int schoolId) async {
    try {
      final rows = await (_db.select(_db.students)
        ..where((s) => s.schoolId.equals(schoolId))).get();
      
      return rows.map((row) => model.Student(
        id: row.id,
        schoolId: row.schoolId,
        classId: row.classId,
        fullName: row.fullName,
        dateOfBirth: row.dateOfBirth,
        gender: row.gender,
        profilePhotoUrl: row.profilePhotoUrl,
        phoneNumber1: row.phoneNumber1,
        phoneNumber2: row.phoneNumber2,
      )).toList();
    } catch (e) {
      logger.e('Error getting cached students: $e');
      return [];
    }
  }
  
  Future<List<model.Student>> getCachedStudentsByClass(int classId) async {
    try {
      final rows = await (_db.select(_db.students)
        ..where((s) => s.classId.equals(classId))).get();
      
      return rows.map((row) => model.Student(
        id: row.id,
        schoolId: row.schoolId,
        classId: row.classId,
        fullName: row.fullName,
        dateOfBirth: row.dateOfBirth,
        gender: row.gender,
        profilePhotoUrl: row.profilePhotoUrl,
        phoneNumber1: row.phoneNumber1,
        phoneNumber2: row.phoneNumber2,
      )).toList();
    } catch (e) {
      logger.e('Error getting cached students by class: $e');
      return [];
    }
  }
  
  // Users
  Future<void> cacheUsers(List<model.User> users) async {
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.users,
          users.map((u) => UsersCompanion.insert(
            id: u.id,
            fullName: Value(u.fullName),
            role: u.role,
            schoolId: Value(u.schoolId),
            email: Value(u.email),
            profilePhotoUrl: Value(u.profilePhotoUrl),
            phoneNumber1: Value(u.phoneNumber1),
            phoneNumber2: Value(u.phoneNumber2),
            salary: Value(u.salary),
          )),
        );
      });
    } catch (e) {
      logger.e('Error caching users: $e');
    }
  }
  
  Future<List<model.User>> getCachedUsers(int schoolId) async {
    try {
      final rows = await (_db.select(_db.users)
        ..where((u) => u.schoolId.equals(schoolId))).get();
      
      return rows.map((row) => model.User(
        id: row.id,
        fullName: row.fullName,
        role: row.role,
        schoolId: row.schoolId,
        email: row.email,
        profilePhotoUrl: row.profilePhotoUrl,
        phoneNumber1: row.phoneNumber1,
        phoneNumber2: row.phoneNumber2,
        salary: row.salary,
      )).toList();
    } catch (e) {
      logger.e('Error getting cached users: $e');
      return [];
    }
  }
  
  Future<List<model.User>> getCachedUsersByRole(String role) async {
    try {
      final rows = await (_db.select(_db.users)
        ..where((u) => u.role.equals(role))).get();
      
      return rows.map((row) => model.User(
        id: row.id,
        fullName: row.fullName,
        role: row.role,
        schoolId: row.schoolId,
        email: row.email,
        profilePhotoUrl: row.profilePhotoUrl,
        phoneNumber1: row.phoneNumber1,
        phoneNumber2: row.phoneNumber2,
        salary: row.salary,
      )).toList();
    } catch (e) {
      logger.e('Error getting cached users by role: $e');
      return [];
    }
  }
  
  // Attendance
  Future<void> cacheAttendance(List<model.Attendance> records) async{
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.attendance,
          records.map((a) => AttendanceCompanion.insert(
            id: a.id != null ? Value(a.id!) : const Value.absent(),
            studentId: a.studentId,
            classId: a.classId,
            date: a.date,
            status: a.status,
            markedByTeacherId: Value(a.markedByTeacherId),
          )),
        );
      });
    } catch (e) {
      logger.e('Error caching attendance: $e');
    }
  }
  
  Future<List<model.Attendance>> getCachedAttendance(int classId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final rows = await (_db.select(_db.attendance)
        ..where((a) => 
          a.classId.equals(classId) & 
          a.date.isBiggerOrEqualValue(startOfDay) &
          a.date.isSmallerOrEqualValue(endOfDay)
        )).get();
      
      return rows.map((row) => model.Attendance(
        id: row.id,
        studentId: row.studentId,
        classId: row.classId,
        date: row.date,
        status: row.status,
        markedByTeacherId: row.markedByTeacherId,
      )).toList();
    } catch (e) {
      logger.e('Error getting cached attendance: $e');
      return [];
    }
  }
  
  Future<List<model.Attendance>> getCachedAttendanceForStudent(int studentId) async {
    try {
      final rows = await (_db.select(_db.attendance)
        ..where((a) => a.studentId.equals(studentId))
        ..orderBy([(a) => OrderingTerm.desc(a.date)])).get();
      
      return rows.map((row) => model.Attendance(
        id: row.id,
        studentId: row.studentId,
        classId: row.classId,
        date: row.date,
        status: row.status,
        markedByTeacherId: row.markedByTeacherId,
      )).toList();
    } catch (e) {
      logger.e('Error getting cached attendance for student: $e');
      return [];
    }
  }
  
  // Clear cache
  Future<void> clearStudentsCache() async {
    try {
      await _db.delete(_db.students).go();
    } catch (e) {
      logger.e('Error clearing students cache: $e');
    }
  }
  
  Future<void> clearUsersCache() async {
    try {
      await _db.delete(_db.users).go();
    } catch (e) {
      logger.e('Error clearing users cache: $e');
    }
  }
  
  Future<void> clearAttendanceCache() async {
    try {
      await _db.delete(_db.attendance).go();
    } catch (e) {
      logger.e('Error clearing attendance cache: $e');
    }
  }
  
  Future<void> clearAllCache() async {
    await clearStudentsCache();
    await clearUsersCache();
    await clearAttendanceCache();
  }
  
  // Finance Entries
  Future<void> cacheFinanceEntries(List<Map<String, dynamic>> entries) async {
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.financeEntries,
          entries.map((e) => FinanceEntriesCompanion.insert(
            id: Value(e['id'] as int),
            schoolId: e['school_id'] as int,
            entryType: e['entry_type'] as String,
            amount: (e['amount'] as num).toDouble(),
            description: e['description'] as String,
            category: Value(e['category'] as String?),
            date: DateTime.parse(e['date'] as String),
            createdAt: Value(e['created_at'] != null ? DateTime.parse(e['created_at'] as String) : null),
          )),
        );
      });
    } catch (e) {
      logger.e('Error caching finance entries: $e');
    }
  }
  
  Future<List<Map<String, dynamic>>> getCachedFinanceEntries(int schoolId, String entryType) async {
    try {
      final rows = await (_db.select(_db.financeEntries)
        ..where((f) => f.schoolId.equals(schoolId) & f.entryType.equals(entryType))
        ..orderBy([(f) => OrderingTerm.desc(f.createdAt)])).get();
      
      return rows.map((row) => {
        'id': row.id,
        'school_id': row.schoolId,
        'entry_type': row.entryType,
        'amount': row.amount,
        'description': row.description,
        'category': row.category,
        'date': row.date.toIso8601String(),
        'created_at': row.createdAt?.toIso8601String(),
      }).toList();
    } catch (e) {
      logger.e('Error getting cached finance entries: $e');
      return [];
    }
  }
  

  
  // Classes
  Future<void> cacheClasses(List<model.SchoolClass> classes) async {
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.classes,
          classes.map((c) => ClassesCompanion.insert(
            id: Value(c.id ?? 0),
            schoolId: c.schoolId,
            name: c.name,
            teacherId: Value(c.teacherId),
            section: Value(c.section),
          )),
        );
      });
    } catch (e) {
      logger.e('Error caching classes: $e');
    }
  }
  
  Future<List<model.SchoolClass>> getCachedClasses(int schoolId) async {
    try {
      final rows = await (_db.select(_db.classes)
        ..where((c) => c.schoolId.equals(schoolId))).get();
      
      return rows.map((row) => model.SchoolClass(
        id: row.id,
        schoolId: row.schoolId,
        name: row.name,
        teacherId: row.teacherId,
        section: row.section,
      )).toList();
    } catch (e) {
      logger.e('Error getting cached classes: $e');
      return [];
    }
  }
  
  Future<model.SchoolClass?> getCachedClassById(int id) async {
    try {
      final row = await (_db.select(_db.classes)
        ..where((c) => c.id.equals(id))).getSingleOrNull();
      
      if (row == null) return null;
      
      return model.SchoolClass(
        id: row.id,
        schoolId: row.schoolId,
        name: row.name,
        teacherId: row.teacherId,
        section: row.section,
      );
    } catch (e) {
      logger.e('Error getting cached class by id: $e');
      return null;
    }
  }
  
  // Schools
  Future<void> cacheSchool(model.School school) async {
    try {
      await _db.into(_db.schools).insertOnConflictUpdate(
        SchoolsCompanion.insert(
          id: Value(school.id),
          name: school.name,
          logoUrl: Value(school.logoUrl),
          academicYear: Value(school.academicYear),
          theme: Value(school.theme),
          contactInfo: Value(school.contact),
          hijriDayAdjustment: Value(school.hijriDayAdjustment ?? 0),
        ),
      );
    } catch (e) {
      logger.e('Error caching school: $e');
    }
  }
  
  Future<model.School?> getCachedSchool(int schoolId) async {
    try {
      final row = await (_db.select(_db.schools)
        ..where((s) => s.id.equals(schoolId))).getSingleOrNull();
      
      if (row == null) return null;
      
      return model.School(
        id: row.id,
        name: row.name,
        logoUrl: row.logoUrl ?? '',
        academicYear: row.academicYear ?? '',
        theme: row.theme ?? '',
        contact: row.contactInfo ?? '',
        hijriDayAdjustment: row.hijriDayAdjustment ?? 0,
      );
    } catch (e) {
      logger.e('Error getting cached school: $e');
      return null;
    }
  }
  
  // Timetables
  Future<void> cacheTimetables(List<model.Timetable> timetables) async {
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.timetables,
          timetables.map((t) => TimetablesCompanion.insert(
            id: Value(t.id),
            classId: t.classId,
            dayOfWeek: t.dayOfWeek,
            startTime: t.startTimeString,
            endTime: t.endTimeString,
            subjectName: t.subjectName,
            teacherId: Value(t.teacherId),
          )),
        );
      });
    } catch (e) {
      logger.e('Error caching timetables: $e');
    }
  }
  
  Future<List<model.Timetable>> getCachedTimetables(int classId) async {
    try {
      final rows = await (_db.select(_db.timetables)
        ..where((t) => t.classId.equals(classId))).get();
      
      return rows.map((row) => model.Timetable.fromMap({
        'id': row.id,
        'class_id': row.classId,
        'class_name': '',
        'day_of_week': row.dayOfWeek,
        'start_time': row.startTime,
        'end_time': row.endTime,
        'subject_name': row.subjectName,
        'teacher_id': row.teacherId,
      })).toList();
    } catch (e) {
      logger.e('Error getting cached timetables: $e');
      return [];
    }
  }
  
  Future<List<model.Timetable>> getCachedTimetablesByTeacher(String teacherId) async {
    try {
      final rows = await (_db.select(_db.timetables)
        ..where((t) => t.teacherId.equals(teacherId))).get();
      
      return rows.map((row) => model.Timetable.fromMap({
        'id': row.id,
        'class_id': row.classId,
        'class_name': '',
        'day_of_week': row.dayOfWeek,
        'start_time': row.startTime,
        'end_time': row.endTime,
        'subject_name': row.subjectName,
        'teacher_id': row.teacherId,
      })).toList();
    } catch (e) {
      logger.e('Error getting cached timetables by teacher: $e');
      return [];
    }
  }
  
  // Announcements
  Future<void> cacheAnnouncements(List<model.Announcement> announcements) async {
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.announcements,
          announcements.map((a) => AnnouncementsCompanion.insert(
            id: Value(a.id),
            schoolId: a.schoolId,
            title: a.title,
            content: a.content,
            createdByUserId: Value(a.createdByUserId),
            createdAt: Value(a.createdAt),
            updatedAt: Value(a.updatedAt),
            targetRole: Value(a.targetRole),
            targetClassId: Value(a.targetClassId),
          )),
        );
      });
    } catch (e) {
      logger.e('Error caching announcements: $e');
    }
  }
  
  Future<List<model.Announcement>> getCachedAnnouncements(int schoolId) async {
    try {
      final rows = await (_db.select(_db.announcements)
        ..where((a) => a.schoolId.equals(schoolId))
        ..orderBy([(a) => OrderingTerm.desc(a.createdAt)])).get();
      
      return rows.map((row) => model.Announcement(
        id: row.id,
        schoolId: row.schoolId,
        title: row.title,
        content: row.content,
        createdByUserId: row.createdByUserId,
        targetRole: row.targetRole,
        targetClassId: row.targetClassId,
        createdAt: row.createdAt ?? DateTime.now(),
        updatedAt: row.updatedAt ?? DateTime.now(),
      )).toList();
    } catch (e) {
      logger.e('Error getting cached announcements: $e');
      return [];
    }
  }
  
  // Donations
  Future<void> cacheDonations(List<model.Donation> donations) async {
    try {
      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(
          _db.donations,
          donations.map((d) => DonationsCompanion.insert(
            id: d.id,
            schoolId: d.schoolId,
            donatorName: d.donatorName,
            donatorEmail: Value(d.donatorEmail),
            donatorPhone: Value(d.donatorPhone),
            amount: d.amount,
            donationDate: d.donationDate,
            paymentMethod: d.paymentMethod,
            purpose: Value(d.purpose),
            status: d.status,
            createdAt: Value(d.createdAt),
          )),
        );
      });
    } catch (e) {
      logger.e('Error caching donations: $e');
    }
  }
  
  Future<List<model.Donation>> getCachedDonations(int schoolId) async {
    try {
      final rows = await (_db.select(_db.donations)
        ..where((d) => d.schoolId.equals(schoolId))
        ..orderBy([(d) => OrderingTerm.desc(d.donationDate)])).get();
      
      return rows.map((row) => model.Donation(
        id: row.id,
        schoolId: row.schoolId,
        donatorName: row.donatorName,
        donatorEmail: row.donatorEmail,
        donatorPhone: row.donatorPhone,
        amount: row.amount,
        donationDate: row.donationDate,
        paymentMethod: row.paymentMethod,
        purpose: row.purpose,
        status: row.status,
        createdAt: row.createdAt ?? DateTime.now(),
        updatedAt: row.createdAt ?? DateTime.now(),
      )).toList();
    } catch (e) {
      logger.e('Error getting cached donations: $e');
      return [];
    }
  }
}
