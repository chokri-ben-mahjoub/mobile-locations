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

  @override
  String genericError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get confirm => 'Confirmer';

  @override
  String get delete => 'Supprimer';

  @override
  String get later => 'Plus tard';

  @override
  String get addNow => 'Ajouter maintenant';

  @override
  String get restore => 'Rétablir';

  @override
  String get collapse => 'Réduire';

  @override
  String get collect => 'Encaisser';

  @override
  String get irreversibleAction => 'Cette action est irréversible.';

  @override
  String get otherCategory => 'Autre';

  @override
  String get addButton => 'Ajouter';

  @override
  String get notesTitle => 'Notes';

  @override
  String get newContractButton => 'Contrat';

  @override
  String get insightUnpaid => 'Impayés';

  @override
  String get insightToRenew => 'À renouveler';

  @override
  String get insightOccupancy => 'Occupation';

  @override
  String get searchHint => 'Rechercher un locataire ou un local…';

  @override
  String get filterAll => 'Tous';

  @override
  String get statusDueSoon => 'Expire bientôt';

  @override
  String get sortTooltip => 'Trier';

  @override
  String get sortExpiryDate => 'Date d\'expiration';

  @override
  String get sortRentDesc => 'Loyer (décroissant)';

  @override
  String get sortRentAsc => 'Loyer (croissant)';

  @override
  String get sortNameAsc => 'Nom (A→Z)';

  @override
  String get contractsEmptyTitle => 'Aucun contrat';

  @override
  String get contractsNoResultTitle => 'Aucun résultat';

  @override
  String get contractsEmptySubtitle =>
      'Ajoutez votre premier contrat avec le bouton +.';

  @override
  String contractsNoResultSubtitle(String query) {
    return 'Aucun contrat ni local en attente ne correspond à « $query ».';
  }

  @override
  String get contractsNoMatchCriteria =>
      'Aucun contrat ne correspond à ces critères.';

  @override
  String get heroTotalMonthlyRent => 'Loyer mensuel total';

  @override
  String get heroCollectedThisMonth => 'Encaissé ce mois';

  @override
  String heroExpectedOf(String amount) {
    return 'sur $amount attendus';
  }

  @override
  String heroActiveContractsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contrats actifs',
      one: '1 contrat actif',
    );
    return '$_temp0';
  }

  @override
  String heroToRenewCount(int count) {
    return '$count à renouveler';
  }

  @override
  String get collectThisMonth => 'Encaisser le mois';

  @override
  String get unpaidSheetTitle => 'Loyers à encaisser';

  @override
  String get shareReportTooltip => 'Partager le rapport';

  @override
  String get allRentsCollected => 'Tous les loyers sont encaissés';

  @override
  String vacantUnitsCount(int count) {
    return 'Locaux en attente ($count)';
  }

  @override
  String lastTenantLabel(String name) {
    return 'Dernier locataire : $name';
  }

  @override
  String get reactivateTooltip => 'Réactiver ce contrat';

  @override
  String get newTenantButton => 'Nouveau locataire';

  @override
  String get reactivateConfirmTitle => 'Réactiver ce contrat ?';

  @override
  String reactivateConfirmBody(String unit, String name) {
    return 'Le local $unit redeviendra actif avec $name comme locataire, comme avant sa mise en attente.';
  }

  @override
  String reactivateConfirmBodyShort(String unit, String name) {
    return 'Le local $unit redeviendra actif avec $name comme locataire.';
  }

  @override
  String get reactivateButton => 'Réactiver';

  @override
  String get exportContractsTooltip => 'Exporter les contrats';

  @override
  String get shareMonthReportTooltip => 'Partager le rapport du mois';

  @override
  String collectedInYear(int year) {
    return 'Encaissé en $year';
  }

  @override
  String collectionRate12m(int rate) {
    return 'Taux d\'encaissement sur 12 mois : $rate %';
  }

  @override
  String get last12Months => '12 derniers mois';

  @override
  String get legendCollected => 'Encaissé';

  @override
  String get legendExpected => 'Attendu';

  @override
  String collectedOfExpected(String collected, String expected) {
    return '$collected sur $expected';
  }

  @override
  String get thisMonthTitle => 'Ce mois-ci';

  @override
  String unpaidCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count impayés',
      one: '1 impayé',
    );
    return '$_temp0';
  }

  @override
  String occupiedUnitsDetail(int occupied, int total) {
    return '$occupied/$total locaux occupés';
  }

  @override
  String get upcomingDueDatesTitle => 'Échéances à venir';

  @override
  String get upcomingDueDatesSubtitle =>
      'Contrats arrivant à terme dans les 6 prochains mois';

  @override
  String get noUpcomingDueDates => 'Aucune échéance dans les 6 prochains mois.';

  @override
  String daysRemaining(int days) {
    return 'J-$days';
  }

  @override
  String get contractExpiredLabel => 'Contrat arrivé à échéance';

  @override
  String remainingMonths(int count) {
    return 'Encore $count mois';
  }

  @override
  String remainingDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Encore $count jours',
      one: 'Encore 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get contractNotFound => 'Contrat introuvable.';

  @override
  String get vacantUnitNotice => 'Local en attente — ancien locataire sorti.';

  @override
  String get unitHistoryTooltip => 'Historique de ce local';

  @override
  String get contractStartLabel => 'Début du contrat';

  @override
  String get contractEndLabel => 'Fin du contrat';

  @override
  String get markVacantButton => 'Locataire sorti — mettre le local en attente';

  @override
  String get markVacantConfirmTitle => 'Marquer ce local en attente ?';

  @override
  String get markVacantConfirmBody =>
      'Le contrat sera clôturé et le local n\'apparaîtra plus parmi les contrats actifs jusqu\'à l\'arrivée d\'un nouveau locataire.';

  @override
  String get newTenantQuestionTitle => 'Nouveau locataire ?';

  @override
  String newTenantQuestionBody(String unit) {
    return 'Le local $unit est maintenant en attente. Voulez-vous ajouter son nouveau locataire tout de suite ?';
  }

  @override
  String get deleteContractConfirmTitle => 'Supprimer ce contrat ?';

  @override
  String get paymentsHistoryTitle => 'Historique des paiements';

  @override
  String paidCountOf(int paid, int total) {
    return '$paid/$total payés';
  }

  @override
  String get paymentsHistoryHint =>
      'Touchez un mois pour basculer payé/impayé. Appui long pour corriger le montant.';

  @override
  String showAllMonths(int count) {
    return 'Afficher tous les mois ($count)';
  }

  @override
  String paymentCancelledSnack(String label) {
    return 'Paiement de $label annulé';
  }

  @override
  String collectedSnack(String label) {
    return '$label encaissé';
  }

  @override
  String get amountPaidLabel => 'Montant payé';

  @override
  String get paymentDateLabel => 'Date de paiement';

  @override
  String get markPaidButton => 'Marquer payé';

  @override
  String get shareReceiptButton => 'Partager la quittance';

  @override
  String get cancelPaymentButton => 'Annuler ce paiement';

  @override
  String get utilityBillsSectionTitle => 'Factures STEG / SONEDE';

  @override
  String settledCountOf(int paid, int total) {
    return '$paid/$total réglées';
  }

  @override
  String get attachmentsSectionTitle => 'Pièces jointes';

  @override
  String get noAttachmentsHint =>
      'Aucune pièce jointe. Ajoutez une photo du contrat, de la CIN\nou de l\'état des lieux.';

  @override
  String get documentTypeTitle => 'Type de document';

  @override
  String get takePhotoOption => 'Prendre une photo';

  @override
  String get pickFromGalleryOption => 'Choisir depuis la galerie';

  @override
  String get deleteAttachmentConfirmTitle => 'Supprimer cette pièce jointe ?';

  @override
  String unitHistoryTitle(String unit) {
    return 'Historique — $unit';
  }

  @override
  String get noUnitHistory => 'Aucun historique pour ce local.';

  @override
  String get unitHistoryStatusOld => 'Ancien';

  @override
  String get unitHistoryStatusCurrent => 'Actuel';

  @override
  String get tenantsEmptyTitle => 'Aucun locataire';

  @override
  String get tenantsEmptySubtitle =>
      'Les contrats que vous créez apparaîtront ici.';

  @override
  String tenantsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count actifs',
      one: '1 actif',
    );
    return '$_temp0';
  }

  @override
  String tenantsCountWithVacant(int active, int vacant) {
    String _temp0 = intl.Intl.pluralLogic(
      active,
      locale: localeName,
      other: '$active actifs',
      one: '1 actif',
    );
    String _temp1 = intl.Intl.pluralLogic(
      vacant,
      locale: localeName,
      other: '$vacant locaux en attente',
      one: '1 local en attente',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get tenantsVacantUnitsTitle => 'Locaux en attente';

  @override
  String get tenantsPeriodLabel => 'Période';

  @override
  String tenantsRentLabel(String currency) {
    return 'Loyer ($currency)';
  }

  @override
  String paidOnDate(String date) {
    return 'Payé le $date';
  }

  @override
  String get contractFormEditTitle => 'Modifier le contrat';

  @override
  String contractFormNewTenantForUnit(String unit) {
    return 'Nouveau locataire — $unit';
  }

  @override
  String get contractFormNewTitle => 'Nouveau contrat';

  @override
  String get contractFormSectionTenantUnit => 'Locataire & local';

  @override
  String get contractFormTenantNameLabel => 'Nom du locataire';

  @override
  String get contractFormUnitNumberLabel => 'Numéro de local (ex: A1-1)';

  @override
  String get contractFormSectionDuration => 'Durée du contrat';

  @override
  String get contractFormStartDateLabel => 'Date de début';

  @override
  String get contractFormEndDateLabel => 'Date de fin';

  @override
  String get contractFormQuickDuration => 'Durée rapide';

  @override
  String get contractFormSectionRentMeters => 'Loyer & compteurs';

  @override
  String get contractFormInvalidAmount => 'Montant invalide';

  @override
  String get contractFormStegLabel => 'Compteur STEG (optionnel)';

  @override
  String get contractFormSonedeLabel => 'Compteur SONEDE (optionnel)';

  @override
  String get contractFormSectionNotes => 'Notes';

  @override
  String get contractFormNotesLabel => 'Notes (optionnel)';

  @override
  String get contractFormSave => 'Enregistrer';

  @override
  String get contractFormAdd => 'Ajouter le contrat';

  @override
  String get meterAutofillHint =>
      'Le compteur reste le même pour ce local, même en cas de changement de locataire.';

  @override
  String get pdfGeneratedOn => 'Généré le';
}
