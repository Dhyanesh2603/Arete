import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/natural_language_parser.dart';
import '../../../domain/models/task.dart';
import '../../providers/focus_session_provider.dart';
import '../../providers/tasks_provider.dart';

class TasksView extends ConsumerStatefulWidget {
  const TasksView({super.key});

  @override
  ConsumerState<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends ConsumerState<TasksView> {
  final TextEditingController _newController = TextEditingController();

  @override
  void dispose() {
    _newController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    final tasksNotifier = ref.read(tasksProvider.notifier);
    final tasks = tasksState.filteredTasks;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TASK MANAGEMENT', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Organize daily action items by High, Medium, and Low priorities.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier1,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    '${tasksState.completedCount} Completed  |  ${tasksState.pendingCount} Pending',
                    style: AppTypography.monoBadge.copyWith(color: AppColors.cyan),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Add Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_task_rounded, size: 20, color: AppColors.cyan),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _newController,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textHigh),
                      decoration: const InputDecoration(
                        hintText: 'Add new task: e.g. Solve LeetCode 124 tomorrow #dsa !high ~45m ... Press Enter',
                        hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
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
            const SizedBox(height: 16),

            // Priority Filter Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Text('Priority Filter:', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                  const SizedBox(width: 10),
                  _buildFilterChip(
                    'All Priorities',
                    tasksState.filterPriority == null,
                    () => tasksNotifier.setPriorityFilter(null),
                  ),
                  _buildFilterChip(
                    'High (Red)',
                    tasksState.filterPriority == TaskPriority.high,
                    () => tasksNotifier.setPriorityFilter(TaskPriority.high),
                    color: TaskPriority.high.color,
                  ),
                  _buildFilterChip(
                    'Medium (Yellow)',
                    tasksState.filterPriority == TaskPriority.medium,
                    () => tasksNotifier.setPriorityFilter(TaskPriority.medium),
                    color: TaskPriority.medium.color,
                  ),
                  _buildFilterChip(
                    'Low (Green)',
                    tasksState.filterPriority == TaskPriority.low,
                    () => tasksNotifier.setPriorityFilter(TaskPriority.low),
                    color: TaskPriority.low.color,
                  ),
                  const Spacer(),
                  // Completed Filter
                  Text('Status:', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'All',
                    tasksState.filterCompleted == null,
                    () => tasksNotifier.setCompletedFilter(null),
                  ),
                  _buildFilterChip(
                    'Pending',
                    tasksState.filterCompleted == false,
                    () => tasksNotifier.setCompletedFilter(false),
                    color: AppColors.cyan,
                  ),
                  _buildFilterChip(
                    'Done',
                    tasksState.filterCompleted == true,
                    () => tasksNotifier.setCompletedFilter(true),
                    color: AppColors.mint,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tasks List
            if (tasks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: Text(
                    'No tasks match the selected filter.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              ...tasks.map((task) => _buildTaskRow(context, ref, task, tasksNotifier)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, {Color? color}) {
    final chipColor = color ?? AppColors.textHigh;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
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

  Widget _buildTaskRow(BuildContext context, WidgetRef ref, Task task, TasksNotifier notifier) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: task.isCompleted ? AppColors.surfaceTier1.withValues(alpha: 0.4) : AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: task.isCompleted ? AppColors.mint.withValues(alpha: 0.2) : AppColors.borderSubtle,
        ),
      ),
      child: Row(
        children: [
          // Completion Checkbox
          InkWell(
            onTap: () => notifier.toggleTask(task.id),
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: task.isCompleted ? AppColors.mint : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: task.isCompleted ? AppColors.mint : AppColors.borderActive,
                  width: 1.5,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 14, color: Color(0xFF0B0D13))
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Title & Tags
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTypography.bodyLarge.copyWith(
                    color: task.isCompleted ? AppColors.textMuted : AppColors.textHigh,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                if (task.projectTag != null || task.milestoneTitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${task.projectTag != null ? '#${task.projectTag}  ' : ''}${task.milestoneTitle != null ? '|  ${task.milestoneTitle}' : ''}',
                    style: AppTypography.caption.copyWith(color: AppColors.textSubtle, fontSize: 10),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Priority Badge: High (Red), Medium (Yellow), Low (Green)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: task.priority.backgroundColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: task.priority.color.withValues(alpha: 0.3)),
            ),
            child: Text(
              task.priority.label.toUpperCase(),
              style: AppTypography.monoBadge.copyWith(
                fontSize: 9,
                color: task.priority.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Pomodoro Estimate Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.surfaceTier2,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${task.estimatedPomodoros} Pomos (${task.estimatedMinutes}m)',
              style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 10),
            ),
          ),
          const SizedBox(width: 8),

          // Start Focus Button
          Tooltip(
            message: 'Start focus timer for this task',
            child: IconButton(
              icon: const Icon(Icons.play_arrow_rounded, size: 18, color: AppColors.cyan),
              onPressed: () {
                ref.read(focusSessionProvider.notifier).startSession(
                      taskTitle: task.title,
                      objective: 'Priority: ${task.priority.label}',
                      durationMinutes: task.estimatedMinutes,
                    );
                context.go('/focus');
              },
            ),
          ),
        ],
      ),
    );
  }
}
