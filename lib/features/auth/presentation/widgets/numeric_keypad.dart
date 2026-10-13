import 'package:flutter/material.dart';

import '../../../../core/widgets/pressable.dart';

class NumericKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final bool compact;

  const NumericKeypad({
    super.key,
    this.compact = false,
    required this.onDigit,
    required this.onBackspace,
    this.onBiometric,
  });

  @override
  Widget build(BuildContext context) {
    final keySize = compact ? 62.0 : 76.0;
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 330),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in rows)
            Padding(
              padding: EdgeInsets.symmetric(vertical: compact ? 4 : 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final d in row) _Key(label: d, size: keySize, onTap: () => onDigit(d)),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: compact ? 4 : 7),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (onBiometric != null)
                  _Key(
                    icon: Icons.fingerprint_rounded,
                    accent: true,
                    size: keySize,
                    onTap: onBiometric!,
                  )
                else
                  SizedBox(width: keySize, height: keySize),
                _Key(label: '0', size: keySize, onTap: () => onDigit('0')),
                _Key(icon: Icons.backspace_outlined, size: keySize, onTap: onBackspace),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Key extends StatelessWidget {
  final double size;
  final String? label;
  final IconData? icon;
  final bool accent;
  final VoidCallback onTap;

  const _Key({
    this.label,
    this.icon,
    this.accent = false,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDigit = label != null;

    return Pressable(
      onTap: onTap,
      pressedScale: 0.9,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDigit ? scheme.surfaceContainerLow : Colors.transparent,
          border: isDigit
              ? Border.all(color: scheme.outlineVariant.withValues(alpha: 0.35))
              : null,
          boxShadow: isDigit
              ? [
                  BoxShadow(
                    color: scheme.shadow.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: isDigit
            ? Text(
                label!,
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              )
            : Icon(
                icon,
                size: accent ? 32 : 24,
                color: accent ? scheme.primary : scheme.onSurfaceVariant,
              ),
      ),
    );
  }
}
