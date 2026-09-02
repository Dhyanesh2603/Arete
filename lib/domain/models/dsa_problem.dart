enum DsaDifficulty {
  easy,
  medium,
  hard,
}

enum DsaStatus {
  todo,
  inProgress,
  solved,
  revisionNeeded,
}

class DsaProblem {
  final String id;
  final int stepNumber;
  final String stepTitle;
  final String subTopic;
  final String title;
  final DsaDifficulty difficulty;
  final DsaStatus status;
  final String pattern;
  final String? problemUrl;
  final String? solutionUrl;
  final String? notes;
  final int timeSpentMinutes;
  final DateTime? completedAt;

  const DsaProblem({
    required this.id,
    required this.stepNumber,
    required this.stepTitle,
    required this.subTopic,
    required this.title,
    required this.difficulty,
    this.status = DsaStatus.todo,
    required this.pattern,
    this.problemUrl,
    this.solutionUrl,
    this.notes,
    this.timeSpentMinutes = 0,
    this.completedAt,
  });

  DsaProblem copyWith({
    String? id,
    int? stepNumber,
    String? stepTitle,
    String? subTopic,
    String? title,
    DsaDifficulty? difficulty,
    DsaStatus? status,
    String? pattern,
    String? problemUrl,
    String? solutionUrl,
    String? notes,
    int? timeSpentMinutes,
    DateTime? completedAt,
  }) {
    return DsaProblem(
      id: id ?? this.id,
      stepNumber: stepNumber ?? this.stepNumber,
      stepTitle: stepTitle ?? this.stepTitle,
      subTopic: subTopic ?? this.subTopic,
      title: title ?? this.title,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      pattern: pattern ?? this.pattern,
      problemUrl: problemUrl ?? this.problemUrl,
      solutionUrl: solutionUrl ?? this.solutionUrl,
      notes: notes ?? this.notes,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class DsaStepSummary {
  final int stepNumber;
  final String title;
  final int totalProblems;
  final int solvedProblems;

  const DsaStepSummary({
    required this.stepNumber,
    required this.title,
    required this.totalProblems,
    required this.solvedProblems,
  });

  double get progressPercentage =>
      totalProblems == 0 ? 0.0 : (solvedProblems / totalProblems) * 100.0;
}
