import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/dsa_problem.dart';
import '../../domain/models/flight_plan_item.dart';
import '../../domain/models/task.dart';
import 'calendar_provider.dart';
import 'dsa_provider.dart';
import 'focus_session_provider.dart';
import 'habits_provider.dart';
import 'tasks_provider.dart';

class FlightPlanState {
  final List<FlightPlanItem> items;
  final Set<String> completedIds;

  const FlightPlanState({
    required this.items,
    this.completedIds = const {},
  });

  int get totalEstimatedMinutes =>
      items.fold(0, (sum, it) => sum + it.estimatedMinutes);

  int get completedMinutes => items
      .where((it) => completedIds.contains(it.id))
      .fold(0, (sum, it) => sum + it.estimatedMinutes);

  int get completedCount =>
      items.where((it) => completedIds.contains(it.id)).length;

  int get totalCount => items.length;

  double get progress =>
      totalCount == 0 ? 0.0 : completedCount / totalCount;

  FlightPlanItem? get nextItem {
    for (final item in items) {
      if (!completedIds.contains(item.id)) return item;
    }
    return null;
  }

  FlightPlanState copyWith({
    List<FlightPlanItem>? items,
    Set<String>? completedIds,
  }) {
    return FlightPlanState(
      items: items ?? this.items,
      completedIds: completedIds ?? this.completedIds,
    );
  }
}

class FlightPlanNotifier extends StateNotifier<FlightPlanState> {
  final Ref _ref;

  FlightPlanNotifier(this._ref) : super(const FlightPlanState(items: [])) {
    // Recompute sequence whenever upstream providers update
    _ref.listen<DsaState>(dsaProvider, (prev, next) => _recompute());
    _ref.listen<TasksState>(tasksProvider, (prev, next) => _recompute());
    _ref.listen<CalendarState>(calendarProvider, (prev, next) => _recompute());
    _ref.listen<List<dynamic>>(habitsProvider, (prev, next) => _recompute());

    _recompute();
  }

  void _recompute() {
    final dsaState = _ref.read(dsaProvider);
    final tasksState = _ref.read(tasksProvider);
    final calendarState = _ref.read(calendarProvider);
    final habits = _ref.read(habitsProvider);

    final List<FlightPlanItem> list = [];

    // 1. Spaced Repetition or Next Problem Target
    final dueRevisionProblems =
        dsaState.problems.where((p) => p.isDueForRevision).toList();

    if (dueRevisionProblems.isNotEmpty) {
      final problem = dueRevisionProblems.first;
      list.add(FlightPlanItem(
        id: 'fp-dsa-${problem.id}',
        title: 'SM-2 Review: ${problem.title}',
        subtitle: '${problem.stepTitle} - ${problem.pattern}',
        type: FlightPlanItemType.dsaRevision,
        estimatedMinutes: 30,
        badgeText: 'SM-2 RETENTION',
        badgeColor: AppColors.cyan,
        badgeBgColor: AppColors.cyanBg,
        icon: Icons.replay_rounded,
        actionRoute: '/dsa',
        isCompleted: state.completedIds.contains('fp-dsa-${problem.id}'),
      ));
    } else {
      // Pick next unsolved problem from the active or first step
      final nextProblem = dsaState.problems.firstWhere(
        (p) => p.status != DsaStatus.solved,
        orElse: () => dsaState.problems.first,
      );
      list.add(FlightPlanItem(
        id: 'fp-dsa-${nextProblem.id}',
        title: 'Target Problem: ${nextProblem.title}',
        subtitle: '${nextProblem.stepTitle} - ${nextProblem.pattern}',
        type: FlightPlanItemType.dsaTarget,
        estimatedMinutes: 45,
        badgeText: 'NEXT DSA TARGET',
        badgeColor: AppColors.cyan,
        badgeBgColor: AppColors.cyanBg,
        icon: Icons.code_rounded,
        actionRoute: '/dsa',
        isCompleted: state.completedIds.contains('fp-dsa-${nextProblem.id}'),
      ));
    }

    // 2. High Priority Task from Matrix
    final pendingTasks =
        tasksState.tasks.where((t) => !t.isCompleted).toList();
    final highTasks =
        pendingTasks.where((t) => t.priority == TaskPriority.high).toList();
    final selectedTask = highTasks.isNotEmpty
        ? highTasks.first
        : (pendingTasks.isNotEmpty ? pendingTasks.first : null);

    if (selectedTask != null) {
      list.add(FlightPlanItem(
        id: 'fp-task-${selectedTask.id}',
        title: selectedTask.title,
        subtitle: 'Priority: ${selectedTask.priority.label} (${selectedTask.estimatedMinutes}m estimate)',
        type: FlightPlanItemType.highPriorityTask,
        estimatedMinutes: selectedTask.estimatedMinutes,
        badgeText: '${selectedTask.priority.label.toUpperCase()} DEEP WORK',
        badgeColor: selectedTask.priority.color,
        badgeBgColor: selectedTask.priority.backgroundColor,
        icon: Icons.bolt_rounded,
        actionRoute: '/tasks',
        isCompleted: state.completedIds.contains('fp-task-${selectedTask.id}') ||
            selectedTask.isCompleted,
      ));
    }

    // 3. Calendar Scheduled Block
    final todayBlocks = calendarState.todayBlocks
        .where((b) => !b.isCompleted)
        .toList();
    if (todayBlocks.isNotEmpty) {
      final block = todayBlocks.first;
      list.add(FlightPlanItem(
        id: 'fp-cal-${block.id}',
        title: block.title,
        subtitle: '${block.startTime.hour.toString().padLeft(2, '0')}:${block.startTime.minute.toString().padLeft(2, '0')} Scheduled Time Block',
        type: FlightPlanItemType.scheduledBlock,
        estimatedMinutes: block.endTime.difference(block.startTime).inMinutes.clamp(15, 120),
        badgeText: 'TIME BLOCK',
        badgeColor: AppColors.lavender,
        badgeBgColor: AppColors.lavenderBg,
        icon: Icons.calendar_today_rounded,
        actionRoute: '/calendar',
        isCompleted: state.completedIds.contains('fp-cal-${block.id}'),
      ));
    }

    // 4. Daily Habit Consistency
    final pendingHabits =
        habits.where((h) => !h.isCompletedToday).toList();
    if (pendingHabits.isNotEmpty) {
      final habit = pendingHabits.first;
      list.add(FlightPlanItem(
        id: 'fp-habit-${habit.id}',
        title: 'Habit Vector: ${habit.title}',
        subtitle: 'Consistency Score: ${habit.consistencyScore}% (${habit.frequency.name})',
        type: FlightPlanItemType.habitCheck,
        estimatedMinutes: 10,
        badgeText: 'HABIT VECTOR',
        badgeColor: AppColors.mint,
        badgeBgColor: AppColors.mintBg,
        icon: Icons.check_circle_outline_rounded,
        actionRoute: '/habits',
        isCompleted: state.completedIds.contains('fp-habit-${habit.id}'),
      ));
    }

    state = state.copyWith(items: list);
  }

  void toggleItemCompleted(String itemId) {
    final updated = Set<String>.from(state.completedIds);
    if (updated.contains(itemId)) {
      updated.remove(itemId);
    } else {
      updated.add(itemId);
    }
    state = state.copyWith(completedIds: updated);
  }

  void executeFlightPlan(BuildContext context) {
    final target = state.nextItem;
    if (target != null) {
      _ref.read(focusSessionProvider.notifier).startSession(
            taskTitle: target.title,
            objective: target.subtitle,
            durationMinutes: target.estimatedMinutes,
          );
      context.go('/focus');
    }
  }

  void launchItem(BuildContext context, FlightPlanItem item) {
    _ref.read(focusSessionProvider.notifier).startSession(
          taskTitle: item.title,
          objective: item.subtitle,
          durationMinutes: item.estimatedMinutes,
        );
    context.go('/focus');
  }
}

final flightPlanProvider =
    StateNotifierProvider<FlightPlanNotifier, FlightPlanState>((ref) {
  return FlightPlanNotifier(ref);
});
