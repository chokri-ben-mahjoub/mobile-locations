import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:locations_app/core/auth/auth_providers.dart';
import 'package:locations_app/core/database/app_providers.dart';
import 'package:locations_app/core/theme/app_theme.dart';
import 'package:locations_app/core/theme/locale_providers.dart';
import 'package:locations_app/core/widgets/aurora_card.dart';
import 'package:locations_app/features/auth/presentation/onboarding_screen.dart';
import 'package:locations_app/features/auth/presentation/passcode_screen.dart';
import 'package:locations_app/features/contracts/presentation/contract_form_screen.dart';
import 'package:locations_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/Inter-$w.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

void _setScreen(WidgetTester tester, Size logical) {
  tester.view.physicalSize = logical;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Widget _app(Widget home, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('fr'),
        supportedLocales: supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    );

Future<void> _tapDigits(WidgetTester tester, String digits) async {
  for (final d in digits.split('')) {
    await tester.tap(find.text(d));
    await tester.pump(const Duration(milliseconds: 50));
  }
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  setUpAll(() async {
    await _loadInter();
    await initializeDateFormatting('fr_FR', null);
  });

  setUp(() => SharedPreferences.setMockInitialValues({}));

  for (final size in const [Size(1080, 2220), Size(360, 640)]) {
    testWidgets(
      'PIN : création + confirmation (${size.width.toInt()}x${size.height.toInt()})',
      (tester) async {
        _setScreen(tester, size);
        await tester.pumpWidget(
          _app(const PasscodeScreen(mode: PasscodeMode.create)),
        );
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Créez votre code'), findsOneWidget);
        await _tapDigits(tester, '1234');
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Confirmez votre code'), findsOneWidget);

        await _tapDigits(tester, '1234');
        await tester.pumpAndSettle();
        final container = ProviderScope.containerOf(
          tester.element(find.byType(PasscodeScreen)),
        );
        expect(container.read(sessionAuthenticatedProvider), isTrue);
        expect(container.read(pinSetProvider), isTrue);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'PIN : codes différents → erreur (${size.width.toInt()}x${size.height.toInt()})',
      (tester) async {
        _setScreen(tester, size);
        await tester.pumpWidget(
          _app(const PasscodeScreen(mode: PasscodeMode.create)),
        );
        await tester.pump(const Duration(milliseconds: 400));

        await _tapDigits(tester, '1234');
        await tester.pump(const Duration(milliseconds: 300));
        await _tapDigits(tester, '4321');
        await tester.pumpAndSettle();

        expect(
          find.text('Les codes ne correspondent pas, recommencez.'),
          findsOneWidget,
        );
        expect(find.text('Créez votre code'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Onboarding : rendu sans débordement (${size.width.toInt()}x${size.height.toInt()})',
      (tester) async {
        _setScreen(tester, size);
        await tester.pumpWidget(_app(const OnboardingScreen()));
        await tester.pumpAndSettle();

        expect(find.text('Bienvenue sur LocaTrack'), findsOneWidget);
        expect(find.text('Commencer'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  group('Formulaire de contrat', () {
    final settings = appSettingsProvider.overrideWith(
      (ref) => Stream.value(
        const AppSetting(
          reminderLeadMonths: 1,
          currency: 'TND',
          onboardingDone: true,
        ),
      ),
    );

    for (final size in const [Size(1080, 2220), Size(360, 640)]) {
      testWidgets(
        'aperçu en direct, durées rapides (${size.width.toInt()}x${size.height.toInt()})',
        (tester) async {
          _setScreen(tester, size);
          await tester.pumpWidget(
            _app(const ContractFormScreen(), overrides: [settings]),
          );
          await tester.pumpAndSettle();

          expect(find.text('Nom du locataire'), findsNWidgets(2));

          Future<void> fill(String label, String value) async {
            final field = find.widgetWithText(TextFormField, label);
            await tester.scrollUntilVisible(
              field,
              120,
              scrollable: find.byType(Scrollable).first,
            );
            await tester.enterText(field, value);
            await tester.pump();
          }

          await fill('Nom du locataire', 'Sami Ben Ali');
          await fill('Numéro de local (ex: A1-1)', 'A1-7');
          await fill('Loyer mensuel (TND)', '450');
          await tester.drag(find.byType(ListView), const Offset(0, 4000));
          await tester.pumpAndSettle();

          final preview = find.byType(AuroraCard);
          expect(
            find.descendant(of: preview, matching: find.text('Sami Ben Ali')),
            findsOneWidget,
          );
          expect(
            find.descendant(of: preview, matching: find.text('A1-7')),
            findsOneWidget,
          );
          Finder previewLine(RegExp re) => find.byWidgetPredicate(
            (w) => w is Text && re.hasMatch(w.data ?? ''),
          );
          expect(previewLine(RegExp(r'450\s*TND\s*/ mois')), findsOneWidget);

          await tester.ensureVisible(find.text('2 ans'));
          await tester.tap(find.text('2 ans'));
          await tester.pump();
          await tester.drag(find.byType(ListView), const Offset(0, 4000));
          await tester.pumpAndSettle();
          expect(
            previewLine(RegExp(r'450\s*TND\s*/ mois\s*·\s*2 ans')),
            findsOneWidget,
          );

          await tester.drag(find.byType(ListView), const Offset(0, -2000));
          await tester.pumpAndSettle();
          expect(find.text('Ajouter le contrat'), findsOneWidget);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
