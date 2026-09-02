import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/calendar_event.dart';
import '../../providers/calendar_provider.dart';

class CalendarView extends ConsumerWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calState = ref.watch(calendarProvider);
    final calNotifier = ref.read(calendarProvider.notifier);
    final todayBlocks = calState.todayBlocks;

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
                    Text('TIME-BLOCKING & DAILY AGENDA', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Dedicated cognitive reservations protecting Deep Work flow states.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier1,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    'Today: 5 Blocks  |  5.5h Reserved',
                    style: AppTypography.monoBadge.copyWith(color: AppColors.cyan),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Timeline Blocks View
            ...todayBlocks.map((block) {
              Color blockColor;
              Color blockBg;
              switch (block.type) {
                case CalendarBlockType.deepWork:
                  blockColor = AppColors.cyan;
                  blockBg = AppColors.cyanBg;
                  break;
                case CalendarBlockType.studyCohort:
                  blockColor = AppColors.lavender;
                  blockBg = AppColors.lavenderBg;
                  break;
                case CalendarBlockType.habitRoutine:
                  blockColor = AppColors.mint;
                  blockBg = AppColors.mintBg;
                  break;
                case CalendarBlockType.meeting:
                  blockColor = AppColors.amber;
                  blockBg = AppColors.amberBg;
                  break;
                case CalendarBlockType.recovery:
                  blockColor = AppColors.rose;
                  blockBg = AppColors.roseBg;
                  break;
              }

              final startHour = block.startTime.hour.toString().padLeft(2, '0');
              final startMin = block.startTime.minute.toString().padLeft(2, '0');
              final endHour = block.endTime.hour.toString().padLeft(2, '0');
              final endMin = block.endTime.minute.toString().padLeft(2, '0');

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier1,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: block.isCompleted ? AppColors.mint.withValues(alpha: 0.3) : blockColor.withValues(alpha: 0.3),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  children: [
                    // Time Badge
                    Container(
                      width: 110,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: blockBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: blockColor.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          '$startHour:$startMin - $endHour:$endMin',
                          style: AppTypography.monoBadge.copyWith(color: blockColor, fontSize: 11),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            block.title,
                            style: AppTypography.heading2.copyWith(
                              fontSize: 16,
                              decoration: block.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(block.subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTier2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${block.durationMinutes} min',
                        style: AppTypography.monoBadge.copyWith(fontSize: 10, color: AppColors.textMedium),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: Icon(
                        block.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        color: block.isCompleted ? AppColors.mint : AppColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => calNotifier.toggleBlockCompleted(block.id),
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
