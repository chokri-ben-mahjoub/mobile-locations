import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locations_app/l10n/app_localizations.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glow_background.dart';
import '../../../core/widgets/language_switcher.dart';
import 'widgets/feature_carousel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _checking = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _tryBiometricIfEnabled(),
    );
  }

  Future<void> _tryBiometricIfEnabled() async {
    final biometricEnabled = ref.read(biometricEnabledProvider);
    if (!biometricEnabled) return;
    final available = await biometricService.isAvailable;
    if (!available || !mounted) return;
    await _authenticateWithBiometrics();
  }

  Future<void> _authenticateWithBiometrics() async {
    setState(() {
      _checking = true;
      _error = null;
    });
    final available = await biometricService.isAvailable;
    if (!available) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _error = AppLocalizations.of(context).biometricNotConfigured;
      });
      return;
    }
    final success = await biometricService.authenticate();
    if (!mounted) return;
    setState(() => _checking = false);
    if (success) {
      ref.read(sessionAuthenticatedProvider.notifier).state = true;
      // Navigation explicite plutôt que de compter uniquement sur le
      // routeur pour réagir au changement d'état — voir le même
      // correctif sur le code PassCode et l'onboarding.
      context.go('/contracts');
    } else {
      setState(() => _error = AppLocalizations.of(context).biometricCancelled);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: GlowBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: Column(
                  children: [
                    const _Brand(),
                const SizedBox(height: 8),
                Text(
                  l10n.appTagline,
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 28),
                FeatureCarousel(
                  slides: [
                    CarouselSlide(
                      icon: Icons.description_outlined,
                      title: l10n.loginSlide1Title,
                      subtitle: l10n.loginSlide1Subtitle,
                    ),
                    CarouselSlide(
                      icon: Icons.notifications_active_outlined,
                      title: l10n.loginSlide2Title,
                      subtitle: l10n.loginSlide2Subtitle,
                    ),
                    CarouselSlide(
                      icon: Icons.bar_chart_rounded,
                      title: l10n.loginSlide3Title,
                      subtitle: l10n.loginSlide3Subtitle,
                    ),
                  ],
                ),
                const Spacer(),
                if (_error != null) ...[
                  Text(
                    _error!,
                    style: TextStyle(color: scheme.error, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _checking ? null : _authenticateWithBiometrics,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: _checking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.fingerprint),
                    label: Text(
                      l10n.signInWithBiometrics,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () => context.push('/login/verify'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.onSurface,
                      side: BorderSide(color: scheme.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      l10n.signInWithPasscode,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                  ],
                ),
              ),
              const Positioned(top: 0, right: 0, child: LanguageIconButton()),
            ],
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accentColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.apartment_outlined,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: 'Loca',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const TextSpan(
                text: 'Track',
                style: TextStyle(color: accentColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
