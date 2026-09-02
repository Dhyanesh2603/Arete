import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/task.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dsa_provider.dart';
import '../../providers/focus_session_provider.dart';
import '../../providers/peer_cohort_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../widgets/invite_member_dialog.dart';

class MissionControlView extends ConsumerWidget {
  const MissionControlView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsaState = ref.watch(dsaProvider);
    final tasksState = ref.watch(tasksProvider);
    final squadState = ref.watch(peerCohortProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;

    final pendingTasks = tasksState.tasks.where((t) => !t.isCompleted).toList();
    final highPriorityTasks = pendingTasks.where((t) => t.priority == TaskPriority.high).toList();
    final firstPendingTask = highPriorityTasks.isNotEmpty
        ? highPriorityTasks.first
        : pendingTasks.isNotEmpty
            ? pendingTasks.first
            : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 960;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sleek Minimalist Header (No circular symbols)
              _buildCleanHeader(context, user, isWide, dsaState),
              const SizedBox(height: 20),

              // 2. Focused Vital Cards (Only essential metrics)
              _buildVitalCards(context, dsaState, pendingTasks, squadState, isWide),
              const SizedBox(height: 24),

              // 3. Primary Next Action & Today's Priorities
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Primary Next Action & Today's Tasks
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPrimaryActionCard(context, ref, firstPendingTask),
                          const SizedBox(height: 20),
                          _buildPriorityTaskList(context, ref, pendingTasks),
                        ],
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Right Column: Study Squad (with Invite by Email) & Topics
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStudySquadCard(context, squadState),
                          const SizedBox(height: 20),
                          _buildDsaTopicGatesCard(context, dsaState),
                        ],
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPrimaryActionCard(context, ref, firstPendingTask),
                    const SizedBox(height: 20),
                    _buildPriorityTaskList(context, ref, pendingTasks),
                    const SizedBox(height: 20),
                    _buildStudySquadCard(context, squadState),
                    const SizedBox(height: 20),
                    _buildDsaTopicGatesCard(context, dsaState),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCleanHeader(
      BuildContext context, dynamic user, bool isWide, DsaState dsaState) {
    final userName = user?.name ?? 'Developer';
    final userRole = user?.targetRole ?? 'Software Engineer & DSA Aspirant';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        children: [
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
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 10),
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
                const SizedBox(height: 4),
                Text(
                  userRole,
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isWide) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier2,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.bolt_rounded, size: 14, color: AppColors.amber),
                  const SizedBox(width: 6),
                  Text(
                    '${user?.streakDays ?? 0} Day Streak',
                    style: AppTypography.monoBadge.copyWith(color: AppColors.amber, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier2,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.code_rounded, size: 14, color: AppColors.cyan),
                  const SizedBox(width: 6),
                  Text(
                    '${dsaState.solvedCount} / ${dsaState.totalCount} Solved',
                    style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVitalCards(BuildContext context, DsaState dsaState,
      List<Task> pendingTasks, PeerCohortState squadState, bool isWide) {
    final highCount = pendingTasks.where((t) => t.priority == TaskPriority.high).length;
    final medCount = pendingTasks.where((t) => t.priority == TaskPriority.medium).length;
    final lowCount = pendingTasks.where((t) => t.priority == TaskPriority.low).length;

    return Row(
      children: [
        // Card 1: Striver DSA Sheet Progress
        Expanded(
          child: InkWell(
            onTap: () => context.go('/dsa'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(18),
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
                      const Icon(Icons.code_rounded, size: 18, color: AppColors.cyan),
                      const SizedBox(width: 8),
                      Text('Striver A2Z Sheet', style: AppTypography.caption.copyWith(color: AppColors.textMedium)),
                      const Spacer(),
                      Text(
                        '${dsaState.overallProgressPercentage.toStringAsFixed(1)}%',
                        style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${dsaState.solvedCount} / ${dsaState.totalCount}',
                    style: AppTypography.heading1.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: dsaState.totalCount == 0 ? 0 : dsaState.solvedCount / dsaState.totalCount,
                      backgroundColor: AppColors.surfaceTier2,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Card 2: Active Task Queue
        Expanded(
          child: InkWell(
            onTap: () => context.go('/tasks'),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(18),
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
                      const Icon(Icons.checklist_rounded, size: 18, color: AppColors.amber),
                      const SizedBox(width: 8),
                      Text('Priority Queue', style: AppTypography.caption.copyWith(color: AppColors.textMedium)),
                      const Spacer(),
                      Text('Tasks ->', style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${pendingTasks.length} Pending',
                    style: AppTypography.heading1.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildPriorityTag('High', highCount, AppColors.rose, AppColors.roseBg),
                      const SizedBox(width: 6),
                      _buildPriorityTag('Med', medCount, AppColors.amber, AppColors.amberBg),
                      const SizedBox(width: 6),
                      _buildPriorityTag('Low', lowCount, AppColors.mint, AppColors.mintBg),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityTag(String label, int count, Color color, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $count',
        style: AppTypography.monoBadge.copyWith(color: color, fontSize: 10),
      ),
    );
  }

  Widget _buildPrimaryActionCard(
      BuildContext context, WidgetRef ref, Task? heroTask) {
    if (heroTask == null) {
      return Container(
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cyanBg,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('PRIMARY ACTION',
                      style: AppTypography.monoBadge
                          .copyWith(color: AppColors.cyan, fontSize: 9)),
                ),
                const SizedBox(width: 8),
                Text('Queue is clear', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'No high-priority task active right now.',
              style: AppTypography.heading2.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Add your next priority item or pick a problem from the Striver DSA Sheet.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/tasks'),
                  icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF0B0D13)),
                  label: Text('ADD FIRST TASK',
                      style: AppTypography.monoBadge.copyWith(
                          color: const Color(0xFF0B0D13), fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => context.go('/dsa'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('Browse DSA Sheet', style: AppTypography.bodyMedium.copyWith(fontSize: 13)),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: heroTask.priority.color.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: heroTask.priority.backgroundColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${heroTask.priority.label.toUpperCase()} PRIORITY',
                  style: AppTypography.monoBadge
                      .copyWith(color: heroTask.priority.color, fontSize: 9),
                ),
              ),
              const Spacer(),
              Text(
                '${heroTask.estimatedMinutes}m estimate',
                style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            heroTask.title,
            style: AppTypography.heading1.copyWith(fontSize: 17),
          ),
          const SizedBox(height: 14),
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
                    size: 16, color: Color(0xFF0B0D13)),
                label: Text(
                  'START FOCUS',
                  style: AppTypography.monoBadge.copyWith(
                    color: const Color(0xFF0B0D13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => context.go('/tasks'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: Text('View All Tasks', style: AppTypography.bodyMedium.copyWith(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityTaskList(
      BuildContext context, WidgetRef ref, List<Task> pendingTasks) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              Text('PRIORITY TASKS', style: AppTypography.heading2.copyWith(fontSize: 14)),
              const Spacer(),
              InkWell(
                onTap: () => context.go('/tasks'),
                child: Text('Add Task +', style: AppTypography.caption.copyWith(color: AppColors.cyan)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (pendingTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No pending tasks. Your queue is clean.',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted, fontSize: 13),
              ),
            )
          else
            ...pendingTasks.take(4).map((task) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ref.read(tasksProvider.notifier).toggleTask(task.id);
                      },
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: task.priority.color, width: 1.5),
                        ),
                        child: task.isCompleted
                            ? Icon(Icons.check_rounded, size: 14, color: task.priority.color)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        task.title,
                        style: AppTypography.bodyMedium.copyWith(
                          fontSize: 13,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.priority.backgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.priority.label,
                        style: AppTypography.monoBadge.copyWith(
                          color: task.priority.color,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSubtle),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      onPressed: () {
                        ref.read(tasksProvider.notifier).deleteTask(task.id);
                      },
                      tooltip: 'Delete task',
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStudySquadCard(
      BuildContext context, PeerCohortState squadState) {
    final members = squadState.cohort.members;

    return Container(
      padding: const EdgeInsets.all(18),
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
              Text('STUDY SQUAD', style: AppTypography.heading2.copyWith(fontSize: 14)),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const InviteMemberDialog(),
                  );
                },
                icon: const Icon(Icons.add_rounded, size: 14, color: Color(0xFF0B0D13)),
                label: Text(
                  'INVITE PEER',
                  style: AppTypography.monoBadge.copyWith(
                    color: const Color(0xFF0B0D13),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.cyan,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (members.length <= 1)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No study partners invited yet.',
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Invite a friend with their email to compare daily problems and share study accountability.',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            )
          else
            ...members.map((m) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: m.avatarColor,
                      child: Text(
                        m.name.isNotEmpty ? m.name[0].toUpperCase() : 'P',
                        style: AppTypography.monoBadge.copyWith(
                          color: const Color(0xFF0B0D13),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.name, style: AppTypography.bodyMedium.copyWith(fontSize: 12)),
                          Text(
                            m.isInvited ? 'Invitation pending (${m.email})' : m.currentDsaTopic,
                            style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (m.isInvited)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.amberBg,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          'INVITED',
                          style: AppTypography.monoBadge.copyWith(color: AppColors.amber, fontSize: 8),
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

  Widget _buildDsaTopicGatesCard(
      BuildContext context, DsaState dsaState) {
    final summaries = dsaState.stepSummaries.take(4).toList();

    return Container(
      padding: const EdgeInsets.all(18),
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
              Text('TOPIC GATES', style: AppTypography.heading2.copyWith(fontSize: 14)),
              const Spacer(),
              InkWell(
                onTap: () => context.go('/dsa'),
                child: Text('All 18 Steps ->',
                    style: AppTypography.caption.copyWith(color: AppColors.cyan)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...summaries.map((s) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.title,
                          style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${s.solvedProblems}/${s.totalProblems}',
                        style: AppTypography.monoBadge.copyWith(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: s.totalProblems == 0 ? 0.0 : s.solvedProblems / s.totalProblems,
                      backgroundColor: AppColors.surfaceTier2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        s.progressPercentage == 100.0 ? AppColors.mint : AppColors.cyan,
                      ),
                      minHeight: 4,
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
