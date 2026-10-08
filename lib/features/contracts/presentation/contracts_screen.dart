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
          final filtered = q.isEmpty
              ? contracts
              : contracts
                  .where((c) =>
                      c.tenantName.toLowerCase().contains(q) ||
                      c.unitNumber.toLowerCase().contains(q))
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
              const SizedBox(height: 16),
              if (filtered.isEmpty)
                const EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'Aucun contrat',
                  subtitle: 'Ajoutez votre premier contrat avec le bouton +.',
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
              if (vacantUnits.isNotEmpty) ...[
                const SizedBox(height: 24),
                _VacantUnitsSection(units: vacantUnits),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _ContractCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (badgeColor, badgeLabel) = _badge;

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
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.3),
                style: BorderStyle.solid,
              ),
            ),
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
                      onPressed: () =>
                          ref.read(contractsControllerProvider).reactivate(unit.id),
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
      ],
    );
  }
}
