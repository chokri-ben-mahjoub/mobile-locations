import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locations_app/l10n/app_localizations.dart';

import '../../../core/database/app_providers.dart';
import '../../../core/export/export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/shimmer.dart';

/// Vue globale : tous les locataires (contrats actifs et locaux en attente)
/// avec, pour chacun, le loyer, les compteurs STEG/SONEDE et la date du
/// dernier règlement de chaque poste — pour avoir une vision complète sans
/// ouvrir chaque contrat un par un.
class TenantsOverviewScreen extends ConsumerStatefulWidget {
  const TenantsOverviewScreen({super.key});

  @override
  ConsumerState<TenantsOverviewScreen> createState() => _TenantsOverviewScreenState();
}

class _TenantsOverviewScreenState extends ConsumerState<TenantsOverviewScreen> {
  bool _exporting = false;

  Future<void> _export() async {
    setState(() => _exporting = true);
    await runContractsExport(context, ref);
    if (mounted) setState(() => _exporting = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final activeAsync = ref.watch(contractsProvider);
    final vacantAsync = ref.watch(vacantContractsProvider);
    final paymentsAsync = ref.watch(allPaymentsProvider);
    final utilityBillsAsync = ref.watch(allUtilityBillsProvider);
    final currency = ref.watch(currencyProvider);
    final pad = MediaQuery.of(context).padding;

    final loading = activeAsync.isLoading || vacantAsync.isLoading;
    if (loading) {
      return ListView(
        padding: EdgeInsets.fromLTRB(16, pad.top + 16, 16, 16),
        children: const [
          ShimmerBox(height: 36, radius: 12),
          SizedBox(height: 18),
          ShimmerBox(height: 120, radius: 24),
          SizedBox(height: 12),
          ShimmerBox(height: 120, radius: 24),
        ],
      );
    }

    final active = activeAsync.valueOrNull ?? [];
    final vacant = vacantAsync.valueOrNull ?? [];
    final payments = paymentsAsync.valueOrNull ?? [];
    final utilityBills = utilityBillsAsync.valueOrNull ?? [];

    final paymentsByContract = <String, List<Payment>>{};
    for (final p in payments) {
      paymentsByContract.putIfAbsent(p.contractId, () => []).add(p);
    }
    final utilityByContract = <String, List<UtilityBill>>{};
    for (final b in utilityBills) {
      utilityByContract.putIfAbsent(b.contractId, () => []).add(b);
    }

    if (active.isEmpty && vacant.isEmpty) {
      return ListView(
        padding: EdgeInsets.fromLTRB(16, pad.top + 16, 16, 16),
        children: [
          EmptyState(
            icon: Icons.people_outline_rounded,
            title: l10n.tenantsEmptyTitle,
            subtitle: l10n.tenantsEmptySubtitle,
          ),
        ],
      );
    }

    return ListView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: EdgeInsets.fromLTRB(16, pad.top + 14, 16, 24 + pad.bottom),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.navTenants,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
              ),
            ),
            IconButton.filledTonal(
              tooltip: l10n.exportShareButton,
              icon: _exporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_download_outlined, size: 20),
              onPressed: _exporting ? null : _export,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          vacant.isNotEmpty
              ? l10n.tenantsCountWithVacant(active.length, vacant.length)
              : l10n.tenantsCount(active.length),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        for (final c in active) ...[
          _TenantCard(
            contract: c,
            currency: currency,
            payments: paymentsByContract[c.id] ?? const [],
            utilityBills: utilityByContract[c.id] ?? const [],
          ),
          const SizedBox(height: 12),
        ],
        if (vacant.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.tenantsVacantUnitsTitle,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          for (final c in vacant) ...[
            _TenantCard(
              contract: c,
              currency: currency,
              payments: paymentsByContract[c.id] ?? const [],
              utilityBills: utilityByContract[c.id] ?? const [],
              vacant: true,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ],
    );
  }
}

class _TenantCard extends StatelessWidget {
  const _TenantCard({
    required this.contract,
    required this.currency,
    required this.payments,
    required this.utilityBills,
    this.vacant = false,
  });

  final Contract contract;
  final String currency;
  final List<Payment> payments;
  final List<UtilityBill> utilityBills;
  final bool vacant;

  DateTime? _latest(Iterable<DateTime> dates) {
    DateTime? latest;
    for (final d in dates) {
      if (latest == null || d.isAfter(latest)) latest = d;
    }
    return latest;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final expired = !vacant && !contract.endDate.isAfter(now);
    final arabic = isArabicText(contract.tenantName);

    final lastRent = _latest(payments.map((p) => p.paidDate));
    final lastSteg = _latest(
      utilityBills.where((b) => b.type == 'steg').map((b) => b.paidDate),
    );
    final lastSonede = _latest(
      utilityBills.where((b) => b.type == 'sonede').map((b) => b.paidDate),
    );

    final (statusLabel, statusColor) = vacant
        ? (l10n.statusPending, scheme.onSurfaceVariant)
        : expired
            ? (l10n.statusExpired, scheme.error)
            : (l10n.statusActive, okColor);

    return Pressable(
      onTap: () => context.push('/contracts/${contract.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: (vacant ? scheme.onSurfaceVariant : accentColor).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    contract.unitNumber,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: vacant ? scheme.onSurfaceVariant : accentColor,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    contract.tenantName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: arabic ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: arabic ? TextAlign.right : TextAlign.left,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15.5),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(height: 1, color: scheme.outlineVariant.withValues(alpha: 0.25)),
            const SizedBox(height: 14),
            Wrap(
              spacing: 18,
              runSpacing: 12,
              children: [
                _InfoItem(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.tenantsPeriodLabel,
                  value:
                      '${FormatUtils.shortDate.format(contract.startDate)} → ${FormatUtils.shortDate.format(contract.endDate)}',
                ),
                _InfoItem(
                  icon: Icons.payments_outlined,
                  label: l10n.tenantsRentLabel(FormatUtils.currency(contract.monthlyAmount, currency)),
                  value: lastRent == null ? l10n.notPaid : l10n.paidOnDate(FormatUtils.shortDate.format(lastRent)),
                  valueColor: lastRent == null ? scheme.error : okColor,
                ),
                _InfoItem(
                  icon: Icons.bolt_rounded,
                  label: contract.stegMeter == null ? l10n.exportColSteg : '${l10n.exportColSteg} · ${contract.stegMeter}',
                  value: lastSteg == null ? l10n.notPaid : l10n.paidOnDate(FormatUtils.shortDate.format(lastSteg)),
                  valueColor: lastSteg == null ? scheme.onSurfaceVariant : okColor,
                ),
                _InfoItem(
                  icon: Icons.water_drop_outlined,
                  label: contract.sonedeMeter == null ? l10n.exportColSonede : '${l10n.exportColSonede} · ${contract.sonedeMeter}',
                  value: lastSonede == null ? l10n.notPaid : l10n.paidOnDate(FormatUtils.shortDate.format(lastSonede)),
                  valueColor: lastSonede == null ? scheme.onSurfaceVariant : okColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: valueColor ?? scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
