import 'package:drift/drift.dart';

part 'app_database.g.dart';

class Schools extends Table {
  IntColumn get id => integer().named('id')();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get address => text().withLength(min: 1, max: 255)();
  TextColumn get contactInfo => text().withLength(min: 1, max: 255)();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Students extends Table {
  IntColumn get id => integer().named('id')();
  IntColumn get schoolId => integer().references(Schools, #id)();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get gender => text().withLength(min: 1, max: 50)();
  TextColumn get profilePhotoUrl => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Classes extends Table {
  IntColumn get id => integer().named('id')();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get teacherId => text().nullable()(); // Assuming teacher_id is UUID (String)
  IntColumn get schoolId => integer().references(Schools, #id)();
  TextColumn get section => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Schools, Students, Classes])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1; // Assuming schema version 1 for now
}
