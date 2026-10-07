import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/app_providers.dart';
import '../../../core/theme/theme_providers.dart';

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
