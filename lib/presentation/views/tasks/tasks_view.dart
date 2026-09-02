import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/task.dart';
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
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UNIFIED TASK MATRIX', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Atomic execution units categorized by priority and cognitive energy demand.',
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

            // Inline Task Creator Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderActive),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_rounded, size: 20, color: AppColors.cyan),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _newController,
                      style: AppTypography.bodyLarge.copyWith(color: AppColors.textHigh),
                      decoration: InputDecoration(
                        hintText: 'Add new task (e.g. Profile kernel memory with Nsight)... Press Enter',
                        hintStyle: AppTypography.bodyLarge.copyWith(color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          tasksNotifier.addTask(Task(
                            id: 'tk-${DateTime.now().millisecondsSinceEpoch}',
                            title: val.trim(),
                            priority: TaskPriority.p0,
                            cognitiveTier: CognitiveTier.deep3x,
                            estimatedMinutes: 45,
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
                  _buildChip('All', tasksState.filterPriority == null, () => tasksNotifier.setPriorityFilter(null)),
                  _buildChip('P0', tasksState.filterPriority == TaskPriority.p0, () => tasksNotifier.setPriorityFilter(TaskPriority.p0), color: AppColors.rose),
                  _buildChip('P1', tasksState.filterPriority == TaskPriority.p1, () => tasksNotifier.setPriorityFilter(TaskPriority.p1), color: AppColors.amber),
                  _buildChip('P2', tasksState.filterPriority == TaskPriority.p2, () => tasksNotifier.setPriorityFilter(TaskPriority.p2), color: AppColors.cyan),
                  const SizedBox(width: 20),
                  Text('Cognitive:', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                  const SizedBox(width: 8),
                  _buildChip('All', tasksState.filterCognitiveTier == null, () => tasksNotifier.setCognitiveFilter(null)),
                  _buildChip('Deep 3x', tasksState.filterCognitiveTier == CognitiveTier.deep3x, () => tasksNotifier.setCognitiveFilter(CognitiveTier.deep3x), color: AppColors.cyan),
                  _buildChip('Medium 2x', tasksState.filterCognitiveTier == CognitiveTier.medium2x, () => tasksNotifier.setCognitiveFilter(CognitiveTier.medium2x), color: AppColors.amber),
                  _buildChip('Shallow 1x', tasksState.filterCognitiveTier == CognitiveTier.shallow1x, () => tasksNotifier.setCognitiveFilter(CognitiveTier.shallow1x)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Tasks List
            ...tasks.map((task) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      onTap: () => tasksNotifier.toggleTask(task.id),
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
                          if (task.milestoneTitle != null)
                            Text(
                              task.milestoneTitle!,
                              style: AppTypography.caption.copyWith(color: AppColors.textSubtle),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: task.priority == TaskPriority.p0
                            ? AppColors.roseBg
                            : task.priority == TaskPriority.p1
                                ? AppColors.amberBg
                                : AppColors.surfaceTier2,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        task.priority.name.toUpperCase(),
                        style: AppTypography.monoBadge.copyWith(
                          fontSize: 9,
                          color: task.priority == TaskPriority.p0
                              ? AppColors.rose
                              : task.priority == TaskPriority.p1
                                  ? AppColors.amber
                                  : AppColors.textMedium,
                        ),
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
                        task.cognitiveTier == CognitiveTier.deep3x
                            ? 'DEEP 3X'
                            : task.cognitiveTier == CognitiveTier.medium2x
                                ? 'MEDIUM 2X'
                                : 'SHALLOW 1X',
                        style: AppTypography.monoBadge.copyWith(fontSize: 9, color: AppColors.cyan),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('${task.estimatedMinutes}m', style: AppTypography.caption.copyWith(color: AppColors.textSubtle)),
                  ],
                ),
              );
            }),
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
