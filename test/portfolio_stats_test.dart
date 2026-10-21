import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:locations_app/core/analytics/portfolio_stats.dart';
import 'package:locations_app/core/database/app_providers.dart';
import 'package:locations_app/features/analytics/presentation/analytics_screen.dart';

Contract _contract(
  String id,
  String unit,
  DateTime start,
  DateTime end, {
  double amount = 400,
  bool archived = false,
}) {
  return Contract(
    id: id,
    tenantName: 'Locataire $id',
    unitNumber: unit,
    startDate: start,
    endDate: end,
    monthlyAmount: amount,
    notes: '',
    createdAt: start,
    archived: archived,
  );
}

Payment _payment(String contractId, DateTime month, double amount) {
  return Payment(
    id: '$contractId-${month.year}-${month.month}',
    contractId: contractId,
    month: month,
    amount: amount,
    paidDate: month,
    notes: '',
    createdAt: month,
  );
}

void main() {
  final now = DateTime(2026, 10, 13);

  test('stats: encaissé, impayés, occupation', () {
    final a = _contract('a', 'A1', DateTime(2026, 1, 1), DateTime(2027, 1, 1));
    final b = _contract(
      'b',
      'A2',
      DateTime(2026, 6, 1),
      DateTime(2027, 6, 1),
      amount: 300,
    );
    final old = _contract(
      'o',
      'A3',
      DateTime(2025, 1, 1),
      DateTime(2025, 12, 1),
      archived: true,
    );

    final stats = computePortfolioStats(
      active: [a, b],
      vacant: [old],
      payments: [
        _payment('a', DateTime(2026, 10, 1), 400),
        _payment('a', DateTime(2026, 9, 1), 400),
      ],
      now: now,
    );

    expect(stats.months.length, 12);
    expect(stats.current.collected, 400);
    expect(stats.current.expected, 700);
    expect(stats.unpaidThisMonth.map((c) => c.id), ['b']);
    expect(stats.vacantUnits, 1);
    expect(stats.occupiedUnits, 2);
    expect(stats.occupancy, closeTo(2 / 3, 1e-9));
    expect(stats.yearCollected, 800);
  });

  testWidgets('Analyses : toute la liste défile sans erreur de mise en page', (
    tester,
  ) async {
    await initializeDateFormatting('fr_FR', null);
    tester.view.physicalSize = const Size(1080, 2220);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    final today = DateTime.now();
    final contracts = [
      for (var i = 0; i < 6; i++)
        _contract(
          'c$i',
          'U$i',
          DateTime(today.year, 1, 1),
          today.add(Duration(days: 20 + i * 25)),
        ),
    ];
    final stats = computePortfolioStats(
      active: contracts,
      vacant: const [],
      payments: [_payment('c0', DateTime(today.year, today.month, 1), 400)],
      now: today,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          portfolioStatsProvider.overrideWithValue(AsyncValue.data(stats)),
          currencyProvider.overrideWithValue('TND'),
        ],
        child: const MaterialApp(home: AnalyticsScreen()),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Échéances à venir'), findsOneWidget);
    expect(find.text('Locataire c5'), findsOneWidget);
  });
}
