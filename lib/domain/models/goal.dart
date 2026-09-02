enum GoalPriority { p0Critical, p1Strategic, p2Supporting }
enum GoalStatus { active, achieved, paused }

class Goal {
  final String id;
  final String identityTitle;
  final String title;
  final String objectiveStatement;
  final DateTime targetDeadline;
  final GoalPriority priority;
  final GoalStatus status;
  final double weightedProgress;
  final int totalMilestones;
  final int completedMilestones;

  const Goal({
    required this.id,
    required this.identityTitle,
    required this.title,
    required this.objectiveStatement,
    required this.targetDeadline,
    this.priority = GoalPriority.p1Strategic,
    this.status = GoalStatus.active,
    this.weightedProgress = 0.0,
    this.totalMilestones = 0,
    this.completedMilestones = 0,
  });

  Goal copyWith({
    String? id,
    String? identityTitle,
    String? title,
    String? objectiveStatement,
    DateTime? targetDeadline,
    GoalPriority? priority,
    GoalStatus? status,
    double? weightedProgress,
    int? totalMilestones,
    int? completedMilestones,
  }) {
    return Goal(
      id: id ?? this.id,
      identityTitle: identityTitle ?? this.identityTitle,
      title: title ?? this.title,
      objectiveStatement: objectiveStatement ?? this.objectiveStatement,
      targetDeadline: targetDeadline ?? this.targetDeadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      weightedProgress: weightedProgress ?? this.weightedProgress,
      totalMilestones: totalMilestones ?? this.totalMilestones,
      completedMilestones: completedMilestones ?? this.completedMilestones,
    );
  }
}
