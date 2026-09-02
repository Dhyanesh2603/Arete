import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/goal.dart';
import '../../../domain/models/milestone.dart';
import '../../providers/goals_provider.dart';

class GoalsView extends ConsumerWidget {
  const GoalsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsState = ref.watch(goalsProvider);

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
                    Text('STRATEGIC GOALS & MILESTONES', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Identity anchors decomposed into weighted DAG milestones.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 16, color: AppColors.cyan),
                  label: Text('Create Goal', style: AppTypography.monoBadge.copyWith(color: AppColors.cyan)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.cyan.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Goals List
            ...goalsState.goals.map((g) {
              final goalMilestones = goalsState.milestones.where((m) => m.goalId == g.id).toList();
              return _buildGoalCard(context, g, goalMilestones);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, Goal goal, List<Milestone> milestones) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.lavenderBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.lavender.withValues(alpha: 0.3)),
                ),
                child: Text(
                  goal.identityTitle.toUpperCase(),
                  style: AppTypography.monoBadge.copyWith(color: AppColors.lavender, fontSize: 10),
                ),
              ),
              const Spacer(),
              Text(
                '${goal.weightedProgress.toStringAsFixed(1)}% Completed',
                style: AppTypography.monoBadge.copyWith(color: AppColors.mint, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(goal.title, style: AppTypography.heading1.copyWith(fontSize: 20)),
          const SizedBox(height: 6),
          Text(goal.objectiveStatement, style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goal.weightedProgress / 100.0,
              backgroundColor: AppColors.surfaceTier2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mint),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 20),
          Text('WEIGHTED MILESTONES (DAG)', style: AppTypography.monoBadge.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 10),
          // Milestone List
          ...milestones.map((m) {
            final isCompleted = m.status == MilestoneStatus.completed;
            final isActive = m.status == MilestoneStatus.active;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? AppColors.cyan.withValues(alpha: 0.3)
                      : isCompleted
                          ? AppColors.mint.withValues(alpha: 0.3)
                          : AppColors.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : isActive
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                    size: 18,
                    color: isCompleted
                        ? AppColors.mint
                        : isActive
                            ? AppColors.cyan
                            : AppColors.textMuted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m.title, style: AppTypography.bodyLarge.copyWith(color: AppColors.textHigh)),
                        Text('Weight: ${m.weightMultiplier}x  |  Deadline: ${m.deadline.year}-${m.deadline.month}-${m.deadline.day}',
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  Text(
                    '${m.progressPercentage.toStringAsFixed(0)}%',
                    style: AppTypography.monoBadge.copyWith(
                      color: isCompleted ? AppColors.mint : AppColors.textHigh,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
