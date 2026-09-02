import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HabitHeatmapWidget extends StatelessWidget {
  final List<double> dailyIntensities; // 364 or 371 intensity values (0.0 to 1.0)
  final double cellSize;
  final double cellSpacing;

  const HabitHeatmapWidget({
    super.key,
    required this.dailyIntensities,
    this.cellSize = 11.0,
    this.cellSpacing = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    const weeks = 52;
    const daysPerWeek = 7;
    final totalWidth = (weeks * cellSize) + ((weeks - 1) * cellSpacing);
    final totalHeight = (daysPerWeek * cellSize) + ((daysPerWeek - 1) * cellSpacing);

    return RepaintBoundary(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: CustomPaint(
          size: Size(totalWidth, totalHeight),
          painter: _HabitHeatmapPainter(
            dailyIntensities: dailyIntensities,
            cellSize: cellSize,
            cellSpacing: cellSpacing,
          ),
        ),
      ),
    );
  }
}

class _HabitHeatmapPainter extends CustomPainter {
  final List<double> dailyIntensities;
  final double cellSize;
  final double cellSpacing;

  _HabitHeatmapPainter({
    required this.dailyIntensities,
    required this.cellSize,
    required this.cellSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const weeks = 52;
    const daysPerWeek = 7;

    for (int week = 0; week < weeks; week++) {
      for (int day = 0; day < daysPerWeek; day++) {
        final index = (week * daysPerWeek) + day;
        final intensity = index < dailyIntensities.length ? dailyIntensities[index] : 0.0;

        final x = week * (cellSize + cellSpacing);
        final y = day * (cellSize + cellSpacing);
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, cellSize, cellSize),
          const Radius.circular(2.5),
        );

        final cellColor = _getColorForIntensity(intensity);
        final paint = Paint()..color = cellColor;
        canvas.drawRRect(rect, paint);
      }
    }
  }

  Color _getColorForIntensity(double intensity) {
    if (intensity <= 0.0) return const Color(0xFF141824);
    if (intensity < 0.3) return AppColors.mintBg;
    if (intensity < 0.6) return const Color(0xFF059669);
    if (intensity < 0.85) return const Color(0xFF10B981);
    return AppColors.mint; // Full Phosphor Mint
  }

  @override
  bool shouldRepaint(covariant _HabitHeatmapPainter oldDelegate) {
    return oldDelegate.dailyIntensities != dailyIntensities;
  }
}
