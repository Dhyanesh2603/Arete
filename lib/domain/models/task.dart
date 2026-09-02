import 'package:flutter/material.dart';

enum TaskPriority { high, medium, low }

extension TaskPriorityExtension on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.high:
        return const Color(0xFFFB7185); // Rose Red
      case TaskPriority.medium:
        return const Color(0xFFFBBF24); // Amber Yellow
      case TaskPriority.low:
        return const Color(0xFF34D399); // Mint Green
    }
  }

  Color get backgroundColor {
    switch (this) {
      case TaskPriority.high:
        return const Color(0x22FB7185);
      case TaskPriority.medium:
        return const Color(0x22FBBF24);
      case TaskPriority.low:
        return const Color(0x2234D399);
    }
  }
}

class Task {
  final String id;
  final String title;
  final String? milestoneId;
  final String? milestoneTitle;
  final String? projectId;
  final String? projectTag;
  final TaskPriority priority;
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
    this.priority = TaskPriority.medium,
    this.estimatedMinutes = 45,
    this.estimatedPomodoros = 1,
    this.loggedPomodoros = 0,
    this.isCompleted = false,
    this.dueDate,
    this.completedAt,
    this.subtasks = const [],
  });

  Task copyWith({
    String? id,
    String? title,
    String? milestoneId,
    String? milestoneTitle,
    String? projectId,
    String? projectTag,
    TaskPriority? priority,
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
