import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Fond des écrans plein cadre (connexion, onboarding, PIN) : halos de marque.
class GlowBackground extends StatelessWidget {
  final Widget child;

  const GlowBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: -170,
          left: -80,
          right: -80,
          height: 420,
          child: IgnorePointer(
            child: _Glow(color: accentColor.withValues(alpha: 0.32)),
          ),
        ),
        Positioned(
          bottom: -200,
          right: -140,
          width: 380,
          height: 380,
          child: IgnorePointer(
            child: _Glow(color: goldColor.withValues(alpha: 0.12)),
          ),
        ),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;

  const _Glow({required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
