import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_my.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('my')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'EduSync Myanmar'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @teacherDashboard.
  ///
  /// In en, this message translates to:
  /// **'Teacher Dashboard'**
  String get teacherDashboard;

  /// No description provided for @parentDashboard.
  ///
  /// In en, this message translates to:
  /// **'Parent Dashboard'**
  String get parentDashboard;

  /// No description provided for @welcomeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Admin!'**
  String get welcomeAdmin;

  /// No description provided for @welcomeTeacher.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Teacher!'**
  String get welcomeTeacher;

  /// No description provided for @welcomeParent.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Parent!'**
  String get welcomeParent;

  /// No description provided for @useDrawerToNavigate.
  ///
  /// In en, this message translates to:
  /// **'Use the drawer to navigate.'**
  String get useDrawerToNavigate;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @teachers.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get teachers;

  /// No description provided for @parents.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get parents;

  /// No description provided for @students.
  ///
  /// In en, this message translates to:
  /// **'Students'**
  String get students;

  /// No description provided for @classes.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get classes;

  /// No description provided for @error_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'Error: User not found. Please log in again.'**
  String get error_user_not_found;

  /// No description provided for @error_school_not_selected_or_found.
  ///
  /// In en, this message translates to:
  /// **'Error: School not selected or found. Please ensure a school is associated with your account.'**
  String get error_school_not_selected_or_found;

  /// No description provided for @error_fetching_timetable.
  ///
  /// In en, this message translates to:
  /// **'Error fetching timetable'**
  String get error_fetching_timetable;

  /// No description provided for @my_timetable_title.
  ///
  /// In en, this message translates to:
  /// **'My Timetable'**
  String get my_timetable_title;

  /// No description provided for @no_timetable_entries_found.
  ///
  /// In en, this message translates to:
  /// **'No timetable entries found.'**
  String get no_timetable_entries_found;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @friday.
  ///
  /// In en, this message translates to:
  /// **'Friday'**
  String get friday;

  /// No description provided for @saturday.
  ///
  /// In en, this message translates to:
  /// **'Saturday'**
  String get saturday;

  /// No description provided for @sunday.
  ///
  /// In en, this message translates to:
  /// **'Sunday'**
  String get sunday;

  /// No description provided for @unknown_subject.
  ///
  /// In en, this message translates to:
  /// **'Unknown Subject'**
  String get unknown_subject;

  /// No description provided for @classLabel.
  ///
  /// In en, this message translates to:
  /// **'Class'**
  String get classLabel;

  /// No description provided for @unknown_class.
  ///
  /// In en, this message translates to:
  /// **'Unknown Class'**
  String get unknown_class;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @room.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get room;

  /// No description provided for @not_specified.
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get not_specified;

  /// No description provided for @markAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Mark Attendance'**
  String get markAttendanceTitle;

  /// No description provided for @selectClassHint.
  ///
  /// In en, this message translates to:
  /// **'Select Class'**
  String get selectClassHint;

  /// No description provided for @pleaseSelectClass.
  ///
  /// In en, this message translates to:
  /// **'Please select a class.'**
  String get pleaseSelectClass;

  /// No description provided for @noStudentsInClass.
  ///
  /// In en, this message translates to:
  /// **'No students in this class.'**
  String get noStudentsInClass;

  /// No description provided for @saveAttendanceButton.
  ///
  /// In en, this message translates to:
  /// **'Save Attendance'**
  String get saveAttendanceButton;

  /// No description provided for @classTeacherInfoMissing.
  ///
  /// In en, this message translates to:
  /// **'Class or teacher information missing.'**
  String get classTeacherInfoMissing;

  /// No description provided for @attendanceSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Attendance saved successfully!'**
  String get attendanceSavedSuccess;

  /// No description provided for @attendanceSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save attendance.'**
  String get attendanceSaveFailed;

  /// No description provided for @attendanceStatusPresent.
  ///
  /// In en, this message translates to:
  /// **'Present'**
  String get attendanceStatusPresent;

  /// No description provided for @attendanceStatusAbsent.
  ///
  /// In en, this message translates to:
  /// **'Absent'**
  String get attendanceStatusAbsent;

  /// No description provided for @attendanceStatusLate.
  ///
  /// In en, this message translates to:
  /// **'Late'**
  String get attendanceStatusLate;

  /// No description provided for @manageLessonPlansTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Lesson Plans'**
  String get manageLessonPlansTitle;

  /// No description provided for @pleaseSelectClassToViewLessonPlans.
  ///
  /// In en, this message translates to:
  /// **'Please select a class to view lesson plans.'**
  String get pleaseSelectClassToViewLessonPlans;

  /// No description provided for @noLessonPlansFound.
  ///
  /// In en, this message translates to:
  /// **'No lesson plans found for this class.'**
  String get noLessonPlansFound;

  /// No description provided for @addLessonPlanTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add New Lesson Plan'**
  String get addLessonPlanTooltip;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteLessonPlanText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this lesson plan?'**
  String get confirmDeleteLessonPlanText;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @errorDeletingLessonPlan.
  ///
  /// In en, this message translates to:
  /// **'Error deleting lesson plan.'**
  String get errorDeletingLessonPlan;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @addEditLessonPlanNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Add/Edit Lesson Plan screen not yet implemented.'**
  String get addEditLessonPlanNotImplemented;

  /// No description provided for @editClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Class'**
  String get editClassTitle;

  /// No description provided for @addClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Class'**
  String get addClassTitle;

  /// No description provided for @classNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Class Name'**
  String get classNameLabel;

  /// No description provided for @classNameValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter class name'**
  String get classNameValidator;

  /// No description provided for @selectClassTeacherHint.
  ///
  /// In en, this message translates to:
  /// **'Select Class Teacher'**
  String get selectClassTeacherHint;

  /// No description provided for @classTeacherLabel.
  ///
  /// In en, this message translates to:
  /// **'Class Teacher'**
  String get classTeacherLabel;

  /// No description provided for @classTeacherValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a teacher'**
  String get classTeacherValidator;

  /// No description provided for @updateClassButton.
  ///
  /// In en, this message translates to:
  /// **'Update Class'**
  String get updateClassButton;

  /// No description provided for @addClassButton.
  ///
  /// In en, this message translates to:
  /// **'Add Class'**
  String get addClassButton;

  /// No description provided for @failedToLoadTeachersError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load teachers.'**
  String get failedToLoadTeachersError;

  /// No description provided for @errorOccurredPrefix.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurredPrefix;

  /// No description provided for @failedToSaveClassError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save class.'**
  String get failedToSaveClassError;

  /// No description provided for @unnamedTeacher.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Teacher'**
  String get unnamedTeacher;

  /// No description provided for @editTeacherTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Teacher'**
  String get editTeacherTitle;

  /// No description provided for @addTeacherTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Teacher'**
  String get addTeacherTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullNameLabel;

  /// No description provided for @fullNameValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter full name'**
  String get fullNameValidator;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter email'**
  String get emailValidator;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password (min. 6 characters)'**
  String get passwordLabel;

  /// No description provided for @passwordRequiredValidator.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequiredValidator;

  /// No description provided for @passwordTooShortValidator.
  ///
  /// In en, this message translates to:
  /// **'Password too short'**
  String get passwordTooShortValidator;

  /// No description provided for @noProfilePhoto.
  ///
  /// In en, this message translates to:
  /// **'No profile photo'**
  String get noProfilePhoto;

  /// No description provided for @couldNotLoadImage.
  ///
  /// In en, this message translates to:
  /// **'Could not load image'**
  String get couldNotLoadImage;

  /// No description provided for @selectPhotoButton.
  ///
  /// In en, this message translates to:
  /// **'Select Photo'**
  String get selectPhotoButton;

  /// No description provided for @updateTeacherButton.
  ///
  /// In en, this message translates to:
  /// **'Update Teacher'**
  String get updateTeacherButton;

  /// No description provided for @addTeacherButton.
  ///
  /// In en, this message translates to:
  /// **'Add Teacher'**
  String get addTeacherButton;

  /// No description provided for @passwordRequiredForNewTeacherError.
  ///
  /// In en, this message translates to:
  /// **'Password is required for new teacher.'**
  String get passwordRequiredForNewTeacherError;

  /// No description provided for @newTeacherCreationDisabledError.
  ///
  /// In en, this message translates to:
  /// **'New teacher creation is temporarily disabled. Please use Supabase dashboard or an Edge Function.'**
  String get newTeacherCreationDisabledError;

  /// No description provided for @profilePhotoUploadFailedError.
  ///
  /// In en, this message translates to:
  /// **'Profile photo upload failed.'**
  String get profilePhotoUploadFailedError;

  /// No description provided for @failedToUpdateTeacherError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update teacher.'**
  String get failedToUpdateTeacherError;

  /// No description provided for @failedToCreateTeacherError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create teacher.'**
  String get failedToCreateTeacherError;

  /// No description provided for @editParentTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Parent'**
  String get editParentTitle;

  /// No description provided for @addParentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Parent'**
  String get addParentTitle;

  /// No description provided for @updateParentButton.
  ///
  /// In en, this message translates to:
  /// **'Update Parent'**
  String get updateParentButton;

  /// No description provided for @addParentButton.
  ///
  /// In en, this message translates to:
  /// **'Add Parent'**
  String get addParentButton;

  /// No description provided for @passwordRequiredForNewParentError.
  ///
  /// In en, this message translates to:
  /// **'Password is required for new parent.'**
  String get passwordRequiredForNewParentError;

  /// No description provided for @newParentCreationDisabledError.
  ///
  /// In en, this message translates to:
  /// **'New parent creation is temporarily disabled. Please use Supabase dashboard or an Edge Function.'**
  String get newParentCreationDisabledError;

  /// No description provided for @failedToUpdateParentError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update parent.'**
  String get failedToUpdateParentError;

  /// No description provided for @failedToCreateParentError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create parent.'**
  String get failedToCreateParentError;

  /// No description provided for @editStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Student'**
  String get editStudentTitle;

  /// No description provided for @addStudentTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get addStudentTitle;

  /// No description provided for @dateOfBirthLabel.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirthLabel;

  /// No description provided for @dateOfBirthHint.
  ///
  /// In en, this message translates to:
  /// **'YYYY-MM-DD'**
  String get dateOfBirthHint;

  /// No description provided for @selectClassOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Select Class (Optional)'**
  String get selectClassOptionalHint;

  /// No description provided for @classOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Class (Optional)'**
  String get classOptionalLabel;

  /// No description provided for @updateStudentButton.
  ///
  /// In en, this message translates to:
  /// **'Update Student'**
  String get updateStudentButton;

  /// No description provided for @addStudentButton.
  ///
  /// In en, this message translates to:
  /// **'Add Student'**
  String get addStudentButton;

  /// No description provided for @failedToLoadClassesError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load classes.'**
  String get failedToLoadClassesError;

  /// No description provided for @failedToUpdateStudentError.
  ///
  /// In en, this message translates to:
  /// **'Failed to update student.'**
  String get failedToUpdateStudentError;

  /// No description provided for @failedToCreateStudentError.
  ///
  /// In en, this message translates to:
  /// **'Failed to create student.'**
  String get failedToCreateStudentError;

  /// No description provided for @editTimetableEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Timetable Entry'**
  String get editTimetableEntryTitle;

  /// No description provided for @addTimetableEntryTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Timetable Entry'**
  String get addTimetableEntryTitle;

  /// No description provided for @subjectNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject Name'**
  String get subjectNameLabel;

  /// No description provided for @subjectNameValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter subject name'**
  String get subjectNameValidator;

  /// No description provided for @selectDayOfWeekHint.
  ///
  /// In en, this message translates to:
  /// **'Select Day of Week'**
  String get selectDayOfWeekHint;

  /// No description provided for @dayValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a day'**
  String get dayValidator;

  /// No description provided for @startTimeLabelPrefix.
  ///
  /// In en, this message translates to:
  /// **'Start Time: '**
  String get startTimeLabelPrefix;

  /// No description provided for @endTimeLabelPrefix.
  ///
  /// In en, this message translates to:
  /// **'End Time: '**
  String get endTimeLabelPrefix;

  /// No description provided for @timeNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get timeNotSet;

  /// No description provided for @updateEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Update Entry'**
  String get updateEntryButton;

  /// No description provided for @addEntryButton.
  ///
  /// In en, this message translates to:
  /// **'Add Entry'**
  String get addEntryButton;

  /// No description provided for @fillAllFieldsError.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields, including time, day, class, and teacher.'**
  String get fillAllFieldsError;

  /// No description provided for @endTimeAfterStartTimeError.
  ///
  /// In en, this message translates to:
  /// **'End time must be after start time.'**
  String get endTimeAfterStartTimeError;

  /// No description provided for @failedToSaveTimetableEntryError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save timetable entry.'**
  String get failedToSaveTimetableEntryError;

  /// No description provided for @failedToLoadTimetableDataError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load necessary data for timetable entry.'**
  String get failedToLoadTimetableDataError;

  /// No description provided for @financeManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Finance Management'**
  String get financeManagementTitle;

  /// No description provided for @incomeTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeTabLabel;

  /// No description provided for @expensesTabLabel.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expensesTabLabel;

  /// No description provided for @addIncomeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Income Record'**
  String get addIncomeTooltip;

  /// No description provided for @addExpenseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Expense Record'**
  String get addExpenseTooltip;

  /// No description provided for @financialSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Summary'**
  String get financialSummaryTitle;

  /// No description provided for @totalIncomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncomeLabel;

  /// No description provided for @totalExpensesLabel.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpensesLabel;

  /// No description provided for @netBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalanceLabel;

  /// No description provided for @noIncomeRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No income records found.'**
  String get noIncomeRecordsFound;

  /// No description provided for @noExpenseRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No expense records found.'**
  String get noExpenseRecordsFound;

  /// No description provided for @confirmDeleteIncomeText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this income record?'**
  String get confirmDeleteIncomeText;

  /// No description provided for @confirmDeleteExpenseText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense record?'**
  String get confirmDeleteExpenseText;

  /// No description provided for @errorDeletingIncome.
  ///
  /// In en, this message translates to:
  /// **'Error deleting income record.'**
  String get errorDeletingIncome;

  /// No description provided for @errorDeletingExpense.
  ///
  /// In en, this message translates to:
  /// **'Error deleting expense record.'**
  String get errorDeletingExpense;

  /// No description provided for @addEditFinancialRecordNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Add/Edit financial record screen not yet implemented.'**
  String get addEditFinancialRecordNotImplemented;

  /// No description provided for @editIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Income'**
  String get editIncomeTitle;

  /// No description provided for @addIncomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncomeTitle;

  /// No description provided for @editExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Expense'**
  String get editExpenseTitle;

  /// No description provided for @addExpenseTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpenseTitle;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionLabel;

  /// No description provided for @descriptionValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter a description.'**
  String get descriptionValidator;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @amountValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount.'**
  String get amountValidator;

  /// No description provided for @invalidAmountError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid positive amount.'**
  String get invalidAmountError;

  /// No description provided for @recordDateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get recordDateLabel;

  /// No description provided for @dateValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a date.'**
  String get dateValidator;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get updateButton;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @failedToSaveRecordError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save record.'**
  String get failedToSaveRecordError;

  /// No description provided for @announcementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementsTitle;

  /// No description provided for @noAnnouncementsFound.
  ///
  /// In en, this message translates to:
  /// **'No announcements found.'**
  String get noAnnouncementsFound;

  /// No description provided for @postedOn.
  ///
  /// In en, this message translates to:
  /// **'Posted on'**
  String get postedOn;

  /// No description provided for @childAttendanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Attendance'**
  String get childAttendanceTitle;

  /// No description provided for @noChildrenLinked.
  ///
  /// In en, this message translates to:
  /// **'No children linked to your account.'**
  String get noChildrenLinked;

  /// No description provided for @selectChildHint.
  ///
  /// In en, this message translates to:
  /// **'Select Child'**
  String get selectChildHint;

  /// No description provided for @pleaseSelectChild.
  ///
  /// In en, this message translates to:
  /// **'Please select a child to view attendance.'**
  String get pleaseSelectChild;

  /// No description provided for @noAttendanceRecordsFound.
  ///
  /// In en, this message translates to:
  /// **'No attendance records found for the selected child and month.'**
  String get noAttendanceRecordsFound;

  /// No description provided for @childScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Child\'s Schedule'**
  String get childScheduleTitle;

  /// No description provided for @childNotAssignedToClass.
  ///
  /// In en, this message translates to:
  /// **'Child is not currently assigned to a class or no schedule is available.'**
  String get childNotAssignedToClass;

  /// No description provided for @noScheduleFound.
  ///
  /// In en, this message translates to:
  /// **'No schedule found for the selected child\'s class.'**
  String get noScheduleFound;

  /// No description provided for @manageAnnouncementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Announcements'**
  String get manageAnnouncementsTitle;

  /// No description provided for @addAnnouncementTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add New Announcement'**
  String get addAnnouncementTooltip;

  /// No description provided for @confirmDeleteAnnouncementText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this announcement?'**
  String get confirmDeleteAnnouncementText;

  /// No description provided for @errorDeletingAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Error deleting announcement.'**
  String get errorDeletingAnnouncement;

  /// No description provided for @actionRequiresSchoolAndAdminContext.
  ///
  /// In en, this message translates to:
  /// **'Action requires school and admin context.'**
  String get actionRequiresSchoolAndAdminContext;

  /// No description provided for @addEditAnnouncementNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Add/Edit Announcement screen not yet implemented.'**
  String get addEditAnnouncementNotImplemented;

  /// No description provided for @targetAudience.
  ///
  /// In en, this message translates to:
  /// **'Target Audience'**
  String get targetAudience;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @specificclass.
  ///
  /// In en, this message translates to:
  /// **'Specific Class'**
  String get specificclass;

  /// No description provided for @closeButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeButtonLabel;

  /// No description provided for @pleaseSelectClassForAnnouncement.
  ///
  /// In en, this message translates to:
  /// **'Please select a class for this announcement.'**
  String get pleaseSelectClassForAnnouncement;

  /// No description provided for @failedToSaveAnnouncementError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save announcement.'**
  String get failedToSaveAnnouncementError;

  /// No description provided for @editAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Announcement'**
  String get editAnnouncementTitle;

  /// No description provided for @addAnnouncementTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Announcement'**
  String get addAnnouncementTitle;

  /// No description provided for @titleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get titleLabel;

  /// No description provided for @titleValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter a title.'**
  String get titleValidator;

  /// No description provided for @contentLabel.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get contentLabel;

  /// No description provided for @contentValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter content.'**
  String get contentValidator;

  /// No description provided for @selectTargetAudienceHint.
  ///
  /// In en, this message translates to:
  /// **'Select Target Audience'**
  String get selectTargetAudienceHint;

  /// No description provided for @targetAudienceValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a target audience.'**
  String get targetAudienceValidator;

  /// No description provided for @manageAnnouncementsDrawerItem.
  ///
  /// In en, this message translates to:
  /// **'Manage Announcements'**
  String get manageAnnouncementsDrawerItem;

  /// No description provided for @classOrUserMissingError.
  ///
  /// In en, this message translates to:
  /// **'Class or user information is missing to save attendance.'**
  String get classOrUserMissingError;

  /// No description provided for @failedToLoadInitialData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load initial data.'**
  String get failedToLoadInitialData;

  /// No description provided for @failedToLoadSubjects.
  ///
  /// In en, this message translates to:
  /// **'Failed to load subjects for the selected class.'**
  String get failedToLoadSubjects;

  /// No description provided for @fillAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all required fields.'**
  String get fillAllRequiredFields;

  /// No description provided for @failedToSaveLessonPlanError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save lesson plan.'**
  String get failedToSaveLessonPlanError;

  /// No description provided for @editLessonPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Lesson Plan'**
  String get editLessonPlanTitle;

  /// No description provided for @addLessonPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Lesson Plan'**
  String get addLessonPlanTitle;

  /// No description provided for @selectSubjectHint.
  ///
  /// In en, this message translates to:
  /// **'Select Subject'**
  String get selectSubjectHint;

  /// No description provided for @subjectLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subjectLabel;

  /// No description provided for @subjectValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a subject.'**
  String get subjectValidator;

  /// No description provided for @pleaseSelectClassFirstForSubjects.
  ///
  /// In en, this message translates to:
  /// **'Please select a class to see available subjects.'**
  String get pleaseSelectClassFirstForSubjects;

  /// No description provided for @noSubjectsFoundForClass.
  ///
  /// In en, this message translates to:
  /// **'No subjects found for the selected class. Please check timetable.'**
  String get noSubjectsFoundForClass;

  /// No description provided for @manageDailyReportFormsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Daily Report Forms'**
  String get manageDailyReportFormsTitle;

  /// No description provided for @confirmDeleteCustomFormText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this form and all its responses? This action cannot be undone.'**
  String get confirmDeleteCustomFormText;

  /// No description provided for @errorDeletingCustomFormText.
  ///
  /// In en, this message translates to:
  /// **'Error deleting custom form.'**
  String get errorDeletingCustomFormText;

  /// No description provided for @noCustomFormsFoundText.
  ///
  /// In en, this message translates to:
  /// **'No custom forms found. Tap \'+\' to create one.'**
  String get noCustomFormsFoundText;

  /// No description provided for @addCustomFormTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add New Report Form'**
  String get addCustomFormTooltip;

  /// No description provided for @activeFrom.
  ///
  /// In en, this message translates to:
  /// **'Active From'**
  String get activeFrom;

  /// No description provided for @activeTo.
  ///
  /// In en, this message translates to:
  /// **'Active To'**
  String get activeTo;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @formDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Form Details'**
  String get formDetailsTitle;

  /// No description provided for @formTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Form Title'**
  String get formTitleLabel;

  /// No description provided for @formTitleValidator.
  ///
  /// In en, this message translates to:
  /// **'Form title is required.'**
  String get formTitleValidator;

  /// No description provided for @dailyReportLabel.
  ///
  /// In en, this message translates to:
  /// **'Daily Recurring Report'**
  String get dailyReportLabel;

  /// No description provided for @assignToLabel.
  ///
  /// In en, this message translates to:
  /// **'Assign To:'**
  String get assignToLabel;

  /// No description provided for @assignToWholeSchoolLabel.
  ///
  /// In en, this message translates to:
  /// **'Whole School'**
  String get assignToWholeSchoolLabel;

  /// No description provided for @formQuestionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Form Questions'**
  String get formQuestionsTitle;

  /// No description provided for @addQuestionTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get addQuestionTooltip;

  /// No description provided for @noQuestionsAddedText.
  ///
  /// In en, this message translates to:
  /// **'No questions added yet. Click \'+\' to add.'**
  String get noQuestionsAddedText;

  /// No description provided for @pleaseSelectActiveDatesError.
  ///
  /// In en, this message translates to:
  /// **'Please select active dates.'**
  String get pleaseSelectActiveDatesError;

  /// No description provided for @activeToDateError.
  ///
  /// In en, this message translates to:
  /// **'Active To date must be after Active From date.'**
  String get activeToDateError;

  /// No description provided for @addAtLeastOneQuestionError.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one question to the form.'**
  String get addAtLeastOneQuestionError;

  /// No description provided for @failedToSaveFormError.
  ///
  /// In en, this message translates to:
  /// **'Failed to save form.'**
  String get failedToSaveFormError;

  /// No description provided for @editReportFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Report Form'**
  String get editReportFormTitle;

  /// No description provided for @createReportFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Report Form'**
  String get createReportFormTitle;

  /// No description provided for @editQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Question'**
  String get editQuestionTitle;

  /// No description provided for @addQuestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get addQuestionTitle;

  /// No description provided for @questionTextLabel.
  ///
  /// In en, this message translates to:
  /// **'Question Text'**
  String get questionTextLabel;

  /// No description provided for @questionTextValidator.
  ///
  /// In en, this message translates to:
  /// **'Question text is required.'**
  String get questionTextValidator;

  /// No description provided for @questionTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Question Type'**
  String get questionTypeLabel;

  /// No description provided for @optionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Options (one per line)'**
  String get optionsLabel;

  /// No description provided for @optionsRequiredError.
  ///
  /// In en, this message translates to:
  /// **'Options are required for this question type.'**
  String get optionsRequiredError;

  /// No description provided for @atLeastTwoOptionsError.
  ///
  /// In en, this message translates to:
  /// **'At least two options are required for this question type.'**
  String get atLeastTwoOptionsError;

  /// No description provided for @requiredLabel.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredLabel;

  /// No description provided for @typePrefixLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typePrefixLabel;

  /// No description provided for @requiredSuffix.
  ///
  /// In en, this message translates to:
  /// **'(Required)'**
  String get requiredSuffix;

  /// No description provided for @manageDailyReportsDrawerItem.
  ///
  /// In en, this message translates to:
  /// **'Manage Daily Reports'**
  String get manageDailyReportsDrawerItem;

  /// No description provided for @assignToClassesLabel.
  ///
  /// In en, this message translates to:
  /// **'Assign to Specific Classes:'**
  String get assignToClassesLabel;

  /// No description provided for @noClassesAvailableText.
  ///
  /// In en, this message translates to:
  /// **'No classes available to assign.'**
  String get noClassesAvailableText;

  /// No description provided for @errorFetchingForms.
  ///
  /// In en, this message translates to:
  /// **'Error fetching forms'**
  String get errorFetchingForms;

  /// No description provided for @errorFetchingFormDetails.
  ///
  /// In en, this message translates to:
  /// **'Error fetching form details'**
  String get errorFetchingFormDetails;

  /// No description provided for @reportSubmittedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Report submitted successfully!'**
  String get reportSubmittedSuccessfully;

  /// No description provided for @failedToSubmitReport.
  ///
  /// In en, this message translates to:
  /// **'Failed to submit report'**
  String get failedToSubmitReport;

  /// No description provided for @errorSubmittingReport.
  ///
  /// In en, this message translates to:
  /// **'Error submitting report'**
  String get errorSubmittingReport;

  /// No description provided for @dailyReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Reports'**
  String get dailyReportsTitle;

  /// No description provided for @childLabel.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get childLabel;

  /// No description provided for @selectReportForm.
  ///
  /// In en, this message translates to:
  /// **'Select Report Form'**
  String get selectReportForm;

  /// No description provided for @selectFormHint.
  ///
  /// In en, this message translates to:
  /// **'Select Form'**
  String get selectFormHint;

  /// No description provided for @submitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get submitted;

  /// No description provided for @formLabel.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get formLabel;

  /// No description provided for @noActiveFormsForToday.
  ///
  /// In en, this message translates to:
  /// **'No active forms for today.'**
  String get noActiveFormsForToday;

  /// No description provided for @pleaseSelectForm.
  ///
  /// In en, this message translates to:
  /// **'Please select a form.'**
  String get pleaseSelectForm;

  /// No description provided for @formHasNoQuestions.
  ///
  /// In en, this message translates to:
  /// **'This form has no questions.'**
  String get formHasNoQuestions;

  /// No description provided for @reportAlreadySubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report already submitted for this form today.'**
  String get reportAlreadySubmitted;

  /// No description provided for @submitReportButton.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReportButton;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number.'**
  String get pleaseEnterValidNumber;

  /// No description provided for @fieldRequiredValidation.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get fieldRequiredValidation;

  /// No description provided for @noParentsAvailableToLink.
  ///
  /// In en, this message translates to:
  /// **'No parents available in this school to link.'**
  String get noParentsAvailableToLink;

  /// No description provided for @linkParentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Link Parents:'**
  String get linkParentsTitle;

  /// No description provided for @unnamedParent.
  ///
  /// In en, this message translates to:
  /// **'Unnamed Parent'**
  String get unnamedParent;

  /// No description provided for @viewFormResponsesTitle.
  ///
  /// In en, this message translates to:
  /// **'View Form Responses'**
  String get viewFormResponsesTitle;

  /// No description provided for @noFormsAvailableToViewResponses.
  ///
  /// In en, this message translates to:
  /// **'No forms available to view responses.'**
  String get noFormsAvailableToViewResponses;

  /// No description provided for @selectFormToViewResponses.
  ///
  /// In en, this message translates to:
  /// **'Select a form to view its responses'**
  String get selectFormToViewResponses;

  /// No description provided for @noResponsesForThisForm.
  ///
  /// In en, this message translates to:
  /// **'No responses submitted for this form yet.'**
  String get noResponsesForThisForm;

  /// No description provided for @responseFrom.
  ///
  /// In en, this message translates to:
  /// **'Response from'**
  String get responseFrom;

  /// No description provided for @submittedOn.
  ///
  /// In en, this message translates to:
  /// **'Submitted on'**
  String get submittedOn;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @totalStudents.
  ///
  /// In en, this message translates to:
  /// **'Total Students'**
  String get totalStudents;

  /// No description provided for @totalTeachers.
  ///
  /// In en, this message translates to:
  /// **'Total Teachers'**
  String get totalTeachers;

  /// No description provided for @totalParents.
  ///
  /// In en, this message translates to:
  /// **'Total Parents'**
  String get totalParents;

  /// No description provided for @formsToday.
  ///
  /// In en, this message translates to:
  /// **'Forms Today'**
  String get formsToday;

  /// No description provided for @createNewFormAction.
  ///
  /// In en, this message translates to:
  /// **'New Form'**
  String get createNewFormAction;

  /// No description provided for @manageFormsAction.
  ///
  /// In en, this message translates to:
  /// **'Manage Forms'**
  String get manageFormsAction;

  /// No description provided for @manageTeachersAction.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get manageTeachersAction;

  /// No description provided for @manageParentsAction.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get manageParentsAction;

  /// No description provided for @viewReportsAction.
  ///
  /// In en, this message translates to:
  /// **'View Reports'**
  String get viewReportsAction;

  /// No description provided for @announcementsAction.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementsAction;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity.'**
  String get noRecentActivity;

  /// No description provided for @error_school_or_user_not_found.
  ///
  /// In en, this message translates to:
  /// **'School or user information not found.'**
  String get error_school_or_user_not_found;

  /// No description provided for @selectGenderHint.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGenderHint;

  /// No description provided for @genderMale.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get genderOther;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @genderValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender.'**
  String get genderValidator;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @studentsDistributionByClassTitle.
  ///
  /// In en, this message translates to:
  /// **'Students by Class'**
  String get studentsDistributionByClassTitle;

  /// No description provided for @publishButton.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publishButton;

  /// No description provided for @allAudience.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allAudience;

  /// No description provided for @teachersAudience.
  ///
  /// In en, this message translates to:
  /// **'Teachers'**
  String get teachersAudience;

  /// No description provided for @parentsAudience.
  ///
  /// In en, this message translates to:
  /// **'Parents'**
  String get parentsAudience;

  /// No description provided for @selectTeacherHint.
  ///
  /// In en, this message translates to:
  /// **'Select Teacher'**
  String get selectTeacherHint;

  /// No description provided for @noTeachersAvailableHint.
  ///
  /// In en, this message translates to:
  /// **'No teachers available'**
  String get noTeachersAvailableHint;

  /// No description provided for @formDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Form Description'**
  String get formDescriptionLabel;

  /// No description provided for @formTargetAudienceLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Audience'**
  String get formTargetAudienceLabel;

  /// No description provided for @formActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get formActiveLabel;

  /// No description provided for @addQuestionButton.
  ///
  /// In en, this message translates to:
  /// **'Add Question'**
  String get addQuestionButton;

  /// No description provided for @fieldType_text.
  ///
  /// In en, this message translates to:
  /// **'Text Input'**
  String get fieldType_text;

  /// No description provided for @fieldType_yesNo.
  ///
  /// In en, this message translates to:
  /// **'Yes/No'**
  String get fieldType_yesNo;

  /// No description provided for @fieldType_multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple Choice (Single Answer)'**
  String get fieldType_multipleChoice;

  /// No description provided for @fieldType_checkbox.
  ///
  /// In en, this message translates to:
  /// **'Checkbox (Multiple Answers)'**
  String get fieldType_checkbox;

  /// No description provided for @fieldType_number.
  ///
  /// In en, this message translates to:
  /// **'Number Input'**
  String get fieldType_number;

  /// No description provided for @optionsForMCQCheckboxLabel.
  ///
  /// In en, this message translates to:
  /// **'Options (for Multiple Choice/Checkbox, one per line)'**
  String get optionsForMCQCheckboxLabel;

  /// No description provided for @addOptionButton.
  ///
  /// In en, this message translates to:
  /// **'Add Option'**
  String get addOptionButton;

  /// No description provided for @optionHint.
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get optionHint;

  /// No description provided for @saveFormButton.
  ///
  /// In en, this message translates to:
  /// **'Save Form'**
  String get saveFormButton;

  /// No description provided for @updateFormButton.
  ///
  /// In en, this message translates to:
  /// **'Update Form'**
  String get updateFormButton;

  /// No description provided for @optionTextValidator.
  ///
  /// In en, this message translates to:
  /// **'Option text cannot be empty'**
  String get optionTextValidator;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categoryValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get categoryValidator;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @phoneNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumberLabel;

  /// No description provided for @addressLabel.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLabel;

  /// No description provided for @profilePhotoLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile Photo'**
  String get profilePhotoLabel;

  /// No description provided for @selectImageButton.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImageButton;

  /// No description provided for @imageSelectedText.
  ///
  /// In en, this message translates to:
  /// **'Image Selected'**
  String get imageSelectedText;

  /// No description provided for @noImageSelectedText.
  ///
  /// In en, this message translates to:
  /// **'No Image Selected'**
  String get noImageSelectedText;

  /// No description provided for @linkedStudentsLabel.
  ///
  /// In en, this message translates to:
  /// **'Linked Students'**
  String get linkedStudentsLabel;

  /// No description provided for @linkStudentButton.
  ///
  /// In en, this message translates to:
  /// **'Link Student'**
  String get linkStudentButton;

  /// No description provided for @searchStudentHint.
  ///
  /// In en, this message translates to:
  /// **'Search student by name or ID'**
  String get searchStudentHint;

  /// No description provided for @noStudentsFoundToLink.
  ///
  /// In en, this message translates to:
  /// **'No students found to link'**
  String get noStudentsFoundToLink;

  /// No description provided for @saveParentButton.
  ///
  /// In en, this message translates to:
  /// **'Save Parent'**
  String get saveParentButton;

  /// No description provided for @noClassesAvailableHint.
  ///
  /// In en, this message translates to:
  /// **'No classes available'**
  String get noClassesAvailableHint;

  /// No description provided for @rollNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Roll Number'**
  String get rollNumberLabel;

  /// No description provided for @parentEmailOptionalLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent Email (Optional)'**
  String get parentEmailOptionalLabel;

  /// No description provided for @classValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select a class'**
  String get classValidator;

  /// No description provided for @dateOfBirthValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter date of birth'**
  String get dateOfBirthValidator;

  /// No description provided for @subjectSpecializationLabel.
  ///
  /// In en, this message translates to:
  /// **'Subject Specialization'**
  String get subjectSpecializationLabel;

  /// No description provided for @qualificationsLabel.
  ///
  /// In en, this message translates to:
  /// **'Qualifications'**
  String get qualificationsLabel;

  /// No description provided for @dateJoinedLabel.
  ///
  /// In en, this message translates to:
  /// **'Date Joined'**
  String get dateJoinedLabel;

  /// No description provided for @dayOfWeekLabel.
  ///
  /// In en, this message translates to:
  /// **'Day of Week'**
  String get dayOfWeekLabel;

  /// No description provided for @selectDayHint.
  ///
  /// In en, this message translates to:
  /// **'Select Day'**
  String get selectDayHint;

  /// No description provided for @startTimeValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select start time'**
  String get startTimeValidator;

  /// No description provided for @endTimeValidator.
  ///
  /// In en, this message translates to:
  /// **'Please select end time'**
  String get endTimeValidator;

  /// No description provided for @manageClassesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Classes'**
  String get manageClassesTitle;

  /// No description provided for @noClassesFound.
  ///
  /// In en, this message translates to:
  /// **'No classes found. Add one!'**
  String get noClassesFound;

  /// No description provided for @confirmDeleteClassText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this class?'**
  String get confirmDeleteClassText;

  /// No description provided for @editSchoolProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit School Profile'**
  String get editSchoolProfileTitle;

  /// No description provided for @schoolLogoLabel.
  ///
  /// In en, this message translates to:
  /// **'School Logo'**
  String get schoolLogoLabel;

  /// No description provided for @changeLogoButton.
  ///
  /// In en, this message translates to:
  /// **'Change Logo'**
  String get changeLogoButton;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @totalExpenses.
  ///
  /// In en, this message translates to:
  /// **'Total Expenses'**
  String get totalExpenses;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalance;

  /// No description provided for @noTransactionsFound.
  ///
  /// In en, this message translates to:
  /// **'No transactions found.'**
  String get noTransactionsFound;

  /// No description provided for @addTransactionButton.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get addTransactionButton;

  /// No description provided for @confirmDeleteTransactionText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get confirmDeleteTransactionText;

  /// No description provided for @manageCustomFormsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Custom Forms'**
  String get manageCustomFormsTitle;

  /// No description provided for @addCustomFormButton.
  ///
  /// In en, this message translates to:
  /// **'Add Custom Form'**
  String get addCustomFormButton;

  /// No description provided for @viewResponsesButton.
  ///
  /// In en, this message translates to:
  /// **'View Responses'**
  String get viewResponsesButton;

  /// No description provided for @confirmDeleteFormText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this form?'**
  String get confirmDeleteFormText;

  /// No description provided for @schoolRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'School Registration'**
  String get schoolRegistrationTitle;

  /// No description provided for @schoolDetailsStep.
  ///
  /// In en, this message translates to:
  /// **'School Details'**
  String get schoolDetailsStep;

  /// No description provided for @adminAccountStep.
  ///
  /// In en, this message translates to:
  /// **'Admin Account'**
  String get adminAccountStep;

  /// No description provided for @nextButton.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextButton;

  /// No description provided for @previousButton.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previousButton;

  /// No description provided for @manageStudentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Students'**
  String get manageStudentsTitle;

  /// No description provided for @confirmDeleteStudentText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this student? This action cannot be undone.'**
  String get confirmDeleteStudentText;

  /// No description provided for @manageTimetablesTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Timetables'**
  String get manageTimetablesTitle;

  /// No description provided for @selectClassToViewTimetableHint.
  ///
  /// In en, this message translates to:
  /// **'Select Class to View Timetable'**
  String get selectClassToViewTimetableHint;

  /// No description provided for @pleaseSelectClassToViewTimetableText.
  ///
  /// In en, this message translates to:
  /// **'Please select a class to view its timetable.'**
  String get pleaseSelectClassToViewTimetableText;

  /// No description provided for @noTimetableEntriesForText.
  ///
  /// In en, this message translates to:
  /// **'No timetable entries for'**
  String get noTimetableEntriesForText;

  /// No description provided for @addOneText.
  ///
  /// In en, this message translates to:
  /// **'Add one!'**
  String get addOneText;

  /// No description provided for @confirmDeleteTimetableEntryText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this timetable entry?'**
  String get confirmDeleteTimetableEntryText;

  /// No description provided for @manageUsersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsersTitle;

  /// No description provided for @noUsersFoundTextPart1.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get noUsersFoundTextPart1;

  /// No description provided for @noUsersFoundTextPart2.
  ///
  /// In en, this message translates to:
  /// **'found. Add one!'**
  String get noUsersFoundTextPart2;

  /// No description provided for @confirmDeleteUserTextPart1.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this'**
  String get confirmDeleteUserTextPart1;

  /// No description provided for @forgotPasswordButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPasswordButtonLabel;

  /// No description provided for @registerNewSchoolButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Register New School (Admin)'**
  String get registerNewSchoolButtonLabel;

  /// No description provided for @adminFullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin\'s Full Name'**
  String get adminFullNameLabel;

  /// No description provided for @adminFullNameValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter admin\'s full name'**
  String get adminFullNameValidator;

  /// No description provided for @adminEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin Email'**
  String get adminEmailLabel;

  /// No description provided for @adminEmailValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter admin email'**
  String get adminEmailValidator;

  /// No description provided for @adminPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Admin Password'**
  String get adminPasswordLabel;

  /// No description provided for @confirmAdminPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm Admin Password'**
  String get confirmAdminPasswordLabel;

  /// No description provided for @academicYearHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., 2024-2025'**
  String get academicYearHint;

  /// No description provided for @noLogoSelected.
  ///
  /// In en, this message translates to:
  /// **'No logo selected'**
  String get noLogoSelected;

  /// No description provided for @logoSelectedLabel.
  ///
  /// In en, this message translates to:
  /// **'Logo selected'**
  String get logoSelectedLabel;

  /// No description provided for @selectLogoButton.
  ///
  /// In en, this message translates to:
  /// **'Select Logo'**
  String get selectLogoButton;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @aboutAppTitle.
  ///
  /// In en, this message translates to:
  /// **'About EduSync Myanmar'**
  String get aboutAppTitle;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'School Management, Simplified.'**
  String get appTagline;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item?'**
  String get confirmDeleteMessage;

  /// No description provided for @noTeacherAssigned.
  ///
  /// In en, this message translates to:
  /// **'No teacher assigned'**
  String get noTeacherAssigned;

  /// No description provided for @cannotDeleteMissingIdError.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete: Item ID is missing.'**
  String get cannotDeleteMissingIdError;

  /// No description provided for @logoUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Logo URL (Optional)'**
  String get logoUrlLabel;

  /// No description provided for @themeLabel.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get themeLabel;

  /// No description provided for @themeHint.
  ///
  /// In en, this message translates to:
  /// **'Select a theme'**
  String get themeHint;

  /// No description provided for @updateProfileButton.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfileButton;

  /// No description provided for @registerSchoolButton.
  ///
  /// In en, this message translates to:
  /// **'Register School'**
  String get registerSchoolButton;

  /// No description provided for @confirmDeleteTeacherText.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this teacher?'**
  String get confirmDeleteTeacherText;

  /// No description provided for @manageTeachersTitle.
  ///
  /// In en, this message translates to:
  /// **'Manage Teachers'**
  String get manageTeachersTitle;

  /// No description provided for @noTeachersFound.
  ///
  /// In en, this message translates to:
  /// **'No teachers found. Add one!'**
  String get noTeachersFound;

  /// No description provided for @parentDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Parent Dashboard'**
  String get parentDashboardTitle;

  /// No description provided for @parentDashboardWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Parent!\nUse the drawer to view your child\'s information and announcements.'**
  String get parentDashboardWelcomeMessage;

  /// No description provided for @teacherDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher Dashboard'**
  String get teacherDashboardTitle;

  /// No description provided for @teacherDashboardWelcomeMessage.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Teacher!\nUse the drawer to access your tools.'**
  String get teacherDashboardWelcomeMessage;

  /// No description provided for @unknownUserRoleError.
  ///
  /// In en, this message translates to:
  /// **'Unknown user role. Please contact support.'**
  String get unknownUserRoleError;

  /// No description provided for @loginFailedError.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your email and password.'**
  String get loginFailedError;

  /// No description provided for @registrationSuccessMessage.
  ///
  /// In en, this message translates to:
  /// **'School and Admin registered successfully! Please log in.'**
  String get registrationSuccessMessage;

  /// No description provided for @failedToLinkAdminError.
  ///
  /// In en, this message translates to:
  /// **'Critical: Failed to link admin to the new school. Please contact support.'**
  String get failedToLinkAdminError;

  /// No description provided for @teacherLabel.
  ///
  /// In en, this message translates to:
  /// **'Teacher'**
  String get teacherLabel;

  /// No description provided for @schoolNameLabel.
  ///
  /// In en, this message translates to:
  /// **'School Name'**
  String get schoolNameLabel;

  /// No description provided for @schoolNameValidator.
  ///
  /// In en, this message translates to:
  /// **'Please enter school name'**
  String get schoolNameValidator;

  /// No description provided for @academicYearLabel.
  ///
  /// In en, this message translates to:
  /// **'Academic Year'**
  String get academicYearLabel;

  /// No description provided for @contactInfoLabel.
  ///
  /// In en, this message translates to:
  /// **'Contact Info'**
  String get contactInfoLabel;

  /// No description provided for @noStudentsFound.
  ///
  /// In en, this message translates to:
  /// **'No students found. Add one!'**
  String get noStudentsFound;

  /// No description provided for @registerSchoolAdminTitle.
  ///
  /// In en, this message translates to:
  /// **'Register School & Admin'**
  String get registerSchoolAdminTitle;

  /// No description provided for @confirmPasswordValidator.
  ///
  /// In en, this message translates to:
  /// **'Please confirm password'**
  String get confirmPasswordValidator;

  /// No description provided for @passwordsDoNotMatchValidator.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatchValidator;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @versionLabel.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionLabel;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'my': return AppLocalizationsMy();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
