import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
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
            // Top Cohort Header
            _buildCohortHeader(context, cohort),
            const SizedBox(height: 24),

            // Live Study War-Room: Member Focus Telemetry Grid
            Text('LIVE PEER FOCUS SESSIONS', style: AppTypography.heading2),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: cohort.members.map((member) {
                    return SizedBox(
                      width: isWide
                          ? (constraints.maxWidth - 32) / 3
                          : constraints.maxWidth,
                      child: _buildMemberCard(member),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 28),

            // Weekly Accountability Leaderboard
            Text('WEEKLY VELOCITY LEADERBOARD', style: AppTypography.heading2),
            const SizedBox(height: 12),
            _buildLeaderboardTable(cohort),
          ],
        ),
      ),
    );
  }

  Widget _buildCohortHeader(BuildContext context, dynamic cohort) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lavender.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.lavenderBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                      color: AppColors.lavender.withValues(alpha: 0.3)),
                ),
                child: Text('STUDY SQUAD WAR-ROOM',
                    style: AppTypography.monoBadge.copyWith(
                      color: AppColors.lavender,
                      fontSize: 10,
                    )),
              ),
              const SizedBox(width: 12),
              Text(
                cohort.name,
                style: AppTypography.heading1,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.cyanBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.cyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${cohort.activeFocusingMembersCount} Friends in Focus Mode',
                      style: AppTypography.monoBadge
                          .copyWith(color: AppColors.cyan, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Target: ${cohort.targetGoal}',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _buildHeaderStat('GROUP PROBLEMS TODAY',
                  '${cohort.totalGroupProblemsToday}', AppColors.mint),
              const SizedBox(width: 24),
              _buildHeaderStat('GROUP FOCUS TIME THIS WEEK',
                  '${cohort.totalGroupFocusHoursWeek} Hours', AppColors.amber),
              const SizedBox(width: 24),
              _buildHeaderStat('SPRINT DEADLINE', '4 Days Remaining',
                  AppColors.lavender),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTypography.caption
                .copyWith(color: AppColors.textMuted, fontSize: 10)),
        const SizedBox(height: 2),
        Text(value,
            style: AppTypography.monoBadge
                .copyWith(color: color, fontSize: 14)),
      ],
    );
  }

  Widget _buildMemberCard(dynamic member) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: member.isFocusingNow
              ? AppColors.cyan.withValues(alpha: 0.45)
              : AppColors.borderSubtle,
          width: member.isFocusingNow ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: member.avatarColor,
                child: Text(
                  member.name[0],
                  style: AppTypography.monoBadge.copyWith(
                    color: const Color(0xFF0B0D13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: AppTypography.heading2.copyWith(fontSize: 15)),
                    Text(member.handle, style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              if (member.isFocusingNow)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cyanBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('LIVE FOCUS',
                      style: AppTypography.monoBadge.copyWith(
                        color: AppColors.cyan,
                        fontSize: 9,
                      )),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (member.isFocusingNow) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier2,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Task:', style: AppTypography.caption.copyWith(color: AppColors.cyan, fontSize: 10)),
                  const SizedBox(height: 2),
                  Text(
                    member.currentFocusTask ?? 'Deep Work Problem Solving',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            Text('Current Topic: ${member.currentDsaTopic}',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              _buildMiniMetric('Today', '${member.problemsSolvedToday} Solved', AppColors.mint),
              const Spacer(),
              _buildMiniMetric('Total', '${member.totalProblemsSolved}', AppColors.textHigh),
              const Spacer(),
              _buildMiniMetric('Streak', '${member.streakDays} Days', AppColors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSubtle, fontSize: 10)),
        Text(value, style: AppTypography.monoBadge.copyWith(color: color, fontSize: 11)),
      ],
    );
  }

  Widget _buildLeaderboardTable(dynamic cohort) {
    final sortedMembers = List.from(cohort.members)
      ..sort((a, b) => b.totalProblemsSolved.compareTo(a.totalProblemsSolved));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceTier2,
              borderRadius: BorderRadius.vertical(top: Radius.circular(9)),
            ),
            child: Row(
              children: [
                SizedBox(width: 40, child: Text('#', style: AppTypography.monoBadge)),
                Expanded(flex: 3, child: Text('MEMBER', style: AppTypography.monoBadge)),
                Expanded(flex: 2, child: Text('TODAY SOLVED', style: AppTypography.monoBadge)),
                Expanded(flex: 2, child: Text('TOTAL SOLVED', style: AppTypography.monoBadge)),
                Expanded(flex: 2, child: Text('FOCUS TIME', style: AppTypography.monoBadge)),
                Expanded(flex: 2, child: Text('STREAK', style: AppTypography.monoBadge)),
              ],
            ),
          ),
          // Table Rows
          ...sortedMembers.asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final m = entry.value;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$rank',
                      style: AppTypography.monoBadge.copyWith(
                        color: rank == 1
                            ? AppColors.amber
                            : rank == 2
                                ? AppColors.cyan
                                : AppColors.textMuted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: m.avatarColor,
                          child: Text(
                            m.name[0],
                            style: AppTypography.monoBadge.copyWith(
                              fontSize: 9,
                              color: const Color(0xFF0B0D13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(m.name, style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '+${m.problemsSolvedToday}',
                      style: AppTypography.monoBadge.copyWith(
                        color: m.problemsSolvedToday > 0 ? AppColors.mint : AppColors.textMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${m.totalProblemsSolved} Problems',
                      style: AppTypography.monoBadge.copyWith(color: AppColors.textHigh),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${(m.totalFocusMinutesWeek / 60).toStringAsFixed(1)}h',
                      style: AppTypography.monoBadge.copyWith(color: AppColors.amber),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${m.streakDays} Days',
                      style: AppTypography.monoBadge.copyWith(color: AppColors.cyan),
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
