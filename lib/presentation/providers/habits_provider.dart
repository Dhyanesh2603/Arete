import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/habit.dart';

class HabitsNotifier extends StateNotifier<List<Habit>> {
  HabitsNotifier() : super(_initialHabits());

  static List<Habit> _initialHabits() {
    return [
      Habit(
        id: 'h-1',
        title: 'Solve 3 Striver A2Z Problems Daily',
        frequency: HabitFrequency.dailyMorning,
        consistencyScore: 98.4,
        isCompletedToday: true,
        last30DaysHistory: List.generate(30, (i) => i % 7 != 0),
      ),
      Habit(
        id: 'h-2',
        title: '2 Hours Deep Focus Code Lab',
        frequency: HabitFrequency.dailyMorning,
        consistencyScore: 94.2,
        isCompletedToday: true,
        last30DaysHistory: List.generate(30, (i) => i % 5 != 0),
      ),
      Habit(
        id: 'h-3',
        title: 'Read 1 Technical Research Paper / Note',
        frequency: HabitFrequency.dailyEvening,
        consistencyScore: 88.0,
        isCompletedToday: false,
        last30DaysHistory: List.generate(30, (i) => i % 4 != 0),
      ),
      Habit(
        id: 'h-4',
        title: '45m Physical Training & Recovery',
        frequency: HabitFrequency.dailyEvening,
        consistencyScore: 91.5,
        isCompletedToday: false,
        last30DaysHistory: List.generate(30, (i) => i % 6 != 0),
      ),
    ];
  }

  void toggleHabitToday(String habitId) {
    state = state.map((h) {
      if (h.id == habitId) {
        final nextStatus = !h.isCompletedToday;
        final history = List<bool>.from(h.last30DaysHistory);
        if (history.isNotEmpty) {
          history[history.length - 1] = nextStatus;
        }
        final trueCount = history.where((v) => v).length;
        final newScore = (trueCount / history.length) * 100.0;
        return h.copyWith(
          isCompletedToday: nextStatus,
          last30DaysHistory: history,
          consistencyScore: double.parse(newScore.toStringAsFixed(1)),
        );
      }
      return h;
    }).toList();
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  return HabitsNotifier();
});
