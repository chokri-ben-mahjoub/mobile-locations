import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/auth/firebase_auth_providers.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/export/export_service.dart';
import '../../../core/migration/legacy_migration.dart';
import '../../../core/theme/theme_providers.dart';
import '../../../core/widgets/aurora_card.dart';
import '../../../core/widgets/pressable.dart';
import '../../../core/widgets/reveal.dart';
import '../../../core/widgets/section_card.dart';

const _appVersion = 'v1.4.0';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final service = ref.read(firestoreServiceProvider);
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
                      service.updateSettings(reminderLeadMonths: set.first);
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
                      service.updateSettings(reminderLeadMonths: months);
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
          const Reveal(delay: 185, child: _ExportSection()),
          const SizedBox(height: 14),
          const Reveal(delay: 210, child: _AccountSection()),
          if (!kIsWeb) ...[
            const SizedBox(height: 14),
            const Reveal(delay: 260, child: _MigrationSection()),
          ],
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
                  'Synchronisé entre mobile et web.',
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

class _AccountSection extends ConsumerWidget {
  const _AccountSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final user = ref.watch(firebaseAuthStateProvider).valueOrNull;

    return SectionCard(
      title: 'Compte',
      icon: Icons.cloud_outlined,
      children: [
        Text(
          'Connecté en tant que',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          user?.email ?? '—',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Se déconnecter ?'),
                  content: const Text(
                    'Vous devrez ressaisir l\'e-mail et le mot de passe '
                    'du compte pour retrouver vos données.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Se déconnecter'),
                    ),
                  ],
                ),
              );
              if (confirmed == true) {
                await FirebaseAuth.instance.signOut();
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: scheme.error,
              side: BorderSide(color: scheme.error.withValues(alpha: 0.4)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}

/// Import ponctuel des anciennes données locales (avant le passage au
/// stockage cloud) vers Firestore / Firebase Storage. Ne s'affiche que s'il
/// reste des données dans l'ancienne base locale de l'appareil.
class _MigrationSection extends ConsumerStatefulWidget {
  const _MigrationSection();

  @override
  ConsumerState<_MigrationSection> createState() => _MigrationSectionState();
}

class _MigrationSectionState extends ConsumerState<_MigrationSection> {
  final _service = LegacyMigrationService();
  bool _migrating = false;
  bool? _hasLocalData;

  @override
  void initState() {
    super.initState();
    _service.hasLocalData().then((has) {
      if (mounted) setState(() => _hasLocalData = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_hasLocalData != true) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return SectionCard(
      title: 'Anciennes données locales',
      icon: Icons.sync_alt_rounded,
      children: [
        Text(
          'Des contrats enregistrés avant le passage au cloud ont été '
          'détectés sur cet appareil. Importez-les une fois vers le compte '
          'partagé pour les retrouver sur tous vos appareils.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: _migrating ? null : _migrate,
            icon: _migrating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(
              _migrating ? 'Import en cours…' : 'Importer vers le cloud',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _migrate() async {
    setState(() => _migrating = true);
    try {
      final count = await _service.migrateTo(ref.read(firestoreServiceProvider));
      if (mounted) {
        setState(() => _hasLocalData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count éléments importés avec succès.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'import : $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _migrating = false);
    }
  }
}

class _ExportSection extends ConsumerStatefulWidget {
  const _ExportSection();

  @override
  ConsumerState<_ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends ConsumerState<_ExportSection> {
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SectionCard(
      title: 'Export',
      icon: Icons.table_chart_outlined,
      children: [
        Text(
          'Exportez tous les contrats (actifs et en attente) en CSV, Excel, '
          'PDF ou image — les noms de locataires en arabe s\'affichent '
          'correctement dans les 4 formats.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 14),
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
                : const Icon(Icons.ios_share_rounded),
            label: const Text(
              'Exporter / partager',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _export() async {
    final format = await chooseExportFormat(context);
    if (format == null || !mounted) return;

    setState(() => _exporting = true);
    try {
      final active = ref.read(contractsProvider).valueOrNull ?? [];
      final vacant = ref.read(vacantContractsProvider).valueOrNull ?? [];
      final currency = ref.read(currencyProvider);
      await ContractsExportService.export(
        context: context,
        format: format,
        contracts: [...active, ...vacant],
        currency: currency,
      );
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
}

