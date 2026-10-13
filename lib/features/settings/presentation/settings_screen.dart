import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/backup/backup_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/theme/theme_providers.dart';
import '../../../core/widgets/aurora_card.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/reveal.dart';
import '../../../core/widgets/section_card.dart';

const _appVersion = 'v1.3.0';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final db = ref.read(appDatabaseProvider);
    final leadMonths = settings?.reminderLeadMonths ?? 1;
    final scheme = Theme.of(context).colorScheme;
    final pad = MediaQuery.of(context).padding;

    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.fromLTRB(16, pad.top + 14, 16, 150 + pad.bottom),
        children: [
          Text(
            'Réglages',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
          ),
          const SizedBox(height: 16),
          const Reveal(child: _AboutHero()),
          const SizedBox(height: 16),
          Reveal(
            delay: 60,
            child: SectionCard(
              title: 'Rappels d\'expiration',
              icon: Icons.notifications_active_outlined,
              children: [
                Text(
                  'Délai de préavis avant la date de fin d\'un contrat',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: 1, label: Text('1 mois')),
                      ButtonSegment(value: 2, label: Text('2 mois')),
                      ButtonSegment(value: 3, label: Text('3 mois')),
                    ],
                    selected: {leadMonths},
                    onSelectionChanged: (set) {
                      HapticFeedback.selectionClick();
                      db.updateSettings(
                        AppSettingsCompanion(reminderLeadMonths: Value(set.first)),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),
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
          ),
          const SizedBox(height: 14),
          Reveal(
            delay: 110,
            child: SectionCard(
              title: 'Apparence',
              icon: Icons.palette_outlined,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Clair'),
                        icon: Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('Auto'),
                        icon: Icon(Icons.brightness_auto_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Sombre'),
                        icon: Icon(Icons.dark_mode_outlined),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (set) {
                      HapticFeedback.selectionClick();
                      ref.read(themeModeProvider.notifier).set(set.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Reveal(delay: 160, child: _SecuritySection()),
          const SizedBox(height: 14),
          const Reveal(delay: 210, child: _BackupSection()),
        ],
      ),
    );
  }
}

class _AboutHero extends StatelessWidget {
  const _AboutHero();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AuroraCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.apartment_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'LocaTrack',
                      style: text.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        _appVersion,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Vos données restent sur cet appareil.',
                  style: text.bodySmall?.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
              ],
            ),
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
    final scheme = Theme.of(context).colorScheme;

    return SectionCard(
      title: 'Sécurité',
      icon: Icons.lock_outline_rounded,
      children: [
        FutureBuilder<bool>(
          future: biometricService.isAvailable,
          builder: (context, snapshot) {
            final available = snapshot.data ?? false;
            return SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text(
                'Déverrouillage biométrique',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                available
                    ? 'Utiliser l\'empreinte ou le visage pour vous connecter'
                    : 'Non disponible sur cet appareil',
              ),
              value: biometricEnabled && available,
              onChanged: available
                  ? (v) {
                      HapticFeedback.selectionClick();
                      ref.read(biometricEnabledProvider.notifier).set(v);
                    }
                  : null,
            );
          },
        ),
        const Divider(),
        const SizedBox(height: 4),
        Pressable(
          onTap: () => context.push('/settings/change-pin'),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.pin_outlined, size: 20, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Changer le code PassCode',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
        const SizedBox(height: 4),
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

    return SectionCard(
      title: 'Sauvegarde',
      icon: Icons.backup_outlined,
      children: [
        Text(
          'Les données sont stockées uniquement sur cet appareil. '
          'Exportez une sauvegarde régulièrement pour ne rien perdre en cas '
          'de changement de téléphone.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.tonalIcon(
            onPressed: _exporting ? null : _export,
            icon: _exporting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.upload_rounded),
            label: const Text(
              'Exporter une sauvegarde',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: _restoring ? null : _restore,
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: _restoring
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download_rounded),
            label: const Text(
              'Restaurer une sauvegarde',
              style: TextStyle(fontWeight: FontWeight.w700),
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
