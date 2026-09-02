class TomorrowTaskPlan {
  final String timeSlot;
  final String title;
  final String cognitiveTier;

  const TomorrowTaskPlan({
    required this.timeSlot,
    required this.title,
    required this.cognitiveTier,
  });
}

class AiCoachReport {
  final DateTime date;
  final String assessment;
  final String frictionDiagnosis;
  final double deepWorkLoggedHours;
  final int problemsSolved;
  final int habitsCompleted;
  final List<TomorrowTaskPlan> tomorrowPlan;

  const AiCoachReport({
    required this.date,
    required this.assessment,
    required this.frictionDiagnosis,
    required this.deepWorkLoggedHours,
    required this.problemsSolved,
    required this.habitsCompleted,
    required this.tomorrowPlan,
  });
}
