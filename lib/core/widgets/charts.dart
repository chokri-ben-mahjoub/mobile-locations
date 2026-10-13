import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Anneau de progression animé (0..1) avec contenu central.
class ProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final double stroke;
  final Color color;
  final Color trackColor;
  final Widget? center;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.color,
    required this.trackColor,
    this.size = 84,
    this.stroke = 9,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _RingPainter(v, stroke, color, trackColor),
          child: center == null ? null : Center(child: center),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final double stroke;
  final Color color;
  final Color track;

  _RingPainter(this.progress, this.stroke, this.color, this.track);

  @override
  void paint(Canvas canvas, Size size) {
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = track;
    canvas.drawArc(rect, 0, math.pi * 2, false, base);
    if (progress <= 0) return;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color || old.track != track;
}

class BarDatum {
  final String label;
  final double expected;
  final double collected;
  const BarDatum(this.label, this.expected, this.collected);
}

/// Histogramme 12 mois : barre pâle = attendu, barre pleine = encaissé.
/// Toucher une barre la sélectionne et remonte son index.
class MonthlyBarChart extends StatefulWidget {
  final List<BarDatum> data;
  final Color color;
  final Color trackColor;
  final Color labelColor;
  final double height;
  final int? selected;
  final ValueChanged<int> onSelect;

  const MonthlyBarChart({
    super.key,
    required this.data,
    required this.color,
    required this.trackColor,
    required this.labelColor,
    required this.onSelect,
    this.selected,
    this.height = 170,
  });

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _pick(Offset local, double width) {
    final slot = width / widget.data.length;
    final i = (local.dx / slot).floor().clamp(0, widget.data.length - 1);
    HapticFeedback.selectionClick();
    widget.onSelect(i);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (d) => _pick(d.localPosition, box.maxWidth),
        child: AnimatedBuilder(
          animation: CurvedAnimation(parent: _c, curve: Curves.easeOutCubic),
          builder: (context, _) => SizedBox(
            height: widget.height,
            width: double.infinity,
            child: CustomPaint(
              painter: _BarPainter(
                data: widget.data,
                t: Curves.easeOutCubic.transform(_c.value),
                color: widget.color,
                track: widget.trackColor,
                label: widget.labelColor,
                selected: widget.selected,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final List<BarDatum> data;
  final double t;
  final Color color;
  final Color track;
  final Color label;
  final int? selected;

  _BarPainter({
    required this.data,
    required this.t,
    required this.color,
    required this.track,
    required this.label,
    required this.selected,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    const labelH = 22.0;
    final chartH = size.height - labelH;
    final maxV = data.fold<double>(
      1,
      (m, d) => math.max(m, math.max(d.expected, d.collected)),
    );
    final slot = size.width / data.length;
    final barW = math.min(slot * 0.62, 22.0);

    for (var i = 0; i < data.length; i++) {
      final d = data[i];
      final cx = slot * i + slot / 2;
      final isSel = selected == i;
      final dim = selected != null && !isSel;

      final expH = d.expected / maxV * chartH;
      final colH = d.collected / maxV * chartH * t;

      final expRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - barW / 2, chartH - expH, barW, math.max(expH, 3)),
        const Radius.circular(8),
      );
      canvas.drawRRect(expRect, Paint()..color = track);

      if (colH > 0.5) {
        final colRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(cx - barW / 2, chartH - colH, barW, colH),
          const Radius.circular(8),
        );
        canvas.drawRRect(
          colRect,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: dim ? 0.35 : 1),
                color.withValues(alpha: dim ? 0.2 : 0.6),
              ],
            ).createShader(colRect.outerRect),
        );
      }

      final tp = TextPainter(
        text: TextSpan(
          text: d.label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
            color: isSel ? color : label,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, chartH + 8));
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) =>
      old.t != t ||
      old.selected != selected ||
      old.data != data ||
      old.color != color;
}

/// Jauge linéaire fine (ex. progression d'un bail).
class ThinProgress extends StatelessWidget {
  final double value;
  final Color color;
  final Color track;
  final double height;

  const ThinProgress({
    super.key,
    required this.value,
    required this.color,
    required this.track,
    this.height = 5,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: Stack(
          children: [
            Container(height: height, color: track),
            FractionallySizedBox(
              widthFactor: v,
              child: Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withValues(alpha: 0.6), color],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
