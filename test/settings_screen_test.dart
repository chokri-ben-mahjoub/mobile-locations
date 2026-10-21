import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locations_app/core/database/app_providers.dart';
import 'package:locations_app/core/theme/app_theme.dart';
import 'package:locations_app/features/settings/presentation/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/Inter-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void main() {
  setUpAll(_loadInter);

  testWidgets('Inter se charge avec des métriques réelles (pas Ahem)', (
    tester,
  ) async {
    final tp = TextPainter(
      text: const TextSpan(
        text: "Rappels d'expiration",
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    expect(tp.width, lessThan(220));
  });

  test('le thème utilise la police Inter embarquée', () {
    for (final theme in [AppTheme.light(), AppTheme.dark()]) {
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
      expect(theme.textTheme.titleLarge?.fontFamily, 'Inter');
      expect(theme.appBarTheme.titleTextStyle?.fontFamily, 'Inter');
      expect(theme.snackBarTheme.contentTextStyle?.fontFamily, 'Inter');
    }
  });

  testWidgets('Réglages : rendu complet et défilement sans erreur', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2220);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => Stream.value(
              const AppSetting(
                reminderLeadMonths: 2,
                currency: 'TND',
                onboardingDone: true,
              ),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Réglages'), findsOneWidget);
    expect(find.text('Rappels d\'expiration'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -1500));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Exporter une sauvegarde'), findsOneWidget);
    expect(find.text('Restaurer une sauvegarde'), findsOneWidget);
  });
}
