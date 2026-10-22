import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locations_app/l10n/app_localizations.dart';

import '../theme/locale_providers.dart';

/// Icône globe à placer dans l'en-tête de chaque écran — ouvre le
/// sélecteur de langue en un tap, accessible depuis n'importe quelle page
/// (pas seulement Réglages).
class LanguageIconButton extends ConsumerWidget {
  const LanguageIconButton({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: AppLocalizations.of(context).settingsLanguage,
      icon: Icon(Icons.language_rounded, color: color),
      onPressed: () => showLanguagePicker(context, ref),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(),
    );
  }
}

/// Feuille de choix de langue (Système / Français / English / العربية),
/// partagée entre l'icône globe globale et la section "Langue" de Réglages.
/// Se ferme automatiquement dès qu'une langue est choisie.
Future<void> showLanguagePicker(BuildContext context, WidgetRef ref) {
  final l10n = AppLocalizations.of(context);
  return showModalBottomSheet(
    context: context,
    builder: (sheetContext) => Consumer(
      builder: (sheetContext, ref, _) {
        final locale = ref.watch(localeControllerProvider);
        final scheme = Theme.of(sheetContext).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    l10n.settingsLanguage,
                    style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                for (final option in [
                  (null, l10n.languageSystem),
                  (const Locale('fr'), 'Français'),
                  (const Locale('en'), 'English'),
                  (const Locale('ar'), 'العربية'),
                ])
                  ListTile(
                    title: Text(option.$2),
                    trailing: locale == option.$1 ? Icon(Icons.check_rounded, color: scheme.primary) : null,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(localeControllerProvider.notifier).set(option.$1);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
