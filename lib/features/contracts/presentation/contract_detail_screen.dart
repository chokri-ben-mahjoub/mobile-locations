import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/utils/format_utils.dart';
import '../application/contracts_providers.dart';

class ContractDetailScreen extends ConsumerWidget {
  final String contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(contractsProvider).valueOrNull ?? [];
    final currency = ref.watch(currencyProvider);
    Contract? contract;
    for (final c in contracts) {
      if (c.id == contractId) contract = c;
    }

    if (contract == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Contrat introuvable.')),
      );
    }

    final c = contract;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.tenantName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => context.push('/contracts/${c.id}/edit'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, c.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoTile(label: 'Local', value: c.unitNumber),
          _InfoTile(
            label: 'Loyer mensuel',
            value: FormatUtils.currency(c.monthlyAmount, currency),
          ),
          _InfoTile(
            label: 'Début du contrat',
            value: FormatUtils.shortDate.format(c.startDate),
          ),
          _InfoTile(
            label: 'Fin du contrat',
            value: FormatUtils.shortDate.format(c.endDate),
          ),
          _InfoTile(
            label: 'Durée',
            value: FormatUtils.durationLabel(c.startDate, c.endDate),
          ),
          _InfoTile(label: 'Compteur STEG', value: c.stegMeter ?? '—'),
          _InfoTile(label: 'Compteur SONEDE', value: c.sonedeMeter ?? '—'),
          if (c.notes.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Notes', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(c.notes, style: TextStyle(color: scheme.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ce contrat ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(contractsControllerProvider).delete(id);
      if (context.mounted) context.pop();
    }
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
