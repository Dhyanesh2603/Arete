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

  void _showCreateProjectDialog() {
    final titleCtrl = TextEditingController();
    final goalCtrl = TextEditingController();
    final archCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            width: 460,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceTier1,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.borderActive),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.cyanBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.view_kanban_rounded,
                          size: 16, color: AppColors.cyan),
                    ),
                    const SizedBox(width: 10),
                    Text('Create Project',
                        style: AppTypography.heading2.copyWith(fontSize: 16)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text('Project Title',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textMedium)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: TextField(
                    controller: titleCtrl,
                    style: AppTypography.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Distributed Cache Engine',
                      hintStyle:
                          TextStyle(fontSize: 12, color: AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Strategic Goal Anchor',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textMedium)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: TextField(
                    controller: goalCtrl,
                    style: AppTypography.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Master Distributed Systems',
                      hintStyle:
                          TextStyle(fontSize: 12, color: AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Technical Architecture Notes (Markdown)',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textMedium)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier2,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: TextField(
                    controller: archCtrl,
                    maxLines: 3,
                    style: AppTypography.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'Core technical specs, algorithms, and invariants.',
                      hintStyle:
                          TextStyle(fontSize: 12, color: AppColors.textMuted),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Cancel',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textMuted)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        final title = titleCtrl.text.trim();
                        if (title.isEmpty) return;

                        ref.read(projectsProvider.notifier).createProject(
                              title: title,
                              goalTitle: goalCtrl.text.trim(),
                              architectureMarkdown: archCtrl.text.trim(),
                              deadline: DateTime.now()
                                  .add(const Duration(days: 30)),
                            );
                        Navigator.of(ctx).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text(
                        'CREATE PROJECT',
                        style: AppTypography.monoBadge.copyWith(
                          color: const Color(0xFF0B0D13),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddTaskDialog(String projectId) {
    final titleCtrl = TextEditingController();
    ProjectColumn selectedCol = ProjectColumn.backlog;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (dialogCtx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderActive),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Project Task',
                      style: AppTypography.heading2.copyWith(fontSize: 16)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: titleCtrl,
                    style: AppTypography.bodyMedium,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Implement Raft heartbeat logic',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButton<ProjectColumn>(
                    value: selectedCol,
                    dropdownColor: AppColors.surfaceTier2,
                    items: ProjectColumn.values.map((col) {
                      return DropdownMenuItem(
                        value: col,
                        child: Text(col.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedCol = val);
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final title = titleCtrl.text.trim();
                          if (title.isEmpty) return;

                          ref.read(projectsProvider.notifier).addProjectTask(
                                projectId,
                                ProjectTask(
                                  id: 'pt-${DateTime.now().millisecondsSinceEpoch}',
                                  projectId: projectId,
                                  title: title,
                                  column: selectedCol,
                                  priority: 'High',
                                  estimatedMinutes: 45,
                                  loggedMinutes: 0,
                                ),
                              );
                          Navigator.of(ctx).pop();
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan),
                        child: Text('ADD TASK',
                            style: AppTypography.monoBadge
                                .copyWith(color: const Color(0xFF0B0D13))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final projects = ref.watch(projectsProvider);
    final projectsNotifier = ref.read(projectsProvider.notifier);

    if (projects.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.canvas,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PROJECTS & KANBAN',
                          style: AppTypography.heading1),
                      const SizedBox(height: 4),
                      Text(
                        'Finite execution scopes with technical architecture context.',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _showCreateProjectDialog,
                    icon: const Icon(Icons.add_rounded,
                        size: 16, color: Color(0xFF0B0D13)),
                    label: Text(
                      'CREATE PROJECT',
                      style: AppTypography.monoBadge.copyWith(
                        color: const Color(0xFF0B0D13),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 80),
              Center(
                child: Container(
                  width: 480,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceTier1,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.view_kanban_outlined,
                          size: 42, color: AppColors.textSubtle),
                      const SizedBox(height: 14),
                      Text('No active projects',
                          style: AppTypography.heading2.copyWith(fontSize: 16)),
                      const SizedBox(height: 6),
                      Text(
                        'Create a project to map your technical milestones, architecture specs, and Kanban task stages.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textMuted, fontSize: 13),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _showCreateProjectDialog,
                        icon: const Icon(Icons.add_rounded,
                            size: 16, color: Color(0xFF0B0D13)),
                        label: Text(
                          'CREATE FIRST PROJECT',
                          style: AppTypography.monoBadge.copyWith(
                            color: const Color(0xFF0B0D13),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.cyan,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentProject =
        projects[_selectedProjectIndex.clamp(0, projects.length - 1)];

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
                    Text('PROJECTS & KANBAN',
                        style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Finite execution scopes with technical architecture context.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textMuted),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.surfaceHover
                              : AppColors.surfaceTier1,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.cyan
                                : AppColors.borderSubtle,
                          ),
                        ),
                        child: Text(
                          p.title,
                          style: AppTypography.monoBadge.copyWith(
                            color: isSelected
                                ? AppColors.cyan
                                : AppColors.textMedium,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline_rounded,
                      size: 20, color: AppColors.cyan),
                  onPressed: _showCreateProjectDialog,
                  tooltip: 'Create New Project',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Project Info Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentProject.title,
                            style: AppTypography.heading2.copyWith(fontSize: 15)),
                        if (currentProject.goalTitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text('Anchor: ${currentProject.goalTitle}',
                              style: AppTypography.caption
                                  .copyWith(color: AppColors.textMuted)),
                        ],
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddTaskDialog(currentProject.id),
                    icon: const Icon(Icons.add_rounded,
                        size: 14, color: Color(0xFF0B0D13)),
                    label: Text(
                      'ADD TASK',
                      style: AppTypography.monoBadge.copyWith(
                        color: const Color(0xFF0B0D13),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded,
                        size: 18, color: AppColors.textSubtle),
                    onPressed: () {
                      projectsNotifier.deleteProject(currentProject.id);
                    },
                    tooltip: 'Delete Project',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Kanban Columns
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKanbanCol(
                      'BACKLOG', ProjectColumn.backlog, currentProject, projectsNotifier),
                  const SizedBox(width: 14),
                  _buildKanbanCol('IN PROGRESS', ProjectColumn.inProgress,
                      currentProject, projectsNotifier),
                  const SizedBox(width: 14),
                  _buildKanbanCol('IN REVIEW', ProjectColumn.inReview,
                      currentProject, projectsNotifier),
                  const SizedBox(width: 14),
                  _buildKanbanCol('COMPLETED', ProjectColumn.completed,
                      currentProject, projectsNotifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanCol(String title, ProjectColumn col, Project project,
      ProjectsNotifier notifier) {
    final colTasks = project.tasks.where((t) => t.column == col).toList();

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceTier1,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(title,
                    style: AppTypography.monoBadge
                        .copyWith(fontSize: 11, color: AppColors.textMedium)),
                const Spacer(),
                Text('${colTasks.length}',
                    style: AppTypography.monoBadge
                        .copyWith(fontSize: 10, color: AppColors.textMuted)),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: AppColors.borderSubtle, height: 1),
            const SizedBox(height: 10),
            Expanded(
              child: colTasks.isEmpty
                  ? Center(
                      child: Text(
                        'Empty',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSubtle),
                      ),
                    )
                  : ListView.builder(
                      itemCount: colTasks.length,
                      itemBuilder: (ctx, idx) {
                        final task = colTasks[idx];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceTier2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.title,
                                  style: AppTypography.bodyMedium
                                      .copyWith(fontSize: 12)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text('${task.estimatedMinutes}m',
                                      style: AppTypography.monoBadge
                                          .copyWith(fontSize: 9, color: AppColors.textMuted)),
                                  const Spacer(),
                                  if (col != ProjectColumn.backlog)
                                    InkWell(
                                      onTap: () {
                                        final prev =
                                            ProjectColumn.values[col.index - 1];
                                        notifier.moveTask(
                                            project.id, task.id, prev);
                                      },
                                      child: const Icon(
                                          Icons.arrow_back_rounded,
                                          size: 14,
                                          color: AppColors.textMuted),
                                    ),
                                  if (col != ProjectColumn.completed) ...[
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        final next =
                                            ProjectColumn.values[col.index + 1];
                                        notifier.moveTask(
                                            project.id, task.id, next);
                                      },
                                      child: const Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 14,
                                          color: AppColors.cyan),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
