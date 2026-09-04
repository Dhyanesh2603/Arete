import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/flight_plan_provider.dart';

class DailyFlightPlanCard extends ConsumerWidget {
  const DailyFlightPlanCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flightPlan = ref.watch(flightPlanProvider);
    final notifier = ref.read(flightPlanProvider.notifier);

    final totalMinutes = flightPlan.totalEstimatedMinutes;
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    final timeFormatted = hours > 0 ? '${hours}h ${mins}m' : '${mins}m';

    final nextItem = flightPlan.nextItem;
    final allComplete = flightPlan.totalCount > 0 && flightPlan.completedCount == flightPlan.totalCount;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.cyanBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.flight_takeoff_rounded, size: 16, color: AppColors.cyan),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'TODAY\'S FLIGHT PLAN',
                        style: AppTypography.heading2.copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTier2,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          'ADAPTIVE SEQUENCE',
                          style: AppTypography.monoBadge.copyWith(fontSize: 9, color: AppColors.textMedium),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Zero-decision sequence: SM-2 spaced revision + top matrix priorities.',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
              const Spacer(),

              // Planned Target Time pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      '$timeFormatted Planned',
                      style: AppTypography.caption.copyWith(color: AppColors.textMedium, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Master "Execute Flight Plan" CTA
              if (!allComplete && nextItem != null)
                ElevatedButton.icon(
                  onPressed: () => notifier.executeFlightPlan(context),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16, color: Color(0xFF09090B)),
                  label: Text(
                    'EXECUTE FLIGHT PLAN',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF09090B),
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mintBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.mint),
                      const SizedBox(width: 6),
                      Text(
                        'FLIGHT PLAN COMPLETE',
                        style: AppTypography.monoBadge.copyWith(color: AppColors.mint, fontSize: 10),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: flightPlan.progress,
              backgroundColor: AppColors.surfaceTier2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 16),

          // Sequential Steps
          Column(
            children: List.generate(flightPlan.items.length, (index) {
              final item = flightPlan.items[index];
              final isCompleted = flightPlan.completedIds.contains(item.id);
              final isCurrent = nextItem?.id == item.id;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? AppColors.surfaceHover
                      : AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isCurrent
                        ? AppColors.cyan.withValues(alpha: 0.5)
                        : (isCompleted
                            ? AppColors.mint.withValues(alpha: 0.2)
                            : AppColors.borderSubtle),
                    width: isCurrent ? 1.2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Step Number
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.mintBg
                            : (isCurrent ? AppColors.cyanBg : Colors.transparent),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.mint
                              : (isCurrent ? AppColors.cyan : AppColors.textSubtle),
                        ),
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_rounded, size: 13, color: AppColors.mint)
                            : Text(
                                '${index + 1}',
                                style: AppTypography.monoBadge.copyWith(
                                  fontSize: 10,
                                  color: isCurrent ? AppColors.cyan : AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Icon
                    Icon(item.icon, size: 16, color: item.badgeColor),
                    const SizedBox(width: 10),

                    // Title & Subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTypography.bodyMedium.copyWith(
                              color: isCompleted ? AppColors.textMuted : AppColors.textHigh,
                              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
                              decoration: isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.subtitle,
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Badge Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.badgeBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.badgeText,
                        style: AppTypography.monoBadge.copyWith(color: item.badgeColor, fontSize: 9),
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Duration Estimate Pill
                    Text(
                      '${item.estimatedMinutes}m',
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(width: 10),

                    // Checkbox Toggle
                    IconButton(
                      icon: Icon(
                        isCompleted
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        size: 18,
                        color: isCompleted ? AppColors.mint : AppColors.textSubtle,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                      onPressed: () => notifier.toggleItemCompleted(item.id),
                      tooltip: isCompleted ? 'Mark as pending' : 'Mark as complete',
                    ),

                    // Quick Focus Launch Button
                    if (!isCompleted) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.play_arrow_rounded, size: 18, color: AppColors.cyan),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                        onPressed: () => notifier.launchItem(context, item),
                        tooltip: 'Launch into Deep Focus',
                      ),
                    ],
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
