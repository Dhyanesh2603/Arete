import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/project.dart';
import 'auth_provider.dart';

class ProjectsNotifier extends StateNotifier<List<Project>> {
  final Ref _ref;
  String? _currentUserId;

  ProjectsNotifier(this._ref) : super([]) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final newUserId = next.user?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        if (newUserId != null) {
          _loadProjects(newUserId);
        } else {
          state = [];
        }
      }
    });

    final initialUser = _ref.read(authProvider).user;
    if (initialUser != null) {
      _currentUserId = initialUser.id;
      _loadProjects(initialUser.id);
    }
  }

  Future<void> _loadProjects(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('arete_user_${userId}_projects');
    if (raw == null) {
      state = [];
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final projects = list.map((item) {
        final m = item as Map<String, dynamic>;
        final tasksRaw = m['tasks'] as List<dynamic>? ?? [];
        final tasks = tasksRaw.map((tItem) {
          final tm = tItem as Map<String, dynamic>;
          final colStr = tm['column'] as String? ?? 'backlog';
          final col = ProjectColumn.values.firstWhere(
            (c) => c.name == colStr,
            orElse: () => ProjectColumn.backlog,
          );
          return ProjectTask(
            id: tm['id'] as String,
            projectId: tm['projectId'] as String,
            title: tm['title'] as String,
            column: col,
            priority: tm['priority'] as String? ?? 'Medium',
            estimatedMinutes: tm['estimatedMinutes'] as int? ?? 30,
            loggedMinutes: tm['loggedMinutes'] as int? ?? 0,
          );
        }).toList();

        return Project(
          id: m['id'] as String,
          title: m['title'] as String,
          goalTitle: m['goalTitle'] as String? ?? '',
          architectureMarkdown: m['architectureMarkdown'] as String? ?? '',
          deadline: DateTime.tryParse(m['deadline'] as String? ?? '') ??
              DateTime.now().add(const Duration(days: 30)),
          tasks: tasks,
        );
      }).toList();
      state = projects;
    } catch (_) {
      state = [];
    }
  }

  Future<void> createProject({
    required String title,
    required String goalTitle,
    required String architectureMarkdown,
    required DateTime deadline,
  }) async {
    final project = Project(
      id: 'proj-${DateTime.now().millisecondsSinceEpoch}',
      title: title.trim(),
      goalTitle: goalTitle.trim(),
      architectureMarkdown: architectureMarkdown.trim(),
      deadline: deadline,
      tasks: [],
    );
    final updated = [...state, project];
    state = updated;
    await _persist(updated);
  }

  Future<void> deleteProject(String projectId) async {
    final updated = state.where((p) => p.id != projectId).toList();
    state = updated;
    await _persist(updated);
  }

  Future<void> addProjectTask(String projectId, ProjectTask task) async {
    final updated = state.map((p) {
      if (p.id == projectId) {
        return p.copyWith(tasks: [...p.tasks, task]);
      }
      return p;
    }).toList();
    state = updated;
    await _persist(updated);
  }

  Future<void> moveTask(
      String projectId, String taskId, ProjectColumn targetColumn) async {
    final updated = state.map((p) {
      if (p.id == projectId) {
        final updatedTasks = p.tasks.map((t) {
          if (t.id == taskId) {
            return t.copyWith(column: targetColumn);
          }
          return t;
        }).toList();
        return p.copyWith(tasks: updatedTasks);
      }
      return p;
    }).toList();
    state = updated;
    await _persist(updated);
  }

  Future<void> _persist(List<Project> projects) async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = projects.map((p) => {
          'id': p.id,
          'title': p.title,
          'goalTitle': p.goalTitle,
          'architectureMarkdown': p.architectureMarkdown,
          'deadline': p.deadline.toIso8601String(),
          'tasks': p.tasks.map((t) => {
                'id': t.id,
                'projectId': t.projectId,
                'title': t.title,
                'column': t.column.name,
                'priority': t.priority,
                'estimatedMinutes': t.estimatedMinutes,
                'loggedMinutes': t.loggedMinutes,
              }).toList(),
        }).toList();
    await prefs.setString(
        'arete_user_${_currentUserId}_projects', jsonEncode(data));
  }
}

final projectsProvider =
    StateNotifierProvider<ProjectsNotifier, List<Project>>((ref) {
  return ProjectsNotifier(ref);
});
