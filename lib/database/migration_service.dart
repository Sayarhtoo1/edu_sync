import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import 'app_database.dart' as db;
import '../models/school.dart';
import '../models/student.dart';
import '../utils/logger.dart';

class MigrationService {
  final db.AppDatabase _appDatabase;

  static const String _migrationCompletedKey = 'migration_completed';
  static const String schoolKeyPrefix = 'school_';
  static const String studentsKeyPrefix = 'students_';
  static const String studentByIdKeyPrefix = 'student_';
  static const String studentsForParentKeyPrefix = 'students_parent_';

  MigrationService(this._appDatabase);

  Future<void> migrateData() async {
    final prefs = await SharedPreferences.getInstance();
    final migrationCompleted = prefs.getBool(_migrationCompletedKey) ?? false;

    if (migrationCompleted) {
      logger.i('Data migration already completed. Skipping.');
      return;
    }

    logger.i('Starting data migration from SharedPreferences to Drift database...');

    // Migrate School data
      final String? schoolJsonString = prefs.getString('${schoolKeyPrefix}1');
      if (schoolJsonString != null) {
        final school = School.fromJson(json.decode(schoolJsonString));
        await _appDatabase.into(_appDatabase.schools).insert(db.SchoolsCompanion(
          id: Value(school.id),
          name: Value(school.name),
          contactInfo: Value(school.contact),
          updatedAt: Value(DateTime.now()),
        ), mode: InsertMode.insertOrReplace);
        logger.d('Migrated School data for ID: ${school.id}');
      }


    // Migrate Student data
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(studentsKeyPrefix) || key.startsWith(studentByIdKeyPrefix) || key.startsWith(studentsForParentKeyPrefix)) {
        final studentJsonString = prefs.getString(key);
        if (studentJsonString == null) continue; // Skip if string is null
        try {
          final dynamic decodedJson = json.decode(studentJsonString);
            if (decodedJson is List) {
              for (final studentMap in decodedJson) {
                final student = Student.fromMap(studentMap as Map<String, dynamic>);
                await _appDatabase.into(_appDatabase.students).insert(db.StudentsCompanion(
                  id: Value(student.id),
                  schoolId: Value(student.schoolId),
                  fullName: Value(student.fullName),
                  dateOfBirth: Value(student.dateOfBirth),
                  gender: Value(student.gender),
                  profilePhotoUrl: Value(student.profilePhotoUrl),
                  updatedAt: Value(DateTime.now()),
                ), mode: InsertMode.insertOrReplace);
                logger.d('Migrated Student data for ID: ${student.id} from list.');
              }
            } else if (decodedJson is Map) {
              final student = Student.fromMap(decodedJson as Map<String, dynamic>);
              await _appDatabase.into(_appDatabase.students).insert(db.StudentsCompanion(
                id: Value(student.id),
                schoolId: Value(student.schoolId),
                fullName: Value(student.fullName),
                dateOfBirth: Value(student.dateOfBirth),
                gender: Value(student.gender),
                profilePhotoUrl: Value(student.profilePhotoUrl),
                updatedAt: Value(DateTime.now()),
              ), mode: InsertMode.insertOrReplace);
              logger.d('Migrated Student data for ID: ${student.id} from single entry.');
            }
          } catch (e) {
            logger.e('Error decoding or migrating student data for key $key: $e');
          }
      }
    }
    
    // Set migration completed flag
    await prefs.setBool(_migrationCompletedKey, true);
    logger.i('Data migration completed successfully.');
  }
}
