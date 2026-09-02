import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../providers/command_palette_provider.dart';
import '../providers/dsa_provider.dart';
import '../providers/focus_session_provider.dart';
import '../providers/projects_provider.dart';
import '../providers/tasks_provider.dart';
import '../../domain/models/task.dart';

class CommandPaletteModal extends ConsumerStatefulWidget {
  const CommandPaletteModal({super.key});

  @override
  ConsumerState<CommandPaletteModal> createState() =>
      _CommandPaletteModalState();
}

class _CommandPaletteModalState extends ConsumerState<CommandPaletteModal> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paletteState = ref.watch(commandPaletteProvider);
    final dsaState = ref.watch(dsaProvider);
    final projects = ref.watch(projectsProvider);
    final tasksState = ref.watch(tasksProvider);
    final query = paletteState.query.toLowerCase().trim();

    final List<_CommandItem> items = [];

    // System Actions
    items.add(_CommandItem(
      title: 'Start 45m Deep Work Focus Session',
      subtitle: 'Launches full-screen focus mode with 40Hz acoustic preset',
      category: 'ACTIONS',
      shortcut: 'Cmd+Enter',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        ref.read(focusSessionProvider.notifier).startSession(
              taskTitle: 'Deep Work Focus Block',
              objective: 'Solve Striver A2Z DSA Problems & Project Tasks',
            );
        context.go('/focus');
      },
    ));

    items.add(_CommandItem(
      title: 'Run AI Evening Retrospective & Synthesis',
      subtitle: 'Analyze output velocity, friction, and plan tomorrow',
      category: 'ACTIONS',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        context.go('/coach');
      },
    ));

    // Navigation Targets
    items.add(_CommandItem(
      title: 'Navigate to Mission Control Dashboard',
      subtitle: 'HUD, Concentric vector rings & Hero Next Action',
      category: 'NAVIGATION',
      shortcut: 'Cmd+1',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        context.go('/dashboard');
      },
    ));

    items.add(_CommandItem(
      title: 'Navigate to Striver A2Z DSA Tracker',
      subtitle: '18 Steps, topic filtering, difficulty tags',
      category: 'NAVIGATION',
      shortcut: 'Cmd+2',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        context.go('/dsa');
      },
    ));

    items.add(_CommandItem(
      title: 'Navigate to Study Squad',
      subtitle: 'Live study squad telemetry & peer accountability',
      category: 'NAVIGATION',
      shortcut: 'Cmd+3',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        context.go('/cohort');
      },
    ));

    items.add(_CommandItem(
      title: 'Navigate to Strategic Goals & Milestones',
      subtitle: 'Identity targets & weighted completion DAG',
      category: 'NAVIGATION',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        context.go('/goals');
      },
    ));

    items.add(_CommandItem(
      title: 'Navigate to Projects & Kanban Matrix',
      subtitle: 'Linear-style Kanban boards & architecture specs',
      category: 'NAVIGATION',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        context.go('/projects');
      },
    ));

    items.add(_CommandItem(
      title: 'Navigate to Unified Task Matrix',
      subtitle: 'Priority & cognitive demand filtered task queue',
      category: 'NAVIGATION',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        context.go('/tasks');
      },
    ));

    items.add(_CommandItem(
      title: 'Navigate to Time-Blocking Calendar',
      subtitle: 'Daily agenda & deep work block reservations',
      category: 'NAVIGATION',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        context.go('/calendar');
      },
    ));

    items.add(_CommandItem(
      title: 'Navigate to Markdown Knowledge Base',
      subtitle: 'Architecture notes, algorithms & wiki links',
      category: 'NAVIGATION',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        context.go('/knowledge');
      },
    ));

    items.add(_CommandItem(
      title: 'Navigate to Learning Curriculum Resources',
      subtitle: 'Books, courses, and research paper trackers',
      category: 'NAVIGATION',
      onSelect: () {
        ref.read(commandPaletteProvider.notifier).close();
        context.go('/resources');
      },
    ));

    // Matching Projects
    for (final p in projects) {
      if (query.isEmpty || p.title.toLowerCase().contains(query)) {
        items.add(_CommandItem(
          title: 'Project: ${p.title}',
          subtitle: '${p.completedTasks}/${p.totalTasks} Tasks Completed',
          category: 'PROJECTS',
          onSelect: () {
            ref.read(commandPaletteProvider.notifier).close();
            context.go('/projects');
          },
        ));
      }
    }

    // Matching Tasks
    for (final t in tasksState.tasks) {
      if (query.isEmpty || t.title.toLowerCase().contains(query)) {
        items.add(_CommandItem(
          title: t.title,
          subtitle: '${t.priority.label} Priority ${t.projectTag != null ? "#${t.projectTag}" : ""}',
          category: 'TASKS',
          onSelect: () {
            ref.read(commandPaletteProvider.notifier).close();
            context.go('/tasks');
          },
        ));
      }
    }

    // Matching DSA problems
    for (final p in dsaState.problems) {
      if (query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          p.pattern.toLowerCase().contains(query) ||
          p.stepTitle.toLowerCase().contains(query)) {
        items.add(_CommandItem(
          title: p.title,
          subtitle: '${p.stepTitle} - ${p.pattern}',
          category: 'DSA PROBLEMS',
          difficulty: p.difficulty.name.toUpperCase(),
          onSelect: () {
            ref.read(commandPaletteProvider.notifier).close();
            context.go('/dsa');
          },
        ));
      }
    }

    final filteredItems = items.where((it) {
      if (query.isEmpty) return true;
      return it.title.toLowerCase().contains(query) ||
          (it.subtitle?.toLowerCase().contains(query) ?? false) ||
          it.category.toLowerCase().contains(query);
    }).toList();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 680,
          constraints: const BoxConstraints(maxHeight: 480),
          decoration: BoxDecoration(
            color: AppColors.surfaceTier1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderActive, width: 1),
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
            children: [
              // Search Input Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.cyan,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        style: AppTypography.heading2.copyWith(
                          fontSize: 16,
                          color: AppColors.textHigh,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search anything across Arete (DSA, Tasks, Projects, Notes)...',
                          hintStyle: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) {
                          ref.read(commandPaletteProvider.notifier).setQuery(val);
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTier2,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Text('ESC', style: AppTypography.monoBadge),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppColors.borderSubtle, height: 1),
              // Results List
              Flexible(
                child: filteredItems.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No matching commands or entities found.',
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textMuted),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredItems.length,
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        itemBuilder: (context, index) {
                          final item = filteredItems[index];
                          return InkWell(
                            onTap: item.onSelect,
                            hoverColor: AppColors.surfaceHover,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              item.title,
                                              style: AppTypography.bodyLarge.copyWith(
                                                color: AppColors.textHigh,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (item.difficulty != null) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: item.difficulty == 'EASY'
                                                      ? AppColors.cyanBg
                                                      : item.difficulty == 'MEDIUM'
                                                          ? AppColors.amberBg
                                                          : AppColors.roseBg,
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                                child: Text(
                                                  item.difficulty!,
                                                  style: AppTypography.monoBadge.copyWith(
                                                    fontSize: 9,
                                                    color: item.difficulty == 'EASY'
                                                        ? AppColors.cyan
                                                        : item.difficulty == 'MEDIUM'
                                                            ? AppColors.amber
                                                            : AppColors.rose,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        if (item.subtitle != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            item.subtitle!,
                                            style: AppTypography.caption.copyWith(
                                              color: AppColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  if (item.shortcut != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceTier2,
                                        borderRadius: BorderRadius.circular(4),
                                        border:
                                            Border.all(color: AppColors.borderSubtle),
                                      ),
                                      child: Text(
                                        item.shortcut!,
                                        style: AppTypography.monoBadge,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const Divider(color: AppColors.borderSubtle, height: 1),
              // Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Text('Navigate: ↑↓', style: AppTypography.caption),
                    const SizedBox(width: 16),
                    Text('Select: ↵', style: AppTypography.caption),
                    const Spacer(),
                    Text('Arete Command Engine',
                        style: AppTypography.caption.copyWith(color: AppColors.cyan)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommandItem {
  final String title;
  final String? subtitle;
  final String category;
  final String? shortcut;
  final String? difficulty;
  final VoidCallback onSelect;

  const _CommandItem({
    required this.title,
    this.subtitle,
    required this.category,
    this.shortcut,
    this.difficulty,
    required this.onSelect,
  });
}
