import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/goal.dart';
import '../../domain/models/milestone.dart';
import '../../domain/models/task.dart';

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

  double get overallVelocityFactor => 1.14; // +14% ahead of schedule
}

class GoalsNotifier extends StateNotifier<GoalsState> {
  GoalsNotifier() : super(_initialData());

  static GoalsState _initialData() {
    final goals = [
      Goal(
        id: 'g-1',
        identityTitle: 'Senior Distributed AI Systems Architect',
        title: 'Master Striver A2Z DSA Sheet & Land Staff Software Role',
        objectiveStatement:
            'Solve 455+ curated algorithmic problems, build production GPU kernels, and achieve top percentile rank.',
        targetDeadline: DateTime.now().add(const Duration(days: 180)),
        priority: GoalPriority.p0Critical,
        status: GoalStatus.active,
        weightedProgress: 38.5,
        totalMilestones: 4,
        completedMilestones: 1,
      ),
      Goal(
        id: 'g-2',
        identityTitle: 'Sovereign Technical Founder',
        title: 'Ship Arete Web Operating System to 1,000 Active Cohort Members',
        objectiveStatement:
            'Build the fastest, zero-clutter personal operating system and launch on desktop web.',
        targetDeadline: DateTime.now().add(const Duration(days: 90)),
        priority: GoalPriority.p1Strategic,
        status: GoalStatus.active,
        weightedProgress: 65.0,
        totalMilestones: 3,
        completedMilestones: 2,
      ),
    ];

    final milestones = [
      Milestone(
        id: 'm-1',
        goalId: 'g-1',
        title: 'Step 1-4: Basics, Sorting, Arrays & Binary Search',
        weightMultiplier: 2.0,
        deadline: DateTime.now().add(const Duration(days: 14)),
        status: MilestoneStatus.completed,
        progressPercentage: 100.0,
      ),
      Milestone(
        id: 'm-2',
        goalId: 'g-1',
        title: 'Step 6-10: LinkedList, Recursion, Stack/Queues & Sliding Window',
        weightMultiplier: 3.0,
        deadline: DateTime.now().add(const Duration(days: 45)),
        status: MilestoneStatus.active,
        progressPercentage: 42.0,
      ),
      Milestone(
        id: 'm-3',
        goalId: 'g-1',
        title: 'Step 13-15: Binary Trees, BST & Graph Algorithms',
        weightMultiplier: 4.0,
        deadline: DateTime.now().add(const Duration(days: 90)),
        status: MilestoneStatus.active,
        progressPercentage: 18.0,
      ),
      Milestone(
        id: 'm-4',
        goalId: 'g-1',
        title: 'Step 16-18: Dynamic Programming, Tries & Advanced Patterns',
        weightMultiplier: 5.0,
        deadline: DateTime.now().add(const Duration(days: 150)),
        status: MilestoneStatus.pending,
        progressPercentage: 0.0,
        dependencyIds: ['m-2', 'm-3'],
      ),
    ];

    final tasks = [
      Task(
        id: 't-1',
        title: 'Solve Binary Tree Maximum Path Sum (LeetCode 124)',
        milestoneId: 'm-3',
        milestoneTitle: 'Step 13: Binary Trees',
        priority: TaskPriority.p0,
        cognitiveTier: CognitiveTier.deep3x,
        estimatedMinutes: 45,
        isCompleted: false,
      ),
      Task(
        id: 't-2',
        title: 'Review Lowest Common Ancestor (LCA) Approach in BST',
        milestoneId: 'm-3',
        milestoneTitle: 'Step 14: Binary Search Trees',
        priority: TaskPriority.p1,
        cognitiveTier: CognitiveTier.medium2x,
        estimatedMinutes: 30,
        isCompleted: false,
      ),
      Task(
        id: 't-3',
        title: 'Complete 3 Practice Problems on Monotonic Stack',
        milestoneId: 'm-2',
        milestoneTitle: 'Step 9: Stack and Queues',
        priority: TaskPriority.p1,
        cognitiveTier: CognitiveTier.deep3x,
        estimatedMinutes: 60,
        isCompleted: true,
      ),
    ];

    return GoalsState(goals: goals, milestones: milestones, tasks: tasks);
  }

  void toggleTask(String taskId) {
    state = GoalsState(
      goals: state.goals,
      milestones: state.milestones,
      tasks: state.tasks.map((t) {
        if (t.id == taskId) {
          return t.copyWith(isCompleted: !t.isCompleted);
        }
        return t;
      }).toList(),
    );
  }
}

final goalsProvider = StateNotifierProvider<GoalsNotifier, GoalsState>((ref) {
  return GoalsNotifier();
});
