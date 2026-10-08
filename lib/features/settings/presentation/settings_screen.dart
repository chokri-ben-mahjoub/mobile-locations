import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/backup/backup_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/pdf/rent_report_pdf.dart';
import '../../../core/theme/theme_providers.dart';
import '../../../core/utils/format_utils.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final db = ref.read(appDatabaseProvider);
    final leadMonths = settings?.reminderLeadMonths ?? 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionCard(
            title: 'Rappels d\'expiration',
            children: [
              Text(
                'Délai de préavis avant la date de fin d\'un contrat',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('1 mois')),
                  ButtonSegment(value: 2, label: Text('2 mois')),
                  ButtonSegment(value: 3, label: Text('3 mois')),
                ],
                selected: {leadMonths},
                onSelectionChanged: (set) => db.updateSettings(
                  AppSettingsCompanion(reminderLeadMonths: Value(set.first)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: ValueKey('lead-$leadMonths'),
                initialValue: '$leadMonths',
                decoration: const InputDecoration(
                  labelText: 'Ou valeur personnalisée (en mois)',
                ),
                keyboardType: TextInputType.number,
                onFieldSubmitted: (v) {
                  final months = int.tryParse(v.trim());
                  if (months != null && months > 0) {
                    db.updateSettings(
                      AppSettingsCompanion(reminderLeadMonths: Value(months)),
                    );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Apparence',
            children: [
              SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                      value: ThemeMode.light,
                      label: Text('Clair'),
                      icon: Icon(Icons.light_mode_outlined)),
                  ButtonSegment(
                      value: ThemeMode.system,
                      label: Text('Auto'),
                      icon: Icon(Icons.brightness_auto_outlined)),
                  ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text('Sombre'),
                      icon: Icon(Icons.dark_mode_outlined)),
                ],
                selected: {themeMode},
                onSelectionChanged: (set) =>
                    ref.read(themeModeProvider.notifier).set(set.first),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _SecuritySection(),
          const SizedBox(height: 16),
          const _ReportsSection(),
          const SizedBox(height: 16),
          const _BackupSection(),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'À propos',
            children: const [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.apartment_outlined),
                title: Text('LocaTrack'),
                subtitle: Text('Gestion des contrats de location · v1.0.0'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SecuritySection extends ConsumerWidget {
  const _SecuritySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final biometricEnabled = ref.watch(biometricEnabledProvider);

    return _SectionCard(
      title: 'Sécurité',
      children: [
        FutureBuilder<bool>(
          future: biometricService.isAvailable,
          builder: (context, snapshot) {
            final available = snapshot.data ?? false;
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Déverrouillage biométrique'),
              subtitle: Text(
                available
                    ? 'Utiliser l\'empreinte ou le visage pour vous connecter'
                    : 'Non disponible sur cet appareil',
              ),
              value: biometricEnabled && available,
              onChanged: available
                  ? (v) => ref.read(biometricEnabledProvider.notifier).set(v)
                  : null,
            );
          },
        ),
        const Divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.pin_outlined),
          title: const Text('Changer le code PassCode'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/settings/change-pin'),
        ),
      ],
    );
  }
}

class _ReportsSection extends ConsumerStatefulWidget {
  const _ReportsSection();

  @override
  ConsumerState<_ReportsSection> createState() => _ReportsSectionState();
}

class _ReportsSectionState extends ConsumerState<_ReportsSection> {
  bool _generating = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _SectionCard(
      title: 'Rapports',
      children: [
        Text(
          'Exportez en PDF la liste des loyers d\'un mois, avec le statut '
          'payé/impayé de chaque local.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _generating ? null : _pickMonthAndExport,
            icon: _generating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: const Text(
              'Exporter le rapport mensuel (PDF)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickMonthAndExport() async {
    final month = await showDialog<DateTime>(
      context: context,
      builder: (context) => const _MonthPickerDialog(),
    );
    if (month == null) return;

    setState(() => _generating = true);
    try {
      final db = ref.read(appDatabaseProvider);
      final currency = ref.read(currencyProvider);
      final monthStart = DateTime(month.year, month.month, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 0);

      final contracts = await db.getContractsActiveDuring(monthStart, monthEnd);
      final payments = await db.getPaymentsForMonth(monthStart);
      final byContract = {for (final p in payments) p.contractId: p};

      final rows = contracts
          .map((c) => RentReportRow(contract: c, payment: byContract[c.id]))
          .toList();

      if (rows.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Aucun contrat actif pour ce mois.')),
          );
        }
        return;
      }

      await shareMonthlyRentReport(month: monthStart, rows: rows, currency: currency);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }
}

class _MonthPickerDialog extends StatefulWidget {
  const _MonthPickerDialog();

  @override
  State<_MonthPickerDialog> createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<_MonthPickerDialog> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);

  void _shift(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta, 1));
  }

  @override
  Widget build(BuildContext context) {
    final label = FormatUtils.monthYear.format(_month);
    return AlertDialog(
      title: const Text('Choisir le mois'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => _shift(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              label[0].toUpperCase() + label.substring(1),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          IconButton(
            onPressed: () => _shift(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _month),
          child: const Text('Exporter'),
        ),
      ],
    );
  }
}

class _BackupSection extends ConsumerStatefulWidget {
  const _BackupSection();

  @override
  ConsumerState<_BackupSection> createState() => _BackupSectionState();
}

class _BackupSectionState extends ConsumerState<_BackupSection> {
  bool _exporting = false;
  bool _restoring = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return _SectionCard(
      title: 'Sauvegarde',
      children: [
        Text(
          'Les données sont stockées uniquement sur cet appareil. '
          'Exportez une sauvegarde régulièrement pour ne rien perdre en cas '
          'de changement de téléphone.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _exporting ? null : _export,
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_outlined),
            label: const Text(
              'Exporter une sauvegarde',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _restoring ? null : _restore,
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
            ),
            icon: _restoring
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_outlined),
            label: const Text(
              'Restaurer une sauvegarde',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final service = BackupService(ref.read(appDatabaseProvider));
      await service.shareBackup();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'export : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _restore() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurer cette sauvegarde ?'),
        content: const Text(
          'Tous les contrats, paiements et réglages actuels seront '
          'remplacés par le contenu de ce fichier. Cette action est '
          'irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Restaurer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _restoring = true);
    try {
      final service = BackupService(ref.read(appDatabaseProvider));
      await service.restoreFromFile(File(path));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sauvegarde restaurée avec succès.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la restauration : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _restoring = false);
    }
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
