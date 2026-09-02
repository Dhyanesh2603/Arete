enum MilestoneStatus { pending, active, completed, blocked }

class Milestone {
  final String id;
  final String goalId;
  final String title;
  final double weightMultiplier;
  final DateTime deadline;
  final MilestoneStatus status;
  final double progressPercentage;
  final List<String> dependencyIds;

  const Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    this.weightMultiplier = 1.0,
    required this.deadline,
    this.status = MilestoneStatus.pending,
    this.progressPercentage = 0.0,
    this.dependencyIds = const [],
  });

  Milestone copyWith({
    String? id,
    String? goalId,
    String? title,
    double? weightMultiplier,
    DateTime? deadline,
    MilestoneStatus? status,
    double? progressPercentage,
    List<String>? dependencyIds,
  }) {
    return Milestone(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      weightMultiplier: weightMultiplier ?? this.weightMultiplier,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      dependencyIds: dependencyIds ?? this.dependencyIds,
    );
  }
}
