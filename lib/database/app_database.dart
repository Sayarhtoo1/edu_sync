import 'package:drift/drift.dart';

part 'app_database.g.dart';

class Schools extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get logoUrl => text().named('logo_url').nullable()();
  TextColumn get academicYear => text().named('academic_year').nullable()();
  TextColumn get theme => text().nullable()();
  TextColumn get contactInfo => text().named('contact_info').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  IntColumn get hijriDayAdjustment => integer().named('hijri_day_adjustment').nullable()();
}

class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get schoolId => integer().named('school_id')();
  IntColumn get classId => integer().named('class_id').nullable()();
  TextColumn get fullName => text().named('full_name')();
  TextColumn get profilePhotoUrl => text().named('profile_photo_url').nullable()();
  DateTimeColumn get dateOfBirth => dateTime().named('date_of_birth').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get phoneNumber1 => text().named('phone_number_1').nullable()();
  TextColumn get phoneNumber2 => text().named('phone_number_2').nullable()();
}

class Classes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get schoolId => integer().named('school_id')();
  TextColumn get name => text()();
  TextColumn get teacherId => text().named('teacher_id').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  TextColumn get section => text().nullable()();
}

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get fullName => text().named('full_name').nullable()();
  TextColumn get role => text()();
  TextColumn get profilePhotoUrl => text().named('profile_photo_url').nullable()();
  IntColumn get schoolId => integer().named('school_id').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phoneNumber1 => text().named('phone_number_1').nullable()();
  RealColumn get salary => real().nullable()();
  TextColumn get phoneNumber2 => text().named('phone_number_2').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Attendance extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().named('student_id')();
  IntColumn get classId => integer().named('class_id')();
  DateTimeColumn get date => dateTime()();
  TextColumn get markedByTeacherId => text().named('marked_by_teacher_id').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  TextColumn get status => text()();
}

class FinanceEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get schoolId => integer().named('school_id')();
  TextColumn get entryType => text().named('entry_type')();
  RealColumn get amount => real()();
  TextColumn get description => text()();
  TextColumn get category => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
}

class Timetables extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().named('class_id')();
  TextColumn get dayOfWeek => text().named('day_of_week')();
  TextColumn get startTime => text().named('start_time')();
  TextColumn get endTime => text().named('end_time')();
  TextColumn get subjectName => text().named('subject_name')();
  TextColumn get teacherId => text().named('teacher_id').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
}

class Announcements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get schoolId => integer().named('school_id')();
  TextColumn get title => text()();
  TextColumn get content => text()();
  TextColumn get createdByUserId => text().named('created_by_user_id').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').nullable()();
  TextColumn get targetRole => text().named('target_role').nullable()();
  IntColumn get targetClassId => integer().named('target_class_id').nullable()();
}

class Donations extends Table {
  TextColumn get id => text()();
  IntColumn get schoolId => integer().named('school_id')();
  TextColumn get donatorName => text().named('donator_name')();
  TextColumn get donatorEmail => text().named('donator_email').nullable()();
  TextColumn get donatorPhone => text().named('donator_phone').nullable()();
  RealColumn get amount => real()();
  DateTimeColumn get donationDate => dateTime().named('donation_date')();
  TextColumn get paymentMethod => text().named('payment_method')();
  TextColumn get purpose => text().nullable()();
  TextColumn get status => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at').nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Schools, Students, Classes, Users, Attendance, FinanceEntries, Timetables, Announcements, Donations])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 5;
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(users);
        await m.createTable(attendance);
      }
      if (from < 3) {
        await m.createTable(financeEntries);
      }
      if (from < 4) {
        await m.createTable(timetables);
        await m.createTable(announcements);
      }
      if (from < 5) {
        await m.createTable(donations);
      }
    },
  );
}
