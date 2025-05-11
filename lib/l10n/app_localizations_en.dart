// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'EduSync Myanmar';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get teacherDashboard => 'Teacher Dashboard';

  @override
  String get parentDashboard => 'Parent Dashboard';

  @override
  String get welcomeAdmin => 'Welcome, Admin!';

  @override
  String get welcomeTeacher => 'Welcome, Teacher!';

  @override
  String get welcomeParent => 'Welcome, Parent!';

  @override
  String get useDrawerToNavigate => 'Use the drawer to navigate.';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get logout => 'Logout';

  @override
  String get teachers => 'Teachers';

  @override
  String get parents => 'Parents';

  @override
  String get students => 'Students';

  @override
  String get classes => 'Classes';

  @override
  String get error_user_not_found => 'Error: User not found. Please log in again.';

  @override
  String get error_school_not_selected_or_found => 'Error: School not selected or found. Please ensure a school is associated with your account.';

  @override
  String get error_fetching_timetable => 'Error fetching timetable';

  @override
  String get my_timetable_title => 'My Timetable';

  @override
  String get no_timetable_entries_found => 'No timetable entries found.';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get friday => 'Friday';

  @override
  String get saturday => 'Saturday';

  @override
  String get sunday => 'Sunday';

  @override
  String get unknown_subject => 'Unknown Subject';

  @override
  String get classLabel => 'Class';

  @override
  String get unknown_class => 'Unknown Class';

  @override
  String get time => 'Time';

  @override
  String get room => 'Room';

  @override
  String get not_specified => 'Not Specified';

  @override
  String get markAttendanceTitle => 'Mark Attendance';

  @override
  String get selectClassHint => 'Select Class';

  @override
  String get pleaseSelectClass => 'Please select a class.';

  @override
  String get noStudentsInClass => 'No students in this class.';

  @override
  String get saveAttendanceButton => 'Save Attendance';

  @override
  String get classTeacherInfoMissing => 'Class or teacher information missing.';

  @override
  String get attendanceSavedSuccess => 'Attendance saved successfully!';

  @override
  String get attendanceSaveFailed => 'Failed to save attendance.';

  @override
  String get attendanceStatusPresent => 'Present';

  @override
  String get attendanceStatusAbsent => 'Absent';

  @override
  String get attendanceStatusLate => 'Late';

  @override
  String get manageLessonPlansTitle => 'Manage Lesson Plans';

  @override
  String get pleaseSelectClassToViewLessonPlans => 'Please select a class to view lesson plans.';

  @override
  String get noLessonPlansFound => 'No lesson plans found for this class.';

  @override
  String get addLessonPlanTooltip => 'Add New Lesson Plan';

  @override
  String get confirmDeleteTitle => 'Confirm Delete';

  @override
  String get confirmDeleteLessonPlanText => 'Are you sure you want to delete this lesson plan?';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get errorDeletingLessonPlan => 'Error deleting lesson plan.';

  @override
  String get date => 'Date';

  @override
  String get addEditLessonPlanNotImplemented => 'Add/Edit Lesson Plan screen not yet implemented.';

  @override
  String get editClassTitle => 'Edit Class';

  @override
  String get addClassTitle => 'Add Class';

  @override
  String get classNameLabel => 'Class Name';

  @override
  String get classNameValidator => 'Please enter class name';

  @override
  String get selectClassTeacherHint => 'Select Class Teacher';

  @override
  String get classTeacherLabel => 'Class Teacher';

  @override
  String get classTeacherValidator => 'Please select a teacher';

  @override
  String get updateClassButton => 'Update Class';

  @override
  String get addClassButton => 'Add Class';

  @override
  String get failedToLoadTeachersError => 'Failed to load teachers.';

  @override
  String get errorOccurredPrefix => 'An error occurred';

  @override
  String get failedToSaveClassError => 'Failed to save class.';

  @override
  String get unnamedTeacher => 'Unnamed Teacher';

  @override
  String get editTeacherTitle => 'Edit Teacher';

  @override
  String get addTeacherTitle => 'Add Teacher';

  @override
  String get fullNameLabel => 'Full Name';

  @override
  String get fullNameValidator => 'Please enter full name';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailValidator => 'Please enter email';

  @override
  String get passwordLabel => 'Password (min. 6 characters)';

  @override
  String get passwordRequiredValidator => 'Password is required';

  @override
  String get passwordTooShortValidator => 'Password too short';

  @override
  String get noProfilePhoto => 'No profile photo';

  @override
  String get couldNotLoadImage => 'Could not load image';

  @override
  String get selectPhotoButton => 'Select Photo';

  @override
  String get updateTeacherButton => 'Update Teacher';

  @override
  String get addTeacherButton => 'Add Teacher';

  @override
  String get passwordRequiredForNewTeacherError => 'Password is required for new teacher.';

  @override
  String get newTeacherCreationDisabledError => 'New teacher creation is temporarily disabled. Please use Supabase dashboard or an Edge Function.';

  @override
  String get profilePhotoUploadFailedError => 'Profile photo upload failed.';

  @override
  String get failedToUpdateTeacherError => 'Failed to update teacher.';

  @override
  String get failedToCreateTeacherError => 'Failed to create teacher.';

  @override
  String get editParentTitle => 'Edit Parent';

  @override
  String get addParentTitle => 'Add Parent';

  @override
  String get updateParentButton => 'Update Parent';

  @override
  String get addParentButton => 'Add Parent';

  @override
  String get passwordRequiredForNewParentError => 'Password is required for new parent.';

  @override
  String get newParentCreationDisabledError => 'New parent creation is temporarily disabled. Please use Supabase dashboard or an Edge Function.';

  @override
  String get failedToUpdateParentError => 'Failed to update parent.';

  @override
  String get failedToCreateParentError => 'Failed to create parent.';

  @override
  String get editStudentTitle => 'Edit Student';

  @override
  String get addStudentTitle => 'Add Student';

  @override
  String get dateOfBirthLabel => 'Date of Birth';

  @override
  String get dateOfBirthHint => 'YYYY-MM-DD';

  @override
  String get selectClassOptionalHint => 'Select Class (Optional)';

  @override
  String get classOptionalLabel => 'Class (Optional)';

  @override
  String get updateStudentButton => 'Update Student';

  @override
  String get addStudentButton => 'Add Student';

  @override
  String get failedToLoadClassesError => 'Failed to load classes.';

  @override
  String get failedToUpdateStudentError => 'Failed to update student.';

  @override
  String get failedToCreateStudentError => 'Failed to create student.';

  @override
  String get editTimetableEntryTitle => 'Edit Timetable Entry';

  @override
  String get addTimetableEntryTitle => 'Add Timetable Entry';

  @override
  String get subjectNameLabel => 'Subject Name';

  @override
  String get subjectNameValidator => 'Please enter subject name';

  @override
  String get selectDayOfWeekHint => 'Select Day of Week';

  @override
  String get dayValidator => 'Please select a day';

  @override
  String get startTimeLabelPrefix => 'Start Time: ';

  @override
  String get endTimeLabelPrefix => 'End Time: ';

  @override
  String get timeNotSet => 'Not set';

  @override
  String get updateEntryButton => 'Update Entry';

  @override
  String get addEntryButton => 'Add Entry';

  @override
  String get fillAllFieldsError => 'Please fill all fields, including time, day, class, and teacher.';

  @override
  String get endTimeAfterStartTimeError => 'End time must be after start time.';

  @override
  String get failedToSaveTimetableEntryError => 'Failed to save timetable entry.';

  @override
  String get failedToLoadTimetableDataError => 'Failed to load necessary data for timetable entry.';

  @override
  String get financeManagementTitle => 'Finance Management';

  @override
  String get incomeTabLabel => 'Income';

  @override
  String get expensesTabLabel => 'Expenses';

  @override
  String get addIncomeTooltip => 'Add Income Record';

  @override
  String get addExpenseTooltip => 'Add Expense Record';

  @override
  String get financialSummaryTitle => 'Financial Summary';

  @override
  String get totalIncomeLabel => 'Total Income';

  @override
  String get totalExpensesLabel => 'Total Expenses';

  @override
  String get netBalanceLabel => 'Net Balance';

  @override
  String get noIncomeRecordsFound => 'No income records found.';

  @override
  String get noExpenseRecordsFound => 'No expense records found.';

  @override
  String get confirmDeleteIncomeText => 'Are you sure you want to delete this income record?';

  @override
  String get confirmDeleteExpenseText => 'Are you sure you want to delete this expense record?';

  @override
  String get errorDeletingIncome => 'Error deleting income record.';

  @override
  String get errorDeletingExpense => 'Error deleting expense record.';

  @override
  String get addEditFinancialRecordNotImplemented => 'Add/Edit financial record screen not yet implemented.';

  @override
  String get editIncomeTitle => 'Edit Income';

  @override
  String get addIncomeTitle => 'Add Income';

  @override
  String get editExpenseTitle => 'Edit Expense';

  @override
  String get addExpenseTitle => 'Add Expense';

  @override
  String get descriptionLabel => 'Description';

  @override
  String get descriptionValidator => 'Please enter a description.';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountValidator => 'Please enter an amount.';

  @override
  String get invalidAmountError => 'Please enter a valid positive amount.';

  @override
  String get recordDateLabel => 'Date';

  @override
  String get dateValidator => 'Please select a date.';

  @override
  String get updateButton => 'Update';

  @override
  String get addButton => 'Add';

  @override
  String get failedToSaveRecordError => 'Failed to save record.';

  @override
  String get announcementsTitle => 'Announcements';

  @override
  String get noAnnouncementsFound => 'No announcements found.';

  @override
  String get postedOn => 'Posted on';

  @override
  String get childAttendanceTitle => 'Child\'s Attendance';

  @override
  String get noChildrenLinked => 'No children linked to your account.';

  @override
  String get selectChildHint => 'Select Child';

  @override
  String get pleaseSelectChild => 'Please select a child to view attendance.';

  @override
  String get noAttendanceRecordsFound => 'No attendance records found for the selected child and month.';

  @override
  String get childScheduleTitle => 'Child\'s Schedule';

  @override
  String get childNotAssignedToClass => 'Child is not currently assigned to a class or no schedule is available.';

  @override
  String get noScheduleFound => 'No schedule found for the selected child\'s class.';

  @override
  String get manageAnnouncementsTitle => 'Manage Announcements';

  @override
  String get addAnnouncementTooltip => 'Add New Announcement';

  @override
  String get confirmDeleteAnnouncementText => 'Are you sure you want to delete this announcement?';

  @override
  String get errorDeletingAnnouncement => 'Error deleting announcement.';

  @override
  String get actionRequiresSchoolAndAdminContext => 'Action requires school and admin context.';

  @override
  String get addEditAnnouncementNotImplemented => 'Add/Edit Announcement screen not yet implemented.';

  @override
  String get targetAudience => 'Target Audience';

  @override
  String get all => 'All';

  @override
  String get specificclass => 'Specific Class';

  @override
  String get closeButtonLabel => 'Close';

  @override
  String get pleaseSelectClassForAnnouncement => 'Please select a class for this announcement.';

  @override
  String get failedToSaveAnnouncementError => 'Failed to save announcement.';

  @override
  String get editAnnouncementTitle => 'Edit Announcement';

  @override
  String get addAnnouncementTitle => 'Add Announcement';

  @override
  String get titleLabel => 'Title';

  @override
  String get titleValidator => 'Please enter a title.';

  @override
  String get contentLabel => 'Content';

  @override
  String get contentValidator => 'Please enter content.';

  @override
  String get selectTargetAudienceHint => 'Select Target Audience';

  @override
  String get targetAudienceValidator => 'Please select a target audience.';

  @override
  String get manageAnnouncementsDrawerItem => 'Manage Announcements';

  @override
  String get classOrUserMissingError => 'Class or user information is missing to save attendance.';

  @override
  String get failedToLoadInitialData => 'Failed to load initial data.';

  @override
  String get failedToLoadSubjects => 'Failed to load subjects for the selected class.';

  @override
  String get fillAllRequiredFields => 'Please fill all required fields.';

  @override
  String get failedToSaveLessonPlanError => 'Failed to save lesson plan.';

  @override
  String get editLessonPlanTitle => 'Edit Lesson Plan';

  @override
  String get addLessonPlanTitle => 'Add Lesson Plan';

  @override
  String get selectSubjectHint => 'Select Subject';

  @override
  String get subjectLabel => 'Subject';

  @override
  String get subjectValidator => 'Please select a subject.';

  @override
  String get pleaseSelectClassFirstForSubjects => 'Please select a class to see available subjects.';

  @override
  String get noSubjectsFoundForClass => 'No subjects found for the selected class. Please check timetable.';

  @override
  String get manageDailyReportFormsTitle => 'Manage Daily Report Forms';

  @override
  String get confirmDeleteCustomFormText => 'Are you sure you want to delete this form and all its responses? This action cannot be undone.';

  @override
  String get errorDeletingCustomFormText => 'Error deleting custom form.';

  @override
  String get noCustomFormsFoundText => 'No custom forms found. Tap \'+\' to create one.';

  @override
  String get addCustomFormTooltip => 'Add New Report Form';

  @override
  String get activeFrom => 'Active From';

  @override
  String get activeTo => 'Active To';

  @override
  String get daily => 'Daily';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get formDetailsTitle => 'Form Details';

  @override
  String get formTitleLabel => 'Form Title';

  @override
  String get formTitleValidator => 'Form title is required.';

  @override
  String get dailyReportLabel => 'Daily Recurring Report';

  @override
  String get assignToLabel => 'Assign To:';

  @override
  String get assignToWholeSchoolLabel => 'Whole School';

  @override
  String get formQuestionsTitle => 'Form Questions';

  @override
  String get addQuestionTooltip => 'Add Question';

  @override
  String get noQuestionsAddedText => 'No questions added yet. Click \'+\' to add.';

  @override
  String get pleaseSelectActiveDatesError => 'Please select active dates.';

  @override
  String get activeToDateError => 'Active To date must be after Active From date.';

  @override
  String get addAtLeastOneQuestionError => 'Please add at least one question to the form.';

  @override
  String get failedToSaveFormError => 'Failed to save form.';

  @override
  String get editReportFormTitle => 'Edit Report Form';

  @override
  String get createReportFormTitle => 'Create Report Form';

  @override
  String get editQuestionTitle => 'Edit Question';

  @override
  String get addQuestionTitle => 'Add Question';

  @override
  String get questionTextLabel => 'Question Text';

  @override
  String get questionTextValidator => 'Question text is required.';

  @override
  String get questionTypeLabel => 'Question Type';

  @override
  String get optionsLabel => 'Options (one per line)';

  @override
  String get optionsRequiredError => 'Options are required for this question type.';

  @override
  String get atLeastTwoOptionsError => 'At least two options are required for this question type.';

  @override
  String get requiredLabel => 'Required';

  @override
  String get typePrefixLabel => 'Type';

  @override
  String get requiredSuffix => '(Required)';

  @override
  String get manageDailyReportsDrawerItem => 'Manage Daily Reports';

  @override
  String get assignToClassesLabel => 'Assign to Specific Classes:';

  @override
  String get noClassesAvailableText => 'No classes available to assign.';

  @override
  String get errorFetchingForms => 'Error fetching forms';

  @override
  String get errorFetchingFormDetails => 'Error fetching form details';

  @override
  String get reportSubmittedSuccessfully => 'Report submitted successfully!';

  @override
  String get failedToSubmitReport => 'Failed to submit report';

  @override
  String get errorSubmittingReport => 'Error submitting report';

  @override
  String get dailyReportsTitle => 'Daily Reports';

  @override
  String get childLabel => 'Child';

  @override
  String get selectReportForm => 'Select Report Form';

  @override
  String get selectFormHint => 'Select Form';

  @override
  String get submitted => 'Submitted';

  @override
  String get formLabel => 'Form';

  @override
  String get noActiveFormsForToday => 'No active forms for today.';

  @override
  String get pleaseSelectForm => 'Please select a form.';

  @override
  String get formHasNoQuestions => 'This form has no questions.';

  @override
  String get reportAlreadySubmitted => 'Report already submitted for this form today.';

  @override
  String get submitReportButton => 'Submit Report';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number.';

  @override
  String get fieldRequiredValidation => 'This field is required.';

  @override
  String get noParentsAvailableToLink => 'No parents available in this school to link.';

  @override
  String get linkParentsTitle => 'Link Parents:';

  @override
  String get unnamedParent => 'Unnamed Parent';

  @override
  String get viewFormResponsesTitle => 'View Form Responses';

  @override
  String get noFormsAvailableToViewResponses => 'No forms available to view responses.';

  @override
  String get selectFormToViewResponses => 'Select a form to view its responses';

  @override
  String get noResponsesForThisForm => 'No responses submitted for this form yet.';

  @override
  String get responseFrom => 'Response from';

  @override
  String get submittedOn => 'Submitted on';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get totalStudents => 'Total Students';

  @override
  String get totalTeachers => 'Total Teachers';

  @override
  String get totalParents => 'Total Parents';

  @override
  String get formsToday => 'Forms Today';

  @override
  String get createNewFormAction => 'New Form';

  @override
  String get manageFormsAction => 'Manage Forms';

  @override
  String get manageTeachersAction => 'Teachers';

  @override
  String get manageParentsAction => 'Parents';

  @override
  String get viewReportsAction => 'View Reports';

  @override
  String get announcementsAction => 'Announcements';

  @override
  String get noRecentActivity => 'No recent activity.';

  @override
  String get error_school_or_user_not_found => 'School or user information not found.';

  @override
  String get selectGenderHint => 'Select Gender';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get genderLabel => 'Gender';

  @override
  String get genderValidator => 'Please select a gender.';

  @override
  String get unassigned => 'Unassigned';

  @override
  String get noDataAvailable => 'No data available';

  @override
  String get studentsDistributionByClassTitle => 'Students by Class';

  @override
  String get publishButton => 'Publish';

  @override
  String get allAudience => 'All';

  @override
  String get teachersAudience => 'Teachers';

  @override
  String get parentsAudience => 'Parents';

  @override
  String get selectTeacherHint => 'Select Teacher';

  @override
  String get noTeachersAvailableHint => 'No teachers available';

  @override
  String get formDescriptionLabel => 'Form Description';

  @override
  String get formTargetAudienceLabel => 'Target Audience';

  @override
  String get formActiveLabel => 'Active';

  @override
  String get addQuestionButton => 'Add Question';

  @override
  String get fieldType_text => 'Text Input';

  @override
  String get fieldType_yesNo => 'Yes/No';

  @override
  String get fieldType_multipleChoice => 'Multiple Choice (Single Answer)';

  @override
  String get fieldType_checkbox => 'Checkbox (Multiple Answers)';

  @override
  String get fieldType_number => 'Number Input';

  @override
  String get optionsForMCQCheckboxLabel => 'Options (for Multiple Choice/Checkbox, one per line)';

  @override
  String get addOptionButton => 'Add Option';

  @override
  String get optionHint => 'Option';

  @override
  String get saveFormButton => 'Save Form';

  @override
  String get updateFormButton => 'Update Form';

  @override
  String get optionTextValidator => 'Option text cannot be empty';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryValidator => 'Please select a category';

  @override
  String get saveButton => 'Save';

  @override
  String get phoneNumberLabel => 'Phone Number';

  @override
  String get addressLabel => 'Address';

  @override
  String get profilePhotoLabel => 'Profile Photo';

  @override
  String get selectImageButton => 'Select Image';

  @override
  String get imageSelectedText => 'Image Selected';

  @override
  String get noImageSelectedText => 'No Image Selected';

  @override
  String get linkedStudentsLabel => 'Linked Students';

  @override
  String get linkStudentButton => 'Link Student';

  @override
  String get searchStudentHint => 'Search student by name or ID';

  @override
  String get noStudentsFoundToLink => 'No students found to link';

  @override
  String get saveParentButton => 'Save Parent';

  @override
  String get noClassesAvailableHint => 'No classes available';

  @override
  String get rollNumberLabel => 'Roll Number';

  @override
  String get parentEmailOptionalLabel => 'Parent Email (Optional)';

  @override
  String get classValidator => 'Please select a class';

  @override
  String get dateOfBirthValidator => 'Please enter date of birth';

  @override
  String get subjectSpecializationLabel => 'Subject Specialization';

  @override
  String get qualificationsLabel => 'Qualifications';

  @override
  String get dateJoinedLabel => 'Date Joined';

  @override
  String get dayOfWeekLabel => 'Day of Week';

  @override
  String get selectDayHint => 'Select Day';

  @override
  String get startTimeValidator => 'Please select start time';

  @override
  String get endTimeValidator => 'Please select end time';

  @override
  String get manageClassesTitle => 'Manage Classes';

  @override
  String get noClassesFound => 'No classes found. Add one!';

  @override
  String get confirmDeleteClassText => 'Are you sure you want to delete this class?';

  @override
  String get editSchoolProfileTitle => 'Edit School Profile';

  @override
  String get schoolLogoLabel => 'School Logo';

  @override
  String get changeLogoButton => 'Change Logo';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get totalIncome => 'Total Income';

  @override
  String get totalExpenses => 'Total Expenses';

  @override
  String get netBalance => 'Net Balance';

  @override
  String get noTransactionsFound => 'No transactions found.';

  @override
  String get addTransactionButton => 'Add Transaction';

  @override
  String get confirmDeleteTransactionText => 'Are you sure you want to delete this transaction?';

  @override
  String get manageCustomFormsTitle => 'Manage Custom Forms';

  @override
  String get addCustomFormButton => 'Add Custom Form';

  @override
  String get viewResponsesButton => 'View Responses';

  @override
  String get confirmDeleteFormText => 'Are you sure you want to delete this form?';

  @override
  String get schoolRegistrationTitle => 'School Registration';

  @override
  String get schoolDetailsStep => 'School Details';

  @override
  String get adminAccountStep => 'Admin Account';

  @override
  String get nextButton => 'Next';

  @override
  String get previousButton => 'Previous';

  @override
  String get manageStudentsTitle => 'Manage Students';

  @override
  String get confirmDeleteStudentText => 'Are you sure you want to delete this student? This action cannot be undone.';

  @override
  String get manageTimetablesTitle => 'Manage Timetables';

  @override
  String get selectClassToViewTimetableHint => 'Select Class to View Timetable';

  @override
  String get pleaseSelectClassToViewTimetableText => 'Please select a class to view its timetable.';

  @override
  String get noTimetableEntriesForText => 'No timetable entries for';

  @override
  String get addOneText => 'Add one!';

  @override
  String get confirmDeleteTimetableEntryText => 'Are you sure you want to delete this timetable entry?';

  @override
  String get manageUsersTitle => 'Manage Users';

  @override
  String get noUsersFoundTextPart1 => 'No';

  @override
  String get noUsersFoundTextPart2 => 'found. Add one!';

  @override
  String get confirmDeleteUserTextPart1 => 'Are you sure you want to delete this';

  @override
  String get forgotPasswordButtonLabel => 'Forgot Password?';

  @override
  String get registerNewSchoolButtonLabel => 'Register New School (Admin)';

  @override
  String get adminFullNameLabel => 'Admin\'s Full Name';

  @override
  String get adminFullNameValidator => 'Please enter admin\'s full name';

  @override
  String get adminEmailLabel => 'Admin Email';

  @override
  String get adminEmailValidator => 'Please enter admin email';

  @override
  String get adminPasswordLabel => 'Admin Password';

  @override
  String get confirmAdminPasswordLabel => 'Confirm Admin Password';

  @override
  String get academicYearHint => 'e.g., 2024-2025';

  @override
  String get noLogoSelected => 'No logo selected';

  @override
  String get logoSelectedLabel => 'Logo selected';

  @override
  String get selectLogoButton => 'Select Logo';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get aboutAppTitle => 'About EduSync Myanmar';

  @override
  String get appTagline => 'School Management, Simplified.';

  @override
  String get editButton => 'Edit';

  @override
  String get deleteButton => 'Delete';

  @override
  String get confirmDeleteMessage => 'Are you sure you want to delete this item?';

  @override
  String get noTeacherAssigned => 'No teacher assigned';

  @override
  String get cannotDeleteMissingIdError => 'Cannot delete: Item ID is missing.';

  @override
  String get logoUrlLabel => 'Logo URL (Optional)';

  @override
  String get themeLabel => 'App Theme';

  @override
  String get themeHint => 'Select a theme';

  @override
  String get updateProfileButton => 'Update Profile';

  @override
  String get registerSchoolButton => 'Register School';

  @override
  String get confirmDeleteTeacherText => 'Are you sure you want to delete this teacher?';

  @override
  String get manageTeachersTitle => 'Manage Teachers';

  @override
  String get noTeachersFound => 'No teachers found. Add one!';

  @override
  String get parentDashboardTitle => 'Parent Dashboard';

  @override
  String get parentDashboardWelcomeMessage => 'Welcome, Parent!\nUse the drawer to view your child\'s information and announcements.';

  @override
  String get teacherDashboardTitle => 'Teacher Dashboard';

  @override
  String get teacherDashboardWelcomeMessage => 'Welcome, Teacher!\nUse the drawer to access your tools.';

  @override
  String get unknownUserRoleError => 'Unknown user role. Please contact support.';

  @override
  String get loginFailedError => 'Login failed. Please check your email and password.';

  @override
  String get registrationSuccessMessage => 'School and Admin registered successfully! Please log in.';

  @override
  String get failedToLinkAdminError => 'Critical: Failed to link admin to the new school. Please contact support.';

  @override
  String get teacherLabel => 'Teacher';

  @override
  String get schoolNameLabel => 'School Name';

  @override
  String get schoolNameValidator => 'Please enter school name';

  @override
  String get academicYearLabel => 'Academic Year';

  @override
  String get contactInfoLabel => 'Contact Info';

  @override
  String get noStudentsFound => 'No students found. Add one!';

  @override
  String get registerSchoolAdminTitle => 'Register School & Admin';

  @override
  String get confirmPasswordValidator => 'Please confirm password';

  @override
  String get passwordsDoNotMatchValidator => 'Passwords do not match';

  @override
  String get registerButton => 'Register';

  @override
  String get versionLabel => 'Version';
}
