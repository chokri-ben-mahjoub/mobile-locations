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

  @override
  String genericError(String error) {
    return 'Error: $error';
  }

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get later => 'Later';

  @override
  String get addNow => 'Add now';

  @override
  String get restore => 'Restore';

  @override
  String get collapse => 'Collapse';

  @override
  String get collect => 'Collect';

  @override
  String get irreversibleAction => 'This action cannot be undone.';

  @override
  String get otherCategory => 'Other';

  @override
  String get addButton => 'Add';

  @override
  String get notesTitle => 'Notes';

  @override
  String get newContractButton => 'Contract';

  @override
  String get insightUnpaid => 'Unpaid';

  @override
  String get insightToRenew => 'To renew';

  @override
  String get insightOccupancy => 'Occupancy';

  @override
  String get searchHint => 'Search a tenant or a unit…';

  @override
  String get filterAll => 'All';

  @override
  String get statusDueSoon => 'Expiring soon';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortExpiryDate => 'Expiry date';

  @override
  String get sortRentDesc => 'Rent (highest first)';

  @override
  String get sortRentAsc => 'Rent (lowest first)';

  @override
  String get sortNameAsc => 'Name (A→Z)';

  @override
  String get contractsEmptyTitle => 'No contracts';

  @override
  String get contractsNoResultTitle => 'No results';

  @override
  String get contractsEmptySubtitle =>
      'Add your first contract with the + button.';

  @override
  String contractsNoResultSubtitle(String query) {
    return 'No contract or pending unit matches “$query”.';
  }

  @override
  String get contractsNoMatchCriteria => 'No contract matches these criteria.';

  @override
  String get heroTotalMonthlyRent => 'Total monthly rent';

  @override
  String get heroCollectedThisMonth => 'Collected this month';

  @override
  String heroExpectedOf(String amount) {
    return 'out of $amount expected';
  }

  @override
  String heroActiveContractsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active contracts',
      one: '1 active contract',
    );
    return '$_temp0';
  }

  @override
  String heroToRenewCount(int count) {
    return '$count to renew';
  }

  @override
  String get collectThisMonth => 'Collect this month';

  @override
  String get unpaidSheetTitle => 'Rents to collect';

  @override
  String get shareReportTooltip => 'Share report';

  @override
  String get allRentsCollected => 'All rents are collected';

  @override
  String vacantUnitsCount(int count) {
    return 'Pending units ($count)';
  }

  @override
  String lastTenantLabel(String name) {
    return 'Last tenant: $name';
  }

  @override
  String get reactivateTooltip => 'Reactivate this contract';

  @override
  String get newTenantButton => 'New tenant';

  @override
  String get reactivateConfirmTitle => 'Reactivate this contract?';

  @override
  String reactivateConfirmBody(String unit, String name) {
    return 'Unit $unit will become active again with $name as the tenant, as it was before it was marked pending.';
  }

  @override
  String reactivateConfirmBodyShort(String unit, String name) {
    return 'Unit $unit will become active again with $name as the tenant.';
  }

  @override
  String get reactivateButton => 'Reactivate';

  @override
  String get exportContractsTooltip => 'Export contracts';

  @override
  String get shareMonthReportTooltip => 'Share this month\'s report';

  @override
  String collectedInYear(int year) {
    return 'Collected in $year';
  }

  @override
  String collectionRate12m(int rate) {
    return '12-month collection rate: $rate %';
  }

  @override
  String get last12Months => 'Last 12 months';

  @override
  String get legendCollected => 'Collected';

  @override
  String get legendExpected => 'Expected';

  @override
  String collectedOfExpected(String collected, String expected) {
    return '$collected of $expected';
  }

  @override
  String get thisMonthTitle => 'This month';

  @override
  String unpaidCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unpaid',
      one: '1 unpaid',
    );
    return '$_temp0';
  }

  @override
  String occupiedUnitsDetail(int occupied, int total) {
    return '$occupied/$total units occupied';
  }

  @override
  String get upcomingDueDatesTitle => 'Upcoming due dates';

  @override
  String get upcomingDueDatesSubtitle =>
      'Contracts ending within the next 6 months';

  @override
  String get noUpcomingDueDates => 'No due dates in the next 6 months.';

  @override
  String daysRemaining(int days) {
    return 'D-$days';
  }

  @override
  String get contractExpiredLabel => 'Contract has ended';

  @override
  String remainingMonths(int count) {
    return '$count months left';
  }

  @override
  String remainingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days left',
      one: '1 day left',
    );
    return '$_temp0';
  }

  @override
  String get contractNotFound => 'Contract not found.';

  @override
  String get vacantUnitNotice => 'Pending unit — previous tenant has left.';

  @override
  String get unitHistoryTooltip => 'History of this unit';

  @override
  String get contractStartLabel => 'Contract start';

  @override
  String get contractEndLabel => 'Contract end';

  @override
  String get markVacantButton => 'Tenant has left — mark unit as pending';

  @override
  String get markVacantConfirmTitle => 'Mark this unit as pending?';

  @override
  String get markVacantConfirmBody =>
      'The contract will be closed and the unit will no longer appear among active contracts until a new tenant moves in.';

  @override
  String get newTenantQuestionTitle => 'New tenant?';

  @override
  String newTenantQuestionBody(String unit) {
    return 'Unit $unit is now pending. Do you want to add its new tenant right away?';
  }

  @override
  String get deleteContractConfirmTitle => 'Delete this contract?';

  @override
  String get paymentsHistoryTitle => 'Payment history';

  @override
  String paidCountOf(int paid, int total) {
    return '$paid/$total paid';
  }

  @override
  String get paymentsHistoryHint =>
      'Tap a month to toggle paid/unpaid. Long-press to adjust the amount.';

  @override
  String showAllMonths(int count) {
    return 'Show all months ($count)';
  }

  @override
  String paymentCancelledSnack(String label) {
    return '$label payment cancelled';
  }

  @override
  String collectedSnack(String label) {
    return '$label collected';
  }

  @override
  String get amountPaidLabel => 'Amount paid';

  @override
  String get paymentDateLabel => 'Payment date';

  @override
  String get markPaidButton => 'Mark as paid';

  @override
  String get shareReceiptButton => 'Share receipt';

  @override
  String get cancelPaymentButton => 'Cancel this payment';

  @override
  String get utilityBillsSectionTitle => 'STEG / SONEDE bills';

  @override
  String settledCountOf(int paid, int total) {
    return '$paid/$total settled';
  }

  @override
  String get attachmentsSectionTitle => 'Attachments';

  @override
  String get noAttachmentsHint =>
      'No attachments yet. Add a photo of the contract, ID\nor inspection report.';

  @override
  String get documentTypeTitle => 'Document type';

  @override
  String get takePhotoOption => 'Take a photo';

  @override
  String get pickFromGalleryOption => 'Choose from gallery';

  @override
  String get deleteAttachmentConfirmTitle => 'Delete this attachment?';

  @override
  String unitHistoryTitle(String unit) {
    return 'History — $unit';
  }

  @override
  String get noUnitHistory => 'No history for this unit.';

  @override
  String get unitHistoryStatusOld => 'Past';

  @override
  String get unitHistoryStatusCurrent => 'Current';

  @override
  String get tenantsEmptyTitle => 'No tenants';

  @override
  String get tenantsEmptySubtitle => 'Contracts you create will appear here.';

  @override
  String tenantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active',
      one: '1 active',
    );
    return '$_temp0';
  }

  @override
  String tenantsCountWithVacant(int active, int vacant) {
    String _temp0 = intl.Intl.pluralLogic(
      active,
      locale: localeName,
      other: '$active active',
      one: '1 active',
    );
    String _temp1 = intl.Intl.pluralLogic(
      vacant,
      locale: localeName,
      other: '$vacant pending units',
      one: '1 pending unit',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get tenantsVacantUnitsTitle => 'Pending units';

  @override
  String get tenantsPeriodLabel => 'Period';

  @override
  String tenantsRentLabel(String currency) {
    return 'Rent ($currency)';
  }

  @override
  String paidOnDate(String date) {
    return 'Paid on $date';
  }

  @override
  String get contractFormEditTitle => 'Edit contract';

  @override
  String contractFormNewTenantForUnit(String unit) {
    return 'New tenant — $unit';
  }

  @override
  String get contractFormNewTitle => 'New contract';

  @override
  String get contractFormSectionTenantUnit => 'Tenant & unit';

  @override
  String get contractFormTenantNameLabel => 'Tenant name';

  @override
  String get contractFormUnitNumberLabel => 'Unit number (e.g. A1-1)';

  @override
  String get contractFormSectionDuration => 'Contract duration';

  @override
  String get contractFormStartDateLabel => 'Start date';

  @override
  String get contractFormEndDateLabel => 'End date';

  @override
  String get contractFormQuickDuration => 'Quick duration';

  @override
  String get contractFormSectionRentMeters => 'Rent & meters';

  @override
  String get contractFormInvalidAmount => 'Invalid amount';

  @override
  String get contractFormStegLabel => 'STEG meter (optional)';

  @override
  String get contractFormSonedeLabel => 'SONEDE meter (optional)';

  @override
  String get contractFormSectionNotes => 'Notes';

  @override
  String get contractFormNotesLabel => 'Notes (optional)';

  @override
  String get contractFormSave => 'Save';

  @override
  String get contractFormAdd => 'Add contract';

  @override
  String get meterAutofillHint =>
      'The meter stays the same for this unit, even when the tenant changes.';

  @override
  String get pdfGeneratedOn => 'Generated on';
}
