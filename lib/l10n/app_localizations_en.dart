// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get navContracts => 'Contracts';

  @override
  String get navTenants => 'Tenants';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navSettings => 'Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSyncedSubtitle => 'Synced between mobile and web.';

  @override
  String get settingsReminders => 'Expiry reminders';

  @override
  String get settingsRemindersSubtitle =>
      'Notice period before a contract\'s end date';

  @override
  String get months1 => '1 month';

  @override
  String get months2 => '2 months';

  @override
  String get months3 => '3 months';

  @override
  String get settingsCustomDelay => 'Or a custom value (in months)';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get biometricUnlock => 'Biometric unlock';

  @override
  String get biometricAvailableSubtitle => 'Use fingerprint or face to sign in';

  @override
  String get biometricUnavailableSubtitle => 'Not available on this device';

  @override
  String get changePin => 'Change PassCode';

  @override
  String get settingsAccount => 'Account';

  @override
  String get connectedAs => 'Signed in as';

  @override
  String get signOutConfirmTitle => 'Sign out?';

  @override
  String get signOutConfirmBody =>
      'You\'ll need to re-enter the account email and password to get your data back.';

  @override
  String get cancel => 'Cancel';

  @override
  String get signOut => 'Sign out';

  @override
  String get legacyDataTitle => 'Old local data';

  @override
  String get legacyDataBody =>
      'Contracts saved before switching to the cloud were found on this device. Import them once into the shared account to find them on all your devices.';

  @override
  String get importInProgress => 'Importing…';

  @override
  String get importToCloud => 'Import to the cloud';

  @override
  String importSuccess(int count) {
    return '$count items imported successfully.';
  }

  @override
  String importFailed(String error) {
    return 'Import failed: $error';
  }

  @override
  String get exportSectionTitle => 'Export';

  @override
  String get exportSectionBody =>
      'Export all contracts (active and pending) as CSV, Excel, PDF or image — Arabic tenant names display correctly in all 4 formats.';

  @override
  String get exportShareButton => 'Export / share';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get fileDownloaded => 'File downloaded.';

  @override
  String get downloadCancelled => 'Download cancelled.';

  @override
  String get exportSheetTitle => 'Export contracts';

  @override
  String get exportDocumentTitle => 'Rental contracts';

  @override
  String get exportSheetSubtitle =>
      'Arabic tenant names display correctly in every format.';

  @override
  String get download => 'Download';

  @override
  String get share => 'Share';

  @override
  String get formatCsv => 'CSV';

  @override
  String get formatExcel => 'Excel';

  @override
  String get formatPdf => 'PDF';

  @override
  String get formatImage => 'Image';

  @override
  String get formatCsvDescription => '.csv file, Excel-compatible';

  @override
  String get formatExcelDescription => '.xlsx workbook with formatting';

  @override
  String get formatPdfDescription => 'Print-ready PDF document';

  @override
  String get formatImageDescription =>
      'PNG snapshot of the table, ready to share';

  @override
  String get screenClosedBeforeExport =>
      'Screen was closed before the export finished.';

  @override
  String get excelGenerationFailed => 'Failed to generate the Excel file.';

  @override
  String durationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count months',
      one: '1 month',
    );
    return '$_temp0';
  }

  @override
  String durationYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count years',
      one: '1 year',
    );
    return '$_temp0';
  }

  @override
  String get durationNone => '—';

  @override
  String get statusActive => 'Active';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusPending => 'Pending';

  @override
  String get notPaid => 'Not paid';

  @override
  String get exportColNumber => 'No.';

  @override
  String get exportColTenant => 'Tenant';

  @override
  String get exportColUnit => 'Unit';

  @override
  String get exportColStartDate => 'Start date';

  @override
  String get exportColEndDate => 'End date';

  @override
  String get exportColDuration => 'Duration';

  @override
  String exportColMonthlyRent(String currency) {
    return 'Monthly rent ($currency)';
  }

  @override
  String get exportColSteg => 'STEG meter';

  @override
  String get exportColSonede => 'SONEDE meter';

  @override
  String get exportColStatus => 'Status';

  @override
  String get exportColLastRentPaid => 'Last rent paid on';

  @override
  String get exportColLastStegPaid => 'Last STEG paid on';

  @override
  String get exportColLastSonedePaid => 'Last SONEDE paid on';

  @override
  String get exportTableName => 'Contracts';

  @override
  String get onboardingWelcome => 'Welcome to LocaTrack';

  @override
  String get onboardingSubtitle =>
      'Track your commercial rental contracts: rent, due dates and STEG/SONEDE meters.';

  @override
  String get onboardingFeature1Title => 'Reminders before expiry';

  @override
  String get onboardingFeature1Subtitle =>
      'Automatic alerts before each lease ends.';

  @override
  String get onboardingFeature2Title => 'Collect payments in one tap';

  @override
  String get onboardingFeature2Subtitle =>
      'Swipe a card to collect, track 12 months.';

  @override
  String get onboardingFeature3Title => 'Private, on your device';

  @override
  String get onboardingFeature3Subtitle =>
      'PIN and biometrics, backup on demand.';

  @override
  String get start => 'Get started';

  @override
  String get cloudLoginTitle => 'Sign in to your LocaTrack account';

  @override
  String get cloudLoginSubtitle =>
      'Your data is shared between mobile and web.';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get fieldRequired => 'Required field';

  @override
  String get signIn => 'Sign in';

  @override
  String get invalidEmail => 'Invalid email address.';

  @override
  String get wrongCredentials => 'Incorrect email or password.';

  @override
  String get accountDisabled => 'This account has been disabled.';

  @override
  String get tooManyAttempts => 'Too many attempts, try again later.';

  @override
  String get noInternet => 'No internet connection.';

  @override
  String signInFailedCode(String code) {
    return 'Sign in failed ($code).';
  }

  @override
  String get appTagline => 'Rental contract management';

  @override
  String get loginSlide1Title => 'All your contracts in one place';

  @override
  String get loginSlide1Subtitle =>
      'Tenants, rent, dates and meters at a glance.';

  @override
  String get loginSlide2Title => 'Reminders before expiry';

  @override
  String get loginSlide2Subtitle =>
      'Get alerted automatically before each lease ends.';

  @override
  String get loginSlide3Title => 'Overview of your rent';

  @override
  String get loginSlide3Subtitle =>
      'Track total rental income and upcoming due dates.';

  @override
  String get biometricNotConfigured => 'Biometrics not set up on this device.';

  @override
  String get biometricCancelled => 'Biometric authentication cancelled.';

  @override
  String get signInWithBiometrics => 'Sign in with biometrics';

  @override
  String get signInWithPasscode => 'Sign in with PassCode';

  @override
  String get passcodeEnterTitle => 'Enter your code';

  @override
  String get passcodeConfirmTitle => 'Confirm your code';

  @override
  String get passcodeCreateTitle => 'Create your code';

  @override
  String passcodeEnterSubtitle(int length) {
    return 'Enter your $length-digit PassCode';
  }

  @override
  String get passcodeConfirmSubtitle => 'Re-enter the same code to confirm';

  @override
  String get passcodeCreateSubtitle =>
      'This code will let you unlock LocaTrack';

  @override
  String get passcodeWrong => 'Wrong code, try again.';

  @override
  String get passcodeMismatch => 'Codes don\'t match, start over.';
}
