import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/dsa_problem.dart';
import '../providers/dsa_provider.dart';
import '../providers/focus_session_provider.dart';
import 'socratic_hint_modal.dart';

class DsaProblemCard extends ConsumerWidget {
  final DsaProblem problem;

  const DsaProblemCard({super.key, required this.problem});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsaNotifier = ref.read(dsaProvider.notifier);
    final isSolved = problem.status == DsaStatus.solved;

    Color diffColor;
    Color diffBg;
    switch (problem.difficulty) {
      case DsaDifficulty.easy:
        diffColor = AppColors.cyan;
        diffBg = AppColors.cyanBg;
        break;
      case DsaDifficulty.medium:
        diffColor = AppColors.amber;
        diffBg = AppColors.amberBg;
        break;
      case DsaDifficulty.hard:
        diffColor = AppColors.rose;
        diffBg = AppColors.roseBg;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSolved ? AppColors.surfaceTier1.withValues(alpha: 0.5) : AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: problem.isDueForRevision
              ? AppColors.amber.withValues(alpha: 0.6)
              : isSolved
                  ? AppColors.mint.withValues(alpha: 0.25)
                  : AppColors.borderSubtle,
          width: problem.isDueForRevision ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Solved Checkbox
          InkWell(
            onTap: () => dsaNotifier.toggleProblemStatus(problem.id),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSolved ? AppColors.mint : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isSolved ? AppColors.mint : AppColors.borderActive,
                  width: 1.5,
                ),
              ),
              child: isSolved
                  ? const Icon(Icons.check, size: 16, color: Color(0xFF0B0D13))
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Problem Title & Meta
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        problem.title,
                        style: AppTypography.bodyLarge.copyWith(
                          color: isSolved ? AppColors.textMuted : AppColors.textHigh,
                          decoration: isSolved ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (problem.isDueForRevision) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.amberBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          'REVISION DUE',
                          style: AppTypography.monoBadge.copyWith(color: AppColors.amber, fontSize: 9),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '${problem.subTopic}  |  Pattern: ${problem.pattern}',
                      style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                    ),
                    if (problem.reviewCount > 0) ...[
                      const SizedBox(width: 8),
                      Text(
                        '|  Reviews: ${problem.reviewCount}x',
                        style: AppTypography.monoBadge.copyWith(fontSize: 9, color: AppColors.mint),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Difficulty Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: diffBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              problem.difficulty.name.toUpperCase(),
              style: AppTypography.monoBadge.copyWith(fontSize: 10, color: diffColor),
            ),
          ),
          const SizedBox(width: 10),

          // Socratic Hint Button
          Tooltip(
            message: 'Socratic Anti-Spoiler Hints',
            child: InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => SocraticHintModal(problem: problem),
                );
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded, size: 14, color: AppColors.amber),
                    const SizedBox(width: 4),
                    Text('Hint', style: AppTypography.caption.copyWith(color: AppColors.amber, fontSize: 11)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Focus Launcher Button
          Tooltip(
            message: 'Launch Focus Session for this problem',
            child: InkWell(
              onTap: () {
                ref.read(focusSessionProvider.notifier).startSession(
                      taskTitle: problem.title,
                      objective: 'Pattern: ${problem.pattern} | Difficulty: ${problem.difficulty.name.toUpperCase()}',
                      durationMinutes: 45,
                    );
                context.go('/focus');
              },
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: const Icon(Icons.play_arrow_rounded, size: 16, color: AppColors.cyan),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
