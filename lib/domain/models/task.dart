enum TaskPriority { p0, p1, p2 }
enum CognitiveTier { deep3x, medium2x, shallow1x }

class Task {
  final String id;
  final String title;
  final String? milestoneId;
  final String? milestoneTitle;
  final TaskPriority priority;
  final CognitiveTier cognitiveTier;
  final int estimatedMinutes;
  final int actualMinutesLogged;
  final bool isCompleted;
  final DateTime? scheduledTime;

  const Task({
    required this.id,
    required this.title,
    this.milestoneId,
    this.milestoneTitle,
    this.priority = TaskPriority.p1,
    this.cognitiveTier = CognitiveTier.medium2x,
    this.estimatedMinutes = 45,
    this.actualMinutesLogged = 0,
    this.isCompleted = false,
    this.scheduledTime,
  });

  Task copyWith({
    String? id,
    String? title,
    String? milestoneId,
    String? milestoneTitle,
    TaskPriority? priority,
    CognitiveTier? cognitiveTier,
    int? estimatedMinutes,
    int? actualMinutesLogged,
    bool? isCompleted,
    DateTime? scheduledTime,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      milestoneId: milestoneId ?? this.milestoneId,
      milestoneTitle: milestoneTitle ?? this.milestoneTitle,
      priority: priority ?? this.priority,
      cognitiveTier: cognitiveTier ?? this.cognitiveTier,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutesLogged: actualMinutesLogged ?? this.actualMinutesLogged,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledTime: scheduledTime ?? this.scheduledTime,
    );
  }
}
