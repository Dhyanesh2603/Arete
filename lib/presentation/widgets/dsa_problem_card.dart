import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/dsa_problem.dart';

class DsaProblemCard extends StatelessWidget {
  final DsaProblem problem;
  final VoidCallback onToggleStatus;
  final VoidCallback? onStartFocus;

  const DsaProblemCard({
    super.key,
    required this.problem,
    required this.onToggleStatus,
    this.onStartFocus,
  });

  @override
  Widget build(BuildContext context) {
    final isSolved = problem.status == DsaStatus.solved;
    final isInProgress = problem.status == DsaStatus.inProgress;

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
      decoration: BoxDecoration(
        color: isSolved
            ? AppColors.surfaceTier1.withValues(alpha: 0.6)
            : AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSolved
              ? AppColors.mint.withValues(alpha: 0.2)
              : isInProgress
                  ? AppColors.amber.withValues(alpha: 0.4)
                  : AppColors.borderSubtle,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Checkbox Status Trigger
            InkWell(
              onTap: onToggleStatus,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isSolved
                      ? AppColors.mint
                      : isInProgress
                          ? AppColors.amberBg
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSolved
                        ? AppColors.mint
                        : isInProgress
                            ? AppColors.amber
                            : AppColors.borderActive,
                    width: 1.5,
                  ),
                ),
                child: isSolved
                    ? const Icon(Icons.check, size: 14, color: Color(0xFF0B0D13))
                    : isInProgress
                        ? Center(
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.amber,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                        : null,
              ),
            ),
            const SizedBox(width: 14),
            // Problem Details
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
                            color: isSolved
                                ? AppColors.textMuted
                                : AppColors.textHigh,
                            decoration:
                                isSolved ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        problem.subTopic,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '|  ${problem.pattern}',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSubtle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Difficulty Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: diffBg,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: diffColor.withValues(alpha: 0.3)),
              ),
              child: Text(
                problem.difficulty.name.toUpperCase(),
                style: AppTypography.monoBadge.copyWith(
                  fontSize: 10,
                  color: diffColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Focus Trigger
            if (onStartFocus != null && !isSolved)
              Tooltip(
                message: 'Start Deep Work on this problem',
                child: InkWell(
                  onTap: onStartFocus,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier2,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 16,
                      color: AppColors.cyan,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
