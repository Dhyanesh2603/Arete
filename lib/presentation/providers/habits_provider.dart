import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';
import '../../domain/models/habit.dart';
import 'auth_provider.dart';

class HabitsNotifier extends StateNotifier<List<Habit>> {
  final Ref _ref;
  String? _currentUserId;

  HabitsNotifier(this._ref) : super([]) {
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final newUserId = next.user?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        if (newUserId != null) {
          loadUserHabits(newUserId);
        } else {
          state = [];
        }
      }
    });

    final initialUser = _ref.read(authProvider).user;
    if (initialUser != null) {
      _currentUserId = initialUser.id;
      loadUserHabits(initialUser.id);
    }
  }

  Future<void> loadUserHabits(String userId) async {
    final userHabits = await SupabaseService.fetchUserHabits(userId);
    state = userHabits;
  }

  Future<void> toggleHabitToday(String habitId) async {
    final updated = state.map((h) {
      if (h.id == habitId) {
        final nextStatus = !h.isCompletedToday;
        final history = List<bool>.from(h.last30DaysHistory);
        if (history.isNotEmpty) {
          history[history.length - 1] = nextStatus;
        }
        final trueCount = history.where((v) => v).length;
        final newScore = history.isEmpty ? 100.0 : (trueCount / history.length) * 100.0;
        return h.copyWith(
          isCompletedToday: nextStatus,
          last30DaysHistory: history,
          consistencyScore: double.parse(newScore.toStringAsFixed(1)),
        );
      }
      return h;
    }).toList();

    state = updated;
    if (_currentUserId != null) {
      await SupabaseService.saveUserHabits(_currentUserId!, updated);
    }
  }

  Future<void> addHabit(Habit habit) async {
    final updated = [...state, habit];
    state = updated;
    if (_currentUserId != null) {
      await SupabaseService.saveUserHabits(_currentUserId!, updated);
    }
  }

  Future<void> deleteHabit(String habitId) async {
    final updated = state.where((h) => h.id != habitId).toList();
    state = updated;
    if (_currentUserId != null) {
      await SupabaseService.saveUserHabits(_currentUserId!, updated);
    }
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, List<Habit>>((ref) {
  return HabitsNotifier(ref);
});
