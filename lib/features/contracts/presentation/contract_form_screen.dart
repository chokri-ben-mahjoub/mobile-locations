import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locations_app/l10n/app_localizations.dart';

import '../../../core/database/app_providers.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/aurora_card.dart';
import '../../../core/widgets/language_switcher.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/reveal.dart';
import '../../../core/widgets/section_card.dart';
import '../application/contracts_providers.dart';

/// Formulaire d'ajout (contractId == null) ou de modification d'un contrat.
class ContractFormScreen extends ConsumerStatefulWidget {
  final String? contractId;
  final String? prefillUnitNumber;
  final String? replaceVacantId;

  const ContractFormScreen({
    super.key,
    this.contractId,
    this.prefillUnitNumber,
    this.replaceVacantId,
  });

  @override
  ConsumerState<ContractFormScreen> createState() => _ContractFormScreenState();
}

class _ContractFormScreenState extends ConsumerState<ContractFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tenantNameController = TextEditingController();
  final _unitNumberController = TextEditingController();
  final _amountController = TextEditingController();
  final _stegController = TextEditingController();
  final _sonedeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  bool _loadedExisting = false;
  bool _saving = false;

  bool get _isEditing => widget.contractId != null;

  @override
  void initState() {
    super.initState();
    if (widget.prefillUnitNumber != null) {
      _unitNumberController.text = widget.prefillUnitNumber!;
    }
  }

  @override
  void dispose() {
    _tenantNameController.dispose();
    _unitNumberController.dispose();
    _amountController.dispose();
    _stegController.dispose();
    _sonedeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadExisting(Contract c) {
    _tenantNameController.text = c.tenantName;
    _unitNumberController.text = c.unitNumber;
    _amountController.text = c.monthlyAmount.toStringAsFixed(0);
    _stegController.text = c.stegMeter ?? '';
    _sonedeController.text = c.sonedeMeter ?? '';
    _notesController.text = c.notes;
    _startDate = c.startDate;
    _endDate = c.endDate;
    _loadedExisting = true;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? _startDate : _endDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final controller = ref.read(contractsControllerProvider);
    final amount = double.parse(_amountController.text.trim());
    final steg = _stegController.text.trim();
    final sonede = _sonedeController.text.trim();

    if (_isEditing) {
      await controller.update(
        widget.contractId!,
        tenantName: _tenantNameController.text.trim(),
        unitNumber: _unitNumberController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        monthlyAmount: amount,
        stegMeter: steg.isEmpty ? null : steg,
        sonedeMeter: sonede.isEmpty ? null : sonede,
        notes: _notesController.text.trim(),
      );
    } else {
      await controller.create(
        tenantName: _tenantNameController.text.trim(),
        unitNumber: _unitNumberController.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        monthlyAmount: amount,
        stegMeter: steg.isEmpty ? null : steg,
        sonedeMeter: sonede.isEmpty ? null : sonede,
        notes: _notesController.text.trim(),
      );
      if (widget.replaceVacantId != null) {
        await controller.delete(widget.replaceVacantId!);
      }
    }

    HapticFeedback.mediumImpact();
    if (!mounted) return;
    context.pop();
  }

  void _applyMonths(int months) {
    final target = DateTime(_startDate.year, _startDate.month + months, 1);
    final lastDay = DateTime(target.year, target.month + 1, 0).day;
    setState(() {
      _endDate = DateTime(
        target.year,
        target.month,
        _startDate.day > lastDay ? lastDay : _startDate.day,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && !_loadedExisting) {
      final contracts = ref.watch(contractsProvider).valueOrNull ?? [];
      for (final c in contracts) {
        if (c.id == widget.contractId) _loadExisting(c);
      }
    }

    final currency = ref.watch(currencyProvider);
    final scheme = Theme.of(context).colorScheme;
    final months = FormatUtils.monthsBetween(_startDate, _endDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing
              ? 'Modifier le contrat'
              : widget.prefillUnitNumber != null
              ? 'Nouveau locataire — ${widget.prefillUnitNumber}'
              : 'Nouveau contrat',
        ),
        actions: const [LanguageIconButton()],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            32 + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            ListenableBuilder(
              listenable: Listenable.merge([
                _tenantNameController,
                _unitNumberController,
                _amountController,
              ]),
              builder: (context, _) => _Preview(
                unit: _unitNumberController.text.trim(),
                tenant: _tenantNameController.text.trim(),
                amount: double.tryParse(_amountController.text.trim()),
                currency: currency,
                start: _startDate,
                end: _endDate,
              ),
            ),
            const SizedBox(height: 16),
            Reveal(
              delay: 40,
              child: SectionCard(
                icon: Icons.person_outline_rounded,
                title: 'Locataire & local',
                children: [
                  TextFormField(
                    controller: _tenantNameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nom du locataire',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _unitNumberController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Numéro de local (ex: A1-1)',
                      prefixIcon: Icon(Icons.door_front_door_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Reveal(
              delay: 90,
              child: SectionCard(
                icon: Icons.event_outlined,
                title: 'Durée du contrat',
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DatePickerField(
                          label: 'Date de début',
                          value: _startDate,
                          onTap: () => _pickDate(isStart: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DatePickerField(
                          label: 'Date de fin',
                          value: _endDate,
                          onTap: () => _pickDate(isStart: false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Durée rapide',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final (label, n) in const [
                        ('6 mois', 6),
                        ('1 an', 12),
                        ('2 ans', 24),
                        ('3 ans', 36),
                      ])
                        _DurationChip(
                          label: label,
                          selected: months == n,
                          onTap: () => _applyMonths(n),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Reveal(
              delay: 140,
              child: SectionCard(
                icon: Icons.payments_outlined,
                title: 'Loyer & compteurs',
                children: [
                  TextFormField(
                    controller: _amountController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: 'Loyer mensuel ($currency)',
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Champ requis';
                      if (double.tryParse(v.trim()) == null)
                        return 'Montant invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _stegController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Compteur STEG (optionnel)',
                      prefixIcon: Icon(Icons.bolt_outlined),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _sonedeController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Compteur SONEDE (optionnel)',
                      prefixIcon: Icon(Icons.water_drop_outlined),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Reveal(
              delay: 190,
              child: SectionCard(
                icon: Icons.notes_rounded,
                title: 'Notes',
                children: [
                  TextFormField(
                    controller: _notesController,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optionnel)',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _isEditing ? Icons.check_rounded : Icons.add_rounded,
                      ),
                label: Text(_isEditing ? 'Enregistrer' : 'Ajouter le contrat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Aperçu en direct du contrat, mis à jour pendant la saisie.
class _Preview extends StatelessWidget {
  final String unit;
  final String tenant;
  final double? amount;
  final String currency;
  final DateTime start;
  final DateTime end;

  const _Preview({
    required this.unit,
    required this.tenant,
    required this.amount,
    required this.currency,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    const white = Colors.white;
    final amountLabel = amount == null
        ? '—'
        : FormatUtils.currency(amount!, currency);
    return AuroraCard(
      padding: const EdgeInsets.all(18),
      radius: 28,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: white.withValues(alpha: 0.2)),
                ),
                child: Text(
                  unit.isEmpty ? '—' : unit,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tenant.isEmpty ? 'Nom du locataire' : tenant,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: white.withValues(
                          alpha: tenant.isEmpty ? 0.55 : 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$amountLabel / mois  ·  ${FormatUtils.durationLabel(AppLocalizations.of(context), start, end)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(
                        color: white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                FormatUtils.shortDate.format(start),
                style: TextStyle(
                  fontSize: 12,
                  color: white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: white.withValues(alpha: 0.25),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                FormatUtils.shortDate.format(end),
                style: TextStyle(
                  fontSize: 12,
                  color: white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Pressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, size: 18, color: scheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    FormatUtils.shortDate.format(value),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
