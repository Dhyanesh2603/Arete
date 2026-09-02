import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/dsa_problem.dart';

class SocraticHintModal extends StatefulWidget {
  final DsaProblem problem;

  const SocraticHintModal({super.key, required this.problem});

  @override
  State<SocraticHintModal> createState() => _SocraticHintModalState();
}

class _SocraticHintModalState extends State<SocraticHintModal> {
  int _unlockedTier = 1;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 620,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceTier1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.7),
                blurRadius: 36,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.cyanBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'SOCRATIC ANTI-SPOILER ASSISTANT',
                      style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 10),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(widget.problem.title, style: AppTypography.heading1.copyWith(fontSize: 18)),
              const SizedBox(height: 4),
              Text(
                'Pattern: ${widget.problem.pattern}  |  Step: ${widget.problem.stepTitle}',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),

              // Tier 1: Pattern & Intuition
              _buildHintTier(
                tierNumber: 1,
                title: 'TIER 1: ALGORITHMIC INTUITION',
                content: widget.problem.hintTier1,
                isUnlocked: _unlockedTier >= 1,
                accentColor: AppColors.cyan,
                bgColor: AppColors.cyanBg,
              ),
              const SizedBox(height: 12),

              // Tier 2: State Invariant & Recurrence
              _buildHintTier(
                tierNumber: 2,
                title: 'TIER 2: RECURRENCE & INVARIANT',
                content: widget.problem.hintTier2,
                isUnlocked: _unlockedTier >= 2,
                accentColor: AppColors.amber,
                bgColor: AppColors.amberBg,
                onUnlock: () => setState(() => _unlockedTier = 2),
              ),
              const SizedBox(height: 12),

              // Tier 3: Edge Cases & Traps
              _buildHintTier(
                tierNumber: 3,
                title: 'TIER 3: CRITICAL EDGE CASES',
                content: widget.problem.hintTier3,
                isUnlocked: _unlockedTier >= 3,
                accentColor: AppColors.rose,
                bgColor: AppColors.roseBg,
                onUnlock: () => setState(() => _unlockedTier = 3),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderSubtle),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    child: Text('Return to Problem', style: AppTypography.bodyMedium),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHintTier({
    required int tierNumber,
    required String title,
    required String content,
    required bool isUnlocked,
    required Color accentColor,
    required Color bgColor,
    VoidCallback? onUnlock,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnlocked ? AppColors.surfaceTier2 : AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isUnlocked ? accentColor.withValues(alpha: 0.3) : AppColors.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.monoBadge.copyWith(color: accentColor, fontSize: 10)),
              const Spacer(),
              if (!isUnlocked && onUnlock != null)
                InkWell(
                  onTap: onUnlock,
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceHover,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.borderActive),
                    ),
                    child: Text(
                      'Reveal Next Hint',
                      style: AppTypography.caption.copyWith(color: AppColors.textHigh, fontSize: 10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isUnlocked)
            Text(content, style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh, height: 1.4))
          else
            Text(
              'Locked to preserve deliberate problem-solving friction. Try building intuition before revealing.',
              style: AppTypography.caption.copyWith(color: AppColors.textSubtle, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }
}
