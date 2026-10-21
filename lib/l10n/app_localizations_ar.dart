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
      'صدّر جميع العقود (النشطة والمعلقة) بصيغة CSV أو Excel أو PDF أو صورة — تظهر أسماء المستأجرين بالعربية بشكل صحيح في الصيغ الأربع.';

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
  String get formatPdf => 'PDF';

  @override
  String get formatImage => 'صورة';

  @override
  String get formatCsvDescription => 'ملف .csv، متوافق مع Excel';

  @override
  String get formatExcelDescription => 'ملف .xlsx بتنسيق جاهز';

  @override
  String get formatPdfDescription => 'مستند PDF جاهز للطباعة';

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
}
