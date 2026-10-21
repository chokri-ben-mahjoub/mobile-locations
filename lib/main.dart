import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/auth/auth_providers.dart';
import 'core/auth/firebase_auth_providers.dart';
import 'core/notifications/notification_providers.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_providers.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kIsWeb) {
    // Certains réseaux/FAI bloquent le streaming WebChannel par défaut de
    // Firestore Web, ce qui bloque indéfiniment la première connexion.
    // Le mode "long polling" (détection automatique) contourne ce blocage.
    FirebaseFirestore.instance.settings = const Settings(
      webExperimentalAutoDetectLongPolling: true,
      persistenceEnabled: true,
    );
  }
  await initializeDateFormatting('fr_FR', null);
  await notificationService.init();
  await notificationService.requestPermission();
  runApp(const ProviderScope(child: LocaTrackApp()));
}

class LocaTrackApp extends ConsumerWidget {
  const LocaTrackApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authReady = ref.watch(authReadyProvider);
    final firebaseAuthState = ref.watch(firebaseAuthStateProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Observé en continu pour maintenir les rappels de contrats à jour.
    ref.watch(notificationSyncProvider);

    if (authReady.isLoading || firebaseAuthState.isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'LocaTrack',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      locale: const Locale('fr'),
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
