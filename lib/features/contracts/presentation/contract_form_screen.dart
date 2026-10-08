import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/utils/format_utils.dart';
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

    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing && !_loadedExisting) {
      final contracts = ref.watch(contractsProvider).valueOrNull ?? [];
      for (final c in contracts) {
        if (c.id == widget.contractId) _loadExisting(c);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing
            ? 'Modifier le contrat'
            : widget.prefillUnitNumber != null
                ? 'Nouveau locataire — ${widget.prefillUnitNumber}'
                : 'Nouveau contrat'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _FormSection(
              icon: Icons.person_outline_rounded,
              title: 'Locataire & local',
              children: [
                TextFormField(
                  controller: _tenantNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom du locataire',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _unitNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de local (ex: A1-1)',
                    prefixIcon: Icon(Icons.door_front_door_outlined),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FormSection(
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
              ],
            ),
            const SizedBox(height: 16),
            _FormSection(
              icon: Icons.payments_outlined,
              title: 'Loyer & compteurs',
              children: [
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Loyer mensuel (TND)',
                    prefixIcon: Icon(Icons.payments_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Champ requis';
                    if (double.tryParse(v.trim()) == null) return 'Montant invalide';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _stegController,
                  decoration: const InputDecoration(
                    labelText: 'Compteur STEG (optionnel)',
                    prefixIcon: Icon(Icons.bolt_outlined),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _sonedeController,
                  decoration: const InputDecoration(
                    labelText: 'Compteur SONEDE (optionnel)',
                    prefixIcon: Icon(Icons.water_drop_outlined),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FormSection(
              icon: Icons.notes_rounded,
              title: 'Notes',
              children: [
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes (optionnel)',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(_isEditing ? 'Enregistrer' : 'Ajouter le contrat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  const _DatePickerField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: InputDecorator(
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              FormatUtils.shortDate.format(value),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _FormSection({required this.icon, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: scheme.primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
