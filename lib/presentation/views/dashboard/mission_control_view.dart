import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/task.dart';
import '../../../domain/models/workspace_page.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dsa_provider.dart';
import '../../providers/focus_session_provider.dart';
import '../../providers/peer_cohort_provider.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/workspace_provider.dart';
import '../../widgets/daily_flight_plan_card.dart';
import '../../widgets/invite_member_dialog.dart';
import '../../widgets/task_detail_modal.dart';

class MissionControlView extends ConsumerWidget {
  const MissionControlView({super.key});

  IconData _resolvePageIcon(String iconKey) {
    switch (iconKey) {
      case 'code':
        return Icons.code_rounded;
      case 'terminal':
        return Icons.terminal_rounded;
      case 'bookmark':
        return Icons.bookmark_border_rounded;
      case 'folder':
        return Icons.folder_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'target':
        return Icons.adjust_rounded;
      case 'rocket':
        return Icons.rocket_launch_outlined;
      case 'bolt':
        return Icons.bolt_rounded;
      case 'storage':
        return Icons.storage_rounded;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'tune':
        return Icons.tune_rounded;
      case 'star':
        return Icons.star_border_rounded;
      case 'checklist':
        return Icons.checklist_rounded;
      case 'menu_book':
        return Icons.menu_book_outlined;
      case 'article':
      default:
        return Icons.article_outlined;
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _formatRelative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.month}/${dt.day}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dsaState = ref.watch(dsaProvider);
    final tasksState = ref.watch(tasksProvider);
    final squadState = ref.watch(peerCohortProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final workspacePages = ref.watch(workspaceProvider);

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
              // 1. Sleek Circadian Workspace Header
              _buildCleanHeader(context, user, isWide, ref),
              const SizedBox(height: 20),

              // 2. High-Signal Workspace Vital Cards
              _buildVitalCards(context, dsaState, pendingTasks, workspacePages, isWide),
              const SizedBox(height: 24),

              // 3. Adaptive Daily Flight Plan Engine
              const DailyFlightPlanCard(),
              const SizedBox(height: 24),

              // 4. Notion-Style Pinned & Recent Documents Showcase
              _buildDocumentsSection(context, ref, workspacePages, isWide),
              const SizedBox(height: 24),

              // 5. Execution & Specialty Engines Section
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Primary Focus & Active Priority Matrix
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
                    // Right Column: Specialty Companions (Striver DSA Track + Study Squad)
                    Expanded(
                      flex: 4,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDsaCompanionCard(context, dsaState),
                          const SizedBox(height: 20),
                          _buildStudySquadCard(context, squadState),
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
                    _buildDsaCompanionCard(context, dsaState),
                    const SizedBox(height: 20),
                    _buildStudySquadCard(context, squadState),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCleanHeader(
    BuildContext context,
    dynamic user,
    bool isWide,
    WidgetRef ref,
  ) {
    final userName = user?.name ?? 'Developer';
    final greeting = _getGreeting();

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
                      '$greeting, $userName',
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
                        'WORKSPACE ACTIVE',
                        style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Unified execution cockpit: documents, priority matrix, and deep work.',
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
            ElevatedButton.icon(
              onPressed: () async {
                final newDoc = await ref.read(workspaceProvider.notifier).createPage();
                if (context.mounted) {
                  context.go('/pages/${newDoc.id}');
                }
              },
              icon: const Icon(Icons.add_rounded, size: 14, color: Color(0xFF0B0D13)),
              label: Text(
                'NEW DOCUMENT',
                style: AppTypography.monoBadge.copyWith(
                  color: const Color(0xFF0B0D13),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cyan,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVitalCards(
    BuildContext context,
    DsaState dsaState,
    List<Task> pendingTasks,
    List<WorkspacePage> workspacePages,
    bool isWide,
  ) {
    final highCount = pendingTasks.where((t) => t.priority == TaskPriority.high).length;
    final medCount = pendingTasks.where((t) => t.priority == TaskPriority.medium).length;
    final lowCount = pendingTasks.where((t) => t.priority == TaskPriority.low).length;
    final pinnedCount = workspacePages.where((p) => p.isPinned).length;

    return Row(
      children: [
        // Card 1: Tasks Queue
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
                      const Icon(Icons.checklist_rounded, size: 18, color: AppColors.cyan),
                      const SizedBox(width: 8),
                      Text('Task Queue', style: AppTypography.caption.copyWith(color: AppColors.textMedium)),
                      const Spacer(),
                      Text('Matrix ->', style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11)),
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
        const SizedBox(width: 14),

        // Card 2: Workspace Documents (Notion style)
        Expanded(
          child: InkWell(
            onTap: () {
              if (workspacePages.isNotEmpty) {
                context.go('/pages/${workspacePages.first.id}');
              }
            },
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
                      const Icon(Icons.article_outlined, size: 18, color: AppColors.indigo),
                      const SizedBox(width: 8),
                      Text('Documents', style: AppTypography.caption.copyWith(color: AppColors.textMedium)),
                      const Spacer(),
                      Text(
                        pinnedCount > 0 ? '$pinnedCount Pinned' : 'Workspace',
                        style: AppTypography.monoBadge.copyWith(color: AppColors.indigo, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${workspacePages.length} Pages',
                    style: AppTypography.heading1.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    workspacePages.isEmpty
                        ? 'Click + to create first page'
                        : 'Latest: ${workspacePages.first.title.isEmpty ? "Untitled" : workspacePages.first.title}',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Card 3: Deep Work Focus Immersion
        Expanded(
          child: InkWell(
            onTap: () => context.go('/focus'),
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
                      const Icon(Icons.timer_outlined, size: 18, color: AppColors.amber),
                      const SizedBox(width: 8),
                      Text('Deep Work', style: AppTypography.caption.copyWith(color: AppColors.textMedium)),
                      const Spacer(),
                      Text('Focus ->', style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Audio & Flow',
                    style: AppTypography.heading1.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Binaural beats & immersion timer',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

  Widget _buildDocumentsSection(
    BuildContext context,
    WidgetRef ref,
    List<WorkspacePage> pages,
    bool isWide,
  ) {
    final recent = pages.take(4).toList();

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
              Text('WORKSPACE DOCUMENTS', style: AppTypography.heading2.copyWith(fontSize: 14)),
              const Spacer(),
              InkWell(
                onTap: () async {
                  final newPage = await ref.read(workspaceProvider.notifier).createPage();
                  if (context.mounted) {
                    context.go('/pages/${newPage.id}');
                  }
                },
                child: Row(
                  children: [
                    const Icon(Icons.add_rounded, size: 14, color: AppColors.cyan),
                    const SizedBox(width: 4),
                    Text('New Page', style: AppTypography.caption.copyWith(color: AppColors.cyan)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          if (recent.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.cyanBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.article_outlined, size: 24, color: AppColors.cyan),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'No documents in this workspace yet',
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Create modular notes, project roadmaps, or technical specifications with slash commands.',
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final p = await ref.read(workspaceProvider.notifier).createPage();
                      if (context.mounted) {
                        context.go('/pages/${p.id}');
                      }
                    },
                    icon: const Icon(Icons.add_rounded, size: 14, color: Color(0xFF0B0D13)),
                    label: Text(
                      'CREATE DOCUMENT',
                      style: AppTypography.monoBadge.copyWith(
                        color: const Color(0xFF0B0D13),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (ctx, constraints) {
                final cardWidth = isWide
                    ? (constraints.maxWidth - (3 * 12)) / 4
                    : (constraints.maxWidth - 12) / 2;

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: recent.map((page) {
                    return InkWell(
                      onTap: () => context.go('/pages/${page.id}'),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTier2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(_resolvePageIcon(page.icon), size: 18, color: AppColors.cyan),
                                const Spacer(),
                                if (page.isPinned)
                                  const Icon(Icons.push_pin_rounded, size: 14, color: AppColors.cyan),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              page.title.isEmpty ? 'Untitled Document' : page.title,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  _formatRelative(page.updatedAt),
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSubtle,
                                    fontSize: 10,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  '${page.blocks.length} blocks',
                                  style: AppTypography.caption.copyWith(
                                    color: AppColors.textSubtle,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPrimaryActionCard(
    BuildContext context,
    WidgetRef ref,
    Task? heroTask,
  ) {
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
              'No active task scheduled.',
              style: AppTypography.heading2.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Add your next priority item to keep your momentum alive.',
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
    BuildContext context,
    WidgetRef ref,
    List<Task> pendingTasks,
  ) {
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
              return InkWell(
                onTap: () => TaskDetailModal.show(context, task),
                borderRadius: BorderRadius.circular(6),
                child: Container(
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
                      PopupMenuButton<TaskPriority>(
                        tooltip: 'Change Priority',
                        color: AppColors.surfaceTier2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: AppColors.borderSubtle),
                        ),
                        onSelected: (newPriority) {
                          ref.read(tasksProvider.notifier).updateTaskPriority(task.id, newPriority);
                        },
                        itemBuilder: (context) => TaskPriority.values.map((p) {
                          return PopupMenuItem<TaskPriority>(
                            value: p,
                            height: 36,
                            child: Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: p.color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  p.label,
                                  style: AppTypography.monoBadge.copyWith(
                                    color: p.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: task.priority.backgroundColor,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: task.priority.color.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                task.priority.label,
                                style: AppTypography.monoBadge.copyWith(
                                  color: task.priority.color,
                                  fontSize: 9,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.arrow_drop_down_rounded, size: 12, color: task.priority.color),
                            ],
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
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDsaCompanionCard(
    BuildContext context,
    DsaState dsaState,
  ) {
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
              const Icon(Icons.code_rounded, size: 16, color: AppColors.cyan),
              const SizedBox(width: 8),
              Text('STRIVER DSA TRACK', style: AppTypography.heading2.copyWith(fontSize: 14)),
              const Spacer(),
              InkWell(
                onTap: () => context.go('/dsa'),
                child: Text('Curriculum ->',
                    style: AppTypography.caption.copyWith(color: AppColors.cyan)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                '${dsaState.solvedCount} / ${dsaState.totalCount} Solved',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Spacer(),
              Text(
                '${dsaState.overallProgressPercentage.toStringAsFixed(1)}%',
                style: AppTypography.monoBadge.copyWith(color: AppColors.cyan, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: dsaState.totalCount == 0 ? 0.0 : dsaState.solvedCount / dsaState.totalCount,
              backgroundColor: AppColors.surfaceTier2,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceTier2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              children: [
                const Icon(Icons.psychology_outlined, size: 16, color: AppColors.amber),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dsaState.revisionDueCount > 0
                        ? '${dsaState.revisionDueCount} problem(s) due for SM-2 review'
                        : 'SM-2 spaced retention schedule up to date',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudySquadCard(
    BuildContext context,
    PeerCohortState squadState,
  ) {
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
                    'Invite a peer with their email to compare daily problems and share study accountability.',
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
}
