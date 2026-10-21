import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @navContracts.
  ///
  /// In fr, this message translates to:
  /// **'Contrats'**
  String get navContracts;

  /// No description provided for @navTenants.
  ///
  /// In fr, this message translates to:
  /// **'Locataires'**
  String get navTenants;

  /// No description provided for @navAnalytics.
  ///
  /// In fr, this message translates to:
  /// **'Analyses'**
  String get navAnalytics;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get navSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get settingsTitle;

  /// No description provided for @settingsSyncedSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisé entre mobile et web.'**
  String get settingsSyncedSubtitle;

  /// No description provided for @settingsReminders.
  ///
  /// In fr, this message translates to:
  /// **'Rappels d\'expiration'**
  String get settingsReminders;

  /// No description provided for @settingsRemindersSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Délai de préavis avant la date de fin d\'un contrat'**
  String get settingsRemindersSubtitle;

  /// No description provided for @months1.
  ///
  /// In fr, this message translates to:
  /// **'1 mois'**
  String get months1;

  /// No description provided for @months2.
  ///
  /// In fr, this message translates to:
  /// **'2 mois'**
  String get months2;

  /// No description provided for @months3.
  ///
  /// In fr, this message translates to:
  /// **'3 mois'**
  String get months3;

  /// No description provided for @settingsCustomDelay.
  ///
  /// In fr, this message translates to:
  /// **'Ou valeur personnalisée (en mois)'**
  String get settingsCustomDelay;

  /// No description provided for @settingsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeAuto.
  ///
  /// In fr, this message translates to:
  /// **'Auto'**
  String get themeAuto;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get languageSystem;

  /// No description provided for @languageFrench.
  ///
  /// In fr, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// No description provided for @languageEnglish.
  ///
  /// In fr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageArabic.
  ///
  /// In fr, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @settingsSecurity.
  ///
  /// In fr, this message translates to:
  /// **'Sécurité'**
  String get settingsSecurity;

  /// No description provided for @biometricUnlock.
  ///
  /// In fr, this message translates to:
  /// **'Déverrouillage biométrique'**
  String get biometricUnlock;

  /// No description provided for @biometricAvailableSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser l\'empreinte ou le visage pour vous connecter'**
  String get biometricAvailableSubtitle;

  /// No description provided for @biometricUnavailableSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Non disponible sur cet appareil'**
  String get biometricUnavailableSubtitle;

  /// No description provided for @changePin.
  ///
  /// In fr, this message translates to:
  /// **'Changer le code PassCode'**
  String get changePin;

  /// No description provided for @settingsAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settingsAccount;

  /// No description provided for @connectedAs.
  ///
  /// In fr, this message translates to:
  /// **'Connecté en tant que'**
  String get connectedAs;

  /// No description provided for @signOutConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get signOutConfirmTitle;

  /// No description provided for @signOutConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Vous devrez ressaisir l\'e-mail et le mot de passe du compte pour retrouver vos données.'**
  String get signOutConfirmBody;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @signOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get signOut;

  /// No description provided for @legacyDataTitle.
  ///
  /// In fr, this message translates to:
  /// **'Anciennes données locales'**
  String get legacyDataTitle;

  /// No description provided for @legacyDataBody.
  ///
  /// In fr, this message translates to:
  /// **'Des contrats enregistrés avant le passage au cloud ont été détectés sur cet appareil. Importez-les une fois vers le compte partagé pour les retrouver sur tous vos appareils.'**
  String get legacyDataBody;

  /// No description provided for @importInProgress.
  ///
  /// In fr, this message translates to:
  /// **'Import en cours…'**
  String get importInProgress;

  /// No description provided for @importToCloud.
  ///
  /// In fr, this message translates to:
  /// **'Importer vers le cloud'**
  String get importToCloud;

  /// No description provided for @importSuccess.
  ///
  /// In fr, this message translates to:
  /// **'{count} éléments importés avec succès.'**
  String importSuccess(int count);

  /// No description provided for @importFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de l\'import : {error}'**
  String importFailed(String error);

  /// No description provided for @exportSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Export'**
  String get exportSectionTitle;

  /// No description provided for @exportSectionBody.
  ///
  /// In fr, this message translates to:
  /// **'Exportez tous les contrats (actifs et en attente) en CSV, Excel, PDF ou image — les noms de locataires en arabe s\'affichent correctement dans les 4 formats.'**
  String get exportSectionBody;

  /// No description provided for @exportShareButton.
  ///
  /// In fr, this message translates to:
  /// **'Exporter / partager'**
  String get exportShareButton;

  /// No description provided for @exportFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de l\'export : {error}'**
  String exportFailed(String error);

  /// No description provided for @fileDownloaded.
  ///
  /// In fr, this message translates to:
  /// **'Fichier téléchargé.'**
  String get fileDownloaded;

  /// No description provided for @downloadCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Téléchargement annulé.'**
  String get downloadCancelled;

  /// No description provided for @exportSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les contrats'**
  String get exportSheetTitle;

  /// No description provided for @exportDocumentTitle.
  ///
  /// In fr, this message translates to:
  /// **'Contrats de location'**
  String get exportDocumentTitle;

  /// No description provided for @exportSheetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les noms des locataires en arabe s\'affichent correctement dans tous les formats.'**
  String get exportSheetSubtitle;

  /// No description provided for @download.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get download;

  /// No description provided for @share.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get share;

  /// No description provided for @formatCsv.
  ///
  /// In fr, this message translates to:
  /// **'CSV'**
  String get formatCsv;

  /// No description provided for @formatExcel.
  ///
  /// In fr, this message translates to:
  /// **'Excel'**
  String get formatExcel;

  /// No description provided for @formatPdf.
  ///
  /// In fr, this message translates to:
  /// **'PDF'**
  String get formatPdf;

  /// No description provided for @formatImage.
  ///
  /// In fr, this message translates to:
  /// **'Image'**
  String get formatImage;

  /// No description provided for @formatCsvDescription.
  ///
  /// In fr, this message translates to:
  /// **'Fichier .csv, compatible Excel'**
  String get formatCsvDescription;

  /// No description provided for @formatExcelDescription.
  ///
  /// In fr, this message translates to:
  /// **'Classeur .xlsx avec mise en forme'**
  String get formatExcelDescription;

  /// No description provided for @formatPdfDescription.
  ///
  /// In fr, this message translates to:
  /// **'Document PDF prêt à imprimer'**
  String get formatPdfDescription;

  /// No description provided for @formatImageDescription.
  ///
  /// In fr, this message translates to:
  /// **'Capture PNG du tableau, à partager'**
  String get formatImageDescription;

  /// No description provided for @screenClosedBeforeExport.
  ///
  /// In fr, this message translates to:
  /// **'Écran fermé avant la fin de l\'export.'**
  String get screenClosedBeforeExport;

  /// No description provided for @excelGenerationFailed.
  ///
  /// In fr, this message translates to:
  /// **'Échec de la génération du fichier Excel.'**
  String get excelGenerationFailed;

  /// No description provided for @durationMonths.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 mois} other{{count} mois}}'**
  String durationMonths(int count);

  /// No description provided for @durationYears.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 an} other{{count} ans}}'**
  String durationYears(int count);

  /// No description provided for @durationNone.
  ///
  /// In fr, this message translates to:
  /// **'—'**
  String get durationNone;

  /// No description provided for @statusActive.
  ///
  /// In fr, this message translates to:
  /// **'Actif'**
  String get statusActive;

  /// No description provided for @statusExpired.
  ///
  /// In fr, this message translates to:
  /// **'Expiré'**
  String get statusExpired;

  /// No description provided for @statusPending.
  ///
  /// In fr, this message translates to:
  /// **'En attente'**
  String get statusPending;

  /// No description provided for @notPaid.
  ///
  /// In fr, this message translates to:
  /// **'Non payé'**
  String get notPaid;

  /// No description provided for @exportColNumber.
  ///
  /// In fr, this message translates to:
  /// **'N°'**
  String get exportColNumber;

  /// No description provided for @exportColTenant.
  ///
  /// In fr, this message translates to:
  /// **'Locataire'**
  String get exportColTenant;

  /// No description provided for @exportColUnit.
  ///
  /// In fr, this message translates to:
  /// **'Local'**
  String get exportColUnit;

  /// No description provided for @exportColStartDate.
  ///
  /// In fr, this message translates to:
  /// **'Date début'**
  String get exportColStartDate;

  /// No description provided for @exportColEndDate.
  ///
  /// In fr, this message translates to:
  /// **'Date fin'**
  String get exportColEndDate;

  /// No description provided for @exportColDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée'**
  String get exportColDuration;

  /// No description provided for @exportColMonthlyRent.
  ///
  /// In fr, this message translates to:
  /// **'Loyer mensuel ({currency})'**
  String exportColMonthlyRent(String currency);

  /// No description provided for @exportColSteg.
  ///
  /// In fr, this message translates to:
  /// **'Compteur STEG'**
  String get exportColSteg;

  /// No description provided for @exportColSonede.
  ///
  /// In fr, this message translates to:
  /// **'Compteur SONEDE'**
  String get exportColSonede;

  /// No description provided for @exportColStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get exportColStatus;

  /// No description provided for @exportColLastRentPaid.
  ///
  /// In fr, this message translates to:
  /// **'Dernier loyer payé le'**
  String get exportColLastRentPaid;

  /// No description provided for @exportColLastStegPaid.
  ///
  /// In fr, this message translates to:
  /// **'Dernier STEG payé le'**
  String get exportColLastStegPaid;

  /// No description provided for @exportColLastSonedePaid.
  ///
  /// In fr, this message translates to:
  /// **'Dernier SONEDE payé le'**
  String get exportColLastSonedePaid;

  /// No description provided for @exportTableName.
  ///
  /// In fr, this message translates to:
  /// **'Contrats'**
  String get exportTableName;

  /// No description provided for @onboardingWelcome.
  ///
  /// In fr, this message translates to:
  /// **'Bienvenue sur LocaTrack'**
  String get onboardingWelcome;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez vos contrats de location de locaux commerciaux : loyers, échéances et compteurs STEG/SONEDE.'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingFeature1Title.
  ///
  /// In fr, this message translates to:
  /// **'Rappels avant expiration'**
  String get onboardingFeature1Title;

  /// No description provided for @onboardingFeature1Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Alertes automatiques avant la fin de chaque bail.'**
  String get onboardingFeature1Subtitle;

  /// No description provided for @onboardingFeature2Title.
  ///
  /// In fr, this message translates to:
  /// **'Encaissements en un geste'**
  String get onboardingFeature2Title;

  /// No description provided for @onboardingFeature2Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Glissez une carte pour encaisser, suivez 12 mois.'**
  String get onboardingFeature2Subtitle;

  /// No description provided for @onboardingFeature3Title.
  ///
  /// In fr, this message translates to:
  /// **'Privé, sur votre appareil'**
  String get onboardingFeature3Title;

  /// No description provided for @onboardingFeature3Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Code et biométrie, sauvegarde à la demande.'**
  String get onboardingFeature3Subtitle;

  /// No description provided for @start.
  ///
  /// In fr, this message translates to:
  /// **'Commencer'**
  String get start;

  /// No description provided for @cloudLoginTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion au compte LocaTrack'**
  String get cloudLoginTitle;

  /// No description provided for @cloudLoginSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Vos données sont partagées entre le mobile et le web.'**
  String get cloudLoginSubtitle;

  /// No description provided for @email.
  ///
  /// In fr, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get password;

  /// No description provided for @fieldRequired.
  ///
  /// In fr, this message translates to:
  /// **'Champ requis'**
  String get fieldRequired;

  /// No description provided for @signIn.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signIn;

  /// No description provided for @invalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide.'**
  String get invalidEmail;

  /// No description provided for @wrongCredentials.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou mot de passe incorrect.'**
  String get wrongCredentials;

  /// No description provided for @accountDisabled.
  ///
  /// In fr, this message translates to:
  /// **'Ce compte a été désactivé.'**
  String get accountDisabled;

  /// No description provided for @tooManyAttempts.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives, réessayez plus tard.'**
  String get tooManyAttempts;

  /// No description provided for @noInternet.
  ///
  /// In fr, this message translates to:
  /// **'Pas de connexion internet.'**
  String get noInternet;

  /// No description provided for @signInFailedCode.
  ///
  /// In fr, this message translates to:
  /// **'Connexion impossible ({code}).'**
  String signInFailedCode(String code);

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Gestion des contrats de location'**
  String get appTagline;

  /// No description provided for @loginSlide1Title.
  ///
  /// In fr, this message translates to:
  /// **'Tous vos contrats au même endroit'**
  String get loginSlide1Title;

  /// No description provided for @loginSlide1Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Locataires, loyers, dates et compteurs en un coup d\'œil.'**
  String get loginSlide1Subtitle;

  /// No description provided for @loginSlide2Title.
  ///
  /// In fr, this message translates to:
  /// **'Rappels avant expiration'**
  String get loginSlide2Title;

  /// No description provided for @loginSlide2Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Soyez alerté automatiquement avant la fin de chaque bail.'**
  String get loginSlide2Subtitle;

  /// No description provided for @loginSlide3Title.
  ///
  /// In fr, this message translates to:
  /// **'Vue d\'ensemble des loyers'**
  String get loginSlide3Title;

  /// No description provided for @loginSlide3Subtitle.
  ///
  /// In fr, this message translates to:
  /// **'Suivez le revenu locatif total et les échéances à venir.'**
  String get loginSlide3Subtitle;

  /// No description provided for @biometricNotConfigured.
  ///
  /// In fr, this message translates to:
  /// **'Biométrie non configurée sur cet appareil.'**
  String get biometricNotConfigured;

  /// No description provided for @biometricCancelled.
  ///
  /// In fr, this message translates to:
  /// **'Authentification biométrique annulée.'**
  String get biometricCancelled;

  /// No description provided for @signInWithBiometrics.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter avec biométrie'**
  String get signInWithBiometrics;

  /// No description provided for @signInWithPasscode.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter via PassCode'**
  String get signInWithPasscode;

  /// No description provided for @passcodeEnterTitle.
  ///
  /// In fr, this message translates to:
  /// **'Entrez votre code'**
  String get passcodeEnterTitle;

  /// No description provided for @passcodeConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Confirmez votre code'**
  String get passcodeConfirmTitle;

  /// No description provided for @passcodeCreateTitle.
  ///
  /// In fr, this message translates to:
  /// **'Créez votre code'**
  String get passcodeCreateTitle;

  /// No description provided for @passcodeEnterSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Saisissez votre PassCode à {length} chiffres'**
  String passcodeEnterSubtitle(int length);

  /// No description provided for @passcodeConfirmSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ressaisissez le même code pour confirmer'**
  String get passcodeConfirmSubtitle;

  /// No description provided for @passcodeCreateSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce code vous permettra de déverrouiller LocaTrack'**
  String get passcodeCreateSubtitle;

  /// No description provided for @passcodeWrong.
  ///
  /// In fr, this message translates to:
  /// **'Code incorrect, réessayez.'**
  String get passcodeWrong;

  /// No description provided for @passcodeMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les codes ne correspondent pas, recommencez.'**
  String get passcodeMismatch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
