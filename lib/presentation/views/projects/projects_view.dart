import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/project.dart';
import '../../providers/projects_provider.dart';

class ProjectsView extends ConsumerStatefulWidget {
  const ProjectsView({super.key});

  @override
  ConsumerState<ProjectsView> createState() => _ProjectsViewState();
}

class _ProjectsViewState extends ConsumerState<ProjectsView> {
  int _selectedProjectIndex = 0;

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final projectsNotifier = ref.read(projectsProvider.notifier);

    if (projects.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.canvas,
        body: Center(child: Text('No active projects.')),
      );
    }

    final currentProject = projects[_selectedProjectIndex.clamp(0, projects.length - 1)];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header & Project Selector Tabs
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROJECTS & KANBAN MATRIX', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Finite execution scopes with technical architecture context.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                // Project Switcher Pills
                ...projects.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final p = entry.value;
                  final isSelected = idx == _selectedProjectIndex;

                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: InkWell(
                      onTap: () => setState(() => _selectedProjectIndex = idx),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.surfaceHover : AppColors.surfaceTier1,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected ? AppColors.cyan : AppColors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          p.title.length > 25 ? '${p.title.substring(0, 22)}...' : p.title,
                          style: AppTypography.caption.copyWith(
                            color: isSelected ? AppColors.cyan : AppColors.textMedium,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),

            // Project Info Banner
            Container(
              padding: const EdgeInsets.all(18),
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
                        Text(currentProject.title, style: AppTypography.heading2),
                        const SizedBox(height: 4),
                        Text(
                          'Goal: ${currentProject.goalTitle}  |  Deadline: ${currentProject.deadline.year}-${currentProject.deadline.month}-${currentProject.deadline.day}',
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${currentProject.completedTasks} / ${currentProject.totalTasks} Tasks (${currentProject.progressPercentage.toStringAsFixed(0)}%)',
                    style: AppTypography.monoBadge.copyWith(color: AppColors.mint, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Kanban Board Columns (Backlog, In Progress, In Review, Completed)
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKanbanColumn(
                    title: 'BACKLOG',
                    column: ProjectColumn.backlog,
                    color: AppColors.textMuted,
                    bgColor: AppColors.surfaceTier2,
                    tasks: currentProject.tasks.where((t) => t.column == ProjectColumn.backlog).toList(),
                    project: currentProject,
                    notifier: projectsNotifier,
                  ),
                  const SizedBox(width: 14),
                  _buildKanbanColumn(
                    title: 'IN PROGRESS',
                    column: ProjectColumn.inProgress,
                    color: AppColors.cyan,
                    bgColor: AppColors.cyanBg,
                    tasks: currentProject.tasks.where((t) => t.column == ProjectColumn.inProgress).toList(),
                    project: currentProject,
                    notifier: projectsNotifier,
                  ),
                  const SizedBox(width: 14),
                  _buildKanbanColumn(
                    title: 'IN REVIEW',
                    column: ProjectColumn.inReview,
                    color: AppColors.amber,
                    bgColor: AppColors.amberBg,
                    tasks: currentProject.tasks.where((t) => t.column == ProjectColumn.inReview).toList(),
                    project: currentProject,
                    notifier: projectsNotifier,
                  ),
                  const SizedBox(width: 14),
                  _buildKanbanColumn(
                    title: 'COMPLETED',
                    column: ProjectColumn.completed,
                    color: AppColors.mint,
                    bgColor: AppColors.mintBg,
                    tasks: currentProject.tasks.where((t) => t.column == ProjectColumn.completed).toList(),
                    project: currentProject,
                    notifier: projectsNotifier,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanColumn({
    required String title,
    required ProjectColumn column,
    required Color color,
    required Color bgColor,
    required List<ProjectTask> tasks,
    required Project project,
    required ProjectsNotifier notifier,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
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
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Text(title, style: AppTypography.monoBadge.copyWith(color: color, fontSize: 11)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier2,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${tasks.length}', style: AppTypography.monoBadge.copyWith(fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Text('No tasks in $title',
                          style: AppTypography.caption.copyWith(color: AppColors.textSubtle)),
                    )
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, idx) {
                        final task = tasks[idx];
                        return _buildKanbanTaskCard(task, project, notifier);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanTaskCard(ProjectTask task, Project project, ProjectsNotifier notifier) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: task.priority == 'P0' ? AppColors.roseBg : AppColors.surfaceHover,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.priority,
                  style: AppTypography.monoBadge.copyWith(
                    fontSize: 9,
                    color: task.priority == 'P0' ? AppColors.rose : AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.cyanBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.cognitiveTier,
                  style: AppTypography.monoBadge.copyWith(fontSize: 9, color: AppColors.cyan),
                ),
              ),
              const Spacer(),
              Text('${task.estimatedMinutes}m', style: AppTypography.caption.copyWith(color: AppColors.textSubtle)),
            ],
          ),
          const SizedBox(height: 8),
          Text(task.title, style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh)),
          const SizedBox(height: 10),
          // Shift Column Quick Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (task.column != ProjectColumn.backlog)
                _buildShiftBtn(Icons.arrow_back_rounded, () {
                  final prev = ProjectColumn.values[task.column.index - 1];
                  notifier.moveTask(project.id, task.id, prev);
                }),
              const SizedBox(width: 4),
              if (task.column != ProjectColumn.completed)
                _buildShiftBtn(Icons.arrow_forward_rounded, () {
                  final next = ProjectColumn.values[task.column.index + 1];
                  notifier.moveTask(project.id, task.id, next);
                }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surfaceTier1,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Icon(icon, size: 12, color: AppColors.textMuted),
      ),
    );
  }
}
