import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/presentation/analytics_screen.dart';
import '../../features/auth/presentation/cloud_login_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/passcode_screen.dart';
import '../../features/contracts/presentation/contract_detail_screen.dart';
import '../../features/contracts/presentation/contract_form_screen.dart';
import '../../features/contracts/presentation/contracts_screen.dart';
import '../../features/contracts/presentation/unit_history_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/tenants/presentation/tenants_overview_screen.dart';
import '../auth/auth_providers.dart';
import '../auth/firebase_auth_providers.dart';
import '../database/app_providers.dart';
import 'scaffold_with_nav.dart';

const _authFreeLocations = {
  '/cloud-login',
  '/onboarding',
  '/login',
  '/login/verify',
  '/login/create',
};

/// Relaie les changements des 4 flux d'authentification/onboarding à
/// GoRouter (`refreshListenable`) pour qu'il ré-évalue `redirect` sur
/// l'écran courant, SANS reconstruire tout le `GoRouter` (contrairement à
/// un `ref.watch` direct dans `appRouterProvider`, qui recréait un nouvel
/// objet GoRouter — et donc un nouveau Navigator, perdant la pile de
/// navigation en cours — à chaque changement ; c'est ce qui faisait que
/// "Commencer" sur l'onboarding semblait ne rien faire : le
/// `context.go('/login/create')` s'exécutait sur un router déjà obsolète
/// pendant la reconstruction).
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(Ref ref) {
    for (final provider in [
      firebaseSignedInProvider,
      onboardingDoneProvider,
      pinSetProvider,
      sessionAuthenticatedProvider,
    ]) {
      ref.listen(provider, (_, _) => notifyListeners());
    }
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _AuthRefreshNotifier(ref);
  ref.onDispose(refresh.dispose);

  bool firebaseSignedIn() => ref.read(firebaseSignedInProvider);
  bool onboardingDone() => ref.read(onboardingDoneProvider);
  bool pinSet() => ref.read(pinSetProvider);
  bool sessionAuthenticated() => ref.read(sessionAuthenticatedProvider);

  String initialLocation() {
    if (!firebaseSignedIn()) return '/cloud-login';
    if (!onboardingDone()) return '/onboarding';
    if (!pinSet()) return '/login/create';
    if (!sessionAuthenticated()) return '/login';
    return '/contracts';
  }

  return GoRouter(
    initialLocation: initialLocation(),
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (!firebaseSignedIn()) {
        return loc == '/cloud-login' ? null : '/cloud-login';
      }
      if (!onboardingDone()) {
        return loc == '/onboarding' ? null : '/onboarding';
      }
      if (!pinSet()) {
        return loc == '/login/create' ? null : '/login/create';
      }
      if (!sessionAuthenticated()) {
        if (loc == '/login' || loc == '/login/verify') return null;
        return '/login';
      }
      if (_authFreeLocations.contains(loc)) return '/contracts';
      return null;
    },
    routes: [
      GoRoute(
        path: '/cloud-login',
        builder: (context, state) => const CloudLoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/login/verify',
        builder: (context, state) => const PasscodeScreen(mode: PasscodeMode.verify),
      ),
      GoRoute(
        path: '/login/create',
        builder: (context, state) => const PasscodeScreen(mode: PasscodeMode.create),
      ),
      GoRoute(
        path: '/settings/change-pin',
        builder: (context, state) => const PasscodeScreen(mode: PasscodeMode.create),
      ),
      GoRoute(
        path: '/contracts/new',
        builder: (context, state) => ContractFormScreen(
          prefillUnitNumber: state.uri.queryParameters['unit'],
          replaceVacantId: state.uri.queryParameters['replace'],
        ),
      ),
      GoRoute(
        path: '/contracts/:id',
        builder: (context, state) =>
            ContractDetailScreen(contractId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/contracts/:id/edit',
        builder: (context, state) =>
            ContractFormScreen(contractId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/units/:unit/history',
        builder: (context, state) =>
            UnitHistoryScreen(unitNumber: state.pathParameters['unit']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            ScaffoldWithNav(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/contracts',
                builder: (context, state) => const ContractsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tenants',
                builder: (context, state) => const TenantsOverviewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const AnalyticsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
