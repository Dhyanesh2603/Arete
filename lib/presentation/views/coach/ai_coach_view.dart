import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/ai_coach_provider.dart';

class AICoachView extends ConsumerWidget {
  const AICoachView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachState = ref.watch(aiCoachProvider);
    final coachNotifier = ref.read(aiCoachProvider.notifier);
    final report = coachState.latestReport;

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
                    Text('AI COGNITIVE COACH & RETROSPECTIVE', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Serverless intelligence analyzing output velocity, friction diagnosis, and dynamic schedule re-balancing.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: coachState.isAnalyzing ? null : () => coachNotifier.triggerSynthesis(),
                  icon: coachState.isAnalyzing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF0B0D13)),
                        )
                      : const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF0B0D13)),
                  label: Text(
                    coachState.isAnalyzing ? 'SYNTHESIZING...' : 'RUN EVENING SYNTHESIS',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF0B0D13),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (report != null) ...[
              // Daily Retrospective Assessment
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier1,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.cyan.withValues(alpha: 0.35), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.cyanBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('DAILY ASSESSMENT', style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 10)),
                        ),
                        const Spacer(),
                        Text(
                          '${report.deepWorkLoggedHours}h Focus Logged  |  ${report.problemsSolved} Problems  |  ${report.habitsCompleted} Habits',
                          style: AppTypography.monoBadge.copyWith(color: AppColors.mint),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(report.assessment, style: AppTypography.bodyLarge.copyWith(height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Friction Diagnosis
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier1,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.amber.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.amber),
                        const SizedBox(width: 8),
                        Text('FRICTION & BOTTLENECK DIAGNOSIS', style: AppTypography.heading2),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(report.frictionDiagnosis, style: AppTypography.bodyMedium.copyWith(color: AppColors.textMedium, height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Auto-Generated Tomorrow's Plan
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
                        Text('RECOMMENDED TOMORROW SCHEDULE', style: AppTypography.heading2),
                        const Spacer(),
                        Text('Dynamic AI Calibration', style: AppTypography.caption.copyWith(color: AppColors.cyan)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...report.tomorrowPlan.map((slot) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTier2,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 100,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceTier1,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(slot.timeSlot, style: AppTypography.monoBadge.copyWith(color: AppColors.amber, fontSize: 10)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(slot.title, style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.cyanBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(slot.cognitiveTier, style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 9)),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
