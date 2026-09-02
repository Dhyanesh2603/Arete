enum TaskPriority { p0, p1, p2 }

enum CognitiveTier { deep3x, medium2x, shallow1x }

enum EisenhowerQuadrant {
  q1DoFirst, // Urgent & Important (P0 Deep Work)
  q2Schedule, // Not Urgent & Important (P1 Strategic / Goals / Projects)
  q3Delegate, // Urgent & Low Value (P2 Shallow / Quick Chores)
  q4Eliminate // Backlog / Defer
}

class Task {
  final String id;
  final String title;
  final String? milestoneId;
  final String? milestoneTitle;
  final String? projectId;
  final String? projectTag;
  final TaskPriority priority;
  final CognitiveTier cognitiveTier;
  final int estimatedMinutes;
  final int estimatedPomodoros;
  final int loggedPomodoros;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final List<String> subtasks;

  const Task({
    required this.id,
    required this.title,
    this.milestoneId,
    this.milestoneTitle,
    this.projectId,
    this.projectTag,
    this.priority = TaskPriority.p1,
    this.cognitiveTier = CognitiveTier.medium2x,
    this.estimatedMinutes = 45,
    this.estimatedPomodoros = 1,
    this.loggedPomodoros = 0,
    this.isCompleted = false,
    this.dueDate,
    this.completedAt,
    this.subtasks = const [],
  });

  EisenhowerQuadrant get quadrant {
    if (priority == TaskPriority.p0) return EisenhowerQuadrant.q1DoFirst;
    if (priority == TaskPriority.p1) return EisenhowerQuadrant.q2Schedule;
    if (cognitiveTier == CognitiveTier.shallow1x) return EisenhowerQuadrant.q3Delegate;
    return EisenhowerQuadrant.q4Eliminate;
  }

  Task copyWith({
    String? id,
    String? title,
    String? milestoneId,
    String? milestoneTitle,
    String? projectId,
    String? projectTag,
    TaskPriority? priority,
    CognitiveTier? cognitiveTier,
    int? estimatedMinutes,
    int? estimatedPomodoros,
    int? loggedPomodoros,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? completedAt,
    List<String>? subtasks,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      milestoneId: milestoneId ?? this.milestoneId,
      milestoneTitle: milestoneTitle ?? this.milestoneTitle,
      projectId: projectId ?? this.projectId,
      projectTag: projectTag ?? this.projectTag,
      priority: priority ?? this.priority,
      cognitiveTier: cognitiveTier ?? this.cognitiveTier,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      estimatedPomodoros: estimatedPomodoros ?? this.estimatedPomodoros,
      loggedPomodoros: loggedPomodoros ?? this.loggedPomodoros,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      subtasks: subtasks ?? this.subtasks,
    );
  }
}
