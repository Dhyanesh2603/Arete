enum ProjectColumn { backlog, inProgress, inReview, completed }

class ProjectTask {
  final String id;
  final String projectId;
  final String title;
  final String description;
  final ProjectColumn column;
  final String priority; // High, Medium, Low
  final int estimatedMinutes;
  final int loggedMinutes;
  final DateTime? dueDate;

  const ProjectTask({
    required this.id,
    required this.projectId,
    required this.title,
    this.description = '',
    this.column = ProjectColumn.backlog,
    this.priority = 'Medium',
    this.estimatedMinutes = 45,
    this.loggedMinutes = 0,
    this.dueDate,
  });

  ProjectTask copyWith({
    String? id,
    String? projectId,
    String? title,
    String? description,
    ProjectColumn? column,
    String? priority,
    int? estimatedMinutes,
    int? loggedMinutes,
    DateTime? dueDate,
  }) {
    return ProjectTask(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      column: column ?? this.column,
      priority: priority ?? this.priority,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      loggedMinutes: loggedMinutes ?? this.loggedMinutes,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}

class Project {
  final String id;
  final String title;
  final String goalTitle;
  final String architectureMarkdown;
  final List<ProjectTask> tasks;
  final DateTime deadline;

  const Project({
    required this.id,
    required this.title,
    required this.goalTitle,
    required this.architectureMarkdown,
    required this.tasks,
    required this.deadline,
  });

  int get totalTasks => tasks.length;
  int get completedTasks =>
      tasks.where((t) => t.column == ProjectColumn.completed).length;
  double get progressPercentage =>
      totalTasks == 0 ? 0.0 : (completedTasks / totalTasks) * 100.0;

  Project copyWith({
    String? id,
    String? title,
    String? goalTitle,
    String? architectureMarkdown,
    List<ProjectTask>? tasks,
    DateTime? deadline,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      goalTitle: goalTitle ?? this.goalTitle,
      architectureMarkdown:
          architectureMarkdown ?? this.architectureMarkdown,
      tasks: tasks ?? this.tasks,
      deadline: deadline ?? this.deadline,
    );
  }
}
