import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/announcement.dart';
import '../models/school_class.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/custom_form.dart';
import '../models/form_field_item.dart';
import '../models/income.dart';
import '../models/expense.dart';
import '../models/form_response.dart';
import '../models/form_response_answer.dart';
import '../models/lesson_plan.dart';
import '../models/school.dart';
import '../models/timetable.dart';

class CacheService {
  static const String _announcementsKeyPrefix = 'cached_announcements_for_school_';
  static const String _classesKeyPrefix = 'cached_classes_for_school_';
  static const String _studentsKeyPrefix = 'cached_students_for_class_';
  static const String _attendanceKeyPrefix = 'cached_attendance_for_class_';
  static const String _customFormsKeyPrefix = 'cached_custom_forms_for_school_';
  static const String _formFieldsKeyPrefix = 'cached_form_fields_for_form_';
  static const String _incomeKeyPrefix = 'cached_income_for_school_';
  static const String _expenseKeyPrefix = 'cached_expense_for_school_';
  static const String _formResponsesKeyPrefix = 'cached_form_responses_for_form_';
  static const String _formResponseAnswersKeyPrefix = 'cached_form_response_answers_for_response_';
  static const String _lessonPlansKeyPrefix = 'cached_lesson_plans_for_class_';
  static const String _schoolKeyPrefix = 'cached_school_';
  static const String _timetableForClassKeyPrefix = 'cached_timetable_for_class_';
  static const String _timetableForTeacherKeyPrefix = 'cached_timetable_for_teacher_';
  static const String _studentIdsForParentKeyPrefix = 'cached_student_ids_for_parent_';
  static const String _studentsForParentKeyPrefix = 'cached_students_for_parent_';
  static const String _parentIdsForStudentKeyPrefix = 'cached_parent_ids_for_student_';
  static const String _studentByIdKeyPrefix = 'cached_student_by_id_';

  Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  // --- Announcements ---

  Future<void> saveAnnouncements(int schoolId, List<Announcement> announcements) async {
    final prefs = await _prefs;
    final announcementsJson = announcements.map((a) => a.toMap()).toList();
    await prefs.setString('$_announcementsKeyPrefix$schoolId', json.encode(announcementsJson));
    print('Announcements saved for offline use.');
  }

  Future<List<Announcement>> getAnnouncements(int schoolId) async {
    final prefs = await _prefs;
    final announcementsString = prefs.getString('$_announcementsKeyPrefix$schoolId');
    if (announcementsString != null) {
      final List<dynamic> announcementsJson = json.decode(announcementsString);
      return announcementsJson.map((json) => Announcement.fromMap(json)).toList();
    }
    return [];
  }

  // --- School Classes ---

  Future<void> saveClasses(int schoolId, List<SchoolClass> classes) async {
    final prefs = await _prefs;
    final classesJson = classes.map((c) => c.toMap()).toList();
    await prefs.setString('$_classesKeyPrefix$schoolId', json.encode(classesJson));
    print('Classes saved for offline use.');
  }

  Future<List<SchoolClass>> getClasses(int schoolId) async {
    final prefs = await _prefs;
    final classesString = prefs.getString('$_classesKeyPrefix$schoolId');
    if (classesString != null) {
      final List<dynamic> classesJson = json.decode(classesString);
      return classesJson.map((json) => SchoolClass.fromMap(json)).toList();
    }
    return [];
  }

  // --- Students ---

  Future<void> saveStudentsForClass(int classId, List<Student> students) async {
    final prefs = await _prefs;
    final studentsJson = students.map((s) => s.toMap()).toList();
    await prefs.setString('$_studentsKeyPrefix$classId', json.encode(studentsJson));
    print('Students for class $classId saved for offline use.');
  }

  Future<List<Student>> getStudentsForClass(int classId) async {
    final prefs = await _prefs;
    final studentsString = prefs.getString('$_studentsKeyPrefix$classId');
    if (studentsString != null) {
      final List<dynamic> studentsJson = json.decode(studentsString);
      return studentsJson.map((json) => Student.fromMap(json)).toList();
    }
    return [];
  }

  // --- Attendance ---

  Future<void> saveAttendanceForClass(int classId, DateTime date, List<Attendance> attendance) async {
    final prefs = await _prefs;
    final dateString = date.toIso8601String().substring(0, 10); // YYYY-MM-DD
    final attendanceJson = attendance.map((a) => a.toMap()).toList();
    await prefs.setString('$_attendanceKeyPrefix${classId}_$dateString', json.encode(attendanceJson));
    print('Attendance for class $classId on $dateString saved for offline use.');
  }

  Future<List<Attendance>> getAttendanceForClass(int classId, DateTime date) async {
    final prefs = await _prefs;
    final dateString = date.toIso8601String().substring(0, 10); // YYYY-MM-DD
    final attendanceString = prefs.getString('$_attendanceKeyPrefix${classId}_$dateString');
    if (attendanceString != null) {
      final List<dynamic> attendanceJson = json.decode(attendanceString);
      return attendanceJson.map((json) => Attendance.fromMap(json)).toList();
    }
    return [];
  }

  // --- Custom Forms ---

  Future<void> saveCustomFormsForSchool(int schoolId, List<CustomForm> forms) async {
    final prefs = await _prefs;
    final formsJson = forms.map((f) => f.toMap()).toList();
    await prefs.setString('$_customFormsKeyPrefix$schoolId', json.encode(formsJson));
  }

  Future<List<CustomForm>> getCustomFormsForSchool(int schoolId) async {
    final prefs = await _prefs;
    final formsString = prefs.getString('$_customFormsKeyPrefix$schoolId');
    if (formsString != null) {
      final List<dynamic> formsJson = json.decode(formsString);
      return formsJson.map((json) => CustomForm.fromMap(json)).toList();
    }
    return [];
  }

  // --- Form Fields ---

  Future<void> saveFormFields(String formId, List<FormFieldItem> fields) async {
    final prefs = await _prefs;
    final fieldsJson = fields.map((f) => f.toMap()).toList();
    await prefs.setString('$_formFieldsKeyPrefix$formId', json.encode(fieldsJson));
  }

  Future<List<FormFieldItem>> getFormFields(String formId) async {
    final prefs = await _prefs;
    final fieldsString = prefs.getString('$_formFieldsKeyPrefix$formId');
    if (fieldsString != null) {
      final List<dynamic> fieldsJson = json.decode(fieldsString);
      return fieldsJson.map((json) => FormFieldItem.fromMap(json)).toList();
    }
    return [];
  }

  // --- Income ---

  Future<void> saveIncomeRecords(int schoolId, List<Income> incomes) async {
    final prefs = await _prefs;
    final incomesJson = incomes.map((i) => i.toMap()).toList();
    await prefs.setString('$_incomeKeyPrefix$schoolId', json.encode(incomesJson));
  }

  Future<List<Income>> getIncomeRecords(int schoolId) async {
    final prefs = await _prefs;
    final incomesString = prefs.getString('$_incomeKeyPrefix$schoolId');
    if (incomesString != null) {
      final List<dynamic> incomesJson = json.decode(incomesString);
      return incomesJson.map((json) => Income.fromMap(json)).toList();
    }
    return [];
  }

  // --- Expenses ---

  Future<void> saveExpenseRecords(int schoolId, List<Expense> expenses) async {
    final prefs = await _prefs;
    final expensesJson = expenses.map((e) => e.toMap()).toList();
    await prefs.setString('$_expenseKeyPrefix$schoolId', json.encode(expensesJson));
  }

  Future<List<Expense>> getExpenseRecords(int schoolId) async {
    final prefs = await _prefs;
    final expensesString = prefs.getString('$_expenseKeyPrefix$schoolId');
    if (expensesString != null) {
      final List<dynamic> expensesJson = json.decode(expensesString);
      return expensesJson.map((json) => Expense.fromMap(json)).toList();
    }
    return [];
  }

  // --- Form Responses ---

  Future<void> saveFormResponses(String formId, List<FormResponse> responses) async {
    final prefs = await _prefs;
    final responsesJson = responses.map((r) => r.toMap()).toList();
    await prefs.setString('$_formResponsesKeyPrefix$formId', json.encode(responsesJson));
  }

  Future<List<FormResponse>> getFormResponses(String formId) async {
    final prefs = await _prefs;
    final responsesString = prefs.getString('$_formResponsesKeyPrefix$formId');
    if (responsesString != null) {
      final List<dynamic> responsesJson = json.decode(responsesString);
      return responsesJson.map((json) => FormResponse.fromMap(json)).toList();
    }
    return [];
  }

  // --- Form Response Answers ---

  Future<void> saveFormResponseAnswers(String responseId, List<FormResponseAnswer> answers) async {
    final prefs = await _prefs;
    final answersJson = answers.map((a) => a.toMap()).toList();
    await prefs.setString('$_formResponseAnswersKeyPrefix$responseId', json.encode(answersJson));
  }

  Future<List<FormResponseAnswer>> getFormResponseAnswers(String responseId) async {
    final prefs = await _prefs;
    final answersString = prefs.getString('$_formResponseAnswersKeyPrefix$responseId');
    if (answersString != null) {
      final List<dynamic> answersJson = json.decode(answersString);
      return answersJson.map((json) => FormResponseAnswer.fromMap(json)).toList();
    }
    return [];
  }

  // --- Lesson Plans ---

  Future<void> saveLessonPlans(int classId, List<LessonPlan> lessonPlans) async {
    final prefs = await _prefs;
    final lessonPlansJson = lessonPlans.map((l) => l.toMap()).toList();
    await prefs.setString('$_lessonPlansKeyPrefix$classId', json.encode(lessonPlansJson));
  }

  Future<List<LessonPlan>> getLessonPlans(int classId) async {
    final prefs = await _prefs;
    final lessonPlansString = prefs.getString('$_lessonPlansKeyPrefix$classId');
    if (lessonPlansString != null) {
      final List<dynamic> lessonPlansJson = json.decode(lessonPlansString);
      return lessonPlansJson.map((json) => LessonPlan.fromMap(json)).toList();
    }
    return [];
  }

  // --- School ---

  Future<void> saveSchool(School school) async {
    final prefs = await _prefs;
    await prefs.setString('$_schoolKeyPrefix${school.id}', json.encode(school.toJson()));
  }

  Future<School?> getSchool(int schoolId) async {
    final prefs = await _prefs;
    final schoolString = prefs.getString('$_schoolKeyPrefix$schoolId');
    if (schoolString != null) {
      return School.fromJson(json.decode(schoolString));
    }
    return null;
  }

  // --- Timetable ---

  Future<void> saveTimetableForClass(int classId, List<Timetable> timetable) async {
    final prefs = await _prefs;
    final timetableJson = timetable.map((t) => t.toMap()).toList();
    await prefs.setString('$_timetableForClassKeyPrefix$classId', json.encode(timetableJson));
  }

  Future<List<Timetable>> getTimetableForClass(int classId) async {
    final prefs = await _prefs;
    final timetableString = prefs.getString('$_timetableForClassKeyPrefix$classId');
    if (timetableString != null) {
      final List<dynamic> timetableJson = json.decode(timetableString);
      return timetableJson.map((json) => Timetable.fromMap(json)).toList();
    }
    return [];
  }

  Future<void> saveTimetableForTeacher(String teacherId, List<Timetable> timetable) async {
    final prefs = await _prefs;
    final timetableJson = timetable.map((t) => t.toMap()).toList();
    await prefs.setString('$_timetableForTeacherKeyPrefix$teacherId', json.encode(timetableJson));
  }

  Future<List<Timetable>> getTimetableForTeacher(String teacherId) async {
    final prefs = await _prefs;
    final timetableString = prefs.getString('$_timetableForTeacherKeyPrefix$teacherId');
    if (timetableString != null) {
      final List<dynamic> timetableJson = json.decode(timetableString);
      return timetableJson.map((json) => Timetable.fromMap(json)).toList();
    }
    return [];
  }

  // --- Student IDs for Parent ---

  Future<void> saveStudentIdsForParent(String parentId, List<int> studentIds) async {
    final prefs = await _prefs;
    await prefs.setStringList('$_studentIdsForParentKeyPrefix$parentId', studentIds.map((id) => id.toString()).toList());
  }

  Future<List<int>> getStudentIdsForParent(String parentId) async {
    final prefs = await _prefs;
    final studentIdsString = prefs.getStringList('$_studentIdsForParentKeyPrefix$parentId');
    if (studentIdsString != null) {
      return studentIdsString.map((id) => int.parse(id)).toList();
    }
    return [];
  }

  // --- Students for Parent ---

  Future<void> saveStudentsForParent(String parentId, List<Student> students) async {
    final prefs = await _prefs;
    final studentsJson = students.map((s) => s.toMap()).toList();
    await prefs.setString('$_studentsForParentKeyPrefix$parentId', json.encode(studentsJson));
  }

  Future<List<Student>> getStudentsForParent(String parentId) async {
    final prefs = await _prefs;
    final studentsString = prefs.getString('$_studentsForParentKeyPrefix$parentId');
    if (studentsString != null) {
      final List<dynamic> studentsJson = json.decode(studentsString);
      return studentsJson.map((json) => Student.fromMap(json)).toList();
    }
    return [];
  }

  // --- Parent IDs for Student ---

  Future<void> saveParentIdsForStudent(int studentId, List<String> parentIds) async {
    final prefs = await _prefs;
    await prefs.setStringList('$_parentIdsForStudentKeyPrefix$studentId', parentIds);
  }

  Future<List<String>> getParentIdsForStudent(int studentId) async {
    final prefs = await _prefs;
    final parentIds = prefs.getStringList('$_parentIdsForStudentKeyPrefix$studentId');
    return parentIds ?? [];
  }

  // --- Student by ID ---

  Future<void> saveStudentById(Student student) async {
    final prefs = await _prefs;
    await prefs.setString('$_studentByIdKeyPrefix${student.id}', json.encode(student.toMap()));
  }

  Future<Student?> getStudentById(int studentId) async {
    final prefs = await _prefs;
    final studentString = prefs.getString('$_studentByIdKeyPrefix$studentId');
    if (studentString != null) {
      return Student.fromMap(json.decode(studentString));
    }
    return null;
  }
}
