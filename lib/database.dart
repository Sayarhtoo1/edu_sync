import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'models/school.dart';
import 'models/user.dart';
import 'models/teacher.dart';
import 'models/parent.dart';
import 'models/class.dart';
import 'models/attendance.dart';
import 'models/lesson_plan.dart';
import 'models/timetable.dart';
import 'models/income.dart';
import 'models/expense.dart';

import 'type_converters.dart';

part 'database.g.dart';

@TypeConverters([DateTimeConverter])
@Database(version: 1, entities: [School, User, Teacher, Parent, Class, Attendance, LessonPlan, Timetable, Income, Expense])
abstract class AppDatabase extends FloorDatabase {
  // Define DAOs for each entity
}
