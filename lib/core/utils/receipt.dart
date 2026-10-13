import 'package:intl/intl.dart';

import '../database/app_database.dart';
import 'format_utils.dart';

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

/// Quittance de loyer en texte brut, prête à être partagée (WhatsApp, SMS…).
String buildReceiptText({
  required Contract contract,
  required DateTime month,
  required double amount,
  required DateTime paidDate,
  required String currency,
}) {
  final period = _cap(FormatUtils.monthYear.format(month));
  return [
    'QUITTANCE DE LOYER',
    '─────────────────',
    'Période : $period',
    'Locataire : ${contract.tenantName}',
    'Local : ${contract.unitNumber}',
    'Montant reçu : ${FormatUtils.currency(amount, currency)}',
    'Date de paiement : ${FormatUtils.shortDate.format(paidDate)}',
    '',
    'Je soussigné(e) reconnais avoir reçu la somme ci-dessus au titre du '
        'loyer de la période indiquée.',
    '',
    'Généré avec LocaTrack',
  ].join('\n');
}

/// Récapitulatif du mois pour partage rapide.
String buildMonthReportText({
  required DateTime month,
  required double expected,
  required double collected,
  required List<Contract> unpaid,
  required String currency,
}) {
  final period = _cap(DateFormat('MMMM yyyy', 'fr_FR').format(month));
  final rate = expected <= 0 ? 0 : (collected / expected * 100).round();
  final lines = <String>[
    'RAPPORT LOCATIF — $period',
    '─────────────────',
    'Attendu : ${FormatUtils.currency(expected, currency)}',
    'Encaissé : ${FormatUtils.currency(collected, currency)} ($rate %)',
  ];
  if (unpaid.isEmpty) {
    lines.add('Tous les loyers sont encaissés.');
  } else {
    lines.add('');
    lines.add('Impayés (${unpaid.length}) :');
    for (final c in unpaid) {
      lines.add(
        '• ${c.unitNumber} — ${c.tenantName} : '
        '${FormatUtils.currency(c.monthlyAmount, currency)}',
      );
    }
  }
  lines
    ..add('')
    ..add('Généré avec LocaTrack');
  return lines.join('\n');
}
