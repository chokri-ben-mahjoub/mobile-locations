import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/passcode_screen.dart';
import '../../features/contracts/presentation/contract_detail_screen.dart';
import '../../features/contracts/presentation/contract_form_screen.dart';
import '../../features/contracts/presentation/contracts_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../auth/auth_providers.dart';
import '../database/app_providers.dart';
import 'scaffold_with_nav.dart';

const _authFreeLocations = {'/onboarding', '/login', '/login/verify', '/login/create'};

final appRouterProvider = Provider<GoRouter>((ref) {
  final onboardingDone = ref.watch(onboardingDoneProvider);
  final pinSet = ref.watch(pinSetProvider);
  final sessionAuthenticated = ref.watch(sessionAuthenticatedProvider);

  String initialLocation() {
    if (!onboardingDone) return '/onboarding';
    if (!pinSet) return '/login/create';
    if (!sessionAuthenticated) return '/login';
    return '/contracts';
  }

  return GoRouter(
    initialLocation: initialLocation(),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      if (!onboardingDone) {
        return loc == '/onboarding' ? null : '/onboarding';
      }
      if (!pinSet) {
        return loc == '/login/create' ? null : '/login/create';
      }
      if (!sessionAuthenticated) {
        if (loc == '/login' || loc == '/login/verify') return null;
        return '/login';
      }
      if (_authFreeLocations.contains(loc)) return '/contracts';
      return null;
    },
    routes: [
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
        builder: (context, state) => const ContractFormScreen(),
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
