import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dsa_provider.dart';
import '../../providers/habits_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../widgets/habit_heatmap_painter.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsaState = ref.watch(dsaProvider);
    final tasksState = ref.watch(tasksProvider);
    final habits = ref.watch(habitsProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final solvedCount = dsaState.solvedCount;
    final completedTasks = tasksState.completedCount;
    final totalTasks = tasksState.tasks.length;
    final streakDays = user?.streakDays ?? 0;

    // Compute real intensities from user's habits (or 0.0 if empty)
    final intensities = List.generate(365, (i) {
      if (habits.isEmpty) return 0.0;
      // Index relative to last 30 days
      final dayOffset = 365 - 1 - i;
      if (dayOffset < 30) {
        int completedOnDay = 0;
        for (final h in habits) {
          final historyIdx = h.last30DaysHistory.length - 1 - dayOffset;
          if (historyIdx >= 0 &&
              historyIdx < h.last30DaysHistory.length &&
              h.last30DaysHistory[historyIdx]) {
            completedOnDay++;
          }
        }
        return habits.isEmpty ? 0.0 : (completedOnDay / habits.length).clamp(0.0, 1.0);
      }
      return 0.0;
    });

    final hasData = solvedCount > 0 || completedTasks > 0;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VELOCITY & TELEMETRY ANALYTICS',
                style: AppTypography.heading1),
            const SizedBox(height: 4),
            Text(
              'Real-time output velocity calculated from your verified tasks and DSA solutions.',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // Summary Metric Bar
            Row(
              children: [
                _buildMetricCard(
                  'Problems Solved',
                  '$solvedCount / ${dsaState.totalCount}',
                  AppColors.cyan,
                ),
                const SizedBox(width: 14),
                _buildMetricCard(
                  'Tasks Completed',
                  '$completedTasks / $totalTasks',
                  AppColors.amber,
                ),
                const SizedBox(width: 14),
                _buildMetricCard(
                  'Active Habits',
                  '${habits.length}',
                  AppColors.mint,
                ),
                const SizedBox(width: 14),
                _buildMetricCard(
                  'Consistency Streak',
                  '$streakDays Days',
                  AppColors.lavender,
                ),
              ],
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
                      Text('SOLVED VELOCITY TRAJECTORY',
                          style: AppTypography.heading2.copyWith(fontSize: 15)),
                      const Spacer(),
                      _buildLegend('Actual Solved', AppColors.cyan),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 200,
                    child: hasData
                        ? LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: [
                                    const FlSpot(0, 0),
                                    FlSpot(1, solvedCount.toDouble()),
                                  ],
                                  isCurved: false,
                                  color: AppColors.cyan,
                                  barWidth: 2.5,
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.show_chart_rounded,
                                    size: 32, color: AppColors.textSubtle),
                                const SizedBox(height: 10),
                                Text(
                                  'No velocity data logged yet.',
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.textMuted, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Solve Striver DSA problems or complete tasks to begin plotting your trajectory.',
                                  style: AppTypography.caption.copyWith(
                                      color: AppColors.textSubtle, fontSize: 11),
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
                  Text('365-DAY CONSISTENCY MATRIX',
                      style: AppTypography.heading2.copyWith(fontSize: 15)),
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
                border: Border.all(
                    color: AppColors.cyan.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed_rounded,
                          size: 18, color: AppColors.cyan),
                      const SizedBox(width: 8),
                      Text('SYSTEM STATUS',
                          style: AppTypography.heading2.copyWith(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hasData
                        ? 'Active execution verified across $solvedCount algorithmic problems and $completedTasks completed tasks.'
                        : 'Clean state. Ready for daily deep work, task execution, and algorithmic mastery.',
                    style: AppTypography.bodyMedium
                        .copyWith(color: AppColors.textMedium),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceTier1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: AppTypography.caption
                    .copyWith(color: AppColors.textMuted, fontSize: 11)),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.heading2
                  .copyWith(fontSize: 18, color: color),
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
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 6),
        Text(label,
            style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
      ],
    );
  }
}
