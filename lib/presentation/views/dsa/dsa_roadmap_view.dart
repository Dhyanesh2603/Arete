import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/dsa_problem.dart';
import '../../providers/dsa_provider.dart';
import '../../widgets/dsa_problem_card.dart';

class DsaRoadmapView extends ConsumerStatefulWidget {
  const DsaRoadmapView({super.key});

  @override
  ConsumerState<DsaRoadmapView> createState() => _DsaRoadmapViewState();
}

class _DsaRoadmapViewState extends ConsumerState<DsaRoadmapView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dsaState = ref.watch(dsaProvider);
    final dsaNotifier = ref.read(dsaProvider.notifier);
    final filteredProblems = dsaState.filteredProblems;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Title & Actions
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('STRIVER A2Z DSA MASTERY ENGINE', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Complete 18-step curriculum with Spaced Repetition (SM-2) & Socratic hints.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                // Mock Interview Launcher Button
                ElevatedButton.icon(
                  onPressed: () => context.go('/mock-interview'),
                  icon: const Icon(Icons.timer_outlined, size: 16, color: Color(0xFF0B0D13)),
                  label: Text(
                    '45M MOCK INTERVIEW',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF0B0D13),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier1,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    '${dsaState.solvedCount} / ${dsaState.totalCount} Solved (${((dsaState.solvedCount / (dsaState.totalCount == 0 ? 1 : dsaState.totalCount)) * 100).toStringAsFixed(1)}%)',
                    style: AppTypography.monoBadge.copyWith(color: AppColors.mint, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Controls & Filters Row
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  // Step Dropdown + Search
                  Row(
                    children: [
                      // Step Selector Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTier2,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: dsaState.selectedStepNumber,
                            dropdownColor: AppColors.surfaceTier1,
                            hint: Text('All 18 Steps', style: AppTypography.bodyMedium),
                            items: [
                              const DropdownMenuItem<int?>(
                                value: null,
                                child: Text('All 18 Steps (Full Sheet)'),
                              ),
                              ...dsaState.stepSummaries.map((s) {
                                final cleanTitle = s.title.startsWith('Step ')
                                    ? s.title
                                    : 'Step ${s.stepNumber}: ${s.title}';
                                return DropdownMenuItem<int?>(
                                  value: s.stepNumber,
                                  child: Text(
                                      '$cleanTitle (${s.solvedProblems}/${s.totalProblems})'),
                                );
                              }),
                            ],
                            onChanged: (val) => dsaNotifier.setStepFilter(val),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Search Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceTier2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh),
                            decoration: InputDecoration(
                              hintText: 'Search problem, pattern (e.g. Kadane, Two Pointers, BFS)...',
                              hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                              border: InputBorder.none,
                              icon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                            ),
                            onChanged: (val) => dsaNotifier.setSearchQuery(val),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Difficulty + Status + Spaced Repetition Filter Chips
                  Row(
                    children: [
                      Text('Difficulty:', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                      const SizedBox(width: 8),
                      _buildChip('All', dsaState.selectedDifficulty == null, () => dsaNotifier.setDifficultyFilter(null)),
                      _buildChip('Easy', dsaState.selectedDifficulty == DsaDifficulty.easy, () => dsaNotifier.setDifficultyFilter(DsaDifficulty.easy), color: AppColors.cyan),
                      _buildChip('Medium', dsaState.selectedDifficulty == DsaDifficulty.medium, () => dsaNotifier.setDifficultyFilter(DsaDifficulty.medium), color: AppColors.amber),
                      _buildChip('Hard', dsaState.selectedDifficulty == DsaDifficulty.hard, () => dsaNotifier.setDifficultyFilter(DsaDifficulty.hard), color: AppColors.rose),
                      const SizedBox(width: 16),
                      Text('Status:', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                      const SizedBox(width: 8),
                      _buildChip('All', dsaState.selectedStatus == null, () => dsaNotifier.setStatusFilter(null)),
                      _buildChip('Solved', dsaState.selectedStatus == DsaStatus.solved, () => dsaNotifier.setStatusFilter(DsaStatus.solved), color: AppColors.mint),
                      _buildChip('Todo', dsaState.selectedStatus == DsaStatus.todo, () => dsaNotifier.setStatusFilter(DsaStatus.todo)),
                      const SizedBox(width: 16),
                      // Spaced Repetition Due Filter
                      _buildChip(
                        'Revision Due (${dsaState.revisionDueCount})',
                        dsaState.filterDueForRevisionOnly,
                        () => dsaNotifier.toggleRevisionOnlyFilter(),
                        color: AppColors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Problem Items List
            Expanded(
              child: filteredProblems.isEmpty
                  ? Center(
                      child: Text(
                        'No problems match the current filter criteria.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredProblems.length,
                      itemBuilder: (context, index) {
                        return DsaProblemCard(problem: filteredProblems[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    final chipColor = color ?? AppColors.textHigh;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
