import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:share_plus/share_plus.dart';

import '../../../core/analytics/portfolio_stats.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/receipt.dart';
import '../../../core/widgets/animated_count.dart';
import '../../../core/widgets/aurora_card.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/reveal.dart';
import '../../../core/widgets/shimmer.dart';
import '../application/contracts_providers.dart';
import '../application/quick_pay.dart';

enum ContractUrgency { expired, dueSoon, active }

enum ContractSortOption { expiryAsc, rentDesc, rentAsc, nameAsc }

ContractUrgency contractUrgency(
  Contract c,
  int reminderLeadMonths,
  DateTime now,
) {
  if (!c.endDate.isAfter(now)) return ContractUrgency.expired;
  final reminderDate = DateTime(
    c.endDate.year,
    c.endDate.month - reminderLeadMonths,
    c.endDate.day,
  );
  if (!reminderDate.isAfter(now)) return ContractUrgency.dueSoon;
  return ContractUrgency.active;
}

class ContractsScreen extends ConsumerStatefulWidget {
  const ContractsScreen({super.key});

  @override
  ConsumerState<ContractsScreen> createState() => _ContractsScreenState();
}

class _ContractsScreenState extends ConsumerState<ContractsScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ContractUrgency? _statusFilter;
  ContractSortOption _sortBy = ContractSortOption.expiryAsc;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setFilter(ContractUrgency? f) {
    HapticFeedback.selectionClick();
    setState(() => _statusFilter = f);
  }

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(contractsProvider);
    final vacantUnits = ref.watch(vacantContractsProvider).valueOrNull ?? [];
    final reminderLeadMonths = ref.watch(reminderLeadMonthsProvider);
    final currency = ref.watch(currencyProvider);
    final stats = ref.watch(portfolioStatsProvider).valueOrNull;
    final payments = ref.watch(allPaymentsProvider).valueOrNull ?? [];
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final paidIds = {
      for (final p in payments)
        if (p.month == thisMonth) p.contractId,
    };

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 78),
        child: FloatingActionButton.extended(
          onPressed: () {
            HapticFeedback.lightImpact();
            context.push('/contracts/new');
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Contrat'),
        ),
      ),
      body: contractsAsync.when(
        loading: () => const ContractsSkeleton(),
        error: (err, stack) => Center(child: Text('Erreur : $err')),
        data: (contracts) {
          final total = contracts.length;
          final totalMonthly = contracts.fold<double>(
            0,
            (sum, c) => sum + c.monthlyAmount,
          );
          final urgencyOf = {
            for (final c in contracts)
              c.id: contractUrgency(c, reminderLeadMonths, now),
          };
          final dueSoonCount = urgencyOf.values
              .where((u) => u == ContractUrgency.dueSoon)
              .length;

          final q = _query.trim().toLowerCase();
          final searched = q.isEmpty
              ? List<Contract>.from(contracts)
              : contracts
                    .where(
                      (c) =>
                          c.tenantName.toLowerCase().contains(q) ||
                          c.unitNumber.toLowerCase().contains(q),
                    )
                    .toList();

          int countFor(ContractUrgency u) =>
              searched.where((c) => urgencyOf[c.id] == u).length;

          final filtered = _statusFilter == null
              ? searched
              : searched
                    .where((c) => urgencyOf[c.id] == _statusFilter)
                    .toList();

          filtered.sort((a, b) {
            switch (_sortBy) {
              case ContractSortOption.expiryAsc:
                return a.endDate.compareTo(b.endDate);
              case ContractSortOption.rentDesc:
                return b.monthlyAmount.compareTo(a.monthlyAmount);
              case ContractSortOption.rentAsc:
                return a.monthlyAmount.compareTo(b.monthlyAmount);
              case ContractSortOption.nameAsc:
                return a.tenantName.compareTo(b.tenantName);
            }
          });

          final filteredVacant = q.isEmpty
              ? vacantUnits
              : vacantUnits
                    .where(
                      (u) =>
                          u.tenantName.toLowerCase().contains(q) ||
                          u.unitNumber.toLowerCase().contains(q),
                    )
                    .toList();

          final unpaidCount = stats?.unpaidThisMonth.length ?? 0;
          final pad = MediaQuery.of(context).padding;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, pad.top + 14, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Header(
                        unpaidCount: unpaidCount,
                        onBell: () => _showUnpaidSheet(context),
                      ),
                      const SizedBox(height: 18),
                      Reveal(
                        child: _Hero(
                          totalMonthly: totalMonthly,
                          activeCount: total,
                          dueSoonCount: dueSoonCount,
                          stats: stats,
                          currency: currency,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Reveal(
                        delay: 80,
                        child: Row(
                          children: [
                            Expanded(
                              child: _InsightTile(
                                icon: Icons.pending_actions_rounded,
                                label: 'Impayés',
                                value: unpaidCount,
                                color: unpaidCount > 0 ? scheme.error : okColor,
                                onTap: () => _showUnpaidSheet(context),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _InsightTile(
                                icon: Icons.autorenew_rounded,
                                label: 'À renouveler',
                                value: dueSoonCount,
                                color: dueSoonCount > 0
                                    ? warnColor
                                    : scheme.onSurfaceVariant,
                                onTap: () =>
                                    _setFilter(ContractUrgency.dueSoon),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _InsightTile(
                                icon: Icons.donut_large_rounded,
                                label: 'Occupation',
                                value: ((stats?.occupancy ?? 0) * 100).round(),
                                suffix: '%',
                                color: scheme.primary,
                                onTap: () => context.go('/analytics'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _searchController,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un locataire ou un local…',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _query.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _query = '');
                                  },
                                ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: scheme.primary.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (v) => setState(() => _query = v),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterPill(
                                    label: 'Tous',
                                    count: searched.length,
                                    selected: _statusFilter == null,
                                    onTap: () => _setFilter(null),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterPill(
                                    label: 'Actifs',
                                    count: countFor(ContractUrgency.active),
                                    selected:
                                        _statusFilter == ContractUrgency.active,
                                    onTap: () =>
                                        _setFilter(ContractUrgency.active),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterPill(
                                    label: 'Expire bientôt',
                                    count: countFor(ContractUrgency.dueSoon),
                                    selected:
                                        _statusFilter ==
                                        ContractUrgency.dueSoon,
                                    onTap: () =>
                                        _setFilter(ContractUrgency.dueSoon),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterPill(
                                    label: 'Expirés',
                                    count: countFor(ContractUrgency.expired),
                                    selected:
                                        _statusFilter ==
                                        ContractUrgency.expired,
                                    onTap: () =>
                                        _setFilter(ContractUrgency.expired),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton<ContractSortOption>(
                            tooltip: 'Trier',
                            initialValue: _sortBy,
                            onSelected: (v) => setState(() => _sortBy = v),
                            icon: Icon(
                              Icons.swap_vert_rounded,
                              color: scheme.onSurfaceVariant,
                            ),
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: ContractSortOption.expiryAsc,
                                child: Text('Date d\'expiration'),
                              ),
                              PopupMenuItem(
                                value: ContractSortOption.rentDesc,
                                child: Text('Loyer (décroissant)'),
                              ),
                              PopupMenuItem(
                                value: ContractSortOption.rentAsc,
                                child: Text('Loyer (croissant)'),
                              ),
                              PopupMenuItem(
                                value: ContractSortOption.nameAsc,
                                child: Text('Nom (A→Z)'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),
              if (filtered.isEmpty && filteredVacant.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyState(
                    icon: q.isEmpty
                        ? Icons.inbox_outlined
                        : Icons.search_off_rounded,
                    title: q.isEmpty ? 'Aucun contrat' : 'Aucun résultat',
                    subtitle: q.isEmpty
                        ? 'Ajoutez votre premier contrat avec le bouton +.'
                        : 'Aucun contrat ni local en attente ne correspond à « $q ».',
                  ),
                )
              else if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: Text(
                      'Aucun contrat ne correspond à ces critères.',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final contract = filtered[index];
                      return Reveal(
                        key: ValueKey(contract.id),
                        delay: (index < 8 ? index : 8) * 45,
                        child: _ContractCard(
                          contract: contract,
                          currency: currency,
                          urgency: urgencyOf[contract.id]!,
                          paidThisMonth: paidIds.contains(contract.id),
                          now: now,
                          onTap: () =>
                              context.push('/contracts/${contract.id}'),
                        ),
                      );
                    },
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 150 + pad.bottom),
                sliver: SliverToBoxAdapter(
                  child: filteredVacant.isEmpty
                      ? const SizedBox.shrink()
                      : _VacantUnitsSection(units: filteredVacant),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUnpaidSheet(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _UnpaidSheet(),
    );
  }
}

class _Header extends StatelessWidget {
  final int unpaidCount;
  final VoidCallback onBell;

  const _Header({required this.unpaidCount, required this.onBell});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final today = toBeginningOfSentenceCase(
      DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now()),
    );

    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary,
                Color.lerp(scheme.primary, Colors.black, 0.35)!,
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.apartment_rounded,
            color: scheme.onPrimary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'LocaTrack',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
              ),
              Text(
                today,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
        Pressable(
          onTap: onBell,
          child: Badge(
            isLabelVisible: unpaidCount > 0,
            label: Text('$unpaidCount'),
            backgroundColor: scheme.error,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.35),
                ),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final double totalMonthly;
  final int activeCount;
  final int dueSoonCount;
  final PortfolioStats? stats;
  final String currency;

  const _Hero({
    required this.totalMonthly,
    required this.activeCount,
    required this.dueSoonCount,
    required this.stats,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final month = stats?.current;
    final collected = month?.collected ?? 0;
    final expected = month?.expected ?? totalMonthly;
    final rate = month?.rate ?? 0;
    final monthLabel = toBeginningOfSentenceCase(
      FormatUtils.monthYear.format(DateTime.now()),
    );

    return AuroraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Loyer mensuel total',
                  style: text.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ),
              _GlassPill(icon: Icons.calendar_month_rounded, label: monthLabel),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedAmount(
              value: totalMonthly,
              currency: currency,
              style: text.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ProgressRing(
                progress: rate,
                size: 78,
                stroke: 9,
                color: Colors.white,
                trackColor: Colors.white.withValues(alpha: 0.2),
                center: AnimatedInt(
                  value: (rate * 100).round(),
                  suffix: '%',
                  style: text.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Encaissé ce mois',
                      style: text.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: AnimatedAmount(
                        value: collected,
                        currency: currency,
                        style: text.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'sur ${FormatUtils.currency(expected, currency)} attendus',
                      style: text.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _GlassPill(
                icon: Icons.description_rounded,
                label:
                    '$activeCount contrat${activeCount > 1 ? 's' : ''} actif${activeCount > 1 ? 's' : ''}',
              ),
              if (dueSoonCount > 0)
                _GlassPill(
                  icon: Icons.notifications_active_rounded,
                  label: '$dueSoonCount à renouveler',
                  tint: goldColor,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? tint;

  const _GlassPill({required this.icon, required this.label, this.tint});

  @override
  Widget build(BuildContext context) {
    final fg = tint ?? Colors.white;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: (tint ?? Colors.white).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: (tint ?? Colors.white).withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final String suffix;
  final Color color;
  final VoidCallback onTap;

  const _InsightTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 12),
            AnimatedInt(
              value: value,
              suffix: suffix,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      pressedScale: 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: (selected ? scheme.onPrimary : scheme.onSurfaceVariant)
                    .withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContractCard extends ConsumerWidget {
  final Contract contract;
  final String currency;
  final ContractUrgency urgency;
  final bool paidThisMonth;
  final DateTime now;
  final VoidCallback onTap;

  const _ContractCard({
    required this.contract,
    required this.currency,
    required this.urgency,
    required this.paidThisMonth,
    required this.now,
    required this.onTap,
  });

  (Color, String) get _badge {
    switch (urgency) {
      case ContractUrgency.expired:
        return (Colors.grey, 'Expiré');
      case ContractUrgency.dueSoon:
        return (warnColor, 'Expire bientôt');
      case ContractUrgency.active:
        return (okColor, 'Actif');
    }
  }

  double get _lifetime {
    final total = contract.endDate.difference(contract.startDate).inHours;
    if (total <= 0) return 1;
    return (now.difference(contract.startDate).inHours / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final (badgeColor, badgeLabel) = _badge;

    final card = Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            scheme.primary.withValues(alpha: 0.2),
                            scheme.primary.withValues(alpha: 0.07),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        contract.unitNumber,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -5,
                      top: -5,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (c, a) =>
                            ScaleTransition(scale: a, child: c),
                        child: Container(
                          key: ValueKey(paidThisMonth),
                          width: 19,
                          height: 19,
                          decoration: BoxDecoration(
                            color: paidThisMonth ? okColor : scheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: scheme.surfaceContainerLow,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            paidThisMonth
                                ? Icons.check_rounded
                                : Icons.priority_high_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                        textDirection: isArabicText(contract.tenantName)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        textAlign: isArabicText(contract.tenantName)
                            ? TextAlign.right
                            : TextAlign.left,
                        style: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: FormatUtils.currency(
                                contract.monthlyAmount,
                                currency,
                              ),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            TextSpan(
                              text:
                                  '  ·  fin ${DateFormat('dd/MM/yy').format(contract.endDate)}',
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: badgeColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ThinProgress(
              value: _lifetime,
              color: badgeColor,
              track: scheme.surfaceContainerHigh,
              height: 4,
            ),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: ValueKey('pay-${contract.id}'),
        direction: paidThisMonth
            ? DismissDirection.none
            : DismissDirection.startToEnd,
        dismissThresholds: const {DismissDirection.startToEnd: 0.32},
        onUpdate: (d) {
          if (d.reached && !d.previousReached) HapticFeedback.mediumImpact();
        },
        confirmDismiss: (_) async {
          await quickPayCurrentMonth(context, ref, contract);
          return false;
        },
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [okColor, okColor.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.payments_rounded, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Encaisser le mois',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        child: card,
      ),
    );
  }
}

class _UnpaidSheet extends ConsumerWidget {
  const _UnpaidSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final stats = ref.watch(portfolioStatsProvider).valueOrNull;
    final currency = ref.watch(currencyProvider);
    final unpaid = stats?.unpaidThisMonth ?? const <Contract>[];
    final monthLabel = toBeginningOfSentenceCase(
      FormatUtils.monthYear.format(DateTime.now()),
    );

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loyers à encaisser',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                        ),
                        Text(
                          monthLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  if (stats != null)
                    IconButton.filledTonal(
                      tooltip: 'Partager le rapport',
                      icon: const Icon(Icons.ios_share_rounded, size: 20),
                      onPressed: () => Share.share(
                        buildMonthReportText(
                          month: DateTime.now(),
                          expected: stats.current.expected,
                          collected: stats.current.collected,
                          unpaid: unpaid,
                          currency: currency,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              if (unpaid.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: okColor.withValues(alpha: 0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 36,
                            color: okColor,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Tous les loyers sont encaissés',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: unpaid.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final c = unpaid[i];
                      return Container(
                        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: scheme.error.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                c.unitNumber,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.error,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.tenantName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textDirection: isArabicText(c.tenantName)
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    textAlign: isArabicText(c.tenantName)
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    FormatUtils.currency(
                                      c.monthlyAmount,
                                      currency,
                                    ),
                                    style: TextStyle(
                                      color: scheme.onSurfaceVariant,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: () =>
                                  quickPayCurrentMonth(context, ref, c),
                              child: const Text('Encaisser'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VacantUnitsSection extends ConsumerWidget {
  final List<Contract> units;

  const _VacantUnitsSection({required this.units});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              size: 18,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Locaux en attente (${units.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        for (final unit in units)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => context.push('/contracts/${unit.id}'),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: scheme.onSurfaceVariant.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Text(
                              unit.unitNumber,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'En attente',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Dernier locataire : ${unit.tenantName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Réactiver ce contrat',
                            icon: Icon(
                              Icons.restart_alt_rounded,
                              color: scheme.onSurfaceVariant,
                            ),
                            onPressed: () =>
                                _confirmReactivate(context, ref, unit),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: FilledButton.tonalIcon(
                          onPressed: () => context.push(
                            '/contracts/new'
                            '?unit=${Uri.encodeComponent(unit.unitNumber)}'
                            '&replace=${unit.id}',
                          ),
                          icon: const Icon(
                            Icons.person_add_alt_1_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'Nouveau locataire',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirmReactivate(
    BuildContext context,
    WidgetRef ref,
    Contract unit,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réactiver ce contrat ?'),
        content: Text(
          'Le local ${unit.unitNumber} redeviendra actif avec '
          '${unit.tenantName} comme locataire, comme avant sa mise en attente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Réactiver'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(contractsControllerProvider).reactivate(unit.id);
    }
  }
}
