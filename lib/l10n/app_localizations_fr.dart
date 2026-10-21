// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get navContracts => 'Contrats';

  @override
  String get navTenants => 'Locataires';

  @override
  String get navAnalytics => 'Analyses';

  @override
  String get navSettings => 'Réglages';

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get settingsSyncedSubtitle => 'Synchronisé entre mobile et web.';

  @override
  String get settingsReminders => 'Rappels d\'expiration';

  @override
  String get settingsRemindersSubtitle =>
      'Délai de préavis avant la date de fin d\'un contrat';

  @override
  String get months1 => '1 mois';

  @override
  String get months2 => '2 mois';

  @override
  String get months3 => '3 mois';

  @override
  String get settingsCustomDelay => 'Ou valeur personnalisée (en mois)';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeAuto => 'Auto';

  @override
  String get themeDark => 'Sombre';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get settingsSecurity => 'Sécurité';

  @override
  String get biometricUnlock => 'Déverrouillage biométrique';

  @override
  String get biometricAvailableSubtitle =>
      'Utiliser l\'empreinte ou le visage pour vous connecter';

  @override
  String get biometricUnavailableSubtitle => 'Non disponible sur cet appareil';

  @override
  String get changePin => 'Changer le code PassCode';

  @override
  String get settingsAccount => 'Compte';

  @override
  String get connectedAs => 'Connecté en tant que';

  @override
  String get signOutConfirmTitle => 'Se déconnecter ?';

  @override
  String get signOutConfirmBody =>
      'Vous devrez ressaisir l\'e-mail et le mot de passe du compte pour retrouver vos données.';

  @override
  String get cancel => 'Annuler';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get legacyDataTitle => 'Anciennes données locales';

  @override
  String get legacyDataBody =>
      'Des contrats enregistrés avant le passage au cloud ont été détectés sur cet appareil. Importez-les une fois vers le compte partagé pour les retrouver sur tous vos appareils.';

  @override
  String get importInProgress => 'Import en cours…';

  @override
  String get importToCloud => 'Importer vers le cloud';

  @override
  String importSuccess(int count) {
    return '$count éléments importés avec succès.';
  }

  @override
  String importFailed(String error) {
    return 'Échec de l\'import : $error';
  }

  @override
  String get exportSectionTitle => 'Export';

  @override
  String get exportSectionBody =>
      'Exportez tous les contrats (actifs et en attente) en CSV, Excel, PDF ou image — les noms de locataires en arabe s\'affichent correctement dans les 4 formats.';

  @override
  String get exportShareButton => 'Exporter / partager';

  @override
  String exportFailed(String error) {
    return 'Échec de l\'export : $error';
  }

  @override
  String get fileDownloaded => 'Fichier téléchargé.';

  @override
  String get downloadCancelled => 'Téléchargement annulé.';

  @override
  String get exportSheetTitle => 'Exporter les contrats';

  @override
  String get exportDocumentTitle => 'Contrats de location';

  @override
  String get exportSheetSubtitle =>
      'Les noms des locataires en arabe s\'affichent correctement dans tous les formats.';

  @override
  String get download => 'Télécharger';

  @override
  String get share => 'Partager';

  @override
  String get formatCsv => 'CSV';

  @override
  String get formatExcel => 'Excel';

  @override
  String get formatPdf => 'PDF';

  @override
  String get formatImage => 'Image';

  @override
  String get formatCsvDescription => 'Fichier .csv, compatible Excel';

  @override
  String get formatExcelDescription => 'Classeur .xlsx avec mise en forme';

  @override
  String get formatPdfDescription => 'Document PDF prêt à imprimer';

  @override
  String get formatImageDescription => 'Capture PNG du tableau, à partager';

  @override
  String get screenClosedBeforeExport =>
      'Écran fermé avant la fin de l\'export.';

  @override
  String get excelGenerationFailed =>
      'Échec de la génération du fichier Excel.';

  @override
  String durationMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mois',
      one: '1 mois',
    );
    return '$_temp0';
  }

  @override
  String durationYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ans',
      one: '1 an',
    );
    return '$_temp0';
  }

  @override
  String get durationNone => '—';

  @override
  String get statusActive => 'Actif';

  @override
  String get statusExpired => 'Expiré';

  @override
  String get statusPending => 'En attente';

  @override
  String get notPaid => 'Non payé';

  @override
  String get exportColNumber => 'N°';

  @override
  String get exportColTenant => 'Locataire';

  @override
  String get exportColUnit => 'Local';

  @override
  String get exportColStartDate => 'Date début';

  @override
  String get exportColEndDate => 'Date fin';

  @override
  String get exportColDuration => 'Durée';

  @override
  String exportColMonthlyRent(String currency) {
    return 'Loyer mensuel ($currency)';
  }

  @override
  String get exportColSteg => 'Compteur STEG';

  @override
  String get exportColSonede => 'Compteur SONEDE';

  @override
  String get exportColStatus => 'Statut';

  @override
  String get exportColLastRentPaid => 'Dernier loyer payé le';

  @override
  String get exportColLastStegPaid => 'Dernier STEG payé le';

  @override
  String get exportColLastSonedePaid => 'Dernier SONEDE payé le';

  @override
  String get exportTableName => 'Contrats';

  @override
  String get onboardingWelcome => 'Bienvenue sur LocaTrack';

  @override
  String get onboardingSubtitle =>
      'Suivez vos contrats de location de locaux commerciaux : loyers, échéances et compteurs STEG/SONEDE.';

  @override
  String get onboardingFeature1Title => 'Rappels avant expiration';

  @override
  String get onboardingFeature1Subtitle =>
      'Alertes automatiques avant la fin de chaque bail.';

  @override
  String get onboardingFeature2Title => 'Encaissements en un geste';

  @override
  String get onboardingFeature2Subtitle =>
      'Glissez une carte pour encaisser, suivez 12 mois.';

  @override
  String get onboardingFeature3Title => 'Privé, sur votre appareil';

  @override
  String get onboardingFeature3Subtitle =>
      'Code et biométrie, sauvegarde à la demande.';

  @override
  String get start => 'Commencer';

  @override
  String get cloudLoginTitle => 'Connexion au compte LocaTrack';

  @override
  String get cloudLoginSubtitle =>
      'Vos données sont partagées entre le mobile et le web.';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get fieldRequired => 'Champ requis';

  @override
  String get signIn => 'Se connecter';

  @override
  String get invalidEmail => 'Adresse e-mail invalide.';

  @override
  String get wrongCredentials => 'E-mail ou mot de passe incorrect.';

  @override
  String get accountDisabled => 'Ce compte a été désactivé.';

  @override
  String get tooManyAttempts => 'Trop de tentatives, réessayez plus tard.';

  @override
  String get noInternet => 'Pas de connexion internet.';

  @override
  String signInFailedCode(String code) {
    return 'Connexion impossible ($code).';
  }

  @override
  String get appTagline => 'Gestion des contrats de location';

  @override
  String get loginSlide1Title => 'Tous vos contrats au même endroit';

  @override
  String get loginSlide1Subtitle =>
      'Locataires, loyers, dates et compteurs en un coup d\'œil.';

  @override
  String get loginSlide2Title => 'Rappels avant expiration';

  @override
  String get loginSlide2Subtitle =>
      'Soyez alerté automatiquement avant la fin de chaque bail.';

  @override
  String get loginSlide3Title => 'Vue d\'ensemble des loyers';

  @override
  String get loginSlide3Subtitle =>
      'Suivez le revenu locatif total et les échéances à venir.';

  @override
  String get biometricNotConfigured =>
      'Biométrie non configurée sur cet appareil.';

  @override
  String get biometricCancelled => 'Authentification biométrique annulée.';

  @override
  String get signInWithBiometrics => 'Se connecter avec biométrie';

  @override
  String get signInWithPasscode => 'Se connecter via PassCode';

  @override
  String get passcodeEnterTitle => 'Entrez votre code';

  @override
  String get passcodeConfirmTitle => 'Confirmez votre code';

  @override
  String get passcodeCreateTitle => 'Créez votre code';

  @override
  String passcodeEnterSubtitle(int length) {
    return 'Saisissez votre PassCode à $length chiffres';
  }

  @override
  String get passcodeConfirmSubtitle =>
      'Ressaisissez le même code pour confirmer';

  @override
  String get passcodeCreateSubtitle =>
      'Ce code vous permettra de déverrouiller LocaTrack';

  @override
  String get passcodeWrong => 'Code incorrect, réessayez.';

  @override
  String get passcodeMismatch => 'Les codes ne correspondent pas, recommencez.';
}
