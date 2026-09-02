import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/goal.dart';
import '../../../domain/models/milestone.dart';
import '../../providers/goals_provider.dart';

class GoalsView extends ConsumerWidget {
  const GoalsView({super.key});

  void _showCreateGoalDialog(BuildContext context, WidgetRef ref) {
    final titleCtrl = TextEditingController();
    final identityCtrl = TextEditingController();
    final objCtrl = TextEditingController();
    GoalPriority selectedPriority = GoalPriority.p0Critical;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (dialogCtx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: 440,
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
                          color: AppColors.cyanBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.flag_rounded,
                            size: 16, color: AppColors.cyan),
                      ),
                      const SizedBox(width: 10),
                      Text('Create Strategic Goal',
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
                  Text('Goal Title',
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
                        hintText: 'e.g. Master Algorithms & Land Senior Role',
                        hintStyle: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Identity Anchor',
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
                      controller: identityCtrl,
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Staff Distributed Systems Engineer',
                        hintStyle: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Objective Statement',
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
                      controller: objCtrl,
                      maxLines: 2,
                      style: AppTypography.bodyMedium,
                      decoration: const InputDecoration(
                        hintText: 'What defines success for this goal?',
                        hintStyle: TextStyle(
                            fontSize: 12, color: AppColors.textMuted),
                        border: InputBorder.none,
                      ),
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

                          ref.read(goalsProvider.notifier).createGoal(
                                title: title,
                                identityTitle: identityCtrl.text.trim(),
                                objectiveStatement: objCtrl.text.trim(),
                                targetDeadline: DateTime.now()
                                    .add(const Duration(days: 180)),
                                priority: selectedPriority,
                              );
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan),
                        child: Text(
                          'CREATE GOAL',
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
                    Text('STRATEGIC GOALS & MILESTONES',
                        style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Identity anchors decomposed into weighted milestones.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showCreateGoalDialog(context, ref),
                  icon: const Icon(Icons.add_rounded,
                      size: 16, color: Color(0xFF0B0D13)),
                  label: Text(
                    'CREATE GOAL',
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

            if (goalsState.goals.isEmpty)
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
                        const Icon(Icons.flag_outlined,
                            size: 42, color: AppColors.textSubtle),
                        const SizedBox(height: 14),
                        Text('No strategic goals defined',
                            style: AppTypography.heading2.copyWith(fontSize: 16)),
                        const SizedBox(height: 6),
                        Text(
                          'Define identity-level objectives and milestones to align daily tasks with long-term ambitions.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.textMuted, fontSize: 13),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateGoalDialog(context, ref),
                          icon: const Icon(Icons.add_rounded,
                              size: 16, color: Color(0xFF0B0D13)),
                          label: Text(
                            'CREATE FIRST GOAL',
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
            else
              ...goalsState.goals.map((g) {
                final goalMilestones = goalsState.milestones
                    .where((m) => m.goalId == g.id)
                    .toList();
                return _buildGoalCard(context, ref, g, goalMilestones);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, WidgetRef ref, Goal goal,
      List<Milestone> milestones) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cyanBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  goal.identityTitle.isNotEmpty
                      ? goal.identityTitle.toUpperCase()
                      : 'STRATEGIC GOAL',
                  style: AppTypography.monoBadge
                      .copyWith(color: AppColors.cyan, fontSize: 10),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.textSubtle),
                onPressed: () {
                  ref.read(goalsProvider.notifier).deleteGoal(goal.id);
                },
                tooltip: 'Delete Goal',
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(goal.title, style: AppTypography.heading2.copyWith(fontSize: 17)),
          if (goal.objectiveStatement.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              goal.objectiveStatement,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: goal.weightedProgress / 100.0,
                    backgroundColor: AppColors.surfaceTier2,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.cyan),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${goal.weightedProgress.toStringAsFixed(0)}%',
                style: AppTypography.monoBadge
                    .copyWith(color: AppColors.cyan, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
