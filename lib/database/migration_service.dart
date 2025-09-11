import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/drift.dart';
import '../services/cache_service.dart';
import 'app_database.dart' as db; // Alias app_database to avoid conflicts
import '../models/school.dart';
import '../models/student.dart';
import '../utils/logger.dart';

class MigrationService {
  final db.AppDatabase _appDatabase;
  // final CacheService _cacheService; // Removed as it's unused

  static const String _migrationCompletedKey = 'migration_completed';

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
      final String? schoolJsonString = prefs.getString('${CacheService.schoolKeyPrefix}1'); // Assuming school ID 1 is the primary one
      if (schoolJsonString != null) {
        final school = School.fromJson(json.decode(schoolJsonString));
        await _appDatabase.into(_appDatabase.schools).insert(db.SchoolsCompanion(
          id: Value(school.id),
          name: Value(school.name),
          address: Value(school.contact), // Assuming contact is used as address
          contactInfo: Value(school.contact),
          updatedAt: Value(DateTime.now()),
        ), mode: InsertMode.insertOrReplace);
        logger.d('Migrated School data for ID: ${school.id}');
      }


    // Migrate Student data
    final allKeys = prefs.getKeys();
    for (final key in allKeys) {
      if (key.startsWith(CacheService.studentsKeyPrefix) || key.startsWith(CacheService.studentByIdKeyPrefix) || key.startsWith(CacheService.studentsForParentKeyPrefix)) {
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
                  name: Value(student.fullName),
                  dateOfBirth: Value(student.dateOfBirth),
                  gender: Value(student.gender ?? ''),
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
                name: Value(student.fullName),
                dateOfBirth: Value(student.dateOfBirth),
              gender: Value(student.gender ?? ''),
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
