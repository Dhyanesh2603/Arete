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

  List<Milestone> getMilestonesForGoal(String goalId) {
    return milestones.where((m) => m.goalId == goalId).toList();
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
    final rawGoals = prefs.getString('arete_user_${userId}_goals');
    final rawMilestones = prefs.getString('arete_user_${userId}_milestones');

    List<Goal> loadedGoals = [];
    List<Milestone> loadedMilestones = [];

    if (rawMilestones != null) {
      try {
        final mList = jsonDecode(rawMilestones) as List<dynamic>;
        loadedMilestones = mList.map((item) {
          final m = item as Map<String, dynamic>;
          final sStr = m['status'] as String? ?? 'pending';
          final status = MilestoneStatus.values.firstWhere(
            (s) => s.name == sStr,
            orElse: () => MilestoneStatus.pending,
          );
          return Milestone(
            id: m['id'] as String,
            goalId: m['goalId'] as String,
            title: m['title'] as String,
            weightMultiplier: (m['weightMultiplier'] as num?)?.toDouble() ?? 1.0,
            deadline: DateTime.tryParse(m['deadline'] as String? ?? '') ??
                DateTime.now().add(const Duration(days: 30)),
            status: status,
          );
        }).toList();
      } catch (_) {}
    }

    if (rawGoals != null) {
      try {
        final list = jsonDecode(rawGoals) as List<dynamic>;
        loadedGoals = list.map((item) {
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

          final gId = m['id'] as String;
          final gMilestones = loadedMilestones.where((ms) => ms.goalId == gId).toList();
          final totalM = gMilestones.length;
          final completedM = gMilestones.where((ms) => ms.status == MilestoneStatus.completed).length;

          double weightedProg = (m['weightedProgress'] as num?)?.toDouble() ?? 0.0;
          if (totalM > 0) {
            final totalW = gMilestones.fold(0.0, (s, ms) => s + ms.weightMultiplier);
            final doneW = gMilestones.where((ms) => ms.status == MilestoneStatus.completed).fold(0.0, (s, ms) => s + ms.weightMultiplier);
            weightedProg = totalW == 0 ? 0.0 : (doneW / totalW) * 100.0;
          }

          return Goal(
            id: gId,
            identityTitle: m['identityTitle'] as String? ?? '',
            title: m['title'] as String,
            objectiveStatement: m['objectiveStatement'] as String? ?? '',
            targetDeadline: DateTime.tryParse(m['targetDeadline'] as String? ?? '') ??
                DateTime.now().add(const Duration(days: 90)),
            priority: priority,
            status: status,
            weightedProgress: double.parse(weightedProg.toStringAsFixed(1)),
            totalMilestones: totalM,
            completedMilestones: completedM,
          );
        }).toList();
      } catch (_) {}
    }

    state = GoalsState(goals: loadedGoals, milestones: loadedMilestones, tasks: []);
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
    await _persist(updated, state.milestones);
  }

  Future<void> deleteGoal(String goalId) async {
    final updatedGoals = state.goals.where((g) => g.id != goalId).toList();
    final updatedMilestones = state.milestones.where((m) => m.goalId != goalId).toList();
    state = GoalsState(
        goals: updatedGoals, milestones: updatedMilestones, tasks: state.tasks);
    await _persist(updatedGoals, updatedMilestones);
  }

  Future<void> addMilestone({
    required String goalId,
    required String title,
    double weightMultiplier = 1.0,
    required DateTime deadline,
  }) async {
    final milestone = Milestone(
      id: 'ms-${DateTime.now().millisecondsSinceEpoch}',
      goalId: goalId,
      title: title.trim(),
      weightMultiplier: weightMultiplier,
      deadline: deadline,
      status: MilestoneStatus.pending,
    );
    final updatedMilestones = [...state.milestones, milestone];
    final updatedGoals = _recalculateGoalsProgress(state.goals, updatedMilestones);

    state = GoalsState(goals: updatedGoals, milestones: updatedMilestones, tasks: state.tasks);
    await _persist(updatedGoals, updatedMilestones);
  }

  Future<void> toggleMilestone(String milestoneId) async {
    final updatedMilestones = state.milestones.map((m) {
      if (m.id == milestoneId) {
        final newStatus = m.status == MilestoneStatus.completed
            ? MilestoneStatus.pending
            : MilestoneStatus.completed;
        return m.copyWith(status: newStatus);
      }
      return m;
    }).toList();

    final updatedGoals = _recalculateGoalsProgress(state.goals, updatedMilestones);
    state = GoalsState(goals: updatedGoals, milestones: updatedMilestones, tasks: state.tasks);
    await _persist(updatedGoals, updatedMilestones);
  }

  Future<void> deleteMilestone(String milestoneId) async {
    final updatedMilestones = state.milestones.where((m) => m.id != milestoneId).toList();
    final updatedGoals = _recalculateGoalsProgress(state.goals, updatedMilestones);
    state = GoalsState(goals: updatedGoals, milestones: updatedMilestones, tasks: state.tasks);
    await _persist(updatedGoals, updatedMilestones);
  }

  List<Goal> _recalculateGoalsProgress(List<Goal> goals, List<Milestone> milestones) {
    return goals.map((g) {
      final gMilestones = milestones.where((m) => m.goalId == g.id).toList();
      final total = gMilestones.length;
      final completed = gMilestones.where((m) => m.status == MilestoneStatus.completed).length;

      double pct = 0.0;
      if (total > 0) {
        final totalW = gMilestones.fold(0.0, (s, m) => s + m.weightMultiplier);
        final doneW = gMilestones.where((m) => m.status == MilestoneStatus.completed).fold(0.0, (s, m) => s + m.weightMultiplier);
        pct = totalW == 0 ? 0.0 : (doneW / totalW) * 100.0;
      }

      return g.copyWith(
        totalMilestones: total,
        completedMilestones: completed,
        weightedProgress: double.parse(pct.toStringAsFixed(1)),
      );
    }).toList();
  }

  Future<void> _persist(List<Goal> goals, List<Milestone> milestones) async {
    if (_currentUserId == null) return;
    final prefs = await SharedPreferences.getInstance();

    final goalsData = goals
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

    final milestonesData = milestones
        .map((m) => {
              'id': m.id,
              'goalId': m.goalId,
              'title': m.title,
              'weightMultiplier': m.weightMultiplier,
              'deadline': m.deadline.toIso8601String(),
              'status': m.status.name,
            })
        .toList();

    await prefs.setString('arete_user_${_currentUserId}_goals', jsonEncode(goalsData));
    await prefs.setString('arete_user_${_currentUserId}_milestones', jsonEncode(milestonesData));
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  return GoalsNotifier(ref);
});
