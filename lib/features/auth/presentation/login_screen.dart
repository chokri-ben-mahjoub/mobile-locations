import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryBiometricIfEnabled());
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
      setState(() {
        _checking = false;
        _error = 'Biométrie non configurée sur cet appareil.';
      });
      return;
    }
    final success = await biometricService.authenticate();
    if (!mounted) return;
    setState(() => _checking = false);
    if (success) {
      ref.read(sessionAuthenticatedProvider.notifier).state = true;
    } else {
      setState(() => _error = 'Authentification biométrique annulée.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          child: Column(
            children: [
              const _Brand(),
              const SizedBox(height: 8),
              Text(
                'Gestion des contrats de location',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28),
              const FeatureCarousel(
                accentColor: accentColor,
                slides: [
                  CarouselSlide(
                    icon: Icons.description_outlined,
                    title: 'Tous vos contrats au même endroit',
                    subtitle:
                        'Locataires, loyers, dates et compteurs en un coup d\'œil.',
                  ),
                  CarouselSlide(
                    icon: Icons.notifications_active_outlined,
                    title: 'Rappels avant expiration',
                    subtitle:
                        'Soyez alerté automatiquement avant la fin de chaque bail.',
                  ),
                  CarouselSlide(
                    icon: Icons.bar_chart_rounded,
                    title: 'Vue d\'ensemble des loyers',
                    subtitle:
                        'Suivez le revenu locatif total et les échéances à venir.',
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
                  label: const Text(
                    'Se connecter avec biométrie',
                    style: TextStyle(fontWeight: FontWeight.w600),
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
                  child: const Text(
                    'Se connecter via PassCode',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
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
          child: const Icon(Icons.apartment_outlined, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
            children: [
              TextSpan(
                text: 'Loca',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
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
