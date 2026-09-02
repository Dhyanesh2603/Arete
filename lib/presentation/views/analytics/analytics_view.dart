import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../widgets/habit_heatmap_painter.dart';

class AnalyticsView extends StatelessWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final intensities = List.generate(365, (i) {
      if (i % 7 == 0) return 0.3;
      if (i % 4 == 0) return 0.6;
      return 0.95;
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('LIFE TELEMETRY & VELOCITY ANALYTICS', style: AppTypography.heading1),
            const SizedBox(height: 4),
            Text(
              'Objective telemetry answering: What is my velocity and what is blocking my ambitions?',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // Velocity Burn-Up Chart
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('VELOCITY VS TARGET TRAJECTORY', style: AppTypography.heading2),
                      const Spacer(),
                      _buildLegend('Actual Solved', AppColors.cyan),
                      const SizedBox(width: 14),
                      _buildLegend('Target Trajectory', AppColors.lavender),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          // Actual Solved Line
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 5),
                              FlSpot(1, 12),
                              FlSpot(2, 18),
                              FlSpot(3, 24),
                              FlSpot(4, 35),
                              FlSpot(5, 48),
                            ],
                            isCurved: true,
                            color: AppColors.cyan,
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                          ),
                          // Target Planned Line
                          LineChartBarData(
                            spots: const [
                              FlSpot(0, 5),
                              FlSpot(1, 10),
                              FlSpot(2, 18),
                              FlSpot(3, 26),
                              FlSpot(4, 34),
                              FlSpot(5, 42),
                            ],
                            isCurved: true,
                            color: AppColors.lavender.withValues(alpha: 0.5),
                            barWidth: 2,
                            dashArray: [5, 5],
                            dotData: const FlDotData(show: false),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 365-Day Consistency Heatmap
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('365-DAY CONSISTENCY MATRIX', style: AppTypography.heading2),
                  const SizedBox(height: 16),
                  HabitHeatmapWidget(dailyIntensities: intensities),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Friction Radar
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.rose.withValues(alpha: 0.25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.radar_rounded, size: 18, color: AppColors.rose),
                      const SizedBox(width: 8),
                      Text('FRICTION & BOTTLENECK RADAR', style: AppTypography.heading2),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No critical path blockers detected. Velocity across Trees and Binary Search is +14% above projected baseline.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.mint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 3,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}
