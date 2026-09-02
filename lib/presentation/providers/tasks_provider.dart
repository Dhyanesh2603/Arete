import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../domain/models/task.dart';
import 'auth_provider.dart';

class TasksState {
  final List<Task> tasks;
  final TaskPriority? filterPriority;
  final bool? filterCompleted;
  final String searchQuery;
  final bool isLoading;

  const TasksState({
    required this.tasks,
    this.filterPriority,
    this.filterCompleted,
    this.searchQuery = '',
    this.isLoading = false,
  });

  TasksState copyWith({
    List<Task>? tasks,
    TaskPriority? filterPriority,
    bool clearPriority = false,
    bool? filterCompleted,
    bool clearCompleted = false,
    String? searchQuery,
    bool? isLoading,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      filterPriority:
          clearPriority ? null : (filterPriority ?? this.filterPriority),
      filterCompleted:
          clearCompleted ? null : (filterCompleted ?? this.filterCompleted),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
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
  final Ref _ref;
  String? _currentUserId;

  TasksNotifier(this._ref) : super(const TasksState(tasks: [])) {
    // Listen to active user changes
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final newUserId = next.user?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        if (newUserId != null) {
          loadUserTasks(newUserId);
        } else {
          state = const TasksState(tasks: []);
        }
      }
    });

    final initialUser = _ref.read(authProvider).user;
    if (initialUser != null) {
      _currentUserId = initialUser.id;
      loadUserTasks(initialUser.id);
    }
  }

  Future<void> loadUserTasks(String userId) async {
    state = state.copyWith(isLoading: true);
    final userTasks = await SupabaseService.fetchUserTasks(userId);
    // Starts completely empty if new user
    state = state.copyWith(tasks: userTasks, isLoading: false);
  }

  Future<void> toggleTask(String taskId) async {
    final updated = state.tasks.map((t) {
      if (t.id == taskId) {
        return t.copyWith(
          isCompleted: !t.isCompleted,
          completedAt: !t.isCompleted ? DateTime.now() : null,
        );
      }
      return t;
    }).toList();

    state = state.copyWith(tasks: updated);
    if (_currentUserId != null) {
      await SupabaseService.saveUserTasks(_currentUserId!, updated);
    }
  }

  Future<void> addTask(Task task) async {
    final updated = [task, ...state.tasks];
    state = state.copyWith(tasks: updated);
    if (_currentUserId != null) {
      await SupabaseService.saveUserTasks(_currentUserId!, updated);
    }
  }

  Future<void> deleteTask(String taskId) async {
    final updated = state.tasks.where((t) => t.id != taskId).toList();
    state = state.copyWith(tasks: updated);
    if (_currentUserId != null) {
      await SupabaseService.saveUserTasks(_currentUserId!, updated);
    }
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
  return TasksNotifier(ref);
});
