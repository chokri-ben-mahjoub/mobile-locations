// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get navContracts => 'العقود';

  @override
  String get navTenants => 'المستأجرون';

  @override
  String get navAnalytics => 'التحليلات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsSyncedSubtitle => 'متزامن بين الهاتف والويب.';

  @override
  String get settingsReminders => 'تذكيرات انتهاء العقد';

  @override
  String get settingsRemindersSubtitle => 'مهلة الإشعار قبل تاريخ انتهاء العقد';

  @override
  String get months1 => 'شهر واحد';

  @override
  String get months2 => 'شهران';

  @override
  String get months3 => '3 أشهر';

  @override
  String get settingsCustomDelay => 'أو قيمة مخصصة (بالأشهر)';

  @override
  String get settingsAppearance => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeAuto => 'تلقائي';

  @override
  String get themeDark => 'داكن';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsSecurity => 'الأمان';

  @override
  String get biometricUnlock => 'فتح القفل بالبصمة';

  @override
  String get biometricAvailableSubtitle =>
      'استخدم بصمة الإصبع أو الوجه لتسجيل الدخول';

  @override
  String get biometricUnavailableSubtitle => 'غير متوفر على هذا الجهاز';

  @override
  String get changePin => 'تغيير رمز الدخول';

  @override
  String get settingsAccount => 'الحساب';

  @override
  String get connectedAs => 'متصل باسم';

  @override
  String get signOutConfirmTitle => 'تسجيل الخروج؟';

  @override
  String get signOutConfirmBody =>
      'ستحتاج إلى إعادة إدخال البريد الإلكتروني وكلمة المرور لاسترجاع بياناتك.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get legacyDataTitle => 'بيانات محلية قديمة';

  @override
  String get legacyDataBody =>
      'تم العثور على عقود محفوظة قبل الانتقال إلى الحوسبة السحابية على هذا الجهاز. استوردها مرة واحدة إلى الحساب المشترك لاستعادتها على جميع أجهزتك.';

  @override
  String get importInProgress => 'جارٍ الاستيراد…';

  @override
  String get importToCloud => 'استيراد إلى السحابة';

  @override
  String importSuccess(int count) {
    return 'تم استيراد $count عنصر بنجاح.';
  }

  @override
  String importFailed(String error) {
    return 'فشل الاستيراد: $error';
  }

  @override
  String get exportSectionTitle => 'التصدير';

  @override
  String get exportSectionBody =>
      'صدّر جميع العقود (النشطة والمعلقة) بصيغة CSV أو Excel أو صورة — تظهر أسماء المستأجرين بالعربية بشكل صحيح في الصيغ الثلاث.';

  @override
  String get exportShareButton => 'تصدير / مشاركة';

  @override
  String exportFailed(String error) {
    return 'فشل التصدير: $error';
  }

  @override
  String get fileDownloaded => 'تم تنزيل الملف.';

  @override
  String get downloadCancelled => 'تم إلغاء التنزيل.';

  @override
  String get exportSheetTitle => 'تصدير العقود';

  @override
  String get exportDocumentTitle => 'عقود الإيجار';

  @override
  String get exportSheetSubtitle =>
      'تظهر أسماء المستأجرين بالعربية بشكل صحيح في جميع الصيغ.';

  @override
  String get download => 'تنزيل';

  @override
  String get share => 'مشاركة';

  @override
  String get formatCsv => 'CSV';

  @override
  String get formatExcel => 'Excel';

  @override
  String get formatImage => 'صورة';

  @override
  String get formatCsvDescription => 'ملف .csv، متوافق مع Excel';

  @override
  String get formatExcelDescription => 'ملف .xlsx بتنسيق جاهز';

  @override
  String get formatImageDescription => 'صورة PNG للجدول، جاهزة للمشاركة';

  @override
  String get screenClosedBeforeExport => 'تم إغلاق الشاشة قبل انتهاء التصدير.';

  @override
  String get excelGenerationFailed => 'فشل إنشاء ملف Excel.';

  @override
  String durationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count شهر',
      many: '$count شهرًا',
      few: '$count أشهر',
      two: 'شهران',
      one: 'شهر واحد',
    );
    return '$_temp0';
  }

  @override
  String durationYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count سنة',
      many: '$count سنة',
      few: '$count سنوات',
      two: 'سنتان',
      one: 'سنة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get durationNone => '—';

  @override
  String get statusActive => 'نشط';

  @override
  String get statusExpired => 'منتهي';

  @override
  String get statusPending => 'في الانتظار';

  @override
  String get notPaid => 'غير مدفوع';

  @override
  String get exportColNumber => 'الرقم';

  @override
  String get exportColTenant => 'المستأجر';

  @override
  String get exportColUnit => 'المحل';

  @override
  String get exportColStartDate => 'تاريخ البداية';

  @override
  String get exportColEndDate => 'تاريخ النهاية';

  @override
  String get exportColDuration => 'المدة';

  @override
  String exportColMonthlyRent(String currency) {
    return 'الإيجار الشهري ($currency)';
  }

  @override
  String get exportColSteg => 'رقم عداد الستاغ';

  @override
  String get exportColSonede => 'رقم عداد الصوناد';

  @override
  String get exportColStatus => 'الحالة';

  @override
  String get exportColLastRentPaid => 'آخر دفعة إيجار';

  @override
  String get exportColLastStegPaid => 'آخر دفعة ستاغ';

  @override
  String get exportColLastSonedePaid => 'آخر دفعة صوناد';

  @override
  String get exportTableName => 'العقود';

  @override
  String get onboardingWelcome => 'مرحبًا بك في LocaTrack';

  @override
  String get onboardingSubtitle =>
      'تابع عقود إيجار محلاتك التجارية: الإيجارات والمواعيد وعدادات الستاغ والصوناد.';

  @override
  String get onboardingFeature1Title => 'تذكيرات قبل الانتهاء';

  @override
  String get onboardingFeature1Subtitle =>
      'تنبيهات تلقائية قبل انتهاء كل عقد إيجار.';

  @override
  String get onboardingFeature2Title => 'تحصيل الدفعات بلمسة واحدة';

  @override
  String get onboardingFeature2Subtitle =>
      'اسحب البطاقة للتحصيل، وتابع 12 شهرًا.';

  @override
  String get onboardingFeature3Title => 'خاص، على جهازك';

  @override
  String get onboardingFeature3Subtitle =>
      'رمز دخول وبصمة، ونسخ احتياطي عند الطلب.';

  @override
  String get start => 'ابدأ';

  @override
  String get cloudLoginTitle => 'تسجيل الدخول إلى حساب LocaTrack';

  @override
  String get cloudLoginSubtitle => 'بياناتك مشتركة بين الهاتف والويب.';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get invalidEmail => 'عنوان بريد إلكتروني غير صالح.';

  @override
  String get wrongCredentials => 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';

  @override
  String get accountDisabled => 'تم تعطيل هذا الحساب.';

  @override
  String get tooManyAttempts => 'محاولات كثيرة جدًا، حاول مرة أخرى لاحقًا.';

  @override
  String get noInternet => 'لا يوجد اتصال بالإنترنت.';

  @override
  String signInFailedCode(String code) {
    return 'تعذر تسجيل الدخول ($code).';
  }

  @override
  String get appTagline => 'إدارة عقود الإيجار';

  @override
  String get loginSlide1Title => 'جميع عقودك في مكان واحد';

  @override
  String get loginSlide1Subtitle =>
      'المستأجرون والإيجارات والتواريخ والعدادات في لمحة واحدة.';

  @override
  String get loginSlide2Title => 'تذكيرات قبل الانتهاء';

  @override
  String get loginSlide2Subtitle =>
      'احصل على تنبيه تلقائي قبل انتهاء كل عقد إيجار.';

  @override
  String get loginSlide3Title => 'نظرة عامة على الإيجارات';

  @override
  String get loginSlide3Subtitle =>
      'تابع إجمالي الدخل الإيجاري والمواعيد القادمة.';

  @override
  String get biometricNotConfigured => 'لم يتم إعداد البصمة على هذا الجهاز.';

  @override
  String get biometricCancelled => 'تم إلغاء المصادقة بالبصمة.';

  @override
  String get signInWithBiometrics => 'تسجيل الدخول بالبصمة';

  @override
  String get signInWithPasscode => 'تسجيل الدخول برمز الدخول';

  @override
  String get passcodeEnterTitle => 'أدخل رمزك';

  @override
  String get passcodeConfirmTitle => 'أكّد رمزك';

  @override
  String get passcodeCreateTitle => 'أنشئ رمزك';

  @override
  String passcodeEnterSubtitle(int length) {
    return 'أدخل رمز الدخول المكوّن من $length أرقام';
  }

  @override
  String get passcodeConfirmSubtitle => 'أعد إدخال نفس الرمز للتأكيد';

  @override
  String get passcodeCreateSubtitle => 'سيتيح لك هذا الرمز فتح قفل LocaTrack';

  @override
  String get passcodeWrong => 'رمز غير صحيح، حاول مرة أخرى.';

  @override
  String get passcodeMismatch => 'الرمزان غير متطابقين، أعد المحاولة.';

  @override
  String genericError(String error) {
    return 'خطأ: $error';
  }

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get later => 'لاحقًا';

  @override
  String get addNow => 'أضف الآن';

  @override
  String get restore => 'استرجاع';

  @override
  String get collapse => 'طي';

  @override
  String get collect => 'تحصيل';

  @override
  String get irreversibleAction => 'هذا الإجراء لا يمكن التراجع عنه.';

  @override
  String get otherCategory => 'أخرى';

  @override
  String get addButton => 'إضافة';

  @override
  String get notesTitle => 'ملاحظات';

  @override
  String get newContractButton => 'عقد';

  @override
  String get insightUnpaid => 'غير مدفوع';

  @override
  String get insightToRenew => 'للتجديد';

  @override
  String get insightOccupancy => 'نسبة الإشغال';

  @override
  String get searchHint => 'ابحث عن مستأجر أو محل…';

  @override
  String get filterAll => 'الكل';

  @override
  String get statusDueSoon => 'ينتهي قريبًا';

  @override
  String get sortTooltip => 'ترتيب';

  @override
  String get sortExpiryDate => 'تاريخ الانتهاء';

  @override
  String get sortRentDesc => 'الإيجار (تنازلي)';

  @override
  String get sortRentAsc => 'الإيجار (تصاعدي)';

  @override
  String get sortNameAsc => 'الاسم (أ→ي)';

  @override
  String get contractsEmptyTitle => 'لا توجد عقود';

  @override
  String get contractsNoResultTitle => 'لا توجد نتائج';

  @override
  String get contractsEmptySubtitle => 'أضف عقدك الأول باستخدام زر +.';

  @override
  String contractsNoResultSubtitle(String query) {
    return 'لا يوجد عقد أو محل في الانتظار يطابق « $query ».';
  }

  @override
  String get contractsNoMatchCriteria => 'لا يوجد عقد يطابق هذه المعايير.';

  @override
  String get heroTotalMonthlyRent => 'إجمالي الإيجار الشهري';

  @override
  String get heroCollectedThisMonth => 'تم تحصيله هذا الشهر';

  @override
  String heroExpectedOf(String amount) {
    return 'من أصل $amount متوقع';
  }

  @override
  String heroActiveContractsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عقد نشط',
      many: '$count عقدًا نشطًا',
      few: '$count عقود نشطة',
      two: 'عقدان نشطان',
      one: 'عقد نشط واحد',
    );
    return '$_temp0';
  }

  @override
  String heroToRenewCount(int count) {
    return '$count للتجديد';
  }

  @override
  String get collectThisMonth => 'تحصيل الشهر';

  @override
  String get unpaidSheetTitle => 'إيجارات للتحصيل';

  @override
  String get shareReportTooltip => 'مشاركة التقرير';

  @override
  String get allRentsCollected => 'تم تحصيل جميع الإيجارات';

  @override
  String vacantUnitsCount(int count) {
    return 'محلات في الانتظار ($count)';
  }

  @override
  String lastTenantLabel(String name) {
    return 'آخر مستأجر: $name';
  }

  @override
  String get reactivateTooltip => 'إعادة تفعيل هذا العقد';

  @override
  String get newTenantButton => 'مستأجر جديد';

  @override
  String get reactivateConfirmTitle => 'إعادة تفعيل هذا العقد؟';

  @override
  String reactivateConfirmBody(String unit, String name) {
    return 'سيصبح المحل $unit نشطًا من جديد مع $name كمستأجر، كما كان قبل وضعه في الانتظار.';
  }

  @override
  String reactivateConfirmBodyShort(String unit, String name) {
    return 'سيصبح المحل $unit نشطًا من جديد مع $name كمستأجر.';
  }

  @override
  String get reactivateButton => 'إعادة تفعيل';

  @override
  String get exportContractsTooltip => 'تصدير العقود';

  @override
  String get shareMonthReportTooltip => 'مشاركة تقرير الشهر';

  @override
  String collectedInYear(int year) {
    return 'تم التحصيل في $year';
  }

  @override
  String collectionRate12m(int rate) {
    return 'معدل التحصيل خلال 12 شهرًا: $rate %';
  }

  @override
  String get last12Months => 'آخر 12 شهرًا';

  @override
  String get legendCollected => 'تم التحصيل';

  @override
  String get legendExpected => 'متوقع';

  @override
  String collectedOfExpected(String collected, String expected) {
    return '$collected من أصل $expected';
  }

  @override
  String get thisMonthTitle => 'هذا الشهر';

  @override
  String unpaidCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count غير مدفوع',
      many: '$count غير مدفوع',
      few: '$count غير مدفوعة',
      two: 'غير مدفوعين',
      one: 'غير مدفوع واحد',
    );
    return '$_temp0';
  }

  @override
  String occupiedUnitsDetail(int occupied, int total) {
    return '$occupied/$total محلات مشغولة';
  }

  @override
  String get upcomingDueDatesTitle => 'مواعيد قادمة';

  @override
  String get upcomingDueDatesSubtitle => 'عقود تنتهي خلال الأشهر الستة القادمة';

  @override
  String get noUpcomingDueDates => 'لا توجد مواعيد خلال الأشهر الستة القادمة.';

  @override
  String daysRemaining(int days) {
    return 'متبقي $days';
  }

  @override
  String get contractExpiredLabel => 'انتهى العقد';

  @override
  String remainingMonths(int count) {
    return 'متبقي $count أشهر';
  }

  @override
  String remainingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'متبقي $count يوم',
      many: 'متبقي $count يومًا',
      few: 'متبقي $count أيام',
      two: 'متبقي يومان',
      one: 'متبقي يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get contractNotFound => 'العقد غير موجود.';

  @override
  String get vacantUnitNotice => 'محل في الانتظار — غادر المستأجر السابق.';

  @override
  String get unitHistoryTooltip => 'سجل هذا المحل';

  @override
  String get contractStartLabel => 'بداية العقد';

  @override
  String get contractEndLabel => 'نهاية العقد';

  @override
  String get markVacantButton => 'غادر المستأجر — ضع المحل في الانتظار';

  @override
  String get markVacantConfirmTitle => 'وضع هذا المحل في الانتظار؟';

  @override
  String get markVacantConfirmBody =>
      'سيتم إغلاق العقد ولن يظهر المحل ضمن العقود النشطة حتى وصول مستأجر جديد.';

  @override
  String get newTenantQuestionTitle => 'مستأجر جديد؟';

  @override
  String newTenantQuestionBody(String unit) {
    return 'المحل $unit أصبح الآن في الانتظار. هل تريد إضافة مستأجره الجديد الآن؟';
  }

  @override
  String get deleteContractConfirmTitle => 'حذف هذا العقد؟';

  @override
  String get paymentsHistoryTitle => 'سجل الدفعات';

  @override
  String paidCountOf(int paid, int total) {
    return '$paid/$total مدفوعة';
  }

  @override
  String get paymentsHistoryHint =>
      'المس شهرًا لتبديل حالته بين مدفوع وغير مدفوع. اضغط مطولًا لتعديل المبلغ.';

  @override
  String showAllMonths(int count) {
    return 'عرض جميع الأشهر ($count)';
  }

  @override
  String paymentCancelledSnack(String label) {
    return 'تم إلغاء دفعة $label';
  }

  @override
  String collectedSnack(String label) {
    return 'تم تحصيل $label';
  }

  @override
  String get amountPaidLabel => 'المبلغ المدفوع';

  @override
  String get paymentDateLabel => 'تاريخ الدفع';

  @override
  String get markPaidButton => 'تحديد كمدفوع';

  @override
  String get shareReceiptButton => 'مشاركة الإيصال';

  @override
  String get cancelPaymentButton => 'إلغاء هذه الدفعة';

  @override
  String get utilityBillsSectionTitle => 'فواتير الستاغ / الصوناد';

  @override
  String settledCountOf(int paid, int total) {
    return '$paid/$total مسددة';
  }

  @override
  String get attachmentsSectionTitle => 'المرفقات';

  @override
  String get noAttachmentsHint =>
      'لا توجد مرفقات بعد. أضف صورة للعقد أو بطاقة التعريف\nأو محضر المعاينة.';

  @override
  String get documentTypeTitle => 'نوع المستند';

  @override
  String get takePhotoOption => 'التقاط صورة';

  @override
  String get pickFromGalleryOption => 'اختيار من المعرض';

  @override
  String get deleteAttachmentConfirmTitle => 'حذف هذا المرفق؟';

  @override
  String unitHistoryTitle(String unit) {
    return 'السجل — $unit';
  }

  @override
  String get noUnitHistory => 'لا يوجد سجل لهذا المحل.';

  @override
  String get unitHistoryStatusOld => 'سابق';

  @override
  String get unitHistoryStatusCurrent => 'الحالي';

  @override
  String get tenantsEmptyTitle => 'لا يوجد مستأجرون';

  @override
  String get tenantsEmptySubtitle => 'ستظهر هنا العقود التي تنشئها.';

  @override
  String tenantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نشط',
      many: '$count نشطًا',
      few: '$count نشطة',
      two: 'نشطان',
      one: 'نشط واحد',
    );
    return '$_temp0';
  }

  @override
  String tenantsCountWithVacant(int active, int vacant) {
    String _temp0 = intl.Intl.pluralLogic(
      active,
      locale: localeName,
      other: '$active نشط',
      many: '$active نشطًا',
      few: '$active نشطة',
      two: 'نشطان',
      one: 'نشط واحد',
    );
    String _temp1 = intl.Intl.pluralLogic(
      vacant,
      locale: localeName,
      other: '$vacant محل في الانتظار',
      many: '$vacant محلًا في الانتظار',
      few: '$vacant محلات في الانتظار',
      two: 'محلان في الانتظار',
      one: 'محل واحد في الانتظار',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get tenantsVacantUnitsTitle => 'محلات في الانتظار';

  @override
  String get tenantsPeriodLabel => 'الفترة';

  @override
  String tenantsRentLabel(String currency) {
    return 'الإيجار ($currency)';
  }

  @override
  String paidOnDate(String date) {
    return 'دُفع في $date';
  }

  @override
  String get contractFormEditTitle => 'تعديل العقد';

  @override
  String contractFormNewTenantForUnit(String unit) {
    return 'مستأجر جديد — $unit';
  }

  @override
  String get contractFormNewTitle => 'عقد جديد';

  @override
  String get contractFormSectionTenantUnit => 'المستأجر والمحل';

  @override
  String get contractFormTenantNameLabel => 'اسم المستأجر';

  @override
  String get contractFormUnitNumberLabel => 'رقم المحل (مثال: A1-1)';

  @override
  String get contractFormSectionDuration => 'مدة العقد';

  @override
  String get contractFormStartDateLabel => 'تاريخ البداية';

  @override
  String get contractFormEndDateLabel => 'تاريخ النهاية';

  @override
  String get contractFormQuickDuration => 'مدة سريعة';

  @override
  String get contractFormSectionRentMeters => 'الإيجار والعدادات';

  @override
  String get contractFormInvalidAmount => 'مبلغ غير صالح';

  @override
  String get contractFormStegLabel => 'عداد الستاغ (اختياري)';

  @override
  String get contractFormSonedeLabel => 'عداد الصوناد (اختياري)';

  @override
  String get contractFormSectionNotes => 'ملاحظات';

  @override
  String get contractFormNotesLabel => 'ملاحظات (اختياري)';

  @override
  String get contractFormSave => 'حفظ';

  @override
  String get contractFormAdd => 'إضافة العقد';

  @override
  String get meterAutofillHint =>
      'يبقى العداد كما هو لنفس المحل حتى عند تغيير المستأجر.';

  @override
  String get pdfGeneratedOn => 'تم الإنشاء في';
}
