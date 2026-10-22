import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:locations_app/l10n/app_localizations.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/attachments/attachment_service.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/utils/arabic_text.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/receipt.dart';
import '../../../core/widgets/aurora_card.dart';
import '../../../core/widgets/charts.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/widgets/pressable.dart';
import '../application/contracts_providers.dart';

class _LifetimeBar extends StatelessWidget {
  final Contract contract;

  const _LifetimeBar({required this.contract});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final total = contract.endDate.difference(contract.startDate).inHours;
    final elapsed = now.difference(contract.startDate).inHours;
    final progress = total <= 0 ? 1.0 : (elapsed / total).clamp(0.0, 1.0);
    final daysLeft = contract.endDate.difference(now).inDays;
    final expired = !contract.endDate.isAfter(now);
    final label = expired
        ? 'Contrat arrivé à échéance'
        : daysLeft > 60
        ? 'Encore ${(daysLeft / 30).round()} mois'
        : 'Encore $daysLeft jour${daysLeft > 1 ? 's' : ''}';

    return Column(
      children: [
        ThinProgress(
          value: progress,
          color: Colors.white,
          track: Colors.white.withValues(alpha: 0.2),
          height: 6,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              FormatUtils.shortDate.format(contract.startDate),
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Text(
              FormatUtils.shortDate.format(contract.endDate),
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

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
        title: Text(
          c.tenantName,
          textDirection: isArabicText(c.tenantName) ? TextDirection.rtl : TextDirection.ltr,
        ),
        actions: [
          const LanguageIconButton(),
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
                  Icon(
                    Icons.hourglass_empty_rounded,
                    color: scheme.onSurfaceVariant,
                  ),
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
                    onPressed: () => _confirmReactivate(context, ref, c),
                    child: const Text('Réactiver'),
                  ),
                ],
              ),
            ),
          AuroraCard(
            padding: const EdgeInsets.all(20),
            radius: 28,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        c.unitNumber,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.tenantName,
                            textDirection: isArabicText(c.tenantName)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            textAlign: isArabicText(c.tenantName) ? TextAlign.right : TextAlign.left,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            FormatUtils.currency(c.monthlyAmount, currency),
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Historique de ce local',
                      onPressed: () => context.push(
                        '/units/${Uri.encodeComponent(c.unitNumber)}/history',
                      ),
                      icon: Icon(
                        Icons.history_rounded,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _LifetimeBar(contract: c),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                _InfoTile(
                  icon: Icons.event_outlined,
                  label: 'Début du contrat',
                  value: FormatUtils.shortDate.format(c.startDate),
                ),
                _InfoTile(
                  icon: Icons.event_busy_outlined,
                  label: 'Fin du contrat',
                  value: FormatUtils.shortDate.format(c.endDate),
                ),
                _InfoTile(
                  icon: Icons.hourglass_bottom_rounded,
                  label: 'Durée',
                  value: FormatUtils.durationLabel(AppLocalizations.of(context), c.startDate, c.endDate),
                ),
                _InfoTile(
                  icon: Icons.bolt_outlined,
                  label: 'Compteur STEG',
                  value: c.stegMeter ?? '—',
                ),
                _InfoTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Compteur SONEDE',
                  value: c.sonedeMeter ?? '—',
                  isLast: true,
                ),
              ],
            ),
          ),
          if (c.notes.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: scheme.outlineVariant.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: Theme.of(context).textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    c.notes,
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          _PaymentsSection(contract: c, currency: currency),
          if (c.stegMeter != null || c.sonedeMeter != null) ...[
            const SizedBox(height: 24),
            _UtilityBillsSection(contract: c),
          ],
          const SizedBox(height: 24),
          _AttachmentsSection(contractId: c.id),
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

  Future<void> _confirmReactivate(
    BuildContext context,
    WidgetRef ref,
    Contract c,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réactiver ce contrat ?'),
        content: Text(
          'Le local ${c.unitNumber} redeviendra actif avec '
          '${c.tenantName} comme locataire.',
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
      await ref.read(contractsControllerProvider).reactivate(c.id);
    }
  }

  Future<void> _confirmMarkVacant(
    BuildContext context,
    WidgetRef ref,
    Contract c,
  ) async {
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

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
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
    final payments =
        ref
            .watch(paymentsForContractProvider(widget.contract.id))
            .valueOrNull ??
        [];
    final byMonth = {for (final p in payments) p.month: p};

    final months = _months();
    final visibleMonths = _expanded ? months : months.take(6).toList();
    final paidCount = months.where((m) => byMonth[m] != null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Historique des paiements',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            Text(
              '$paidCount/${months.length} payés',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Touchez un mois pour basculer payé/impayé. Appui long pour corriger le montant.',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: scheme.onSurfaceVariant),
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
            child: Text(
              _expanded
                  ? 'Réduire'
                  : 'Afficher tous les mois (${months.length})',
            ),
          ),
      ],
    );
  }

  /// Un seul tap : bascule rapidement payé (montant du loyer, aujourd'hui)
  /// ou impayé, sans passer par un formulaire.
  Future<void> _toggleMonth(DateTime month, Payment? existing) async {
    final controller = ref.read(paymentsControllerProvider);
    final messenger = ScaffoldMessenger.of(context);
    final label = FormatUtils.monthYear.format(month);
    if (existing != null) {
      HapticFeedback.lightImpact();
      await controller.markUnpaid(widget.contract.id, month);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Paiement de $label annulé'),
            action: SnackBarAction(
              label: 'Rétablir',
              onPressed: () => controller.markPaid(
                contractId: existing.contractId,
                month: month,
                amount: existing.amount,
                paidDate: existing.paidDate,
              ),
            ),
          ),
        );
    } else {
      HapticFeedback.heavyImpact();
      await controller.markPaid(
        contractId: widget.contract.id,
        month: month,
        amount: widget.contract.monthlyAmount,
        paidDate: DateTime.now(),
      );
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('$label encaissé'),
            action: SnackBarAction(
              label: 'Annuler',
              onPressed: () => controller.markUnpaid(widget.contract.id, month),
            ),
          ),
        );
    }
  }

  Future<void> _editMonth(
    BuildContext context,
    DateTime month,
    Payment? existing,
  ) async {
    final result = await showModalBottomSheet<_PaymentAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => _PaymentActionSheet(
        month: month,
        existing: existing,
        defaultAmount: widget.contract.monthlyAmount,
        contract: widget.contract,
        currency: widget.currency,
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
    final label = FormatUtils.dayMonth
        .format(month)
        .replaceFirst(RegExp(r'^\d+ '), '');
    final isCurrentMonth =
        DateTime.now().year == month.year &&
        DateTime.now().month == month.month;

    return Pressable(
      onTap: onTap,
      onLongPress: onLongPress,
      pressedScale: 0.92,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: paid
              ? okColor.withValues(alpha: 0.16)
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
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Icon(
                paid
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                key: ValueKey(paid),
                size: 18,
                color: paid ? okColor : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${label[0].toUpperCase()}${label.substring(1)} ${month.year.toString().substring(2)}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: paid ? okColor : scheme.onSurfaceVariant,
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
  _PaymentAction.unpaid() : markPaid = false, amount = null, paidDate = null;
}

class _PaymentActionSheet extends StatefulWidget {
  final DateTime month;
  final Payment? existing;
  final double defaultAmount;
  final Contract contract;
  final String currency;

  const _PaymentActionSheet({
    required this.month,
    required this.existing,
    required this.defaultAmount,
    required this.contract,
    required this.currency,
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
        20,
        4,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label[0].toUpperCase() + label.substring(1),
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
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
              child: FilledButton.tonalIcon(
                onPressed: () {
                  final p = widget.existing!;
                  Share.share(
                    buildReceiptText(
                      contract: widget.contract,
                      month: widget.month,
                      amount: p.amount,
                      paidDate: p.paidDate,
                      currency: widget.currency,
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded, size: 18),
                label: const Text('Partager la quittance'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.pop(context, _PaymentAction.unpaid()),
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
  final IconData icon;
  final String label;
  final String value;
  final bool isLast;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: isLast
          ? null
          : BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
            ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: scheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _UtilityBillsSection extends ConsumerStatefulWidget {
  final Contract contract;

  const _UtilityBillsSection({required this.contract});

  @override
  ConsumerState<_UtilityBillsSection> createState() => _UtilityBillsSectionState();
}

class _UtilityBillsSectionState extends ConsumerState<_UtilityBillsSection> {
  late String _type = widget.contract.stegMeter != null ? 'steg' : 'sonede';
  bool _expanded = false;

  List<DateTime> _months() {
    final c = widget.contract;
    final now = DateTime.now();
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
    final c = widget.contract;
    final hasSteg = c.stegMeter != null;
    final hasSonede = c.sonedeMeter != null;

    final bills =
        ref.watch(utilityBillsProvider((c.id, _type))).valueOrNull ?? [];
    final byMonth = {for (final b in bills) b.month: b};

    final months = _months();
    final visibleMonths = _expanded ? months : months.take(6).toList();
    final paidCount = months.where((m) => byMonth[m] != null).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Factures STEG / SONEDE', style: Theme.of(context).textTheme.titleSmall),
            const Spacer(),
            Text(
              '$paidCount/${months.length} réglées',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (hasSteg && hasSonede)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SegmentedButton<String>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: 'steg',
                  label: Text('STEG'),
                  icon: Icon(Icons.bolt_rounded, size: 16),
                ),
                ButtonSegment(
                  value: 'sonede',
                  label: Text('SONEDE'),
                  icon: Icon(Icons.water_drop_rounded, size: 16),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (set) {
                HapticFeedback.selectionClick();
                setState(() => _type = set.first);
              },
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  hasSteg ? Icons.bolt_rounded : Icons.water_drop_rounded,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  hasSteg ? 'Compteur STEG ${c.stegMeter}' : 'Compteur SONEDE ${c.sonedeMeter}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final month in visibleMonths)
              _MonthChip(
                month: month,
                paid: byMonth[month] != null,
                onTap: () => _toggleMonth(month, byMonth[month]),
                onLongPress: () => _toggleMonth(month, byMonth[month]),
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

  Future<void> _toggleMonth(DateTime month, UtilityBill? existing) async {
    final controller = ref.read(utilityBillsControllerProvider);
    if (existing != null) {
      HapticFeedback.lightImpact();
      await controller.markUnpaid(widget.contract.id, _type, month);
    } else {
      HapticFeedback.heavyImpact();
      await controller.markPaid(
        contractId: widget.contract.id,
        type: _type,
        month: month,
        paidDate: DateTime.now(),
      );
    }
  }
}

class _AttachmentsSection extends ConsumerWidget {
  final String contractId;

  const _AttachmentsSection({required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final attachments =
        ref.watch(attachmentsForContractProvider(contractId)).valueOrNull ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pièces jointes',
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _showAddSheet(context, ref),
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: const Text('Ajouter'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (attachments.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: scheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.photo_library_outlined,
                  color: scheme.onSurfaceVariant,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  'Aucune pièce jointe. Ajoutez une photo du contrat, de la CIN\n'
                  'ou de l\'état des lieux.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final attachment in attachments)
                _AttachmentThumb(
                  attachment: attachment,
                  onTap: () => _openViewer(context, ref, attachment),
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _showAddSheet(BuildContext context, WidgetRef ref) async {
    final category = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Type de document',
                style: Theme.of(context).textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            for (final entry in attachmentCategoryLabels.entries)
              ListTile(
                leading: Icon(_categoryIcon(entry.key)),
                title: Text(entry.value),
                onTap: () => Navigator.pop(context, entry.key),
              ),
          ],
        ),
      ),
    );
    if (category == null || !context.mounted) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final service = ref.read(attachmentServiceProvider);
    await service.captureAndSave(
      contractId: contractId,
      category: category,
      source: source,
    );
  }

  Future<void> _openViewer(
    BuildContext context,
    WidgetRef ref,
    Attachment attachment,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => _AttachmentViewer(attachment: attachment),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'contrat':
        return Icons.description_outlined;
      case 'cin':
        return Icons.badge_outlined;
      case 'etat_lieux':
        return Icons.home_work_outlined;
      default:
        return Icons.attach_file_rounded;
    }
  }
}

class _AttachmentThumb extends StatelessWidget {
  final Attachment attachment;
  final VoidCallback onTap;

  const _AttachmentThumb({required this.attachment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.memory(
              base64Decode(attachment.data),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                width: 80,
                height: 80,
                color: scheme.surfaceContainerHigh,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 80,
            child: Text(
              attachmentCategoryLabels[attachment.category] ?? 'Autre',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentViewer extends ConsumerWidget {
  final Attachment attachment;

  const _AttachmentViewer({required this.attachment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const Spacer(),
                Text(
                  attachmentCategoryLabels[attachment.category] ?? 'Autre',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () => Share.shareXFiles([
                    XFile.fromData(
                      base64Decode(attachment.data),
                      name: '${attachment.category}.jpg',
                      mimeType: 'image/jpeg',
                    ),
                  ]),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: () =>
                      _confirmDeleteAttachment(context, ref, attachment),
                ),
              ],
            ),
            Expanded(
              child: InteractiveViewer(
                child: Center(child: Image.memory(base64Decode(attachment.data))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteAttachment(
    BuildContext context,
    WidgetRef ref,
    Attachment attachment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer cette pièce jointe ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(attachmentServiceProvider).delete(attachment);
      if (context.mounted) Navigator.pop(context);
    }
  }
}
