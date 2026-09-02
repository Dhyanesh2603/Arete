import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dsa_provider.dart';
import '../../providers/focus_session_provider.dart';
import '../../providers/habits_provider.dart';
import '../../providers/peer_cohort_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../widgets/concentric_rings_painter.dart';
import '../../widgets/telemetry_metric_card.dart';

class MissionControlView extends ConsumerWidget {
  const MissionControlView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsaState = ref.watch(dsaProvider);
    final tasksState = ref.watch(tasksProvider);
    final habits = ref.watch(habitsProvider);
    final cohortState = ref.watch(peerCohortProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final completedHabitsToday = habits.where((h) => h.isCompletedToday).length;
    final highPriorityTasks = tasksState.tasks.where((t) => !t.isCompleted && t.priority == TaskPriority.high).toList();
    final firstPendingTask = highPriorityTasks.isNotEmpty
        ? highPriorityTasks.first
        : tasksState.tasks.where((t) => !t.isCompleted).isNotEmpty
            ? tasksState.tasks.where((t) => !t.isCompleted).first
            : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 960;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Personalized Header Banner
              _buildPersonalizedHeader(context, user, isWide, dsaState),
              const SizedBox(height: 20),

              // 4 Glanceable Metric Cards
              _buildTelemetryGrid(
                  dsaState, habits, completedHabitsToday, cohortState, isWide, user),
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
                          _buildHeroNextActionCard(context, ref, firstPendingTask),
                          const SizedBox(height: 20),
                          _buildTimelineFlowCard(context, tasksState),
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
                    _buildHeroNextActionCard(context, ref, firstPendingTask),
                    const SizedBox(height: 20),
                    _buildCohortLiveStatusCard(context, cohortState),
                    const SizedBox(height: 20),
                    _buildTimelineFlowCard(context, tasksState),
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
      BuildContext context, dynamic user, bool isWide, DsaState dsaState) {
    final userName = user?.name ?? 'Developer';
    final userRole = user?.targetRole ?? 'Software Engineer & DSA Aspirant';

    final focusRatio = ((user?.totalFocusHours ?? 0.0) / 5.0).clamp(0.0, 1.0);
    final dsaRatio = dsaState.totalCount == 0 ? 0.0 : (dsaState.solvedCount / dsaState.totalCount);

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
          ConcentricRingsWidget(
            focusProgress: focusRatio,
            habitProgress: 1.0,
            velocityProgress: dsaRatio,
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
              value: '${user?.streakDays ?? 0} Days',
              color: AppColors.amber,
              bgColor: AppColors.amberBg,
            ),
            const SizedBox(width: 8),
            _buildPill(
              label: 'SOLVED',
              value: '${dsaState.solvedCount} / ${dsaState.totalCount}',
              color: AppColors.mint,
              bgColor: AppColors.mintBg,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid(dynamic dsaState, dynamic habits,
      int completedHabitsToday, dynamic cohortState, bool isWide, dynamic user) {
    return Row(
      children: [
        TelemetryMetricCard(
          label: 'Striver A2Z DSA Sheet',
          value: '${dsaState.solvedCount} / ${dsaState.totalCount}',
          subValue: dsaState.solvedCount == 0 ? 'Start Step 1' : '${dsaState.solvedCount} Solved',
          accentColor: AppColors.cyan,
          bgColor: AppColors.cyanBg,
          icon: Icons.code_rounded,
        ),
        const SizedBox(width: 12),
        TelemetryMetricCard(
          label: 'Deep Work Focus Today',
          value: '${user?.totalFocusHours ?? 0.0}h',
          subValue: '/ 5.0h Target',
          accentColor: AppColors.amber,
          bgColor: AppColors.amberBg,
          icon: Icons.timer_outlined,
        ),
        const SizedBox(width: 12),
        TelemetryMetricCard(
          label: 'Habit Consistency',
          value: habits.isEmpty ? '0 Active' : '$completedHabitsToday/${habits.length}',
          subValue: habits.isEmpty ? 'Create First Habit' : 'Completed Today',
          accentColor: AppColors.mint,
          bgColor: AppColors.mintBg,
          icon: Icons.repeat_rounded,
        ),
        const SizedBox(width: 12),
        TelemetryMetricCard(
          label: 'Study Squad Alpha',
          value: '${cohortState.cohort.totalGroupProblemsToday} Solved',
          subValue: '${cohortState.cohort.activeFocusingMembersCount} Live Now',
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
      BuildContext context, WidgetRef ref, Task? heroTask) {
    if (heroTask == null) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.surfaceTier1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderSubtle),
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
                  child: Text('NEXT ACTION',
                      style: AppTypography.monoBadge
                          .copyWith(color: AppColors.cyan, fontSize: 10)),
                ),
                const SizedBox(width: 10),
                Text('Ready for execution', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'No active tasks in your queue.',
              style: AppTypography.heading1.copyWith(fontSize: 17, color: AppColors.textHigh),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your first high-priority task in Tasks or start practicing from the Striver DSA Sheet.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/tasks'),
                  icon: const Icon(Icons.add_task_rounded, size: 16, color: Color(0xFF0B0D13)),
                  label: Text(
                    'ADD FIRST TASK',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF0B0D13),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => context.go('/dsa'),
                  icon: const Icon(Icons.code_rounded, size: 16, color: AppColors.textMedium),
                  label: Text('Open Striver Sheet', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMedium)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: heroTask.priority.color.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: heroTask.priority.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('PRIMARY NEXT ACTION',
                    style: AppTypography.monoBadge
                        .copyWith(color: heroTask.priority.color, fontSize: 10)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  heroTask.milestoneTitle ?? (heroTask.projectTag != null ? '#${heroTask.projectTag}' : 'Task Queue'),
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: heroTask.priority.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: heroTask.priority.color.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${heroTask.priority.label.toUpperCase()} PRIORITY',
                  style: AppTypography.monoBadge
                      .copyWith(color: heroTask.priority.color, fontSize: 9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            heroTask.title,
            style: AppTypography.heading1.copyWith(
              color: AppColors.textHigh,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Estimated duration: ${heroTask.estimatedMinutes} minutes (${heroTask.estimatedPomodoros} Pomodoro session).',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(focusSessionProvider.notifier).startSession(
                        taskTitle: heroTask.title,
                        objective: 'Priority: ${heroTask.priority.label}',
                        durationMinutes: heroTask.estimatedMinutes,
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
                  context.go('/tasks');
                },
                icon: const Icon(Icons.checklist_rounded,
                    size: 16, color: AppColors.textMedium),
                label: Text(
                  'View All Tasks',
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

  Widget _buildTimelineFlowCard(BuildContext context, TasksState tasksState) {
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
              InkWell(
                onTap: () => context.go('/calendar'),
                child: Text('Calendar ->', style: AppTypography.caption.copyWith(color: AppColors.cyan)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (tasksState.tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No blocks scheduled yet today. Tasks you add with time estimates will appear in your timeline.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tasksState.tasks.take(4).map((t) {
                  return Container(
                    width: 190,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: t.priority.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: t.priority.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          style: AppTypography.monoBadge.copyWith(
                            fontSize: 11,
                            color: t.priority.color,
                            decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${t.estimatedMinutes}m · ${t.priority.label}',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
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
