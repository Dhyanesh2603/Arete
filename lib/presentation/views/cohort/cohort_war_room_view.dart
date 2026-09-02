import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/focus_session_provider.dart';
import '../../providers/peer_cohort_provider.dart';

class CohortWarRoomView extends ConsumerWidget {
  const CohortWarRoomView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cohortState = ref.watch(peerCohortProvider);
    final cohort = cohortState.cohort;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Synchronized Sprint Trigger
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('DSA COHORT WAR-ROOM', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'High-performance study squad holding each other accountable. Zero social clutter.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.read(focusSessionProvider.notifier).startSession(
                          taskTitle: 'Synchronized Squad Focus Sprint',
                          objective: '45-minute collective deep work block with Alex, Maya & squad',
                          durationMinutes: 45,
                        );
                    context.go('/focus');
                  },
                  icon: const Icon(Icons.groups_rounded, size: 18, color: Color(0xFF0B0D13)),
                  label: Text(
                    'JOIN SQUAD FOCUS SPRINT (45M)',
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
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier1,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    '${cohort.activeFocusingMembersCount} / ${cohort.members.length} Focusing Now',
                    style: AppTypography.monoBadge.copyWith(color: AppColors.mint, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Live Study Squad Members Grid
            Text('LIVE SQUAD STATUS', style: AppTypography.heading2),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                mainAxisExtent: 160,
              ),
              itemCount: cohort.members.length,
              itemBuilder: (context, index) {
                final member = cohort.members[index];
                final isMe = member.id == cohortState.currentUserId;

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier1,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: member.isFocusingNow
                          ? AppColors.cyan.withValues(alpha: 0.5)
                          : AppColors.borderSubtle,
                      width: member.isFocusingNow ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: member.avatarColor,
                            child: Text(
                              member.name[0],
                              style: AppTypography.monoBadge.copyWith(
                                color: const Color(0xFF0B0D13),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      member.name,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: AppColors.textHigh,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (isMe)
                                      Text(
                                        ' (You)',
                                        style: AppTypography.caption.copyWith(color: AppColors.cyan),
                                      ),
                                  ],
                                ),
                                Text(
                                  member.isFocusingNow ? 'In Focus Mode' : 'Online',
                                  style: AppTypography.caption.copyWith(
                                    color: member.isFocusingNow ? AppColors.cyan : AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isMe)
                            Tooltip(
                              message: 'Send Momentum Nudge',
                              child: InkWell(
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Momentum boost sent to ${member.name}.'),
                                      backgroundColor: AppColors.surfaceTier2,
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceTier2,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.borderSubtle),
                                  ),
                                  child: const Icon(Icons.bolt_rounded, size: 14, color: AppColors.amber),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        member.currentFocusTask ?? 'Working on ${member.currentDsaTopic}',
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 12,
                          color: member.isFocusingNow ? AppColors.textHigh : AppColors.textMuted,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${member.problemsSolvedToday} Solved Today',
                            style: AppTypography.monoBadge.copyWith(
                              color: member.problemsSolvedToday > 0 ? AppColors.mint : AppColors.textMuted,
                              fontSize: 10,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${member.deepWorkHoursToday}h Focus',
                            style: AppTypography.caption.copyWith(color: AppColors.textSubtle, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),

            // Weekly Leaderboard Table
            Text('WEEKLY VELOCITY LEADERBOARD', style: AppTypography.heading2),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(width: 40, child: Text('RANK', style: AppTypography.monoBadge)),
                        const SizedBox(width: 14),
                        Expanded(flex: 3, child: Text('MEMBER', style: AppTypography.monoBadge)),
                        Expanded(flex: 2, child: Text('TOPIC GATE', style: AppTypography.monoBadge)),
                        Expanded(flex: 2, child: Text('SOLVED TODAY', style: AppTypography.monoBadge)),
                        Expanded(flex: 2, child: Text('TOTAL SOLVED', style: AppTypography.monoBadge)),
                        Expanded(flex: 2, child: Text('DEEP WORK', style: AppTypography.monoBadge)),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.borderSubtle, height: 1),
                  ...cohort.members.asMap().entries.map((entry) {
                    final index = entry.key;
                    final member = entry.value;

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              '#${index + 1}',
                              style: AppTypography.monoBadge.copyWith(
                                color: index == 0 ? AppColors.amber : AppColors.textMuted,
                                fontWeight: index == 0 ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 3,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: member.avatarColor,
                                  child: Text(member.name[0], style: AppTypography.monoBadge.copyWith(color: const Color(0xFF0B0D13), fontSize: 10)),
                                ),
                                const SizedBox(width: 10),
                                Text(member.name, style: AppTypography.bodyMedium),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(member.currentDsaTopic, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              '+${member.problemsSolvedToday}',
                              style: AppTypography.monoBadge.copyWith(color: AppColors.mint),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('${member.totalProblemsSolved} problems', style: AppTypography.bodyMedium),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('${member.deepWorkHoursToday}h logged', style: AppTypography.caption.copyWith(color: AppColors.cyan)),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
