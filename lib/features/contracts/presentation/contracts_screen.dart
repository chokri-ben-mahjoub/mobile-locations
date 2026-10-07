import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/stat_card.dart';

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
    final reminderLeadMonths = ref.watch(reminderLeadMonthsProvider);
    final currency = ref.watch(currencyProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('LocaTrack')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/contracts/new'),
        child: const Icon(Icons.add),
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
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
                for (final contract in filtered)
                  _ContractCard(
                    contract: contract,
                    currency: currency,
                    urgency: contractUrgency(contract, reminderLeadMonths, now),
                    onTap: () => context.push('/contracts/${contract.id}'),
                  ),
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
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
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
                      const SizedBox(height: 2),
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
                Chip(
                  label: Text(badgeLabel, style: const TextStyle(fontSize: 11)),
                  visualDensity: VisualDensity.compact,
                  backgroundColor: badgeColor.withValues(alpha: 0.14),
                  labelStyle: TextStyle(color: badgeColor),
                  side: BorderSide.none,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
