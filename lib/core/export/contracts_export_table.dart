import '../data/models.dart';
import '../utils/format_utils.dart';
import 'export_table.dart';

String contractStatusLabel(Contract c, DateTime now) {
  if (c.archived) return 'En attente';
  if (!c.endDate.isAfter(now)) return 'Expiré';
  return 'Actif';
}

/// Construit le tableau générique (utilisé par les 4 formats d'export —
/// CSV, Excel, PDF, image) à partir des contrats. Les noms de locataires
/// arabes sont transmis tels quels : chaque exporteur gère leur rendu pour
/// son propre format.
ExportTable buildContractsExportTable(List<Contract> contracts, String currency) {
  final now = DateTime.now();
  final sorted = [...contracts]..sort((a, b) => a.endDate.compareTo(b.endDate));

  return ExportTable(
    name: 'Contrats',
    headers: [
      'N°',
      'Locataire',
      'Local',
      'Date début',
      'Date fin',
      'Durée',
      'Loyer mensuel ($currency)',
      'Compteur STEG',
      'Compteur SONEDE',
      'Statut',
    ],
    rows: [
      for (final (i, c) in sorted.indexed)
        [
          i + 1,
          c.tenantName,
          c.unitNumber,
          DateOnly(c.startDate),
          DateOnly(c.endDate),
          FormatUtils.durationLabel(c.startDate, c.endDate),
          c.monthlyAmount,
          c.stegMeter ?? '',
          c.sonedeMeter ?? '',
          contractStatusLabel(c, now),
        ],
    ],
  );
}
