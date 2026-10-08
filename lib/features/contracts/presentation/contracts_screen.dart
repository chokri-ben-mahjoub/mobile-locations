import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/stat_card.dart';
import '../application/contracts_providers.dart';

enum ContractUrgency { expired, dueSoon, active }

enum ContractSortOption { expiryAsc, rentDesc, rentAsc, nameAsc }

ContractUrgency contractUrgency(Contract c, int reminderLeadMonths, DateTime now) {
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

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(contractsProvider);
    final vacantUnits = ref.watch(vacantContractsProvider).valueOrNull ?? [];
    final reminderLeadMonths = ref.watch(reminderLeadMonthsProvider);
    final currency = ref.watch(currencyProvider);
    final now = DateTime.now();

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/contracts/new'),
        icon: const Icon(Icons.add),
        label: const Text('Contrat'),
      ),
      body: contractsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur : $err')),
        data: (contracts) {
          final total = contracts.length;
          final totalMonthly = contracts.fold<double>(0, (sum, c) => sum + c.monthlyAmount);
          final dueSoonCount = contracts
              .where((c) => contractUrgency(c, reminderLeadMonths, now) == ContractUrgency.dueSoon)
              .length;

          final q = _query.trim().toLowerCase();
          var filtered = q.isEmpty
              ? List<Contract>.from(contracts)
              : contracts
                  .where((c) =>
                      c.tenantName.toLowerCase().contains(q) ||
                      c.unitNumber.toLowerCase().contains(q))
                  .toList();

          if (_statusFilter != null) {
            filtered = filtered
                .where((c) => contractUrgency(c, reminderLeadMonths, now) == _statusFilter)
                .toList();
          }

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
                  .where((u) =>
                      u.tenantName.toLowerCase().contains(q) ||
                      u.unitNumber.toLowerCase().contains(q))
                  .toList();

          return ListView(
            padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 100),
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.apartment_rounded, color: scheme.onPrimary, size: 19),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'LocaTrack',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: Icon(Icons.tune_rounded, color: scheme.onSurfaceVariant),
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.surfaceContainerLow,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.primary, Color.lerp(scheme.primary, Colors.black, 0.25)!],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: scheme.primary.withValues(alpha: 0.3),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Loyer mensuel total',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onPrimary.withValues(alpha: 0.85),
                                ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: scheme.onPrimary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.payments_rounded, color: scheme.onPrimary, size: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        FormatUtils.currency(totalMonthly, currency),
                        maxLines: 1,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: scheme.onPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(height: 1, color: scheme.onPrimary.withValues(alpha: 0.15)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(Icons.description_rounded,
                            color: scheme.onPrimary.withValues(alpha: 0.8), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '$total contrat${total > 1 ? 's' : ''} actif${total > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onPrimary.withValues(alpha: 0.85),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        if (dueSoonCount > 0) ...[
                          const SizedBox(width: 14),
                          Icon(Icons.notifications_active_rounded,
                              color: Colors.amber.shade200, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            '$dueSoonCount à renouveler',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.amber.shade100,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
                children: [
                  StatCard(
                    label: 'Contrats',
                    value: '$total',
                    icon: Icons.description_outlined,
                    color: Colors.indigo,
                  ),
                  StatCard(
                    label: 'Loyer mensuel',
                    value: FormatUtils.currency(totalMonthly, currency),
                    icon: Icons.payments_outlined,
                    color: Colors.teal,
                  ),
                  StatCard(
                    label: 'Expirent bientôt',
                    value: '$dueSoonCount',
                    icon: Icons.notifications_active_outlined,
                    color: dueSoonCount > 0 ? Colors.redAccent : Colors.grey,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un locataire ou un local…',
                  prefixIcon: Icon(Icons.search),
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
                          ChoiceChip(
                            label: const Text('Tous'),
                            selected: _statusFilter == null,
                            onSelected: (_) => setState(() => _statusFilter = null),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Actifs'),
                            selected: _statusFilter == ContractUrgency.active,
                            onSelected: (_) =>
                                setState(() => _statusFilter = ContractUrgency.active),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Expire bientôt'),
                            selected: _statusFilter == ContractUrgency.dueSoon,
                            onSelected: (_) =>
                                setState(() => _statusFilter = ContractUrgency.dueSoon),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Expiré'),
                            selected: _statusFilter == ContractUrgency.expired,
                            onSelected: (_) =>
                                setState(() => _statusFilter = ContractUrgency.expired),
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
                    icon: Icon(Icons.sort_rounded, color: scheme.onSurfaceVariant),
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
              const SizedBox(height: 16),
              if (filtered.isEmpty && filteredVacant.isEmpty)
                EmptyState(
                  icon: Icons.inbox_outlined,
                  title: q.isEmpty ? 'Aucun contrat' : 'Aucun résultat',
                  subtitle: q.isEmpty
                      ? 'Ajoutez votre premier contrat avec le bouton +.'
                      : 'Aucun contrat ni local en attente ne correspond à « $q ».',
                )
              else if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Aucun contrat actif ne correspond à cette recherche.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                for (final (index, contract) in filtered.indexed)
                  TweenAnimationBuilder<double>(
                    key: ValueKey(contract.id),
                    tween: Tween(begin: 0, end: 1),
                    duration: Duration(milliseconds: 280 + index * 40),
                    curve: Curves.easeOutCubic,
                    builder: (context, t, child) => Opacity(
                      opacity: t,
                      child: Transform.translate(
                        offset: Offset(0, (1 - t) * 14),
                        child: child,
                      ),
                    ),
                    child: _ContractCard(
                      contract: contract,
                      currency: currency,
                      urgency: contractUrgency(contract, reminderLeadMonths, now),
                      onTap: () => context.push('/contracts/${contract.id}'),
                    ),
                  ),
              if (filteredVacant.isNotEmpty) ...[
                const SizedBox(height: 24),
                _VacantUnitsSection(units: filteredVacant),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ContractCard extends ConsumerWidget {
  final Contract contract;
  final String currency;
  final ContractUrgency urgency;
  final VoidCallback onTap;

  const _ContractCard({
    required this.contract,
    required this.currency,
    required this.urgency,
    required this.onTap,
  });

  (Color, String) get _badge {
    switch (urgency) {
      case ContractUrgency.expired:
        return (Colors.grey, 'Expiré');
      case ContractUrgency.dueSoon:
        return (Colors.redAccent, 'Expire bientôt');
      case ContractUrgency.active:
        return (Colors.green, 'Actif');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final (badgeColor, badgeLabel) = _badge;

    final now = DateTime.now();
    final currentMonthKey = DateTime(now.year, now.month, 1);
    final payments = ref.watch(paymentsForContractProvider(contract.id)).valueOrNull ?? [];
    final paidThisMonth = payments.any((p) => p.month == currentMonthKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: scheme.shadow.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            scheme.primary.withValues(alpha: 0.18),
                            scheme.primary.withValues(alpha: 0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        contract.unitNumber,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Tooltip(
                        message: paidThisMonth
                            ? 'Loyer de ce mois payé'
                            : 'Loyer de ce mois impayé',
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: paidThisMonth ? Colors.green : scheme.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: scheme.surfaceContainerLow, width: 2),
                          ),
                          child: Icon(
                            paidThisMonth ? Icons.check_rounded : Icons.priority_high_rounded,
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
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Jusqu\'au ${FormatUtils.shortDate.format(contract.endDate)} · '
                        '${FormatUtils.currency(contract.monthlyAmount, currency)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                        decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: badgeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
            Icon(Icons.hourglass_empty_rounded, size: 18, color: scheme.onSurfaceVariant),
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
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
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
                              color: scheme.onSurfaceVariant.withValues(alpha: 0.1),
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
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                                Text(
                                  'Dernier locataire : ${unit.tenantName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Réactiver ce contrat',
                            icon: Icon(Icons.restart_alt_rounded, color: scheme.onSurfaceVariant),
                            onPressed: () => _confirmReactivate(context, ref, unit),
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
                          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
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

  Future<void> _confirmReactivate(BuildContext context, WidgetRef ref, Contract unit) async {
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
