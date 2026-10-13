import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Carte « héros » : dégradé de marque + halos lumineux décoratifs.
class AuroraCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  const AuroraCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.radius = 30,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Palette fixe (indépendante du thème) : le texte blanc reste toujours lisible.
    final top = dark ? const Color(0xFF1F6F78) : const Color(0xFF2A8A94);
    final deep = dark ? const Color(0xFF0A2A30) : const Color(0xFF0F3F46);
    const glow = Color(0xFF7CF5E4);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: dark ? 0.25 : 0.38),
            blurRadius: 36,
            offset: const Offset(0, 18),
            spreadRadius: -6,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [top, deep],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -60,
              top: -70,
              child: _Glow(color: glow.withValues(alpha: 0.4), size: 230),
            ),
            Positioned(
              left: -70,
              bottom: -90,
              child: _Glow(
                color: const Color(0xFFFFC857).withValues(alpha: 0.22),
                size: 240,
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final Color color;
  final double size;

  const _Glow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
