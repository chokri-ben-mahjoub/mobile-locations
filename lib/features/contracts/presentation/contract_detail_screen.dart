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
    final vacant = ref.watch(vacantContractsProvider).valueOrNull ?? [];
    final currency = ref.watch(currencyProvider);
    Contract? contract;
    for (final c in [...contracts, ...vacant]) {
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
          if (c.archived)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_empty_rounded, color: scheme.onSurfaceVariant),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Local en attente — ancien locataire sorti.',
                      style: TextStyle(
                        color: scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await ref.read(contractsControllerProvider).reactivate(c.id);
                    },
                    child: const Text('Réactiver'),
                  ),
                ],
              ),
            ),
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
          const SizedBox(height: 20),
          _PaymentsSection(contract: c, currency: currency),
          if (!c.archived) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _confirmMarkVacant(context, ref, c),
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Locataire sorti — mettre le local en attente',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _confirmMarkVacant(BuildContext context, WidgetRef ref, Contract c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Marquer ce local en attente ?'),
        content: const Text(
          'Le contrat sera clôturé et le local n\'apparaîtra plus parmi les '
          'contrats actifs jusqu\'à l\'arrivée d\'un nouveau locataire.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(contractsControllerProvider).markVacant(c.id);
    if (!context.mounted) return;

    final addNow = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nouveau locataire ?'),
        content: Text(
          'Le local ${c.unitNumber} est maintenant en attente. '
          'Voulez-vous ajouter son nouveau locataire tout de suite ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Plus tard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ajouter maintenant'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;

    if (addNow == true) {
      context.pushReplacement(
        '/contracts/new'
        '?unit=${Uri.encodeComponent(c.unitNumber)}'
        '&replace=${c.id}',
      );
    } else {
      context.pop();
    }
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

class _PaymentsSection extends ConsumerStatefulWidget {
  final Contract contract;
  final String currency;

  const _PaymentsSection({required this.contract, required this.currency});

  @override
  ConsumerState<_PaymentsSection> createState() => _PaymentsSectionState();
}

class _PaymentsSectionState extends ConsumerState<_PaymentsSection> {
  bool _expanded = false;

  List<DateTime> _months() {
    final c = widget.contract;
    final now = DateTime.now();
    // Un contrat actif reste suivi jusqu'au mois en cours même si sa date
    // de fin contractuelle est dépassée (locataire pas encore renouvelé/sorti).
    final last = c.archived && c.endDate.isBefore(now) ? c.endDate : now;
    var cursor = DateTime(last.year, last.month, 1);
    final start = DateTime(c.startDate.year, c.startDate.month, 1);
    final months = <DateTime>[];
    while (!cursor.isBefore(start)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month - 1, 1);
    }
    return months;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final payments = ref.watch(paymentsForContractProvider(widget.contract.id)).valueOrNull ?? [];
    final byMonth = {for (final p in payments) p.month: p};

    final months = _months();
    final visibleMonths = _expanded ? months : months.take(6).toList();
    final paidCount = months.where((m) => byMonth[m] != null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Historique des paiements', style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            Text(
              '$paidCount/${months.length} payés',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Touchez un mois pour basculer payé/impayé. Appui long pour corriger le montant.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final month in visibleMonths)
              _MonthChip(
                month: month,
                paid: byMonth[month] != null,
                onTap: () => _toggleMonth(month, byMonth[month]),
                onLongPress: () => _editMonth(context, month, byMonth[month]),
              ),
          ],
        ),
        if (months.length > 6)
          TextButton(
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(_expanded ? 'Réduire' : 'Afficher tous les mois (${months.length})'),
          ),
      ],
    );
  }

  /// Un seul tap : bascule rapidement payé (montant du loyer, aujourd'hui)
  /// ou impayé, sans passer par un formulaire.
  Future<void> _toggleMonth(DateTime month, Payment? existing) async {
    final controller = ref.read(paymentsControllerProvider);
    if (existing != null) {
      await controller.markUnpaid(widget.contract.id, month);
    } else {
      await controller.markPaid(
        contractId: widget.contract.id,
        month: month,
        amount: widget.contract.monthlyAmount,
        paidDate: DateTime.now(),
      );
    }
  }

  Future<void> _editMonth(BuildContext context, DateTime month, Payment? existing) async {
    final result = await showModalBottomSheet<_PaymentAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => _PaymentActionSheet(
        month: month,
        existing: existing,
        defaultAmount: widget.contract.monthlyAmount,
      ),
    );
    if (result == null) return;
    final controller = ref.read(paymentsControllerProvider);
    if (result.markPaid) {
      await controller.markPaid(
        contractId: widget.contract.id,
        month: month,
        amount: result.amount!,
        paidDate: result.paidDate!,
      );
    } else {
      await controller.markUnpaid(widget.contract.id, month);
    }
  }
}

class _MonthChip extends StatelessWidget {
  final DateTime month;
  final bool paid;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _MonthChip({
    required this.month,
    required this.paid,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = FormatUtils.dayMonth.format(month).replaceFirst(RegExp(r'^\d+ '), '');
    final isCurrentMonth =
        DateTime.now().year == month.year && DateTime.now().month == month.month;

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: paid
              ? Colors.green.withValues(alpha: 0.15)
              : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isCurrentMonth
                ? scheme.primary.withValues(alpha: 0.6)
                : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Icon(
              paid ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: paid ? Colors.green.shade700 : scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              '${label[0].toUpperCase()}${label.substring(1)} ${month.year.toString().substring(2)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: paid ? Colors.green.shade700 : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentAction {
  final bool markPaid;
  final double? amount;
  final DateTime? paidDate;

  _PaymentAction.paid(this.amount, this.paidDate) : markPaid = true;
  _PaymentAction.unpaid()
      : markPaid = false,
        amount = null,
        paidDate = null;
}

class _PaymentActionSheet extends StatefulWidget {
  final DateTime month;
  final Payment? existing;
  final double defaultAmount;

  const _PaymentActionSheet({
    required this.month,
    required this.existing,
    required this.defaultAmount,
  });

  @override
  State<_PaymentActionSheet> createState() => _PaymentActionSheetState();
}

class _PaymentActionSheetState extends State<_PaymentActionSheet> {
  late final _amountController = TextEditingController(
    text: (widget.existing?.amount ?? widget.defaultAmount).toStringAsFixed(0),
  );
  late DateTime _paidDate = widget.existing?.paidDate ?? DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = FormatUtils.monthYear.format(widget.month);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 4, 20, MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label[0].toUpperCase() + label.substring(1),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Montant payé'),
          ),
          const SizedBox(height: 14),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _paidDate,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) setState(() => _paidDate = picked);
            },
            child: InputDecorator(
              decoration: const InputDecoration(labelText: 'Date de paiement'),
              child: Text(FormatUtils.shortDate.format(_paidDate)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text.trim());
                if (amount == null) return;
                Navigator.pop(context, _PaymentAction.paid(amount, _paidDate));
              },
              child: const Text('Marquer payé'),
            ),
          ),
          if (widget.existing != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context, _PaymentAction.unpaid()),
                child: const Text('Annuler ce paiement'),
              ),
            ),
          ],
        ],
      ),
    );
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
