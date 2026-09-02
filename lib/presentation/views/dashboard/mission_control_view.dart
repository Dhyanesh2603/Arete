import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dsa_provider.dart';
import '../../providers/focus_session_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/habits_provider.dart';
import '../../providers/peer_cohort_provider.dart';
import '../../widgets/concentric_rings_painter.dart';
import '../../widgets/telemetry_metric_card.dart';

class MissionControlView extends ConsumerWidget {
  const MissionControlView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsaState = ref.watch(dsaProvider);
    final goalsState = ref.watch(goalsProvider);
    final habits = ref.watch(habitsProvider);
    final cohortState = ref.watch(peerCohortProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final completedHabitsToday = habits.where((h) => h.isCompletedToday).length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 960;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personalized Header Banner
              _buildPersonalizedHeader(context, user, isWide),
              const SizedBox(height: 20),

              // 4 Glanceable Metric Cards
              _buildTelemetryGrid(
                  dsaState, habits, completedHabitsToday, cohortState, isWide),
              const SizedBox(height: 20),

              // Main Command Layout
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Hero Next Action & Timeline
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroNextActionCard(context, ref, goalsState),
                          const SizedBox(height: 20),
                          _buildTimelineFlowCard(context),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Right Column: Cohort Live Friends & Striver Topic Radar
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCohortLiveStatusCard(context, cohortState),
                          const SizedBox(height: 20),
                          _buildStriverTopicsRadarCard(context, dsaState),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeroNextActionCard(context, ref, goalsState),
                    const SizedBox(height: 20),
                    _buildCohortLiveStatusCard(context, cohortState),
                    const SizedBox(height: 20),
                    _buildTimelineFlowCard(context),
                    const SizedBox(height: 20),
                    _buildStriverTopicsRadarCard(context, dsaState),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPersonalizedHeader(
      BuildContext context, dynamic user, bool isWide) {
    final userName = user?.name ?? 'Dhyanesh';
    final userRole = user?.targetRole ?? 'Senior AI Systems Architect & DSA Master';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        children: [
          // Concentric Vector Rings Mini HUD
          const ConcentricRingsWidget(
            focusProgress: 0.70, // 3.5h / 5.0h
            habitProgress: 1.00,
            velocityProgress: 0.85,
            size: 40,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Welcome back, $userName',
                      style: AppTypography.heading2.copyWith(
                        color: AppColors.textHigh,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.cyanBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Goal: $userRole',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isWide) ...[
            const SizedBox(width: 12),
            _buildPill(
              label: 'STREAK',
              value: '${user?.streakDays ?? 42} Days',
              color: AppColors.amber,
              bgColor: AppColors.amberBg,
            ),
            const SizedBox(width: 8),
            _buildPill(
              label: 'SOLVED',
              value: '${user?.totalProblemsSolved ?? 48} Problems',
              color: AppColors.mint,
              bgColor: AppColors.mintBg,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid(dynamic dsaState, dynamic habits,
      int completedHabitsToday, dynamic cohortState, bool isWide) {
    return Row(
      children: [
        TelemetryMetricCard(
          label: 'Striver A2Z DSA Sheet',
          value: '${dsaState.solvedCount} / ${dsaState.totalCount}',
          subValue: '+4 Today',
          accentColor: AppColors.cyan,
          bgColor: AppColors.cyanBg,
          icon: Icons.code_rounded,
        ),
        const SizedBox(width: 12),
        TelemetryMetricCard(
          label: 'Deep Work Focus Today',
          value: '3.5h',
          subValue: '/ 5.0h Target',
          accentColor: AppColors.amber,
          bgColor: AppColors.amberBg,
          icon: Icons.timer_outlined,
        ),
        const SizedBox(width: 12),
        TelemetryMetricCard(
          label: 'Habit Consistency',
          value: '98.4%',
          subValue: '$completedHabitsToday/${habits.length} Done',
          accentColor: AppColors.mint,
          bgColor: AppColors.mintBg,
          icon: Icons.repeat_rounded,
        ),
        const SizedBox(width: 12),
        TelemetryMetricCard(
          label: 'Study Squad War-Room',
          value: '${cohortState.cohort.totalGroupProblemsToday} Solved',
          subValue: '${cohortState.cohort.activeFocusingMembersCount} Live',
          accentColor: AppColors.lavender,
          bgColor: AppColors.lavenderBg,
          icon: Icons.groups_rounded,
        ),
      ],
    );
  }

  Widget _buildPill({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ',
              style: AppTypography.caption
                  .copyWith(fontSize: 10, color: AppColors.textMuted)),
          Text(value,
              style: AppTypography.monoBadge
                  .copyWith(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  Widget _buildHeroNextActionCard(
      BuildContext context, WidgetRef ref, GoalsState goalsState) {
    final heroTask = goalsState.heroNextAction;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.cyan.withValues(alpha: 0.35), width: 1.2),
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
                child: Text('PRIMARY NEXT ACTION',
                    style: AppTypography.monoBadge
                        .copyWith(color: AppColors.cyan, fontSize: 10)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  heroTask?.milestoneTitle ?? 'Striver A2Z: Step 13 Trees',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Simplified Priority Badge: High (Red)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: TaskPriority.high.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: TaskPriority.high.color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'HIGH PRIORITY',
                  style: AppTypography.monoBadge
                      .copyWith(color: TaskPriority.high.color, fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            heroTask?.title ??
                'Solve Binary Tree Maximum Path Sum (LeetCode 124)',
            style: AppTypography.heading1.copyWith(
              color: AppColors.textHigh,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Sub-goal: Master bottom-up recursion subtree contribution logic before moving to Graph Algorithms.',
            style:
                AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(focusSessionProvider.notifier).startSession(
                        taskTitle: heroTask?.title ??
                            'Binary Tree Maximum Path Sum',
                        objective:
                            'Master recursion & subtree contribution logic',
                        durationMinutes: 45,
                      );
                  context.go('/focus');
                },
                icon: const Icon(Icons.play_arrow_rounded,
                    size: 18, color: Color(0xFF0B0D13)),
                label: Text(
                  'START FOCUS (Cmd + Enter)',
                  style: AppTypography.monoBadge.copyWith(
                    color: const Color(0xFF0B0D13),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  context.go('/dsa');
                },
                icon: const Icon(Icons.list_alt_rounded,
                    size: 16, color: AppColors.textMedium),
                label: Text(
                  'Open DSA Sheet',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.textMedium),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineFlowCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Text('TODAY SCHEDULE', style: AppTypography.heading2),
              const Spacer(),
              Text('08:00 - 20:00',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 180,
                  child: _buildTimeBlock(
                    title: '08:00 DSA Practice',
                    subtitle: 'Binary Trees LCA (Done)',
                    isDone: true,
                    color: AppColors.mint,
                    bgColor: AppColors.mintBg,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 180,
                  child: _buildTimeBlock(
                    title: '11:00 Max Path Sum',
                    subtitle: 'LeetCode 124 (Current)',
                    isActive: true,
                    color: AppColors.cyan,
                    bgColor: AppColors.cyanBg,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 180,
                  child: _buildTimeBlock(
                    title: '14:30 Squad Sync',
                    subtitle: 'Striver Step 13 Review',
                    color: AppColors.lavender,
                    bgColor: AppColors.lavenderBg,
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 180,
                  child: _buildTimeBlock(
                    title: '18:00 Cardio & Recovery',
                    subtitle: '45m Running (Pending)',
                    color: AppColors.amber,
                    bgColor: AppColors.amberBg,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBlock({
    required String title,
    required String subtitle,
    bool isDone = false,
    bool isActive = false,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive
              ? color
              : color.withValues(alpha: isDone ? 0.3 : 0.2),
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.monoBadge.copyWith(
              fontSize: 11,
              color: color,
              decoration: isDone ? TextDecoration.lineThrough : null,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildCohortLiveStatusCard(
      BuildContext context, PeerCohortState cohortState) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Text('STUDY SQUAD ALPHA', style: AppTypography.heading2),
              const Spacer(),
              InkWell(
                onTap: () => context.go('/cohort'),
                child: Text(
                  'War-Room ->',
                  style:
                      AppTypography.caption.copyWith(color: AppColors.cyan),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...cohortState.cohort.members.take(3).map((m) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier2,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: m.isFocusingNow
                      ? AppColors.cyan.withValues(alpha: 0.3)
                      : AppColors.borderSubtle,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: m.avatarColor,
                    child: Text(
                      m.name[0],
                      style: AppTypography.monoBadge.copyWith(
                        color: const Color(0xFF0B0D13),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          children: [
                            Text(m.name, style: AppTypography.bodyMedium),
                            if (m.isFocusingNow)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: AppColors.cyanBg,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text('IN FOCUS',
                                    style: AppTypography.monoBadge.copyWith(
                                      color: AppColors.cyan,
                                      fontSize: 8,
                                    )),
                              ),
                          ],
                        ),
                        Text(
                          m.currentFocusTask ?? m.currentDsaTopic,
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textMuted),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${m.problemsSolvedToday} Solved',
                    style: AppTypography.monoBadge.copyWith(
                      color: m.problemsSolvedToday > 0
                          ? AppColors.mint
                          : AppColors.textMuted,
                      fontSize: 10,
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

  Widget _buildStriverTopicsRadarCard(
      BuildContext context, DsaState dsaState) {
    final summaries = dsaState.stepSummaries.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(18),
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
              Expanded(
                child: Text('STRIVER TOPIC GATES',
                    style: AppTypography.heading2,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              InkWell(
                onTap: () => context.go('/dsa'),
                child: Text('All 18 Steps ->',
                    style:
                        AppTypography.caption.copyWith(color: AppColors.cyan)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...summaries.map((s) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.title,
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textHigh),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${s.solvedProblems}/${s.totalProblems}',
                        style: AppTypography.monoBadge
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: s.totalProblems == 0
                          ? 0.0
                          : s.solvedProblems / s.totalProblems,
                      backgroundColor: AppColors.surfaceTier2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        s.progressPercentage == 100.0
                            ? AppColors.mint
                            : AppColors.cyan,
                      ),
                      minHeight: 5,
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
