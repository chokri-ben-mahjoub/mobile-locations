import 'package:flutter/material.dart';

import '../utils/format_utils.dart';

/// Montant qui « défile » jusqu'à sa valeur (et se ré-anime à chaque changement).
class AnimatedAmount extends StatelessWidget {
  final double value;
  final String currency;
  final TextStyle? style;
  final Duration duration;

  const AnimatedAmount({
    super.key,
    required this.value,
    required this.currency,
    this.style,
    this.duration = const Duration(milliseconds: 1100),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        FormatUtils.currency(v, currency),
        maxLines: 1,
        style: style?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Entier animé (compteurs, pourcentages).
class AnimatedInt extends StatelessWidget {
  final int value;
  final String suffix;
  final TextStyle? style;

  const AnimatedInt({
    super.key,
    required this.value,
    this.suffix = '',
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        '${v.round()}$suffix',
        style: style?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
