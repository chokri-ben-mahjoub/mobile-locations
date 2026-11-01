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

  /// No description provided for @genericError.
  ///
  /// In fr, this message translates to:
  /// **'Erreur : {error}'**
  String genericError(String error);

  /// No description provided for @confirm.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer'**
  String get confirm;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @later.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get later;

  /// No description provided for @addNow.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter maintenant'**
  String get addNow;

  /// No description provided for @restore.
  ///
  /// In fr, this message translates to:
  /// **'Rétablir'**
  String get restore;

  /// No description provided for @collapse.
  ///
  /// In fr, this message translates to:
  /// **'Réduire'**
  String get collapse;

  /// No description provided for @collect.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser'**
  String get collect;

  /// No description provided for @irreversibleAction.
  ///
  /// In fr, this message translates to:
  /// **'Cette action est irréversible.'**
  String get irreversibleAction;

  /// No description provided for @otherCategory.
  ///
  /// In fr, this message translates to:
  /// **'Autre'**
  String get otherCategory;

  /// No description provided for @addButton.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter'**
  String get addButton;

  /// No description provided for @notesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get notesTitle;

  /// No description provided for @newContractButton.
  ///
  /// In fr, this message translates to:
  /// **'Contrat'**
  String get newContractButton;

  /// No description provided for @insightUnpaid.
  ///
  /// In fr, this message translates to:
  /// **'Impayés'**
  String get insightUnpaid;

  /// No description provided for @insightToRenew.
  ///
  /// In fr, this message translates to:
  /// **'À renouveler'**
  String get insightToRenew;

  /// No description provided for @insightOccupancy.
  ///
  /// In fr, this message translates to:
  /// **'Occupation'**
  String get insightOccupancy;

  /// No description provided for @searchHint.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher un locataire ou un local…'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Tous'**
  String get filterAll;

  /// No description provided for @statusDueSoon.
  ///
  /// In fr, this message translates to:
  /// **'Expire bientôt'**
  String get statusDueSoon;

  /// No description provided for @sortTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sortTooltip;

  /// No description provided for @sortExpiryDate.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'expiration'**
  String get sortExpiryDate;

  /// No description provided for @sortRentDesc.
  ///
  /// In fr, this message translates to:
  /// **'Loyer (décroissant)'**
  String get sortRentDesc;

  /// No description provided for @sortRentAsc.
  ///
  /// In fr, this message translates to:
  /// **'Loyer (croissant)'**
  String get sortRentAsc;

  /// No description provided for @sortNameAsc.
  ///
  /// In fr, this message translates to:
  /// **'Nom (A→Z)'**
  String get sortNameAsc;

  /// No description provided for @contractsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contrat'**
  String get contractsEmptyTitle;

  /// No description provided for @contractsNoResultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat'**
  String get contractsNoResultTitle;

  /// No description provided for @contractsEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutez votre premier contrat avec le bouton +.'**
  String get contractsEmptySubtitle;

  /// No description provided for @contractsNoResultSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contrat ni local en attente ne correspond à « {query} ».'**
  String contractsNoResultSubtitle(String query);

  /// No description provided for @contractsNoMatchCriteria.
  ///
  /// In fr, this message translates to:
  /// **'Aucun contrat ne correspond à ces critères.'**
  String get contractsNoMatchCriteria;

  /// No description provided for @heroTotalMonthlyRent.
  ///
  /// In fr, this message translates to:
  /// **'Loyer mensuel total'**
  String get heroTotalMonthlyRent;

  /// No description provided for @heroCollectedThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé ce mois'**
  String get heroCollectedThisMonth;

  /// No description provided for @heroExpectedOf.
  ///
  /// In fr, this message translates to:
  /// **'sur {amount} attendus'**
  String heroExpectedOf(String amount);

  /// No description provided for @heroActiveContractsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 contrat actif} other{{count} contrats actifs}}'**
  String heroActiveContractsCount(int count);

  /// No description provided for @heroToRenewCount.
  ///
  /// In fr, this message translates to:
  /// **'{count} à renouveler'**
  String heroToRenewCount(int count);

  /// No description provided for @collectThisMonth.
  ///
  /// In fr, this message translates to:
  /// **'Encaisser le mois'**
  String get collectThisMonth;

  /// No description provided for @unpaidSheetTitle.
  ///
  /// In fr, this message translates to:
  /// **'Loyers à encaisser'**
  String get unpaidSheetTitle;

  /// No description provided for @shareReportTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Partager le rapport'**
  String get shareReportTooltip;

  /// No description provided for @allRentsCollected.
  ///
  /// In fr, this message translates to:
  /// **'Tous les loyers sont encaissés'**
  String get allRentsCollected;

  /// No description provided for @vacantUnitsCount.
  ///
  /// In fr, this message translates to:
  /// **'Locaux en attente ({count})'**
  String vacantUnitsCount(int count);

  /// No description provided for @lastTenantLabel.
  ///
  /// In fr, this message translates to:
  /// **'Dernier locataire : {name}'**
  String lastTenantLabel(String name);

  /// No description provided for @reactivateTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Réactiver ce contrat'**
  String get reactivateTooltip;

  /// No description provided for @newTenantButton.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau locataire'**
  String get newTenantButton;

  /// No description provided for @reactivateConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Réactiver ce contrat ?'**
  String get reactivateConfirmTitle;

  /// No description provided for @reactivateConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Le local {unit} redeviendra actif avec {name} comme locataire, comme avant sa mise en attente.'**
  String reactivateConfirmBody(String unit, String name);

  /// No description provided for @reactivateConfirmBodyShort.
  ///
  /// In fr, this message translates to:
  /// **'Le local {unit} redeviendra actif avec {name} comme locataire.'**
  String reactivateConfirmBodyShort(String unit, String name);

  /// No description provided for @reactivateButton.
  ///
  /// In fr, this message translates to:
  /// **'Réactiver'**
  String get reactivateButton;

  /// No description provided for @exportContractsTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Exporter les contrats'**
  String get exportContractsTooltip;

  /// No description provided for @shareMonthReportTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Partager le rapport du mois'**
  String get shareMonthReportTooltip;

  /// No description provided for @collectedInYear.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé en {year}'**
  String collectedInYear(int year);

  /// No description provided for @collectionRate12m.
  ///
  /// In fr, this message translates to:
  /// **'Taux d\'encaissement sur 12 mois : {rate} %'**
  String collectionRate12m(int rate);

  /// No description provided for @last12Months.
  ///
  /// In fr, this message translates to:
  /// **'12 derniers mois'**
  String get last12Months;

  /// No description provided for @legendCollected.
  ///
  /// In fr, this message translates to:
  /// **'Encaissé'**
  String get legendCollected;

  /// No description provided for @legendExpected.
  ///
  /// In fr, this message translates to:
  /// **'Attendu'**
  String get legendExpected;

  /// No description provided for @collectedOfExpected.
  ///
  /// In fr, this message translates to:
  /// **'{collected} sur {expected}'**
  String collectedOfExpected(String collected, String expected);

  /// No description provided for @thisMonthTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ce mois-ci'**
  String get thisMonthTitle;

  /// No description provided for @unpaidCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 impayé} other{{count} impayés}}'**
  String unpaidCount(int count);

  /// No description provided for @occupiedUnitsDetail.
  ///
  /// In fr, this message translates to:
  /// **'{occupied}/{total} locaux occupés'**
  String occupiedUnitsDetail(int occupied, int total);

  /// No description provided for @upcomingDueDatesTitle.
  ///
  /// In fr, this message translates to:
  /// **'Échéances à venir'**
  String get upcomingDueDatesTitle;

  /// No description provided for @upcomingDueDatesSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Contrats arrivant à terme dans les 6 prochains mois'**
  String get upcomingDueDatesSubtitle;

  /// No description provided for @noUpcomingDueDates.
  ///
  /// In fr, this message translates to:
  /// **'Aucune échéance dans les 6 prochains mois.'**
  String get noUpcomingDueDates;

  /// No description provided for @daysRemaining.
  ///
  /// In fr, this message translates to:
  /// **'J-{days}'**
  String daysRemaining(int days);

  /// No description provided for @contractExpiredLabel.
  ///
  /// In fr, this message translates to:
  /// **'Contrat arrivé à échéance'**
  String get contractExpiredLabel;

  /// No description provided for @remainingMonths.
  ///
  /// In fr, this message translates to:
  /// **'Encore {count} mois'**
  String remainingMonths(int count);

  /// No description provided for @remainingDays.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{Encore 1 jour} other{Encore {count} jours}}'**
  String remainingDays(int count);

  /// No description provided for @contractNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Contrat introuvable.'**
  String get contractNotFound;

  /// No description provided for @vacantUnitNotice.
  ///
  /// In fr, this message translates to:
  /// **'Local en attente — ancien locataire sorti.'**
  String get vacantUnitNotice;

  /// No description provided for @unitHistoryTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Historique de ce local'**
  String get unitHistoryTooltip;

  /// No description provided for @contractStartLabel.
  ///
  /// In fr, this message translates to:
  /// **'Début du contrat'**
  String get contractStartLabel;

  /// No description provided for @contractEndLabel.
  ///
  /// In fr, this message translates to:
  /// **'Fin du contrat'**
  String get contractEndLabel;

  /// No description provided for @markVacantButton.
  ///
  /// In fr, this message translates to:
  /// **'Locataire sorti — mettre le local en attente'**
  String get markVacantButton;

  /// No description provided for @markVacantConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Marquer ce local en attente ?'**
  String get markVacantConfirmTitle;

  /// No description provided for @markVacantConfirmBody.
  ///
  /// In fr, this message translates to:
  /// **'Le contrat sera clôturé et le local n\'apparaîtra plus parmi les contrats actifs jusqu\'à l\'arrivée d\'un nouveau locataire.'**
  String get markVacantConfirmBody;

  /// No description provided for @newTenantQuestionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau locataire ?'**
  String get newTenantQuestionTitle;

  /// No description provided for @newTenantQuestionBody.
  ///
  /// In fr, this message translates to:
  /// **'Le local {unit} est maintenant en attente. Voulez-vous ajouter son nouveau locataire tout de suite ?'**
  String newTenantQuestionBody(String unit);

  /// No description provided for @deleteContractConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer ce contrat ?'**
  String get deleteContractConfirmTitle;

  /// No description provided for @paymentsHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique des paiements'**
  String get paymentsHistoryTitle;

  /// No description provided for @paidCountOf.
  ///
  /// In fr, this message translates to:
  /// **'{paid}/{total} payés'**
  String paidCountOf(int paid, int total);

  /// No description provided for @paymentsHistoryHint.
  ///
  /// In fr, this message translates to:
  /// **'Touchez un mois pour basculer payé/impayé. Appui long pour corriger le montant.'**
  String get paymentsHistoryHint;

  /// No description provided for @showAllMonths.
  ///
  /// In fr, this message translates to:
  /// **'Afficher tous les mois ({count})'**
  String showAllMonths(int count);

  /// No description provided for @paymentCancelledSnack.
  ///
  /// In fr, this message translates to:
  /// **'Paiement de {label} annulé'**
  String paymentCancelledSnack(String label);

  /// No description provided for @collectedSnack.
  ///
  /// In fr, this message translates to:
  /// **'{label} encaissé'**
  String collectedSnack(String label);

  /// No description provided for @amountPaidLabel.
  ///
  /// In fr, this message translates to:
  /// **'Montant payé'**
  String get amountPaidLabel;

  /// No description provided for @paymentDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de paiement'**
  String get paymentDateLabel;

  /// No description provided for @markPaidButton.
  ///
  /// In fr, this message translates to:
  /// **'Marquer payé'**
  String get markPaidButton;

  /// No description provided for @shareReceiptButton.
  ///
  /// In fr, this message translates to:
  /// **'Partager la quittance'**
  String get shareReceiptButton;

  /// No description provided for @cancelPaymentButton.
  ///
  /// In fr, this message translates to:
  /// **'Annuler ce paiement'**
  String get cancelPaymentButton;

  /// No description provided for @utilityBillsSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Factures STEG / SONEDE'**
  String get utilityBillsSectionTitle;

  /// No description provided for @settledCountOf.
  ///
  /// In fr, this message translates to:
  /// **'{paid}/{total} réglées'**
  String settledCountOf(int paid, int total);

  /// No description provided for @attachmentsSectionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Pièces jointes'**
  String get attachmentsSectionTitle;

  /// No description provided for @noAttachmentsHint.
  ///
  /// In fr, this message translates to:
  /// **'Aucune pièce jointe. Ajoutez une photo du contrat, de la CIN\nou de l\'état des lieux.'**
  String get noAttachmentsHint;

  /// No description provided for @documentTypeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Type de document'**
  String get documentTypeTitle;

  /// No description provided for @takePhotoOption.
  ///
  /// In fr, this message translates to:
  /// **'Prendre une photo'**
  String get takePhotoOption;

  /// No description provided for @pickFromGalleryOption.
  ///
  /// In fr, this message translates to:
  /// **'Choisir depuis la galerie'**
  String get pickFromGalleryOption;

  /// No description provided for @deleteAttachmentConfirmTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette pièce jointe ?'**
  String get deleteAttachmentConfirmTitle;

  /// No description provided for @unitHistoryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Historique — {unit}'**
  String unitHistoryTitle(String unit);

  /// No description provided for @noUnitHistory.
  ///
  /// In fr, this message translates to:
  /// **'Aucun historique pour ce local.'**
  String get noUnitHistory;

  /// No description provided for @unitHistoryStatusOld.
  ///
  /// In fr, this message translates to:
  /// **'Ancien'**
  String get unitHistoryStatusOld;

  /// No description provided for @unitHistoryStatusCurrent.
  ///
  /// In fr, this message translates to:
  /// **'Actuel'**
  String get unitHistoryStatusCurrent;

  /// No description provided for @tenantsEmptyTitle.
  ///
  /// In fr, this message translates to:
  /// **'Aucun locataire'**
  String get tenantsEmptyTitle;

  /// No description provided for @tenantsEmptySubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Les contrats que vous créez apparaîtront ici.'**
  String get tenantsEmptySubtitle;

  /// No description provided for @tenantsCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, one{1 actif} other{{count} actifs}}'**
  String tenantsCount(int count);

  /// No description provided for @tenantsCountWithVacant.
  ///
  /// In fr, this message translates to:
  /// **'{active, plural, one{1 actif} other{{active} actifs}} · {vacant, plural, one{1 local en attente} other{{vacant} locaux en attente}}'**
  String tenantsCountWithVacant(int active, int vacant);

  /// No description provided for @tenantsVacantUnitsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Locaux en attente'**
  String get tenantsVacantUnitsTitle;

  /// No description provided for @tenantsPeriodLabel.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get tenantsPeriodLabel;

  /// No description provided for @tenantsRentLabel.
  ///
  /// In fr, this message translates to:
  /// **'Loyer ({currency})'**
  String tenantsRentLabel(String currency);

  /// No description provided for @paidOnDate.
  ///
  /// In fr, this message translates to:
  /// **'Payé le {date}'**
  String paidOnDate(String date);

  /// No description provided for @contractFormEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier le contrat'**
  String get contractFormEditTitle;

  /// No description provided for @contractFormNewTenantForUnit.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau locataire — {unit}'**
  String contractFormNewTenantForUnit(String unit);

  /// No description provided for @contractFormNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau contrat'**
  String get contractFormNewTitle;

  /// No description provided for @contractFormSectionTenantUnit.
  ///
  /// In fr, this message translates to:
  /// **'Locataire & local'**
  String get contractFormSectionTenantUnit;

  /// No description provided for @contractFormTenantNameLabel.
  ///
  /// In fr, this message translates to:
  /// **'Nom du locataire'**
  String get contractFormTenantNameLabel;

  /// No description provided for @contractFormUnitNumberLabel.
  ///
  /// In fr, this message translates to:
  /// **'Numéro de local (ex: A1-1)'**
  String get contractFormUnitNumberLabel;

  /// No description provided for @contractFormSectionDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée du contrat'**
  String get contractFormSectionDuration;

  /// No description provided for @contractFormStartDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de début'**
  String get contractFormStartDateLabel;

  /// No description provided for @contractFormEndDateLabel.
  ///
  /// In fr, this message translates to:
  /// **'Date de fin'**
  String get contractFormEndDateLabel;

  /// No description provided for @contractFormQuickDuration.
  ///
  /// In fr, this message translates to:
  /// **'Durée rapide'**
  String get contractFormQuickDuration;

  /// No description provided for @contractFormSectionRentMeters.
  ///
  /// In fr, this message translates to:
  /// **'Loyer & compteurs'**
  String get contractFormSectionRentMeters;

  /// No description provided for @contractFormInvalidAmount.
  ///
  /// In fr, this message translates to:
  /// **'Montant invalide'**
  String get contractFormInvalidAmount;

  /// No description provided for @contractFormStegLabel.
  ///
  /// In fr, this message translates to:
  /// **'Compteur STEG (optionnel)'**
  String get contractFormStegLabel;

  /// No description provided for @contractFormSonedeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Compteur SONEDE (optionnel)'**
  String get contractFormSonedeLabel;

  /// No description provided for @contractFormSectionNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get contractFormSectionNotes;

  /// No description provided for @contractFormNotesLabel.
  ///
  /// In fr, this message translates to:
  /// **'Notes (optionnel)'**
  String get contractFormNotesLabel;

  /// No description provided for @contractFormSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get contractFormSave;

  /// No description provided for @contractFormAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter le contrat'**
  String get contractFormAdd;

  /// No description provided for @meterAutofillHint.
  ///
  /// In fr, this message translates to:
  /// **'Le compteur reste le même pour ce local, même en cas de changement de locataire.'**
  String get meterAutofillHint;

  /// No description provided for @pdfGeneratedOn.
  ///
  /// In fr, this message translates to:
  /// **'Généré le'**
  String get pdfGeneratedOn;
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
