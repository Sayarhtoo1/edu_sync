// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'EduSync မြန်မာ';

  @override
  String get login => 'ဝင်မည်';

  @override
  String get email => 'အီးမေးလ်';

  @override
  String get password => 'စကားဝှက်';

  @override
  String get adminPanel => 'အက်မင် ပאנل';

  @override
  String get teacherDashboard => 'ဆရာ ဒက်ရှ်ဘုတ်';

  @override
  String get parentDashboard => 'မိဘ ဒက်ရှ်ဘုတ်';

  @override
  String get welcomeAdmin => 'အက်မင်၊ ကြိုဆိုပါတယ်။';

  @override
  String get welcomeTeacher => 'ဆရာ/မ၊ ကြိုဆိုပါတယ်။';

  @override
  String get welcomeParent => 'မိဘ၊ ကြိုဆိုပါတယ်။';

  @override
  String get useDrawerToNavigate => 'သွားလာရန် အံဆွဲကို အသုံးပြုပါ။';

  @override
  String get settings => 'ဆက်တင်များ';

  @override
  String get language => 'ဘာသာစကား';

  @override
  String get logout => 'ထွက်မည်';

  @override
  String get teachers => 'ဆရာများ';

  @override
  String get parents => 'မိဘများ';

  @override
  String get students => 'ကျောင်းသားများ';

  @override
  String get classes => 'အတန်းများ';

  @override
  String get error_user_not_found => 'အမှားအယွင်း - အသုံးပြုသူကို ရှာမတွေ့ပါ။ ကျေးဇူးပြု၍ ပြန်လည်ဝင်ရောက်ပါ။';

  @override
  String get error_school_not_selected_or_found => 'အမှားအယွင်း - ကျောင်းကို ရွေးချယ်ထားခြင်း သို့မဟုတ် ရှာမတွေ့ပါ။ သင်၏အကောင့်နှင့် ကျောင်းတစ်ခု ချိတ်ဆက်ထားကြောင်း သေချာပါစေ။';

  @override
  String get error_fetching_timetable => 'အချိန်ဇယား ရယူရာတွင် အမှားအယွင်းဖြစ်ပွားခဲ့သည်။';

  @override
  String get my_timetable_title => 'ကျွန်ုပ်၏ အချိန်ဇယား';

  @override
  String get no_timetable_entries_found => 'အချိန်ဇယား ထည့်သွင်းမှုများ မတွေ့ပါ။';

  @override
  String get monday => 'တနင်္လာ';

  @override
  String get tuesday => 'အင်္ဂါ';

  @override
  String get wednesday => 'ဗုဒ္ဓဟူး';

  @override
  String get thursday => 'ကြာသပတေး';

  @override
  String get friday => 'သောကြာ';

  @override
  String get saturday => 'စနေ';

  @override
  String get sunday => 'တနင်္ဂနွေ';

  @override
  String get unknown_subject => 'အမည်မသိ ဘာသာရပ်';

  @override
  String get classLabel => 'အတန်း';

  @override
  String get unknown_class => 'အမည်မသိ အတန်း';

  @override
  String get time => 'အချိန်';

  @override
  String get room => 'အခန်း';

  @override
  String get not_specified => 'သတ်မှတ်မထားပါ';

  @override
  String get markAttendanceTitle => 'တက်ရောက်မှု မှတ်သားရန်';

  @override
  String get selectClassHint => 'အတန်း ရွေးပါ';

  @override
  String get pleaseSelectClass => 'ကျေးဇူးပြု၍ အတန်းတစ်ခု ရွေးပါ။';

  @override
  String get noStudentsInClass => 'ဤအတန်းတွင် ကျောင်းသားမရှိပါ။';

  @override
  String get saveAttendanceButton => 'တက်ရောက်မှု သိမ်းဆည်းရန်';

  @override
  String get classTeacherInfoMissing => 'အတန်း သို့မဟုတ် ဆရာ/မ အချက်အလက် မပြည့်စုံပါ။';

  @override
  String get attendanceSavedSuccess => 'တက်ရောက်မှုကို အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ။';

  @override
  String get attendanceSaveFailed => 'တက်ရောက်မှု သိမ်းဆည်းခြင်း မအောင်မြင်ပါ။';

  @override
  String get attendanceStatusPresent => 'ရောက်ရှိ';

  @override
  String get attendanceStatusAbsent => 'ပျက်ကွက်';

  @override
  String get attendanceStatusLate => 'နောက်ကျ';

  @override
  String get manageLessonPlansTitle => 'သင်ခန်းစာ အစီအစဉ်များ စီမံရန်';

  @override
  String get pleaseSelectClassToViewLessonPlans => 'သင်ခန်းစာ အစီအစဉ်များ ကြည့်ရန် အတန်းတစ်ခု ရွေးပါ။';

  @override
  String get noLessonPlansFound => 'ဤအတန်းအတွက် သင်ခန်းစာ အစီအစဉ်များ မတွေ့ပါ။';

  @override
  String get addLessonPlanTooltip => 'သင်ခန်းစာ အစီအစဉ်သစ် ထည့်ရန်';

  @override
  String get confirmDeleteTitle => 'ဖျက်ရန် အတည်ပြုပါ';

  @override
  String get confirmDeleteLessonPlanText => 'ဤသင်ခန်းစာ အစီအစဉ်ကို ဖျက်ရန် သေချာပါသလား။';

  @override
  String get cancel => 'မလုပ်တော့ပါ';

  @override
  String get delete => 'ဖျက်မည်';

  @override
  String get errorDeletingLessonPlan => 'သင်ခန်းစာ အစီအစဉ် ဖျက်ရာတွင် အမှားအယွင်းဖြစ်ပွားခဲ့သည်။';

  @override
  String get date => 'ရက်စွဲ';

  @override
  String get addEditLessonPlanNotImplemented => 'သင်ခန်းစာ အစီအစဉ် ထည့်/ပြင်ရန် မျက်နှာပြင်ကို မပြုလုပ်ရသေးပါ။';

  @override
  String get editClassTitle => 'အတန်း ပြင်ရန်';

  @override
  String get addClassTitle => 'အတန်းသစ် ထည့်ရန်';

  @override
  String get classNameLabel => 'အတန်းအမည်';

  @override
  String get classNameValidator => 'ကျေးဇူးပြု၍ အတန်းအမည် ထည့်ပါ။';

  @override
  String get selectClassTeacherHint => 'အတန်းပိုင် ဆရာ/မ ရွေးပါ';

  @override
  String get classTeacherLabel => 'အတန်းပိုင် ဆရာ/မ';

  @override
  String get classTeacherValidator => 'ကျေးဇူးပြု၍ ဆရာ/မ တစ်ဦး ရွေးပါ။';

  @override
  String get updateClassButton => 'အတန်း အချက်အလက် ပြင်ရန်';

  @override
  String get addClassButton => 'အတန်းသစ် ထည့်ရန်';

  @override
  String get failedToLoadTeachersError => 'ဆရာ/မများ စာရင်း ရယူခြင်း မအောင်မြင်ပါ။';

  @override
  String get errorOccurredPrefix => 'အမှားအယွင်း ဖြစ်ပွားခဲ့သည်';

  @override
  String get failedToSaveClassError => 'အတန်း သိမ်းဆည်းခြင်း မအောင်မြင်ပါ။';

  @override
  String get unnamedTeacher => 'အမည်မဖော်ပြထားသော ဆရာ/မ';

  @override
  String get editTeacherTitle => 'ဆရာ/မ အချက်အလက် ပြင်ရန်';

  @override
  String get addTeacherTitle => 'ဆရာ/မ အသစ်ထည့်ရန်';

  @override
  String get fullNameLabel => 'အမည်အပြည့်အစုံ';

  @override
  String get fullNameValidator => 'ကျေးဇူးပြု၍ အမည်အပြည့်အစုံ ထည့်ပါ။';

  @override
  String get emailLabel => 'အီးမေးလ်';

  @override
  String get emailValidator => 'ကျေးဇူးပြု၍ အီးမေးလ် ထည့်ပါ။';

  @override
  String get passwordLabel => 'စကားဝှက် (အနည်းဆုံး စာလုံး ၆ လုံး)';

  @override
  String get passwordRequiredValidator => 'စကားဝှက် လိုအပ်သည်';

  @override
  String get passwordTooShortValidator => 'စကားဝှက် တိုလွန်းသည်';

  @override
  String get noProfilePhoto => 'ပရိုဖိုင်ဓာတ်ပုံ မရှိပါ';

  @override
  String get couldNotLoadImage => 'ပုံကို တင်၍မရပါ';

  @override
  String get selectPhotoButton => 'ဓာတ်ပုံ ရွေးပါ';

  @override
  String get updateTeacherButton => 'ဆရာ/မ အချက်အလက် ပြင်ရန်';

  @override
  String get addTeacherButton => 'ဆရာ/မ အသစ်ထည့်ရန်';

  @override
  String get passwordRequiredForNewTeacherError => 'ဆရာ/မ အသစ်အတွက် စကားဝှက် လိုအပ်ပါသည်။';

  @override
  String get newTeacherCreationDisabledError => 'ဆရာ/မ အသစ်ပြုလုပ်ခြင်းကို ခေတ္တပိတ်ထားသည်။ Supabase dashboard (သို့) Edge Function ကို အသုံးပြုပါ။';

  @override
  String get profilePhotoUploadFailedError => 'ပရိုဖိုင်ဓာတ်ပုံ တင်ခြင်း မအောင်မြင်ပါ။';

  @override
  String get failedToUpdateTeacherError => 'ဆရာ/မ အချက်အလက် ပြင်ဆင်ခြင်း မအောင်မြင်ပါ။';

  @override
  String get failedToCreateTeacherError => 'ဆရာ/မ အသစ်ပြုလုပ်ခြင်း မအောင်မြင်ပါ။';

  @override
  String get editParentTitle => 'မိဘ အချက်အလက် ပြင်ရန်';

  @override
  String get addParentTitle => 'မိဘ အသစ်ထည့်ရန်';

  @override
  String get updateParentButton => 'မိဘ အချက်အလက် ပြင်ရန်';

  @override
  String get addParentButton => 'မိဘ အသစ်ထည့်ရန်';

  @override
  String get passwordRequiredForNewParentError => 'မိဘ အသစ်အတွက် စကားဝှက် လိုအပ်ပါသည်။';

  @override
  String get newParentCreationDisabledError => 'မိဘ အသစ်ပြုလုပ်ခြင်းကို ခေတ္တပိတ်ထားသည်။ Supabase dashboard (သို့) Edge Function ကို အသုံးပြုပါ။';

  @override
  String get failedToUpdateParentError => 'မိဘ အချက်အလက် ပြင်ဆင်ခြင်း မအောင်မြင်ပါ။';

  @override
  String get failedToCreateParentError => 'မိဘ အသစ်ပြုလုပ်ခြင်း မအောင်မြင်ပါ။';

  @override
  String get editStudentTitle => 'ကျောင်းသား ပြင်ရန်';

  @override
  String get addStudentTitle => 'ကျောင်းသားသစ် ထည့်ရန်';

  @override
  String get dateOfBirthLabel => 'မွေးသက္ကရာဇ်';

  @override
  String get dateOfBirthHint => 'YYYY-MM-DD';

  @override
  String get selectClassOptionalHint => 'အတန်း ရွေးပါ (ရွေးချယ်နိုင်)';

  @override
  String get classOptionalLabel => 'အတန်း (ရွေးချယ်နိုင်)';

  @override
  String get updateStudentButton => 'ကျောင်းသား အချက်အလက် ပြင်ရန်';

  @override
  String get addStudentButton => 'ကျောင်းသားသစ် ထည့်ရန်';

  @override
  String get failedToLoadClassesError => 'အတန်းများ စာရင်း ရယူခြင်း မအောင်မြင်ပါ။';

  @override
  String get failedToUpdateStudentError => 'ကျောင်းသား အချက်အလက် ပြင်ဆင်ခြင်း မအောင်မြင်ပါ။';

  @override
  String get failedToCreateStudentError => 'ကျောင်းသားသစ် ပြုလုပ်ခြင်း မအောင်မြင်ပါ။';

  @override
  String get editTimetableEntryTitle => 'အချိန်ဇယား ပြင်ရန်';

  @override
  String get addTimetableEntryTitle => 'အချိန်ဇယား ထည့်ရန်';

  @override
  String get subjectNameLabel => 'ဘာသာရပ်အမည်';

  @override
  String get subjectNameValidator => 'ကျေးဇူးပြု၍ ဘာသာရပ်အမည် ထည့်ပါ။';

  @override
  String get selectDayOfWeekHint => 'နေ့ ရွေးပါ';

  @override
  String get dayValidator => 'ကျေးဇူးပြု၍ နေ့တစ်ခု ရွေးပါ။';

  @override
  String get startTimeLabelPrefix => 'စတင်ချိန်: ';

  @override
  String get endTimeLabelPrefix => 'ပြီးဆုံးချိန်: ';

  @override
  String get timeNotSet => 'မသတ်မှတ်ရသေး';

  @override
  String get updateEntryButton => 'ပြင်ဆင်ရန်';

  @override
  String get addEntryButton => 'ထည့်ရန်';

  @override
  String get fillAllFieldsError => 'ကျေးဇူးပြု၍ အချိန်၊ နေ့၊ အတန်း၊ နှင့် ဆရာ/မ အပါအဝင် အကွက်အားလုံးကို ဖြည့်ပါ။';

  @override
  String get endTimeAfterStartTimeError => 'ပြီးဆုံးချိန်သည် စတင်ချိန်ထက် နောက်ကျရပါမည်။';

  @override
  String get failedToSaveTimetableEntryError => 'အချိန်ဇယား သိမ်းဆည်းခြင်း မအောင်မြင်ပါ။';

  @override
  String get failedToLoadTimetableDataError => 'အချိန်ဇယားအတွက် လိုအပ်သော အချက်အလက်များ ရယူခြင်း မအောင်မြင်ပါ။';

  @override
  String get financeManagementTitle => 'ဘဏ္ဍာရေး စီမံခန့်ခွဲမှု';

  @override
  String get incomeTabLabel => 'ဝင်ငွေ';

  @override
  String get expensesTabLabel => 'အသုံးစရိတ်';

  @override
  String get addIncomeTooltip => 'ဝင်ငွေ မှတ်တမ်းထည့်ရန်';

  @override
  String get addExpenseTooltip => 'အသုံးစရိတ် မှတ်တမ်းထည့်ရန်';

  @override
  String get financialSummaryTitle => 'ဘဏ္ဍာရေး အနှစ်ချုပ်';

  @override
  String get totalIncomeLabel => 'စုစုပေါင်း ဝင်ငွေ';

  @override
  String get totalExpensesLabel => 'စုစုပေါင်း အသုံးစရိတ်';

  @override
  String get netBalanceLabel => 'လက်ကျန်ငွေ';

  @override
  String get noIncomeRecordsFound => 'ဝင်ငွေ မှတ်တမ်းများ မတွေ့ပါ။';

  @override
  String get noExpenseRecordsFound => 'အသုံးစရိတ် မှတ်တမ်းများ မတွေ့ပါ။';

  @override
  String get confirmDeleteIncomeText => 'ဤဝင်ငွေ မှတ်တမ်းကို ဖျက်ရန် သေချာပါသလား။';

  @override
  String get confirmDeleteExpenseText => 'ဤအသုံးစရိတ် မှတ်တမ်းကို ဖျက်ရန် သေချာပါသလား။';

  @override
  String get errorDeletingIncome => 'ဝင်ငွေ မှတ်တမ်း ဖျက်ရာတွင် အမှားအယွင်းဖြစ်ပွားခဲ့သည်။';

  @override
  String get errorDeletingExpense => 'အသုံးစရိတ် မှတ်တမ်း ဖျက်ရာတွင် အမှားအယွင်းဖြစ်ပွားခဲ့သည်။';

  @override
  String get addEditFinancialRecordNotImplemented => 'ဘဏ္ဍာရေး မှတ်တမ်း ထည့်/ပြင်ရန် မျက်နှာပြင်ကို မပြုလုပ်ရသေးပါ။';

  @override
  String get editIncomeTitle => 'ဝင်ငွေ ပြင်ရန်';

  @override
  String get addIncomeTitle => 'ဝင်ငွေ ထည့်ရန်';

  @override
  String get editExpenseTitle => 'အသုံးစရိတ် ပြင်ရန်';

  @override
  String get addExpenseTitle => 'အသုံးစရိတ် ထည့်ရန်';

  @override
  String get descriptionLabel => 'အကြောင်းအရာ';

  @override
  String get descriptionValidator => 'ကျေးဇူးပြု၍ အကြောင်းအရာ ထည့်ပါ။';

  @override
  String get amountLabel => 'ပမာဏ';

  @override
  String get amountValidator => 'ကျေးဇူးပြု၍ ပမာဏ ထည့်ပါ။';

  @override
  String get invalidAmountError => 'ကျေးဇူးပြု၍ မှန်ကန်သော ပမာဏ (အပေါင်းကိန်း) ထည့်ပါ။';

  @override
  String get recordDateLabel => 'ရက်စွဲ';

  @override
  String get dateValidator => 'ကျေးဇူးပြု၍ ရက်စွဲ ရွေးပါ။';

  @override
  String get updateButton => 'ပြင်ဆင်ရန်';

  @override
  String get addButton => 'ထည့်ရန်';

  @override
  String get failedToSaveRecordError => 'မှတ်တမ်း သိမ်းဆည်းခြင်း မအောင်မြင်ပါ။';

  @override
  String get announcementsTitle => 'ကြေညာချက်များ';

  @override
  String get noAnnouncementsFound => 'ကြေညာချက်များ မတွေ့ပါ။';

  @override
  String get postedOn => 'တင်သည့်ရက်';

  @override
  String get childAttendanceTitle => 'ကလေး၏ တက်ရောက်မှု';

  @override
  String get noChildrenLinked => 'သင်၏အကောင့်နှင့် ချိတ်ဆက်ထားသော ကလေး မရှိပါ။';

  @override
  String get selectChildHint => 'ကလေး ရွေးပါ';

  @override
  String get pleaseSelectChild => 'တက်ရောက်မှု ကြည့်ရန် ကျေးဇူးပြု၍ ကလေးတစ်ဦး ရွေးပါ။';

  @override
  String get noAttendanceRecordsFound => 'ရွေးချယ်ထားသော ကလေးနှင့် လအတွက် တက်ရောက်မှု မှတ်တမ်းများ မတွေ့ပါ။';

  @override
  String get childScheduleTitle => 'ကလေး၏ အချိန်ဇယား';

  @override
  String get childNotAssignedToClass => 'ကလေးသည် လက်ရှိတွင် အတန်းတစ်ခုခု၌ သတ်မှတ်ထားခြင်း မရှိပါ သို့မဟုတ် အချိန်ဇယား မရှိပါ။';

  @override
  String get noScheduleFound => 'ရွေးချယ်ထားသော ကလေး၏ အတန်းအတွက် အချိန်ဇယား မတွေ့ပါ။';

  @override
  String get manageAnnouncementsTitle => 'ကြေညာချက်များ စီမံရန်';

  @override
  String get addAnnouncementTooltip => 'ကြေညာချက်အသစ် ထည့်ရန်';

  @override
  String get confirmDeleteAnnouncementText => 'ဤကြေညာချက်ကို ဖျက်ရန် သေချာပါသလား။';

  @override
  String get errorDeletingAnnouncement => 'ကြေညာချက် ဖျက်ရာတွင် အမှားအယွင်းဖြစ်ပွားခဲ့သည်။';

  @override
  String get actionRequiresSchoolAndAdminContext => 'လုပ်ဆောင်ချက်အတွက် ကျောင်းနှင့် အက်မင် အချက်အလက် လိုအပ်သည်။';

  @override
  String get addEditAnnouncementNotImplemented => 'ကြေညာချက် ထည့်/ပြင်ရန် မျက်နှာပြင်ကို မပြုလုပ်ရသေးပါ။';

  @override
  String get targetAudience => 'ပစ်မှတ် အုပ်စု';

  @override
  String get all => 'အားလုံး';

  @override
  String get specificclass => 'သီးသန့်အတန်း';

  @override
  String get closeButtonLabel => 'ပိတ်မည်';

  @override
  String get pleaseSelectClassForAnnouncement => 'ဤကြေညာချက်အတွက် အတန်းတစ်ခု ရွေးပါ။';

  @override
  String get failedToSaveAnnouncementError => 'ကြေညာချက် သိမ်းဆည်းခြင်း မအောင်မြင်ပါ။';

  @override
  String get editAnnouncementTitle => 'ကြေညာချက် ပြင်ရန်';

  @override
  String get addAnnouncementTitle => 'ကြေညာချက် ထည့်ရန်';

  @override
  String get titleLabel => 'ခေါင်းစဉ်';

  @override
  String get titleValidator => 'ကျေးဇူးပြု၍ ခေါင်းစဉ် ထည့်ပါ။';

  @override
  String get contentLabel => 'အကြောင်းအရာ';

  @override
  String get contentValidator => 'ကျေးဇူးပြု၍ အကြောင်းအရာ ထည့်ပါ။';

  @override
  String get selectTargetAudienceHint => 'ပစ်မှတ် အုပ်စု ရွေးပါ';

  @override
  String get targetAudienceValidator => 'ကျေးဇူးပြု၍ ပစ်မှတ် အုပ်စု ရွေးပါ။';

  @override
  String get manageAnnouncementsDrawerItem => 'ကြေညာချက်များ စီမံရန်';

  @override
  String get classOrUserMissingError => 'တက်ရောက်မှု သိမ်းဆည်းရန် အတန်း သို့မဟုတ် အသုံးပြုသူ အချက်အလက် မပြည့်စုံပါ။';

  @override
  String get failedToLoadInitialData => 'အချက်အလက်များ စတင်ရယူခြင်း မအောင်မြင်ပါ။';

  @override
  String get failedToLoadSubjects => 'ရွေးချယ်ထားသော အတန်းအတွက် ဘာသာရပ်များ ရယူခြင်း မအောင်မြင်ပါ။';

  @override
  String get fillAllRequiredFields => 'လိုအပ်သော အကွက်အားလုံးကို ဖြည့်ပါ။';

  @override
  String get failedToSaveLessonPlanError => 'သင်ခန်းစာ အစီအစဉ် သိမ်းဆည်းခြင်း မအောင်မြင်ပါ။';

  @override
  String get editLessonPlanTitle => 'သင်ခန်းစာ အစီအစဉ် ပြင်ရန်';

  @override
  String get addLessonPlanTitle => 'သင်ခန်းစာ အစီအစဉ် ထည့်ရန်';

  @override
  String get selectSubjectHint => 'ဘာသာရပ် ရွေးပါ';

  @override
  String get subjectLabel => 'ဘာသာရပ်';

  @override
  String get subjectValidator => 'ကျေးဇူးပြု၍ ဘာသာရပ် ရွေးပါ။';

  @override
  String get pleaseSelectClassFirstForSubjects => 'ဘာသာရပ်များ ကြည့်ရန် ကျေးဇူးပြု၍ အတန်းတစ်ခု ရွေးပါ။';

  @override
  String get noSubjectsFoundForClass => 'ရွေးချယ်ထားသော အတန်းအတွက် ဘာသာရပ်များ မတွေ့ပါ။ အချိန်ဇယား စစ်ဆေးပါ။';

  @override
  String get manageDailyReportFormsTitle => 'နေ့စဉ် မှတ်တမ်းပုံစံများ စီမံရန်';

  @override
  String get confirmDeleteCustomFormText => 'ဤပုံစံနှင့် သက်ဆိုင်သော တုံ့ပြန်မှုများအားလုံးကို ဖျက်ရန် သေချာပါသလား။ ဤလုပ်ဆောင်ချက်ကို နောက်ပြန်လှည့်၍မရပါ။';

  @override
  String get errorDeletingCustomFormText => 'ပုံစံ ဖျက်ရာတွင် အမှားအယွင်းဖြစ်ပွားခဲ့သည်။';

  @override
  String get noCustomFormsFoundText => 'စိတ်ကြိုက်ပုံစံများ မတွေ့ပါ။ တစ်ခုပြုလုပ်ရန် \'+\' ကိုနှိပ်ပါ။';

  @override
  String get addCustomFormTooltip => 'မှတ်တမ်းပုံစံအသစ် ထည့်ရန်';

  @override
  String get activeFrom => 'စတင်အသုံးပြုနိုင်သည့်ရက်';

  @override
  String get activeTo => 'နောက်ဆုံးအသုံးပြုနိုင်သည့်ရက်';

  @override
  String get daily => 'နေ့စဉ်';

  @override
  String get yes => 'ဟုတ်ကဲ့';

  @override
  String get no => 'မဟုတ်ပါ';

  @override
  String get formDetailsTitle => 'ပုံစံ အသေးစိတ်';

  @override
  String get formTitleLabel => 'ပုံစံ ခေါင်းစဉ်';

  @override
  String get formTitleValidator => 'ပုံစံ ခေါင်းစဉ် လိုအပ်ပါသည်။';

  @override
  String get dailyReportLabel => 'နေ့စဉ် မှတ်တမ်းပုံစံ (အလိုအလျောက်)';

  @override
  String get assignToLabel => 'သတ်မှတ်ရန်:';

  @override
  String get assignToWholeSchoolLabel => 'ကျောင်းတစ်ခုလုံး';

  @override
  String get formQuestionsTitle => 'ပုံစံ မေးခွန်းများ';

  @override
  String get addQuestionTooltip => 'မေးခွန်းအသစ် ထည့်ရန်';

  @override
  String get noQuestionsAddedText => 'မေးခွန်းများ မထည့်ရသေးပါ။ \'+\' ကိုနှိပ်၍ ထည့်ပါ။';

  @override
  String get pleaseSelectActiveDatesError => 'ကျေးဇူးပြု၍ အသုံးပြုနိုင်မည့် ရက်အပိုင်းအခြားကို ရွေးပါ။';

  @override
  String get activeToDateError => 'နောက်ဆုံးရက်သည် စတင်ရက်ထက် နောက်ကျရပါမည်။';

  @override
  String get addAtLeastOneQuestionError => 'ကျေးဇူးပြု၍ ပုံစံတွင် အနည်းဆုံး မေးခွန်းတစ်ခု ထည့်ပါ။';

  @override
  String get failedToSaveFormError => 'ပုံစံ သိမ်းဆည်းခြင်း မအောင်မြင်ပါ။';

  @override
  String get editReportFormTitle => 'မှတ်တမ်းပုံစံ ပြင်ရန်';

  @override
  String get createReportFormTitle => 'မှတ်တမ်းပုံစံသစ် ပြုလုပ်ရန်';

  @override
  String get editQuestionTitle => 'မေးခွန်း ပြင်ရန်';

  @override
  String get addQuestionTitle => 'မေးခွန်း ထည့်ရန်';

  @override
  String get questionTextLabel => 'မေးခွန်း စာသား';

  @override
  String get questionTextValidator => 'မေးခွန်း စာသား လိုအပ်ပါသည်။';

  @override
  String get questionTypeLabel => 'မေးခွန်း အမျိုးအစား';

  @override
  String get optionsLabel => 'ရွေးချယ်စရာများ (တစ်ကြောင်းလျှင် တစ်ခု)';

  @override
  String get optionsRequiredError => 'ဤမေးခွန်းအမျိုးအစားအတွက် ရွေးချယ်စရာများ လိုအပ်ပါသည်။';

  @override
  String get atLeastTwoOptionsError => 'ဤမေးခွန်းအမျိုးအစားအတွက် အနည်းဆုံး ရွေးချယ်စရာ နှစ်ခု လိုအပ်ပါသည်။';

  @override
  String get requiredLabel => 'မဖြစ်မနေ ဖြည့်ရန်';

  @override
  String get typePrefixLabel => 'အမျိုးအစား';

  @override
  String get requiredSuffix => '(မဖြစ်မနေ)';

  @override
  String get manageDailyReportsDrawerItem => 'နေ့စဉ် မှတ်တမ်းများ စီမံရန်';

  @override
  String get assignToClassesLabel => 'သီးသန့်အတန်းများသို့ သတ်မှတ်ရန်:';

  @override
  String get noClassesAvailableText => 'သတ်မှတ်ရန် အတန်းများ မရှိပါ။';

  @override
  String get errorFetchingForms => 'ပုံစံများ ရယူရာတွင် အမှားဖြစ်ပွားသည်';

  @override
  String get errorFetchingFormDetails => 'ပုံစံအသေးစိတ် ရယူရာတွင် အမှားဖြစ်ပွားသည်';

  @override
  String get reportSubmittedSuccessfully => 'မှတ်တမ်း အောင်မြင်စွာ တင်ပြီးပါပြီ!';

  @override
  String get failedToSubmitReport => 'မှတ်တမ်း တင်ခြင်း မအောင်မြင်ပါ';

  @override
  String get errorSubmittingReport => 'မှတ်တမ်း တင်ရာတွင် အမှားဖြစ်ပွားသည်';

  @override
  String get dailyReportsTitle => 'နေ့စဉ် မှတ်တမ်းများ';

  @override
  String get childLabel => 'ကလေး';

  @override
  String get selectReportForm => 'မှတ်တမ်းပုံစံ ရွေးပါ';

  @override
  String get selectFormHint => 'ပုံစံ ရွေးပါ';

  @override
  String get submitted => 'တင်ပြီး';

  @override
  String get formLabel => 'ပုံစံ';

  @override
  String get noActiveFormsForToday => 'ယနေ့အတွက် အသုံးပြုနိုင်သော ပုံစံများ မရှိပါ။';

  @override
  String get pleaseSelectForm => 'ကျေးဇူးပြု၍ ပုံစံတစ်ခု ရွေးပါ။';

  @override
  String get formHasNoQuestions => 'ဤပုံစံတွင် မေးခွန်းများ မရှိပါ။';

  @override
  String get reportAlreadySubmitted => 'ဤပုံစံအတွက် ယနေ့ မှတ်တမ်းတင်ပြီးသား ဖြစ်သည်။';

  @override
  String get submitReportButton => 'မှတ်တမ်း တင်မည်';

  @override
  String get pleaseEnterValidNumber => 'ကျေးဇူးပြု၍ မှန်ကန်သော ကိန်းဂဏန်းတစ်ခု ထည့်ပါ။';

  @override
  String get fieldRequiredValidation => 'ဤအကွက်ကို ဖြည့်ရန် လိုအပ်သည်။';

  @override
  String get noParentsAvailableToLink => 'ဤကျောင်းတွင် ချိတ်ဆက်ရန် မိဘများ မရှိပါ။';

  @override
  String get linkParentsTitle => 'မိဘများ ချိတ်ဆက်ရန်:';

  @override
  String get unnamedParent => 'အမည်မဖော်ပြထားသော မိဘ';

  @override
  String get viewFormResponsesTitle => 'ပုံစံ တုံ့ပြန်မှုများ ကြည့်ရန်';

  @override
  String get noFormsAvailableToViewResponses => 'တုံ့ပြန်မှုများ ကြည့်ရန် ပုံစံများ မရှိပါ။';

  @override
  String get selectFormToViewResponses => 'တုံ့ပြန်မှုများ ကြည့်ရန် ပုံစံတစ်ခု ရွေးပါ';

  @override
  String get noResponsesForThisForm => 'ဤပုံစံအတွက် တင်ထားသော တုံ့ပြန်မှုများ မရှိသေးပါ။';

  @override
  String get responseFrom => 'ထံမှ တုံ့ပြန်ချက်';

  @override
  String get submittedOn => 'တင်သည့်ရက်';

  @override
  String get quickActions => 'အမြန်လုပ်ဆောင်ချက်များ';

  @override
  String get recentActivity => 'မကြာသေးမီက လုပ်ဆောင်ချက်များ';

  @override
  String get totalStudents => 'စုစုပေါင်း ကျောင်းသား';

  @override
  String get totalTeachers => 'စုစုပေါင်း ဆရာများ';

  @override
  String get totalParents => 'စုစုပေါင်း မိဘများ';

  @override
  String get formsToday => 'ယနေ့အတွက် ပုံစံများ';

  @override
  String get createNewFormAction => 'ပုံစံသစ်';

  @override
  String get manageFormsAction => 'ပုံစံများ စီမံရန်';

  @override
  String get manageTeachersAction => 'ဆရာများ';

  @override
  String get manageParentsAction => 'မိဘများ';

  @override
  String get viewReportsAction => 'မှတ်တမ်းများ ကြည့်ရန်';

  @override
  String get announcementsAction => 'ကြေညာချက်များ';

  @override
  String get noRecentActivity => 'မကြာသေးမီက လုပ်ဆောင်ချက် မရှိပါ။';

  @override
  String get error_school_or_user_not_found => 'ကျောင်း သို့မဟုတ် အသုံးပြုသူ အချက်အလက် ရှာမတွေ့ပါ။';

  @override
  String get selectGenderHint => 'ကျား/မ ရွေးပါ';

  @override
  String get genderMale => 'ကျား';

  @override
  String get genderFemale => 'မ';

  @override
  String get genderOther => 'အခြား';

  @override
  String get genderLabel => 'ကျား/မ';

  @override
  String get genderValidator => 'ကျေးဇူးပြု၍ ကျား/မ ရွေးပါ။';

  @override
  String get unassigned => 'သတ်မှတ်မထားသော';

  @override
  String get noDataAvailable => 'အချက်အလက် မရှိပါ';

  @override
  String get studentsDistributionByClassTitle => 'အတန်းအလိုက် ကျောင်းသားဦးရေ';

  @override
  String get publishButton => 'ထုတ်ဝေမည်';

  @override
  String get allAudience => 'အားလုံး';

  @override
  String get teachersAudience => 'ဆရာများ';

  @override
  String get parentsAudience => 'မိဘများ';

  @override
  String get selectTeacherHint => 'ဆရာ/မ ရွေးပါ';

  @override
  String get noTeachersAvailableHint => 'ရွေးချယ်ရန် ဆရာ/မ မရှိပါ';

  @override
  String get formDescriptionLabel => 'ပုံစံ အကြောင်းအရာ';

  @override
  String get formTargetAudienceLabel => 'ပစ်မှတ် အုပ်စု';

  @override
  String get formActiveLabel => 'အသုံးပြုနိုင်သည်';

  @override
  String get addQuestionButton => 'မေးခွန်းထည့်ရန်';

  @override
  String get fieldType_text => 'စာသား ထည့်သွင်းရန်';

  @override
  String get fieldType_yesNo => 'ဟုတ်/မဟုတ်';

  @override
  String get fieldType_multipleChoice => 'ရွေးချယ်စရာများ (အဖြေတစ်ခု)';

  @override
  String get fieldType_checkbox => 'ရွေးချယ်စရာများ (အဖြေများစွာ)';

  @override
  String get fieldType_number => 'ဂဏန်း ထည့်သွင်းရန်';

  @override
  String get optionsForMCQCheckboxLabel => 'ရွေးချယ်စရာများ (MCQ/Checkbox အတွက်၊ တစ်ကြောင်းလျှင် တစ်ခု)';

  @override
  String get addOptionButton => 'ရွေးချယ်စရာ ထည့်ရန်';

  @override
  String get optionHint => 'ရွေးချယ်စရာ';

  @override
  String get saveFormButton => 'ပုံစံ သိမ်းဆည်းရန်';

  @override
  String get updateFormButton => 'ပုံစံ ပြင်ဆင်ရန်';

  @override
  String get optionTextValidator => 'ရွေးချယ်စရာ စာသား လိုအပ်သည်';

  @override
  String get categoryLabel => 'အမျိုးအစား';

  @override
  String get categoryValidator => 'ကျေးဇူးပြု၍ အမျိုးအစား ရွေးပါ';

  @override
  String get saveButton => 'သိမ်းမည်';

  @override
  String get phoneNumberLabel => 'ဖုန်းနံပါတ်';

  @override
  String get addressLabel => 'လိပ်စာ';

  @override
  String get profilePhotoLabel => 'ပရိုဖိုင်ဓာတ်ပုံ';

  @override
  String get selectImageButton => 'ပုံ ရွေးပါ';

  @override
  String get imageSelectedText => 'ပုံ ရွေးပြီး';

  @override
  String get noImageSelectedText => 'ပုံ မရွေးရသေး';

  @override
  String get linkedStudentsLabel => 'ချိတ်ဆက်ထားသော ကျောင်းသားများ';

  @override
  String get linkStudentButton => 'ကျောင်းသား ချိတ်ဆက်ရန်';

  @override
  String get searchStudentHint => 'ကျောင်းသားအမည် (သို့) ID ဖြင့် ရှာပါ';

  @override
  String get noStudentsFoundToLink => 'ချိတ်ဆက်ရန် ကျောင်းသား မတွေ့ပါ';

  @override
  String get saveParentButton => 'မိဘ သိမ်းဆည်းရန်';

  @override
  String get noClassesAvailableHint => 'ရွေးချယ်ရန် အတန်းများ မရှိပါ';

  @override
  String get rollNumberLabel => 'ခုံနံပါတ်';

  @override
  String get parentEmailOptionalLabel => 'မိဘ အီးမေးလ် (ရွေးချယ်နိုင်)';

  @override
  String get classValidator => 'ကျေးဇူးပြု၍ အတန်း ရွေးပါ';

  @override
  String get dateOfBirthValidator => 'ကျေးဇူးပြု၍ မွေးသက္ကရာဇ် ထည့်ပါ';

  @override
  String get subjectSpecializationLabel => 'အထူးပြု ဘာသာရပ်';

  @override
  String get qualificationsLabel => 'အရည်အချင်းများ';

  @override
  String get dateJoinedLabel => 'ဝင်ရောက်သည့်ရက်';

  @override
  String get dayOfWeekLabel => 'နေ့';

  @override
  String get selectDayHint => 'နေ့ ရွေးပါ';

  @override
  String get startTimeValidator => 'ကျေးဇူးပြု၍ စတင်ချိန် ရွေးပါ';

  @override
  String get endTimeValidator => 'ကျေးဇူးပြု၍ ပြီးဆုံးချိန် ရွေးပါ';

  @override
  String get manageClassesTitle => 'အတန်းများ စီမံရန်';

  @override
  String get noClassesFound => 'အတန်းများ မတွေ့ပါ။ တစ်ခုထည့်ရန်!';

  @override
  String get confirmDeleteClassText => 'ဤအတန်းကို ဖျက်ရန် သေချာပါသလား။';

  @override
  String get editSchoolProfileTitle => 'ကျောင်း ပရိုဖိုင် ပြင်ရန်';

  @override
  String get schoolLogoLabel => 'ကျောင်း လိုဂို';

  @override
  String get changeLogoButton => 'လိုဂို ပြောင်းရန်';

  @override
  String get saveChangesButton => 'အပြောင်းအလဲများ သိမ်းဆည်းရန်';

  @override
  String get totalIncome => 'စုစုပေါင်း ဝင်ငွေ';

  @override
  String get totalExpenses => 'စုစုပေါင်း အသုံးစရိတ်';

  @override
  String get netBalance => 'လက်ကျန်ငွေ';

  @override
  String get noTransactionsFound => 'ငွေလွှဲပြောင်းမှု မှတ်တမ်းများ မတွေ့ပါ။';

  @override
  String get addTransactionButton => 'ငွေလွှဲပြောင်းမှု ထည့်ရန်';

  @override
  String get confirmDeleteTransactionText => 'ဤငွေလွှဲပြောင်းမှုကို ဖျက်ရန် သေချာပါသလား။';

  @override
  String get manageCustomFormsTitle => 'စိတ်ကြိုက်ပုံစံများ စီမံရန်';

  @override
  String get addCustomFormButton => 'စိတ်ကြိုက်ပုံစံ ထည့်ရန်';

  @override
  String get viewResponsesButton => 'တုံ့ပြန်မှုများ ကြည့်ရန်';

  @override
  String get confirmDeleteFormText => 'ဤပုံစံကို ဖျက်ရန် သေချာပါသလား။';

  @override
  String get schoolRegistrationTitle => 'ကျောင်း မှတ်ပုံတင်ရန်';

  @override
  String get schoolDetailsStep => 'ကျောင်း အချက်အလက်';

  @override
  String get adminAccountStep => 'အက်မင် အကောင့်';

  @override
  String get nextButton => 'ရှေ့ဆက်ရန်';

  @override
  String get previousButton => 'နောက်သို့';

  @override
  String get manageStudentsTitle => 'ကျောင်းသားများ စီမံရန်';

  @override
  String get confirmDeleteStudentText => 'ဤကျောင်းသားကို ဖျက်ရန် သေချာပါသလား။ ဤလုပ်ဆောင်ချက်ကို နောက်ပြန်လှည့်၍မရပါ။';

  @override
  String get manageTimetablesTitle => 'အချိန်ဇယားများ စီမံရန်';

  @override
  String get selectClassToViewTimetableHint => 'အချိန်ဇယား ကြည့်ရန် အတန်း ရွေးပါ';

  @override
  String get pleaseSelectClassToViewTimetableText => 'အချိန်ဇယား ကြည့်ရန် ကျေးဇူးပြု၍ အတန်းတစ်ခု ရွေးပါ။';

  @override
  String get noTimetableEntriesForText => 'အတွက် အချိန်ဇယား ထည့်သွင်းမှုများ မရှိပါ';

  @override
  String get addOneText => 'တစ်ခုထည့်ရန်!';

  @override
  String get confirmDeleteTimetableEntryText => 'ဤအချိန်ဇယား ထည့်သွင်းမှုကို ဖျက်ရန် သေချာပါသလား။';

  @override
  String get manageUsersTitle => 'အသုံးပြုသူများ စီမံရန်';

  @override
  String get noUsersFoundTextPart1 => 'မရှိပါ';

  @override
  String get noUsersFoundTextPart2 => 'မတွေ့ပါ။ တစ်ခုထည့်ရန်!';

  @override
  String get confirmDeleteUserTextPart1 => 'ဤ';

  @override
  String get forgotPasswordButtonLabel => 'စကားဝှက် မေ့နေပါသလား။';

  @override
  String get registerNewSchoolButtonLabel => 'ကျောင်းအသစ် မှတ်ပုံတင်ရန် (အက်မင်)';

  @override
  String get adminFullNameLabel => 'အက်မင် အမည်အပြည့်အစုံ';

  @override
  String get adminFullNameValidator => 'ကျေးဇူးပြု၍ အက်မင် အမည်အပြည့်အစုံ ထည့်ပါ။';

  @override
  String get adminEmailLabel => 'အက်မင် အီးမေးလ်';

  @override
  String get adminEmailValidator => 'ကျေးဇူးပြု၍ အက်မင် အီးမေးလ် ထည့်ပါ။';

  @override
  String get adminPasswordLabel => 'အက်မင် စကားဝှက်';

  @override
  String get confirmAdminPasswordLabel => 'အက်မင် စကားဝှက် အတည်ပြုပါ';

  @override
  String get academicYearHint => 'ဥပမာ၊ ၂၀၂၄-၂၀၂၅';

  @override
  String get noLogoSelected => 'လိုဂို မရွေးရသေးပါ';

  @override
  String get logoSelectedLabel => 'လိုဂို ရွေးပြီး';

  @override
  String get selectLogoButton => 'လိုဂို ရွေးပါ';

  @override
  String get enableNotifications => 'အသိပေးချက်များ ဖွင့်ရန်';

  @override
  String get aboutAppTitle => 'EduSync Myanmar အကြောင်း';

  @override
  String get appTagline => 'ကျောင်းစီမံခန့်ခွဲမှုကို ရိုးရှင်းလွယ်ကူစေသည်။';

  @override
  String get editButton => 'ပြင်ရန်';

  @override
  String get deleteButton => 'ဖျက်မည်';

  @override
  String get confirmDeleteMessage => 'ဤအရာကို ဖျက်ရန် သေချာပါသလား။';

  @override
  String get noTeacherAssigned => 'ဆရာ/မ သတ်မှတ်မထားပါ';

  @override
  String get cannotDeleteMissingIdError => 'ဖျက်၍မရပါ - အရာဝတ္ထု ID မရှိပါ။';

  @override
  String get logoUrlLabel => 'လိုဂို URL (ရွေးချယ်နိုင်)';

  @override
  String get themeLabel => 'အက်ပ် အပြင်အဆင်';

  @override
  String get themeHint => 'အပြင်အဆင် ရွေးပါ';

  @override
  String get updateProfileButton => 'ပရိုဖိုင် ပြင်ဆင်ရန်';

  @override
  String get registerSchoolButton => 'ကျောင်း မှတ်ပုံတင်ရန်';

  @override
  String get confirmDeleteTeacherText => 'ဤဆရာ/မကို ဖျက်ရန် သေချာပါသလား။';

  @override
  String get manageTeachersTitle => 'ဆရာများ စီမံရန်';

  @override
  String get noTeachersFound => 'ဆရာ/မများ မတွေ့ပါ။ တစ်ခုထည့်ရန်!';

  @override
  String get parentDashboardTitle => 'မိဘ ဒက်ရှ်ဘုတ်';

  @override
  String get parentDashboardWelcomeMessage => 'မိဘ၊ ကြိုဆိုပါတယ်။\nသင်၏ကလေး အချက်အလက်များနှင့် ကြေညာချက်များ ကြည့်ရန် အံဆွဲကို အသုံးပြုပါ။';

  @override
  String get teacherDashboardTitle => 'ဆရာ ဒက်ရှ်ဘုတ်';

  @override
  String get teacherDashboardWelcomeMessage => 'ဆရာ/မ၊ ကြိုဆိုပါတယ်။\nသင်၏ကိရိယာများ အသုံးပြုရန် အံဆွဲကို အသုံးပြုပါ။';

  @override
  String get unknownUserRoleError => 'အသုံးပြုသူအခန်းကဏ္ဍကို မသိပါ။ ကျေးဇူးပြု၍ အကူအညီတောင်းပါ။';

  @override
  String get loginFailedError => 'ဝင်ရောက်ခြင်း မအောင်မြင်ပါ။ သင်၏အီးမေးလ်နှင့် စကားဝှက်ကို စစ်ဆေးပါ။';

  @override
  String get registrationSuccessMessage => 'ကျောင်းနှင့် အက်မင် အောင်မြင်စွာ မှတ်ပုံတင်ပြီးပါပြီ။ ကျေးဇူးပြု၍ ဝင်ရောက်ပါ။';

  @override
  String get failedToLinkAdminError => 'အရေးကြီး: အက်မင်ကို ကျောင်းအသစ်နှင့် ချိတ်ဆက်ရာတွင် မအောင်မြင်ပါ။ ကျေးဇူးပြု၍ အကူအညီတောင်းပါ။';

  @override
  String get teacherLabel => 'ဆရာ/မ';

  @override
  String get schoolNameLabel => 'ကျောင်းအမည်';

  @override
  String get schoolNameValidator => 'ကျေးဇူးပြု၍ ကျောင်းအမည် ထည့်ပါ။';

  @override
  String get academicYearLabel => 'ပညာသင်နှစ်';

  @override
  String get contactInfoLabel => 'ဆက်သွယ်ရန် အချက်အလက်';

  @override
  String get noStudentsFound => 'ကျောင်းသားများ မတွေ့ပါ။ တစ်ခုထည့်ရန်!';

  @override
  String get registerSchoolAdminTitle => 'ကျောင်းနှင့် အက်မင် မှတ်ပုံတင်ရန်';

  @override
  String get confirmPasswordValidator => 'ကျေးဇူးပြု၍ စကားဝှက် အတည်ပြုပါ။';

  @override
  String get passwordsDoNotMatchValidator => 'စကားဝှက်များ မတူညီပါ။';

  @override
  String get registerButton => 'မှတ်ပုံတင်မည်';

  @override
  String get versionLabel => 'ဗားရှင်း';
}
