import 'package:flutter/material.dart';

/// Squelette de chargement avec reflet animé.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 18,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.surfaceContainerHigh;
    final highlight = scheme.surfaceContainerHighest.withValues(alpha: 0.9);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final t = _c.value;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1.5 + 3 * t, 0),
              end: Alignment(-0.5 + 3 * t, 0),
              colors: [base, highlight, base],
            ),
          ),
        );
      },
    );
  }
}

class ContractsSkeleton extends StatelessWidget {
  const ContractsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 16,
        16,
        16,
      ),
      children: const [
        ShimmerBox(height: 40, radius: 14),
        SizedBox(height: 18),
        ShimmerBox(height: 190, radius: 30),
        SizedBox(height: 18),
        ShimmerBox(height: 52, radius: 26),
        SizedBox(height: 16),
        ShimmerBox(height: 76),
        SizedBox(height: 12),
        ShimmerBox(height: 76),
        SizedBox(height: 12),
        ShimmerBox(height: 76),
      ],
    );
  }
}
