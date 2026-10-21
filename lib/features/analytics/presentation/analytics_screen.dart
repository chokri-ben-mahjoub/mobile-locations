import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/analytics/portfolio_stats.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/export/export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/receipt.dart';
import '../../../core/widgets/animated_count.dart';
import '../../../core/widgets/aurora_card.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/shimmer.dart';

String _cap(String s) => toBeginningOfSentenceCase(s);

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  int? _selected;
  bool _exporting = false;

  Future<void> _exportContracts() async {
    setState(() => _exporting = true);
    await runContractsExport(context, ref);
    if (mounted) setState(() => _exporting = false);
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(portfolioStatsProvider);
    final currency = ref.watch(currencyProvider);
    final scheme = Theme.of(context).colorScheme;
    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      body: statsAsync.when(
        loading: () => ListView(
          padding: EdgeInsets.fromLTRB(16, pad.top + 16, 16, 16),
          children: const [
            ShimmerBox(height: 36, radius: 12),
            SizedBox(height: 18),
            ShimmerBox(height: 150, radius: 30),
            SizedBox(height: 16),
            ShimmerBox(height: 260, radius: 26),
          ],
        ),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (stats) {
          final now = DateTime.now();
          final sel = _selected ?? stats.months.length - 1;
          final m = stats.months[sel];
          final expected12 = stats.months.fold<double>(
            0,
            (s, e) => s + e.expected,
          );
          final collected12 = stats.months.fold<double>(
            0,
            (s, e) => s + e.collected,
          );
          final rate12 = expected12 <= 0
              ? 0.0
              : (collected12 / expected12).clamp(0.0, 1.0);
          final upcoming = stats.expiringWithin(180, now);

          return ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(
              16,
              pad.top + 14,
              16,
              150 + pad.bottom,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Analyses',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                          ),
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Exporter les contrats',
                    icon: _exporting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.file_download_outlined, size: 20),
                    onPressed: _exporting ? null : _exportContracts,
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Partager le rapport du mois',
                    icon: const Icon(Icons.ios_share_rounded, size: 20),
                    onPressed: () => Share.share(
                      buildMonthReportText(
                        month: stats.current.month,
                        expected: stats.current.expected,
                        collected: stats.current.collected,
                        unpaid: stats.unpaidThisMonth,
                        currency: currency,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AuroraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encaissé en ${now.year}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AnimatedAmount(
                        value: stats.yearCollected,
                        currency: currency,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ThinProgress(
                      value: rate12,
                      color: Colors.white,
                      track: Colors.white.withValues(alpha: 0.2),
                      height: 6,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Taux d\'encaissement sur 12 mois : ${(rate12 * 100).round()} %',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '12 derniers mois',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        _Legend(color: scheme.primary, label: 'Encaissé'),
                        const SizedBox(width: 12),
                        _Legend(
                          color: scheme.surfaceContainerHighest,
                          label: 'Attendu',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    MonthlyBarChart(
                      data: [
                        for (final s in stats.months)
                          BarDatum(
                            _cap(DateFormat('MMM', 'fr_FR').format(s.month))
                                .replaceAll('.', ''),
                            s.expected,
                            s.collected,
                          ),
                      ],
                      color: scheme.primary,
                      trackColor: scheme.surfaceContainerHighest,
                      labelColor: scheme.onSurfaceVariant,
                      selected: sel,
                      onSelect: (i) => setState(() => _selected = i),
                    ),
                    const SizedBox(height: 14),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Container(
                        key: ValueKey(sel),
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _cap(FormatUtils.monthYear.format(m.month)),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${FormatUtils.currency(m.collected, currency)} '
                                    'sur ${FormatUtils.currency(m.expected, currency)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${(m.rate * 100).round()}%',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: m.rate >= 0.999
                                    ? okColor
                                    : m.rate >= 0.5
                                    ? scheme.primary
                                    : warnColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _RingPanel(
                        title: 'Occupation',
                        progress: stats.occupancy,
                        color: scheme.primary,
                        detail:
                            '${stats.occupiedUnits}/${stats.totalUnits} locaux occupés',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RingPanel(
                        title: 'Ce mois-ci',
                        progress: stats.current.rate,
                        color: stats.current.rate >= 0.999
                            ? okColor
                            : goldColor,
                        detail: stats.unpaidThisMonth.isEmpty
                            ? 'Tout est encaissé'
                            : '${stats.unpaidThisMonth.length} impayé${stats.unpaidThisMonth.length > 1 ? 's' : ''}',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Échéances à venir',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 2),
              Text(
                'Contrats arrivant à terme dans les 6 prochains mois',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                _Panel(
                  child: Row(
                    children: [
                      const Icon(Icons.event_available_rounded, color: okColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Aucune échéance dans les 6 prochains mois.',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ],
                  ),
                )
              else
                for (final c in upcoming)
                  _ExpiryRow(contract: c, now: now, currency: currency),
            ],
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final Widget child;
  const _Panel({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: child,
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _RingPanel extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;
  final String detail;

  const _RingPanel({
    required this.title,
    required this.progress,
    required this.color,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Panel(
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          ProgressRing(
            progress: progress,
            size: 96,
            stroke: 11,
            color: color,
            trackColor: scheme.surfaceContainerHighest,
            center: AnimatedInt(
              value: (progress * 100).round(),
              suffix: '%',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _ExpiryRow extends StatelessWidget {
  final Contract contract;
  final DateTime now;
  final String currency;

  const _ExpiryRow({
    required this.contract,
    required this.now,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final days = contract.endDate.difference(now).inDays;
    final expired = !contract.endDate.isAfter(now);
    final color = expired
        ? scheme.error
        : days <= 30
        ? warnColor
        : scheme.primary;
    final label = expired ? 'Expiré' : 'J-$days';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Pressable(
        onTap: () => context.push('/contracts/${contract.id}'),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('d').format(contract.endDate),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: color,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat(
                        'MMM',
                        'fr_FR',
                      ).format(contract.endDate).replaceAll('.', ''),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contract.tenantName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${contract.unitNumber} · ${FormatUtils.currency(contract.monthlyAmount, currency)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
