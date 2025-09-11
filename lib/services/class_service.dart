import 'dart:async'; // Import for StreamSubscription
import 'package:edu_sync/database/app_database.dart';
import 'package:edu_sync/models/school_class.dart' as app_class;
import 'package:edu_sync/utils/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase, SupabaseClient, RealtimeChannel, PostgresChangeEvent;
import 'package:drift/drift.dart'; // Import for InsertMode

class ClassService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  final AppDatabase _appDatabase;
  RealtimeChannel? _classChannel; // Use RealtimeChannel

  ClassService(this._appDatabase) {
    _initRealtimeListener();
  }

  void _initRealtimeListener() {
    _classChannel = _supabaseClient.channel('public:classes'); // Create a channel for the 'classes' table
    _classChannel?.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'classes',
      callback: (payload) async {
        if (payload.eventType == PostgresChangeEvent.insert) {
          final newClass = app_class.SchoolClass.fromMap(payload.newRecord);
          await _appDatabase.into(_appDatabase.classes).insert(newClass.toCompanion(), mode: InsertMode.insertOrReplace);
          logger.i('Realtime: Inserted class ${newClass.id} into drift.');
        } else if (payload.eventType == PostgresChangeEvent.update) {
          final updatedClass = app_class.SchoolClass.fromMap(payload.newRecord);
          await _appDatabase.update(_appDatabase.classes).replace(updatedClass.toCompanion());
          logger.i('Realtime: Updated class ${updatedClass.id} in drift.');
        } else if (payload.eventType == PostgresChangeEvent.delete) {
          final deletedClassId = payload.oldRecord['id'];
          if (deletedClassId != null) {
            // ignore: use_of_void_result
            await (_appDatabase.delete(_appDatabase.classes)..where((tbl) => tbl.id.equals(deletedClassId))).go();
            logger.i('Realtime: Deleted class $deletedClassId from drift.');
          }
        }
      },
    ).subscribe(); // subscribe() returns void, so no assignment
  }

  void dispose() {
    _classChannel?.unsubscribe(); // Unsubscribe from the channel
    logger.i('ClassService: Realtime listener disposed.');
  }

  // Fetch all classes for a school
  Future<List<app_class.SchoolClass>> getClasses(int schoolId) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    // 1. Attempt to fetch from drift database
    try {
      final classesFromDrift = await _appDatabase.select(_appDatabase.classes).get();
      if (classesFromDrift.isNotEmpty) {
        logger.i('Fetched classes from drift database.');
        return classesFromDrift.map((e) => app_class.SchoolClass.fromData(e)).toList();
      }
    } catch (e) {
      logger.e('Error fetching classes from drift: $e');
    }

    // 2. If drift is empty or offline, fetch from Supabase
    if (!connectivityResult.contains(ConnectivityResult.none)) {
      try {
        final List<dynamic> responseData = await _supabaseClient
            .from('classes')
            .select()
            .eq('school_id', schoolId);
        final classes = responseData.map((data) => app_class.SchoolClass.fromMap(data)).toList();

        // Save to drift, overwriting existing entries
        await _appDatabase.transaction(() async {
          // ignore: use_of_void_result
          await (_appDatabase.delete(_appDatabase.classes)..where((tbl) => tbl.schoolId.equals(schoolId))).go();
          // ignore: use_of_void_result
          await _appDatabase.batch((batch) {
            batch.insertAll(_appDatabase.classes, classes.map((c) => c.toCompanion()).toList());
          });
        });
        logger.i('Fetched classes from Supabase and saved to drift.');
        return classes;
      } catch (e) {
        logger.e('Error fetching classes by school from Supabase: $e');
      }
    }

    // Fallback: If all else fails, return empty list
    return [];
  }

  // Add a new class
  Future<app_class.SchoolClass?> createClass(app_class.SchoolClass newClass) async {
    try {
      final response = await _supabaseClient
          .from('classes')
          .insert(newClass.toMap()..remove('id')) // Remove id for insert
          .select()
          .single();
      final createdClass = app_class.SchoolClass.fromMap(response);

      // Update drift database
      await _appDatabase.into(_appDatabase.classes).insert(createdClass.toCompanion());
      logger.i('Created class in Supabase and drift.');
      return createdClass;
    } catch (e) {
      logger.e('Error creating class: $e');
      return null;
    }
  }

  // Update class details
  Future<bool> updateClass(app_class.SchoolClass classToUpdate) async {
    try {
      if (classToUpdate.id == null) {
        logger.w('Error: Class ID is null, cannot update.');
        return false;
      }
      await _supabaseClient
          .from('classes')
          .update(classToUpdate.toMap()..remove('id')) // Do not update id
          .eq('id', classToUpdate.id!); // Use null-check operator

      // Update drift database
      await _appDatabase.update(_appDatabase.classes).replace(classToUpdate.toCompanion());
      logger.i('Updated class in Supabase and drift.');
      return true;
    } catch (e) {
      logger.e('Error updating class: $e');
      return false;
    }
  }

  // Delete a class
  Future<bool> deleteClass(int classId) async {
    try {
      await _supabaseClient
          .from('classes')
          .delete()
          .eq('id', classId);

      // Delete from drift database
      // ignore: use_of_void_result
      await (_appDatabase.delete(_appDatabase.classes)..where((tbl) => tbl.id.equals(classId))).go();
      logger.i('Deleted class from Supabase and drift.');
      return true;
    } catch (e) {
      logger.e('Error deleting class: $e');
      return false;
    }
  }
}
