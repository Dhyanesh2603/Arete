import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/milestone.dart';
import '../../domain/models/task.dart';
import 'auth_provider.dart';

class GoalsState {
  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<Task> tasks;

  const GoalsState({
    required this.goals,
    required this.milestones,
    required this.tasks,
  });

  Goal? get primaryGoal => goals.isNotEmpty ? goals.first : null;

  Task? get heroNextAction {
    final pending = tasks.where((t) => !t.isCompleted).toList();
    if (pending.isEmpty) return null;
    pending.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    return pending.first;
  }

  double get overallVelocityFactor {
    if (goals.isEmpty) return 0.0;
    final totalProgress =
        goals.fold(0.0, (sum, g) => sum + g.weightedProgress);
    return totalProgress / (goals.length * 100.0);
  }
}

class GoalsNotifier extends StateNotifier<GoalsState> {
  final Ref _ref;
  String? _currentUserId;

  GoalsNotifier(this._ref)
      : super(const GoalsState(goals: [], milestones: [], tasks: [])) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final newUserId = next.user?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        if (newUserId != null) {
          _loadGoals(newUserId);
        } else {
          state = const GoalsState(goals: [], milestones: [], tasks: []);
        }
      }
    });

    final initialUser = _ref.read(authProvider).user;
    if (initialUser != null) {
      _currentUserId = initialUser.id;
      _loadGoals(initialUser.id);
    }
  }

  Future<void> _loadGoals(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('arete_user_${userId}_goals');
    if (raw == null) {
      state = const GoalsState(goals: [], milestones: [], tasks: []);
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final goals = list.map((item) {
        final m = item as Map<String, dynamic>;
        final pStr = m['priority'] as String? ?? 'p1Strategic';
        final priority = GoalPriority.values.firstWhere(
          (p) => p.name == pStr,
          orElse: () => GoalPriority.p1Strategic,
        );
        final sStr = m['status'] as String? ?? 'active';
        final status = GoalStatus.values.firstWhere(
          (s) => s.name == sStr,
          orElse: () => GoalStatus.active,
        );

        return Goal(
          id: m['id'] as String,
          identityTitle: m['identityTitle'] as String? ?? '',
          title: m['title'] as String,
          objectiveStatement: m['objectiveStatement'] as String? ?? '',
          targetDeadline: DateTime.tryParse(m['targetDeadline'] as String? ?? '') ??
              DateTime.now().add(const Duration(days: 90)),
          priority: priority,
          status: status,
          weightedProgress: (m['weightedProgress'] as num?)?.toDouble() ?? 0.0,
          totalMilestones: m['totalMilestones'] as int? ?? 0,
          completedMilestones: m['completedMilestones'] as int? ?? 0,
        );
      }).toList();

      state = GoalsState(goals: goals, milestones: [], tasks: []);
    } catch (_) {
      state = const GoalsState(goals: [], milestones: [], tasks: []);
    }
  }

  Future<void> createGoal({
    required String identityTitle,
    required String title,
    required String objectiveStatement,
    required DateTime targetDeadline,
    required GoalPriority priority,
  }) async {
    final goal = Goal(
      id: 'g-${DateTime.now().millisecondsSinceEpoch}',
      identityTitle: identityTitle.trim(),
      title: title.trim(),
      objectiveStatement: objectiveStatement.trim(),
      targetDeadline: targetDeadline,
      priority: priority,
      status: GoalStatus.active,
      weightedProgress: 0.0,
      totalMilestones: 0,
      completedMilestones: 0,
    );
    final updated = [...state.goals, goal];
    state = GoalsState(
        goals: updated, milestones: state.milestones, tasks: state.tasks);
    await _persist(updated);
  }

  Future<void> deleteGoal(String goalId) async {
    final updated = state.goals.where((g) => g.id != goalId).toList();
    state = GoalsState(
        goals: updated, milestones: state.milestones, tasks: state.tasks);
    await _persist(updated);
  }

  Future<void> _persist(List<Goal> goals) async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();
    final data = goals
        .map((g) => {
              'id': g.id,
              'identityTitle': g.identityTitle,
              'title': g.title,
              'objectiveStatement': g.objectiveStatement,
              'targetDeadline': g.targetDeadline.toIso8601String(),
              'priority': g.priority.name,
              'status': g.status.name,
              'weightedProgress': g.weightedProgress,
              'totalMilestones': g.totalMilestones,
              'completedMilestones': g.completedMilestones,
            })
        .toList();
    await prefs.setString(
        'arete_user_${_currentUserId}_goals', jsonEncode(data));
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  return GoalsNotifier(ref);
});
