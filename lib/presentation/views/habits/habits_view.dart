import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/habits_provider.dart';
import '../../widgets/habit_heatmap_painter.dart';

class HabitsView extends ConsumerWidget {
  const HabitsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final habitsNotifier = ref.read(habitsProvider.notifier);

    // Mock 365-day intensity data
    final intensities = List.generate(365, (i) {
      if (i % 7 == 0) return 0.2;
      if (i % 5 == 0) return 0.5;
      if (i % 3 == 0) return 0.8;
      return 1.0;
    });

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('HABIT CONSISTENCY & INTEGRITY VECTORS', style: AppTypography.heading1),
            const SizedBox(height: 4),
            Text(
              'Identity votes measured by rolling 30-day resilience rather than fragile streaks.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),

            // 365-Day Activity Heatmap Container
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
                  Row(
                    children: [
                      Text('365-DAY EXECUTION MATRIX', style: AppTypography.heading2),
                      const Spacer(),
                      Text('Consistency: 94.8% Year-to-Date',
                          style: AppTypography.monoBadge.copyWith(color: AppColors.mint)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  HabitHeatmapWidget(dailyIntensities: intensities),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Daily Habits List
            Text('ACTIVE IDENTITY HABITS', style: AppTypography.heading2),
            const SizedBox(height: 12),
            ...habits.map((habit) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier1,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: habit.isCompletedToday
                        ? AppColors.mint.withValues(alpha: 0.3)
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => habitsNotifier.toggleHabitToday(habit.id),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: habit.isCompletedToday ? AppColors.mint : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: habit.isCompletedToday ? AppColors.mint : AppColors.borderActive,
                            width: 1.5,
                          ),
                        ),
                        child: habit.isCompletedToday
                            ? const Icon(Icons.check, size: 18, color: Color(0xFF0B0D13))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: AppTypography.bodyLarge.copyWith(
                              color: habit.isCompletedToday ? AppColors.textMuted : AppColors.textHigh,
                              decoration: habit.isCompletedToday ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Frequency: ${habit.frequency.name}  |  30-Day Resilience: ${habit.consistencyScore}%',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: habit.consistencyScore > 90 ? AppColors.mintBg : AppColors.amberBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${habit.consistencyScore}% VECTOR',
                        style: AppTypography.monoBadge.copyWith(
                          color: habit.consistencyScore > 90 ? AppColors.mint : AppColors.amber,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
