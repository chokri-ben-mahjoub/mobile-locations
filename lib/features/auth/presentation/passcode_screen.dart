import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/auth/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glow_background.dart';
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
    HapticFeedback.heavyImpact();
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
    final canUseBiometric = widget.mode == PasscodeMode.verify && biometricEnabled;
    final hasError = _error != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      body: GlowBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) {
              final compact = box.maxHeight < 640;
              final iconSize = compact ? 60.0 : 76.0;

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: box.maxHeight),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          SizedBox(height: compact ? 44 : kToolbarHeight),
                          Container(
                            width: iconSize,
                            height: iconSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  accentColor.withValues(alpha: 0.28),
                                  accentColor.withValues(alpha: 0.08),
                                ],
                              ),
                              border: Border.all(color: accentColor.withValues(alpha: 0.25)),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.25),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                              child: Icon(
                                _confirmStage
                                    ? Icons.verified_user_outlined
                                    : Icons.lock_outline_rounded,
                                key: ValueKey(_confirmStage),
                                color: accentColor,
                                size: iconSize * 0.45,
                              ),
                            ),
                          ),
                          SizedBox(height: compact ? 14 : 22),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Text(
                              _title,
                              key: ValueKey(_title),
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.6,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _subtitle,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                          ),
                          SizedBox(height: compact ? 18 : 32),
                          AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) {
                              final t = _shakeController.value;
                              final offset = (t == 0)
                                  ? 0.0
                                  : (16 * (1 - t)) * ((t * 10).floor().isEven ? 1 : -1);
                              return Transform.translate(offset: Offset(offset, 0), child: child);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < _pinLength; i++)
                                  _PinDot(
                                    filled: i < _digits.length,
                                    error: hasError,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 20,
                            child: _error != null
                                ? Text(
                                    _error!,
                                    style: TextStyle(
                                      color: scheme.error,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                : null,
                          ),
                          const Spacer(),
                          NumericKeypad(
                            compact: compact,
                            onDigit: _onDigit,
                            onBackspace: _onBackspace,
                            onBiometric: canUseBiometric ? _useBiometric : null,
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PinDot extends StatelessWidget {
  final bool filled;
  final bool error;

  const _PinDot({required this.filled, required this.error});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = filled ? 20.0 : 16.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: const EdgeInsets.symmetric(horizontal: 9),
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? accentColor : scheme.surfaceContainerHigh,
        border: Border.all(
          color: error
              ? scheme.error
              : filled
                  ? accentColor
                  : scheme.outlineVariant,
          width: error ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: filled ? 0.45 : 0),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}
