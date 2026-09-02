enum HabitFrequency { dailyMorning, dailyEvening, weeklyTarget }

class Habit {
  final String id;
  final String title;
  final HabitFrequency frequency;
  final int targetCountPerPeriod;
  final double consistencyScore; // 0.0 to 100.0
  final bool isCompletedToday;
  final List<bool> last30DaysHistory;

  const Habit({
    required this.id,
    required this.title,
    this.frequency = HabitFrequency.dailyMorning,
    this.targetCountPerPeriod = 1,
    this.consistencyScore = 100.0,
    this.isCompletedToday = false,
    this.last30DaysHistory = const [],
  });

  Habit copyWith({
    String? id,
    String? title,
    HabitFrequency? frequency,
    int? targetCountPerPeriod,
    double? consistencyScore,
    bool? isCompletedToday,
    List<bool>? last30DaysHistory,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      frequency: frequency ?? this.frequency,
      targetCountPerPeriod: targetCountPerPeriod ?? this.targetCountPerPeriod,
      consistencyScore: consistencyScore ?? this.consistencyScore,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      last30DaysHistory: last30DaysHistory ?? this.last30DaysHistory,
    );
  }
}
