import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
import 'widgets/numeric_keypad.dart';

enum PasscodeMode { create, verify }

const _pinLength = 4;

class PasscodeScreen extends ConsumerStatefulWidget {
  final PasscodeMode mode;

  const PasscodeScreen({super.key, required this.mode});

  @override
  ConsumerState<PasscodeScreen> createState() => _PasscodeScreenState();
}

class _PasscodeScreenState extends ConsumerState<PasscodeScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _digits = [];
  String? _firstPin;
  bool _confirmStage = false;
  String? _error;
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  String get _title {
    if (widget.mode == PasscodeMode.verify) return 'Entrez votre code';
    return _confirmStage ? 'Confirmez votre code' : 'Créez votre code';
  }

  String get _subtitle {
    if (widget.mode == PasscodeMode.verify) {
      return 'Saisissez votre PassCode à $_pinLength chiffres';
    }
    return _confirmStage
        ? 'Ressaisissez le même code pour confirmer'
        : 'Ce code vous permettra de déverrouiller LocaTrack';
  }

  void _onDigit(String d) {
    if (_digits.length >= _pinLength) return;
    setState(() {
      _digits.add(d);
      _error = null;
    });
    if (_digits.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 120), _onComplete);
    }
  }

  void _onBackspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits.removeLast());
  }

  Future<void> _shake() async {
    await _shakeController.forward(from: 0);
  }

  Future<void> _onComplete() async {
    final entered = _digits.join();

    if (widget.mode == PasscodeMode.verify) {
      final valid = ref.read(pinControllerProvider.notifier).verify(entered);
      if (valid) {
        ref.read(sessionAuthenticatedProvider.notifier).state = true;
      } else {
        await _shake();
        setState(() {
          _error = 'Code incorrect, réessayez.';
          _digits.clear();
        });
      }
      return;
    }

    // Mode création
    if (!_confirmStage) {
      setState(() {
        _firstPin = entered;
        _confirmStage = true;
        _digits.clear();
      });
      return;
    }

    if (entered == _firstPin) {
      await ref.read(pinControllerProvider.notifier).setPin(entered);
      ref.read(sessionAuthenticatedProvider.notifier).state = true;
    } else {
      await _shake();
      setState(() {
        _error = 'Les codes ne correspondent pas, recommencez.';
        _confirmStage = false;
        _firstPin = null;
        _digits.clear();
      });
    }
  }

  Future<void> _useBiometric() async {
    final available = await biometricService.isAvailable;
    if (!available || !mounted) return;
    final success = await biometricService.authenticate();
    if (success && mounted) {
      ref.read(sessionAuthenticatedProvider.notifier).state = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final biometricEnabled = ref.watch(biometricEnabledProvider);
    final canUseBiometric =
        widget.mode == PasscodeMode.verify && biometricEnabled;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline, color: accentColor, size: 30),
              ),
              const SizedBox(height: 20),
              Text(
                _title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                _subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  final t = _shakeController.value;
                  final offset = (t == 0) ? 0.0 : (16 * (1 - t)) * ((t * 10).floor().isEven ? 1 : -1);
                  return Transform.translate(offset: Offset(offset, 0), child: child);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < _pinLength; i++)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < _digits.length
                              ? accentColor
                              : scheme.surfaceContainerHigh,
                          border: Border.all(
                            color: i < _digits.length
                                ? accentColor
                                : scheme.outlineVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 20,
                child: _error != null
                    ? Text(
                        _error!,
                        style: TextStyle(color: scheme.error, fontSize: 13),
                      )
                    : null,
              ),
              const Spacer(),
              NumericKeypad(
                onDigit: _onDigit,
                onBackspace: _onBackspace,
                onBiometric: canUseBiometric ? _useBiometric : null,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
