import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/striver_a2z_data.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/dsa_problem.dart';
import '../../providers/dsa_provider.dart';
import '../../providers/focus_session_provider.dart';
import '../../providers/peer_cohort_provider.dart';
import '../../widgets/dsa_problem_card.dart';

class DsaRoadmapView extends ConsumerWidget {
  const DsaRoadmapView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsaState = ref.watch(dsaProvider);
    final dsaNotifier = ref.read(dsaProvider.notifier);
    final problems = dsaState.filteredProblems;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header & Overall Progress Banner
            _buildHeader(context, dsaState),
            const SizedBox(height: 20),

            // Step Selector & Search Row
            _buildFilterControls(context, ref, dsaState, dsaNotifier),
            const SizedBox(height: 16),

            // Problem List
            Row(
              children: [
                Text(
                  'SHOWING ${problems.length} PROBLEMS',
                  style: AppTypography.monoBadge.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const Spacer(),
                Text(
                  'Click circle to toggle status | Click play to start Deep Work',
                  style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (problems.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                alignment: Alignment.center,
                child: Text(
                  'No problems match the selected filters.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                ),
              )
            else
              ...problems.map((problem) {
                return DsaProblemCard(
                  problem: problem,
                  onToggleStatus: () {
                    dsaNotifier.toggleStatus(problem.id);
                    if (problem.status != DsaStatus.solved) {
                      ref.read(peerCohortProvider.notifier).incrementMyProblemsSolved();
                    }
                  },
                  onStartFocus: () {
                    ref.read(focusSessionProvider.notifier).startSession(
                          taskTitle: problem.title,
                          objective: 'Solve Striver A2Z: ${problem.subTopic} (${problem.pattern})',
                          durationMinutes: 45,
                        );
                    context.go('/focus');
                  },
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, DsaState dsaState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cyanBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
                ),
                child: Text('STRIVER A2Z DSA SHEET',
                    style: AppTypography.monoBadge.copyWith(
                      color: AppColors.cyan,
                      fontSize: 10,
                    )),
              ),
              const SizedBox(width: 12),
              Text(
                'Complete Data Structures & Algorithms Mastery',
                style: AppTypography.heading1,
              ),
              const Spacer(),
              Text(
                '${dsaState.solvedCount} / ${dsaState.totalCount} Solved (${dsaState.overallProgress.toStringAsFixed(1)}%)',
                style: AppTypography.monoBadge.copyWith(
                  color: AppColors.mint,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: dsaState.overallProgress / 100.0,
              backgroundColor: AppColors.surfaceTier2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mint),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 14),
          // Difficulty Breakdown Pills
          Row(
            children: [
              _buildDiffStat('EASY', dsaState.easySolved, dsaState.easyTotal, AppColors.cyan, AppColors.cyanBg),
              const SizedBox(width: 12),
              _buildDiffStat('MEDIUM', dsaState.mediumSolved, dsaState.mediumTotal, AppColors.amber, AppColors.amberBg),
              const SizedBox(width: 12),
              _buildDiffStat('HARD', dsaState.hardSolved, dsaState.hardTotal, AppColors.rose, AppColors.roseBg),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDiffStat(String label, int solved, int total, Color color, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Text('$label: ', style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10)),
          Text('$solved / $total', style: AppTypography.monoBadge.copyWith(color: color, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildFilterControls(BuildContext context, WidgetRef ref, DsaState dsaState, DsaNotifier dsaNotifier) {
    final stepTitles = StriverA2ZData.getStepTitles();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Step Dropdown & Search Bar
          Row(
            children: [
              // Step Dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    value: dsaState.selectedStepNumber,
                    dropdownColor: AppColors.surfaceTier2,
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh),
                    hint: Text('All Steps (1 to 18)', style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh)),
                    items: [
                      DropdownMenuItem<int?>(
                        value: null,
                        child: Text('All Steps (1 to 18)', style: AppTypography.bodyMedium),
                      ),
                      ...List.generate(18, (index) {
                        final stepNum = index + 1;
                        final title = stepNum < stepTitles.length ? stepTitles[stepNum] : 'Step $stepNum';
                        return DropdownMenuItem<int?>(
                          value: stepNum,
                          child: Text(title, style: AppTypography.bodyMedium),
                        );
                      }),
                    ],
                    onChanged: (val) {
                      dsaNotifier.setStepFilter(val);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Search Input
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier2,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: TextField(
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh),
                    decoration: InputDecoration(
                      hintText: 'Search problem, pattern (e.g. Kadane, Two Pointers, BFS, DP)...',
                      hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                      icon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textMuted),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (val) {
                      dsaNotifier.setSearchQuery(val);
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Difficulty & Status Filter Chips
          Row(
            children: [
              Text('Difficulty:', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              const SizedBox(width: 8),
              _buildFilterChip('All', dsaState.selectedDifficulty == null, () => dsaNotifier.setDifficultyFilter(null)),
              _buildFilterChip('Easy', dsaState.selectedDifficulty == DsaDifficulty.easy, () => dsaNotifier.setDifficultyFilter(DsaDifficulty.easy), color: AppColors.cyan),
              _buildFilterChip('Medium', dsaState.selectedDifficulty == DsaDifficulty.medium, () => dsaNotifier.setDifficultyFilter(DsaDifficulty.medium), color: AppColors.amber),
              _buildFilterChip('Hard', dsaState.selectedDifficulty == DsaDifficulty.hard, () => dsaNotifier.setDifficultyFilter(DsaDifficulty.hard), color: AppColors.rose),
              const SizedBox(width: 20),
              Text('Status:', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              const SizedBox(width: 8),
              _buildFilterChip('All', dsaState.selectedStatus == null, () => dsaNotifier.setStatusFilter(null)),
              _buildFilterChip('Solved', dsaState.selectedStatus == DsaStatus.solved, () => dsaNotifier.setStatusFilter(DsaStatus.solved), color: AppColors.mint),
              _buildFilterChip('In Progress', dsaState.selectedStatus == DsaStatus.inProgress, () => dsaNotifier.setStatusFilter(DsaStatus.inProgress), color: AppColors.amber),
              _buildFilterChip('Todo', dsaState.selectedStatus == DsaStatus.todo, () => dsaNotifier.setStatusFilter(DsaStatus.todo)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    final chipColor = color ?? AppColors.textHigh;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceHover : AppColors.surfaceTier2,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected ? chipColor.withValues(alpha: 0.6) : AppColors.borderSubtle,
            ),
          ),
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: isSelected ? chipColor : AppColors.textMuted,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
