import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class ConcentricRingsWidget extends StatelessWidget {
  final double focusProgress; // 0.0 to 1.0 (e.g. 3.5h / 5.0h = 0.70)
  final double habitProgress; // 0.0 to 1.0 (e.g. 4/4 = 1.0)
  final double velocityProgress; // 0.0 to 1.0 (e.g. 0.85)
  final double size;

  const ConcentricRingsWidget({
    super.key,
    required this.focusProgress,
    required this.habitProgress,
    required this.velocityProgress,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size, size),
        painter: _ConcentricRingsPainter(
          focusProgress: focusProgress.clamp(0.0, 1.0),
          habitProgress: habitProgress.clamp(0.0, 1.0),
          velocityProgress: velocityProgress.clamp(0.0, 1.0),
        ),
      ),
    );
  }
}

class _ConcentricRingsPainter extends CustomPainter {
  final double focusProgress;
  final double habitProgress;
  final double velocityProgress;

  _ConcentricRingsPainter({
    required this.focusProgress,
    required this.habitProgress,
    required this.velocityProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const strokeWidth = 7.0;
    const gap = 3.5;

    final outerRadius = (size.width / 2) - (strokeWidth / 2);
    final middleRadius = outerRadius - strokeWidth - gap;
    final innerRadius = middleRadius - strokeWidth - gap;

    _drawRing(canvas, center, outerRadius, strokeWidth, AppColors.amberBg,
        AppColors.amber, focusProgress);
    _drawRing(canvas, center, middleRadius, strokeWidth, AppColors.mintBg,
        AppColors.mint, habitProgress);
    _drawRing(canvas, center, innerRadius, strokeWidth, AppColors.cyanBg,
        AppColors.cyan, velocityProgress);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double strokeWidth,
      Color trackColor, Color progressColor, double progress) {
    // Draw background track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    if (progress <= 0.0) return;

    // Draw active arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ConcentricRingsPainter oldDelegate) {
    return oldDelegate.focusProgress != focusProgress ||
        oldDelegate.habitProgress != habitProgress ||
        oldDelegate.velocityProgress != velocityProgress;
  }
}
