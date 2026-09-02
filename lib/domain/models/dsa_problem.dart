enum DsaDifficulty { easy, medium, hard }

enum DsaStatus { todo, inProgress, solved }

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
  final String? notes;
  final int timeSpentMinutes;
  final DateTime? lastSolvedAt;
  final DateTime? nextRevisionDate;
  final int reviewCount;
  final String hintTier1; // Intuition & Pattern
  final String hintTier2; // State / Transition Invariant
  final String hintTier3; // Edge Cases & Pitfalls

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
    this.notes,
    this.timeSpentMinutes = 0,
    this.lastSolvedAt,
    this.nextRevisionDate,
    this.reviewCount = 0,
    this.hintTier1 = 'Analyze the input constraints and identify repeating sub-problems or monotonic properties.',
    this.hintTier2 = 'Determine whether a greedy choice holds, or construct the recurrence relation f(i) based on prior sub-states.',
    this.hintTier3 = 'Verify edge cases: empty input, single element, negative numbers, overflow boundaries, and duplicates.',
  });

  bool get isDueForRevision {
    if (status != DsaStatus.solved || nextRevisionDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rev = DateTime(nextRevisionDate!.year, nextRevisionDate!.month, nextRevisionDate!.day);
    return rev.isBefore(today) || rev.isAtSameMomentAs(today);
  }

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
    String? notes,
    int? timeSpentMinutes,
    DateTime? lastSolvedAt,
    DateTime? nextRevisionDate,
    int? reviewCount,
    String? hintTier1,
    String? hintTier2,
    String? hintTier3,
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
      notes: notes ?? this.notes,
      timeSpentMinutes: timeSpentMinutes ?? this.timeSpentMinutes,
      lastSolvedAt: lastSolvedAt ?? this.lastSolvedAt,
      nextRevisionDate: nextRevisionDate ?? this.nextRevisionDate,
      reviewCount: reviewCount ?? this.reviewCount,
      hintTier1: hintTier1 ?? this.hintTier1,
      hintTier2: hintTier2 ?? this.hintTier2,
      hintTier3: hintTier3 ?? this.hintTier3,
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
