import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/task.dart';

class TasksState {
  final List<Task> tasks;
  final TaskPriority? filterPriority;
  final bool? filterCompleted;
  final String searchQuery;

  const TasksState({
    required this.tasks,
    this.filterPriority,
    this.filterCompleted,
    this.searchQuery = '',
  });

  TasksState copyWith({
    List<Task>? tasks,
    TaskPriority? filterPriority,
    bool clearPriority = false,
    bool? filterCompleted,
    bool clearCompleted = false,
    String? searchQuery,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      filterPriority:
          clearPriority ? null : (filterPriority ?? this.filterPriority),
      filterCompleted:
          clearCompleted ? null : (filterCompleted ?? this.filterCompleted),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  List<Task> get filteredTasks {
    return tasks.where((t) {
      if (filterPriority != null && t.priority != filterPriority) return false;
      if (filterCompleted != null && t.isCompleted != filterCompleted) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        if (!t.title.toLowerCase().contains(q) &&
            !(t.milestoneTitle?.toLowerCase().contains(q) ?? false) &&
            !(t.projectTag?.toLowerCase().contains(q) ?? false)) {
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
        projectTag: 'dsa',
        priority: TaskPriority.high,
        estimatedMinutes: 45,
        isCompleted: false,
      ),
      const Task(
        id: 'tk-2',
        title: 'Benchmark Triton SRAM Shared Memory Bank Conflict Latency',
        milestoneTitle: 'FlashAttention Kernel',
        projectTag: 'system',
        priority: TaskPriority.high,
        estimatedMinutes: 60,
        isCompleted: false,
      ),
      const Task(
        id: 'tk-3',
        title: 'Complete 3 Practice Problems on Monotonic Stack',
        milestoneTitle: 'Step 9: Stack & Queues',
        projectTag: 'dsa',
        priority: TaskPriority.medium,
        estimatedMinutes: 60,
        isCompleted: true,
      ),
      const Task(
        id: 'tk-4',
        title: 'Review Lowest Common Ancestor (LCA) in BST',
        milestoneTitle: 'Step 14: BST',
        projectTag: 'dsa',
        priority: TaskPriority.medium,
        estimatedMinutes: 30,
        isCompleted: false,
      ),
      const Task(
        id: 'tk-5',
        title: 'Read Google Borg Distributed Orchestration Research Paper',
        milestoneTitle: 'Distributed Systems',
        projectTag: 'reading',
        priority: TaskPriority.low,
        estimatedMinutes: 45,
        isCompleted: false,
      ),
      const Task(
        id: 'tk-6',
        title: 'Log Weekly Retrospective in Arete Knowledge Base',
        milestoneTitle: 'Arete Mastery',
        projectTag: 'chores',
        priority: TaskPriority.low,
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
