import 'package:intl/intl.dart';
import 'package:locations_app/l10n/app_localizations.dart';

class FormatUtils {
  static String currency(double amount, String currencyCode) {
    final formatter = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: currencyCode,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static final DateFormat dayMonth = DateFormat('d MMM', 'fr_FR');
  static final DateFormat fullDate = DateFormat('EEEE d MMMM yyyy', 'fr_FR');
  static final DateFormat shortDate = DateFormat('dd/MM/yyyy');
  static final DateFormat monthYear = DateFormat('MMMM yyyy', 'fr_FR');

  /// Durée approximative entre deux dates, en mois entiers.
  static int monthsBetween(DateTime start, DateTime end) {
    var months = (end.year - start.year) * 12 + (end.month - start.month);
    if (end.day < start.day) months -= 1;
    return months < 0 ? 0 : months;
  }

  static String durationLabel(AppLocalizations l10n, DateTime start, DateTime end) {
    final months = monthsBetween(start, end);
    if (months <= 0) return l10n.durationNone;
    if (months % 12 == 0) {
      return l10n.durationYears(months ~/ 12);
    }
    return l10n.durationMonths(months);
  }
}
