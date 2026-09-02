import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/natural_language_parser.dart';
import '../../../domain/models/task.dart';
import '../../providers/focus_session_provider.dart';
import '../../providers/tasks_provider.dart';

enum TaskViewMode { list, eisenhower, today, upcoming, archive }

class TasksView extends ConsumerStatefulWidget {
  const TasksView({super.key});

  @override
  ConsumerState<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends ConsumerState<TasksView> {
  final TextEditingController _newController = TextEditingController();
  TaskViewMode _viewMode = TaskViewMode.list;

  @override
  void dispose() {
    _newController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final tasksNotifier = ref.read(tasksProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UNIFIED TASK MATRIX & SMART VIEWS', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Natural language quick capture, Eisenhower 4-quadrant triage, and Pomodoro tallies.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                // View Mode Switcher
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier1,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      _buildViewModeBtn('List View', TaskViewMode.list),
                      _buildViewModeBtn('Eisenhower Matrix', TaskViewMode.eisenhower),
                      _buildViewModeBtn('Today', TaskViewMode.today),
                      _buildViewModeBtn('Upcoming (7D)', TaskViewMode.upcoming),
                      _buildViewModeBtn('Archive', TaskViewMode.archive),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Natural Language Task Creator Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on_rounded, size: 20, color: AppColors.cyan),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _newController,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textHigh),
                      decoration: InputDecoration(
                        hintText: 'Natural Quick Capture: e.g. Solve LeetCode 124 tomorrow 8am #dsa !p0 ~45m @deep ... Enter',
                        hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          final parsed = NaturalLanguageTaskParser.parse(val);
                          tasksNotifier.addTask(Task(
                            id: 'tk-${DateTime.now().millisecondsSinceEpoch}',
                            title: parsed.title,
                            priority: parsed.priority,
                            cognitiveTier: parsed.cognitiveTier,
                            estimatedMinutes: parsed.estimatedMinutes,
                            estimatedPomodoros: parsed.estimatedPomodoros,
                            dueDate: parsed.dueDate,
                            projectTag: parsed.projectTag,
                          ));
                          _newController.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Dynamic Body Based on View Mode
            if (_viewMode == TaskViewMode.eisenhower)
              _buildEisenhowerMatrix(tasksState, tasksNotifier)
            else if (_viewMode == TaskViewMode.today)
              _buildTodayQueue(tasksState, tasksNotifier)
            else if (_viewMode == TaskViewMode.upcoming)
              _buildUpcomingView(tasksState, tasksNotifier)
            else if (_viewMode == TaskViewMode.archive)
              _buildArchiveView(tasksState, tasksNotifier)
            else
              _buildStandardListView(tasksState, tasksNotifier),
          ],
        ),
      ),
    );
  }

  Widget _buildViewModeBtn(String label, TaskViewMode mode) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () => setState(() => _viewMode = mode),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surfaceHover : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppColors.cyan.withValues(alpha: 0.4) : Colors.transparent),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isSelected ? AppColors.cyan : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // 1. Eisenhower 4-Quadrant Matrix
  Widget _buildEisenhowerMatrix(TasksState state, TasksNotifier notifier) {
    final q1 = state.tasks.where((t) => t.priority == TaskPriority.p0 && !t.isCompleted).toList();
    final q2 = state.tasks.where((t) => t.priority == TaskPriority.p1 && !t.isCompleted).toList();
    final q3 = state.tasks.where((t) => t.priority == TaskPriority.p2 && t.cognitiveTier == CognitiveTier.shallow1x && !t.isCompleted).toList();
    final q4 = state.tasks.where((t) => t.priority == TaskPriority.p2 && t.cognitiveTier != CognitiveTier.shallow1x && !t.isCompleted).toList();

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildQuadrantCard('Q1: URGENT & CRUCIAL (DO FIRST)', 'P0 Deep Work - Execute Today', AppColors.rose, AppColors.roseBg, q1, notifier)),
            const SizedBox(width: 16),
            Expanded(child: _buildQuadrantCard('Q2: STRATEGIC & IMPORTANT (SCHEDULE)', 'P1 Long-Term Goals & Milestones', AppColors.cyan, AppColors.cyanBg, q2, notifier)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildQuadrantCard('Q3: URGENT & LOW LEVERAGE (DELEGATE/BATCH)', 'P2 Shallow Tasks - Batch in 15m intervals', AppColors.amber, AppColors.amberBg, q3, notifier)),
            const SizedBox(width: 16),
            Expanded(child: _buildQuadrantCard('Q4: DEFER / BACKLOG (TRIAGE)', 'Lowest Priority - Re-evaluate or eliminate', AppColors.textMuted, AppColors.surfaceTier2, q4, notifier)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuadrantCard(String title, String subtitle, Color color, Color bgColor, List<Task> tasks, TasksNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: const BoxConstraints(minHeight: 220),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: AppTypography.monoBadge.copyWith(color: color, fontSize: 11))),
              Text('${tasks.length}', style: AppTypography.monoBadge.copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10)),
          const Divider(color: AppColors.borderSubtle, height: 20),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Center(child: Text('Quadrant clear.', style: AppTypography.caption.copyWith(color: AppColors.textSubtle))),
            )
          else
            ...tasks.map((t) => _buildTaskRow(t, notifier)),
        ],
      ),
    );
  }

  // 2. Standard List View with Filters
  Widget _buildStandardListView(TasksState state, TasksNotifier notifier) {
    final tasks = state.filteredTasks;
    return Column(
      children: [
        // Filter Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceTier1,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(
            children: [
              Text('Priority:', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              const SizedBox(width: 8),
              _buildChip('All', state.filterPriority == null, () => notifier.setPriorityFilter(null)),
              _buildChip('P0', state.filterPriority == TaskPriority.p0, () => notifier.setPriorityFilter(TaskPriority.p0), color: AppColors.rose),
              _buildChip('P1', state.filterPriority == TaskPriority.p1, () => notifier.setPriorityFilter(TaskPriority.p1), color: AppColors.amber),
              _buildChip('P2', state.filterPriority == TaskPriority.p2, () => notifier.setPriorityFilter(TaskPriority.p2), color: AppColors.cyan),
              const SizedBox(width: 20),
              Text('Cognitive:', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
              const SizedBox(width: 8),
              _buildChip('All', state.filterCognitiveTier == null, () => notifier.setCognitiveFilter(null)),
              _buildChip('Deep 3x', state.filterCognitiveTier == CognitiveTier.deep3x, () => notifier.setCognitiveFilter(CognitiveTier.deep3x), color: AppColors.cyan),
              _buildChip('Medium 2x', state.filterCognitiveTier == CognitiveTier.medium2x, () => notifier.setCognitiveFilter(CognitiveTier.medium2x), color: AppColors.amber),
              _buildChip('Shallow 1x', state.filterCognitiveTier == CognitiveTier.shallow1x, () => notifier.setCognitiveFilter(CognitiveTier.shallow1x)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...tasks.map((task) => _buildTaskRow(task, notifier)),
      ],
    );
  }

  // 3. Today Queue
  Widget _buildTodayQueue(TasksState state, TasksNotifier notifier) {
    final todayTasks = state.tasks.where((t) => !t.isCompleted).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TODAY FOCUS QUEUE', style: AppTypography.heading2),
        const SizedBox(height: 12),
        ...todayTasks.map((t) => _buildTaskRow(t, notifier)),
      ],
    );
  }

  // 4. Upcoming 7 Days View
  Widget _buildUpcomingView(TasksState state, TasksNotifier notifier) {
    final upcomingTasks = state.tasks.where((t) => !t.isCompleted).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NEXT 7 DAYS TIMELINE', style: AppTypography.heading2),
        const SizedBox(height: 12),
        ...upcomingTasks.map((t) => _buildTaskRow(t, notifier)),
      ],
    );
  }

  // 5. Completed Archive
  Widget _buildArchiveView(TasksState state, TasksNotifier notifier) {
    final archived = state.tasks.where((t) => t.isCompleted).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('COMPLETED TASK ARCHIVE', style: AppTypography.heading2),
        const SizedBox(height: 12),
        if (archived.isEmpty)
          Center(child: Text('No archived tasks.', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)))
        else
          ...archived.map((t) => _buildTaskRow(t, notifier)),
      ],
    );
  }

  Widget _buildTaskRow(Task task, TasksNotifier notifier) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: task.isCompleted ? AppColors.surfaceTier1.withValues(alpha: 0.5) : AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.isCompleted ? AppColors.mint.withValues(alpha: 0.2) : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => notifier.toggleTask(task.id),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: task.isCompleted ? AppColors.mint : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: task.isCompleted ? AppColors.mint : AppColors.borderActive,
                  width: 1.5,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 12, color: Color(0xFF0B0D13))
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: task.isCompleted ? AppColors.textMuted : AppColors.textHigh,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.projectTag != null || task.milestoneTitle != null)
                  Text(
                    '${task.projectTag != null ? '#${task.projectTag}  |  ' : ''}${task.milestoneTitle ?? ''}',
                    style: AppTypography.caption.copyWith(color: AppColors.textSubtle, fontSize: 10),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Pomodoro Tally Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.surfaceTier2,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              '${task.loggedPomodoros}/${task.estimatedPomodoros} Pomos',
              style: AppTypography.monoBadge.copyWith(fontSize: 9, color: AppColors.amber),
            ),
          ),
          const SizedBox(width: 6),

          // Priority Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: task.priority == TaskPriority.p0 ? AppColors.roseBg : AppColors.surfaceTier2,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              task.priority.name.toUpperCase(),
              style: AppTypography.monoBadge.copyWith(
                fontSize: 9,
                color: task.priority == TaskPriority.p0 ? AppColors.rose : AppColors.textMedium,
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Launch Focus for Task
          IconButton(
            icon: const Icon(Icons.play_arrow_rounded, size: 16, color: AppColors.cyan),
            onPressed: () {
              ref.read(focusSessionProvider.notifier).startSession(
                    taskTitle: task.title,
                    objective: 'Priority: ${task.priority.name.toUpperCase()} | Tier: ${task.cognitiveTier.name}',
                    durationMinutes: task.estimatedMinutes,
                  );
              context.go('/focus');
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
