import 'package:locations_app/l10n/app_localizations.dart';

import '../data/models.dart';
import '../utils/format_utils.dart';
import 'export_table.dart';

String contractStatusLabel(AppLocalizations l10n, Contract c, DateTime now) {
  if (c.archived) return l10n.statusPending;
  if (!c.endDate.isAfter(now)) return l10n.statusExpired;
  return l10n.statusActive;
}

DateTime? _latestPaidDate(Iterable<DateTime> dates) {
  DateTime? latest;
  for (final d in dates) {
    if (latest == null || d.isAfter(latest)) latest = d;
  }
  return latest;
}

/// Construit le tableau générique (utilisé par les 4 formats d'export —
/// CSV, Excel, PDF, image) à partir des contrats. Les noms de locataires
/// arabes sont transmis tels quels : chaque exporteur gère leur rendu pour
/// son propre format.
///
/// [payments] et [utilityBills] (optionnels) ajoutent la date du dernier
/// loyer, de la dernière facture STEG et de la dernière facture SONEDE
/// réglés par le locataire, pour chaque contrat.
ExportTable buildContractsExportTable(
  AppLocalizations l10n,
  List<Contract> contracts,
  String currency, {
  List<Payment> payments = const [],
  List<UtilityBill> utilityBills = const [],
}) {
  final now = DateTime.now();
  final sorted = [...contracts]..sort((a, b) => a.endDate.compareTo(b.endDate));

  final paymentsByContract = <String, List<Payment>>{};
  for (final p in payments) {
    paymentsByContract.putIfAbsent(p.contractId, () => []).add(p);
  }
  final utilityBillsByContract = <String, List<UtilityBill>>{};
  for (final b in utilityBills) {
    utilityBillsByContract.putIfAbsent(b.contractId, () => []).add(b);
  }

  return ExportTable(
    name: l10n.exportTableName,
    headers: [
      l10n.exportColNumber,
      l10n.exportColTenant,
      l10n.exportColUnit,
      l10n.exportColStartDate,
      l10n.exportColEndDate,
      l10n.exportColDuration,
      l10n.exportColMonthlyRent(currency),
      l10n.exportColSteg,
      l10n.exportColSonede,
      l10n.exportColStatus,
      l10n.exportColLastRentPaid,
      l10n.exportColLastStegPaid,
      l10n.exportColLastSonedePaid,
    ],
    rows: [
      for (final (i, c) in sorted.indexed)
        [
          i + 1,
          c.tenantName,
          c.unitNumber,
          DateOnly(c.startDate),
          DateOnly(c.endDate),
          FormatUtils.durationLabel(l10n, c.startDate, c.endDate),
          c.monthlyAmount,
          c.stegMeter ?? '',
          c.sonedeMeter ?? '',
          contractStatusLabel(l10n, c, now),
          _lastPaidCell(l10n, paymentsByContract[c.id]?.map((p) => p.paidDate)),
          _lastPaidCell(
            l10n,
            utilityBillsByContract[c.id]?.where((b) => b.type == 'steg').map((b) => b.paidDate),
          ),
          _lastPaidCell(
            l10n,
            utilityBillsByContract[c.id]?.where((b) => b.type == 'sonede').map((b) => b.paidDate),
          ),
        ],
    ],
  );
}

Object _lastPaidCell(AppLocalizations l10n, Iterable<DateTime>? dates) {
  if (dates == null) return l10n.notPaid;
  final latest = _latestPaidDate(dates);
  return latest == null ? l10n.notPaid : DateOnly(latest);
}
