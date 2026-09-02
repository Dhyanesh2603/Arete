import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/task.dart';

class TasksState {
  final List<Task> tasks;
  final TaskPriority? filterPriority;
  final CognitiveTier? filterCognitiveTier;
  final bool? filterCompleted;
  final String searchQuery;

  const TasksState({
    required this.tasks,
    this.filterPriority,
    this.filterCognitiveTier,
    this.filterCompleted,
    this.searchQuery = '',
  });

  TasksState copyWith({
    List<Task>? tasks,
    TaskPriority? filterPriority,
    bool clearPriority = false,
    CognitiveTier? filterCognitiveTier,
    bool clearCognitive = false,
    bool? filterCompleted,
    bool clearCompleted = false,
    String? searchQuery,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      filterPriority:
          clearPriority ? null : (filterPriority ?? this.filterPriority),
      filterCognitiveTier: clearCognitive
          ? null
          : (filterCognitiveTier ?? this.filterCognitiveTier),
      filterCompleted:
          clearCompleted ? null : (filterCompleted ?? this.filterCompleted),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Task> get filteredTasks {
    return tasks.where((t) {
      if (filterPriority != null && t.priority != filterPriority) return false;
      if (filterCognitiveTier != null &&
          t.cognitiveTier != filterCognitiveTier) {
        return false;
      }
      if (filterCompleted != null && t.isCompleted != filterCompleted) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !(t.milestoneTitle?.toLowerCase().contains(q) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;
}

class TasksNotifier extends StateNotifier<TasksState> {
  TasksNotifier() : super(_initialTasks());

  static TasksState _initialTasks() {
    return TasksState(tasks: [
      const Task(
        id: 'tk-1',
        title: 'Solve Binary Tree Maximum Path Sum (LeetCode 124)',
        milestoneTitle: 'Step 13: Binary Trees',
        priority: TaskPriority.p0,
        cognitiveTier: CognitiveTier.deep3x,
        estimatedMinutes: 45,
        isCompleted: false,
      ),
      const Task(
        id: 'tk-2',
        title: 'Benchmark Triton SRAM Shared Memory Bank Conflict Latency',
        milestoneTitle: 'FlashAttention Kernel',
        priority: TaskPriority.p0,
        cognitiveTier: CognitiveTier.deep3x,
        estimatedMinutes: 60,
        isCompleted: false,
      ),
      const Task(
        id: 'tk-3',
        title: 'Complete 3 Practice Problems on Monotonic Stack',
        milestoneTitle: 'Step 9: Stack & Queues',
        priority: TaskPriority.p1,
        cognitiveTier: CognitiveTier.deep3x,
        estimatedMinutes: 60,
        isCompleted: true,
      ),
      const Task(
        id: 'tk-4',
        title: 'Review Lowest Common Ancestor (LCA) in BST',
        milestoneTitle: 'Step 14: BST',
        priority: TaskPriority.p1,
        cognitiveTier: CognitiveTier.medium2x,
        estimatedMinutes: 30,
        isCompleted: false,
      ),
      const Task(
        id: 'tk-5',
        title: 'Read Google Borg Distributed Orchestration Research Paper',
        milestoneTitle: 'Distributed Systems',
        priority: TaskPriority.p2,
        cognitiveTier: CognitiveTier.medium2x,
        estimatedMinutes: 45,
        isCompleted: false,
      ),
      const Task(
        id: 'tk-6',
        title: 'Log Weekly Retrospective in Arete Knowledge Base',
        milestoneTitle: 'Life OS Mastery',
        priority: TaskPriority.p2,
        cognitiveTier: CognitiveTier.shallow1x,
        estimatedMinutes: 15,
        isCompleted: true,
      ),
    ]);
  }

  void toggleTask(String taskId) {
    state = state.copyWith(
      tasks: state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(isCompleted: !t.isCompleted);
        }
        return t;
      }).toList(),
    );
  }

  void addTask(Task task) {
    state = state.copyWith(tasks: [task, ...state.tasks]);
  }

  void setPriorityFilter(TaskPriority? p) {
    if (p == null) {
      state = state.copyWith(clearPriority: true);
    } else {
      state = state.copyWith(filterPriority: p);
    }
  }

  void setCognitiveFilter(CognitiveTier? c) {
    if (c == null) {
      state = state.copyWith(clearCognitive: true);
    } else {
      state = state.copyWith(filterCognitiveTier: c);
    }
  }

  void setCompletedFilter(bool? comp) {
    if (comp == null) {
      state = state.copyWith(clearCompleted: true);
    } else {
      state = state.copyWith(filterCompleted: comp);
    }
  }

  void setSearchQuery(String q) {
    state = state.copyWith(searchQuery: q);
  }
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier();
});
