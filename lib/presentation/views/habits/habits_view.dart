import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/habit.dart';
import '../../providers/habits_provider.dart';

class HabitsView extends ConsumerWidget {
  const HabitsView({super.key});

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    HabitFrequency selectedFreq = HabitFrequency.dailyMorning;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (dialogCtx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: 420,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderActive),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.mintBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.repeat_rounded,
                            size: 16, color: AppColors.mint),
                      ),
                      const SizedBox(width: 10),
                      Text('Create Habit',
                          style: AppTypography.heading2.copyWith(fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            size: 18, color: AppColors.textMuted),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text('Habit Title',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMedium)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: TextField(
                      controller: titleCtrl,
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Solve 1 DSA Problem before 9 AM',
                        hintStyle: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Frequency Routine',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMedium)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: DropdownButton<HabitFrequency>(
                      value: selectedFreq,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      dropdownColor: AppColors.surfaceTier2,
                      items: HabitFrequency.values.map((f) {
                        return DropdownMenuItem(
                          value: f,
                          child: Text(
                            f.name == 'dailyMorning'
                                ? 'Daily Morning'
                                : f.name == 'dailyEvening'
                                    ? 'Daily Evening'
                                    : 'Weekly Vector',
                            style: AppTypography.caption,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => selectedFreq = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text('Cancel',
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textMuted)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) return;

                          ref.read(habitsProvider.notifier).addHabit(
                                Habit(
                                  id: 'h-${DateTime.now().millisecondsSinceEpoch}',
                                  title: title,
                                  frequency: selectedFreq,
                                  consistencyScore: 100.0,
                                  isCompletedToday: false,
                                  last30DaysHistory: [],
                                ),
                              );
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan),
                        child: Text(
                          'CREATE HABIT',
                          style: AppTypography.monoBadge.copyWith(
                            color: const Color(0xFF0B0D13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitsProvider);
    final habitsNotifier = ref.read(habitsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HABIT CONSISTENCY & INTEGRITY',
                        style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Identity votes measured by daily execution consistency.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddHabitDialog(context, ref),
                  icon: const Icon(Icons.add_rounded,
                      size: 16, color: Color(0xFF0B0D13)),
                  label: Text(
                    'ADD HABIT',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF0B0D13),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Habits List or Clean Empty State
            if (habits.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Container(
                    width: 480,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier1,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.repeat_rounded,
                            size: 42, color: AppColors.textSubtle),
                        const SizedBox(height: 14),
                        Text('No active habits',
                            style: AppTypography.heading2.copyWith(fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(
                          'Create daily consistency habits to build identity momentum and track daily completion.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _showAddHabitDialog(context, ref),
                          icon: const Icon(Icons.add_rounded,
                              size: 16, color: Color(0xFF0B0D13)),
                          label: Text(
                            'ADD FIRST HABIT',
                            style: AppTypography.monoBadge.copyWith(
                              color: const Color(0xFF0B0D13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else ...[
              Text('ACTIVE HABITS (${habits.length})',
                  style: AppTypography.heading2.copyWith(fontSize: 15)),
              const SizedBox(height: 12),
              ...habits.map((habit) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
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
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: habit.isCompletedToday
                                ? AppColors.mint
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: habit.isCompletedToday
                                  ? AppColors.mint
                                  : AppColors.borderActive,
                              width: 1.5,
                            ),
                          ),
                          child: habit.isCompletedToday
                              ? const Icon(Icons.check,
                                  size: 16, color: Color(0xFF0B0D13))
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
                                color: habit.isCompletedToday
                                    ? AppColors.textMuted
                                    : AppColors.textHigh,
                                decoration: habit.isCompletedToday
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Routine: ${habit.frequency.name == 'dailyMorning' ? 'Daily Morning' : habit.frequency.name == 'dailyEvening' ? 'Daily Evening' : 'Weekly'}',
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded,
                            size: 18, color: AppColors.textSubtle),
                        onPressed: () {
                          habitsNotifier.deleteHabit(habit.id);
                        },
                        tooltip: 'Delete Habit',
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}
