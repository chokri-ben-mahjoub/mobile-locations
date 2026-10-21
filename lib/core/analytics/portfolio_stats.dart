import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_providers.dart';

class MonthStat {
  final DateTime month;
  final double expected;
  final double collected;
  const MonthStat(this.month, this.expected, this.collected);

  double get rate => expected <= 0 ? 0 : (collected / expected).clamp(0.0, 1.0);
}

class PortfolioStats {
  /// 12 derniers mois, du plus ancien au mois en cours.
  final List<MonthStat> months;
  final List<Contract> active;
  final List<Contract> unpaidThisMonth;
  final int vacantUnits;
  final double yearCollected;

  const PortfolioStats({
    required this.months,
    required this.active,
    required this.unpaidThisMonth,
    required this.vacantUnits,
    required this.yearCollected,
  });

  MonthStat get current => months.last;

  int get occupiedUnits => active.map((c) => c.unitNumber).toSet().length;

  int get totalUnits => occupiedUnits + vacantUnits;

  double get occupancy => totalUnits == 0 ? 0 : occupiedUnits / totalUnits;

  double get monthlyTotal => active.fold(0.0, (s, c) => s + c.monthlyAmount);

  /// Contrats actifs expirant dans les [days] prochains jours (ou déjà expirés).
  List<Contract> expiringWithin(int days, DateTime now) {
    final limit = now.add(Duration(days: days));
    final list = active.where((c) => c.endDate.isBefore(limit)).toList()
      ..sort((a, b) => a.endDate.compareTo(b.endDate));
    return list;
  }
}

DateTime _monthStart(DateTime d) => DateTime(d.year, d.month, 1);

/// Un contrat est suivi du mois de début jusqu'au mois en cours (actif), ou
/// jusqu'à sa fin s'il est clôturé — même règle que l'historique des paiements.
bool _tracked(Contract c, DateTime month, DateTime now) {
  final start = _monthStart(c.startDate);
  final last = c.archived && c.endDate.isBefore(now)
      ? _monthStart(c.endDate)
      : _monthStart(now);
  return !month.isBefore(start) && !month.isAfter(last);
}

PortfolioStats computePortfolioStats({
  required List<Contract> active,
  required List<Contract> vacant,
  required List<Payment> payments,
  required DateTime now,
}) {
  final all = [...active, ...vacant];
  final collectedByMonth = <DateTime, double>{};
  for (final p in payments) {
    final k = _monthStart(p.month);
    collectedByMonth[k] = (collectedByMonth[k] ?? 0) + p.amount;
  }

  final months = <MonthStat>[];
  for (var i = 11; i >= 0; i--) {
    final m = DateTime(now.year, now.month - i, 1);
    final expected = all
        .where((c) => _tracked(c, m, now))
        .fold<double>(0, (s, c) => s + c.monthlyAmount);
    months.add(MonthStat(m, expected, collectedByMonth[m] ?? 0));
  }

  final thisMonth = _monthStart(now);
  final paidIds = {
    for (final p in payments)
      if (_monthStart(p.month) == thisMonth) p.contractId,
  };
  final unpaid = active.where((c) => !paidIds.contains(c.id)).toList()
    ..sort((a, b) => b.monthlyAmount.compareTo(a.monthlyAmount));

  final activeUnits = active.map((c) => c.unitNumber).toSet();
  final vacantUnits = vacant
      .map((c) => c.unitNumber)
      .toSet()
      .difference(activeUnits)
      .length;

  final yearCollected = collectedByMonth.entries
      .where((e) => e.key.year == now.year)
      .fold<double>(0, (s, e) => s + e.value);

  return PortfolioStats(
    months: months,
    active: active,
    unpaidThisMonth: unpaid,
    vacantUnits: vacantUnits,
    yearCollected: yearCollected,
  );
}

final portfolioStatsProvider = Provider<AsyncValue<PortfolioStats>>((ref) {
  final active = ref.watch(contractsProvider);
  final vacant = ref.watch(vacantContractsProvider);
  final payments = ref.watch(allPaymentsProvider);

  if (active.hasError) {
    return AsyncValue.error(active.error!, active.stackTrace!);
  }
  if (!active.hasValue || !vacant.hasValue || !payments.hasValue) {
    return const AsyncValue.loading();
  }
  return AsyncValue.data(
    computePortfolioStats(
      active: active.value!,
      vacant: vacant.value!,
      payments: payments.value!,
      now: DateTime.now(),
    ),
  );
});
