import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/focus_session.dart';

enum FocusModeState { idle, active, paused, completed }

class ActiveFocusSession {
  final String taskTitle;
  final String objective;
  final int totalSeconds;
  final int remainingSeconds;
  final FocusModeState state;
  final AcousticPreset acousticPreset;
  final double focusQualityScore;

  const ActiveFocusSession({
    required this.taskTitle,
    required this.objective,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.state,
    this.acousticPreset = AcousticPreset.binaural40Hz,
    this.focusQualityScore = 9.8,
  });

  ActiveFocusSession copyWith({
    String? taskTitle,
    String? objective,
    int? totalSeconds,
    int? remainingSeconds,
    FocusModeState? state,
    AcousticPreset? acousticPreset,
    double? focusQualityScore,
  }) {
    return ActiveFocusSession(
      taskTitle: taskTitle ?? this.taskTitle,
      objective: objective ?? this.objective,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      state: state ?? this.state,
      acousticPreset: acousticPreset ?? this.acousticPreset,
      focusQualityScore: focusQualityScore ?? this.focusQualityScore,
    );
  }

  double get progress =>
      totalSeconds == 0 ? 0.0 : (totalSeconds - remainingSeconds) / totalSeconds;
}

class FocusSessionNotifier extends StateNotifier<ActiveFocusSession> {
  Timer? _timer;

  FocusSessionNotifier()
      : super(const ActiveFocusSession(
          taskTitle: 'Binary Tree Maximum Path Sum (LeetCode 124)',
          objective: 'Master bottom-up recursion & sub-path contribution tracking',
          totalSeconds: 45 * 60,
          remainingSeconds: 42 * 60 + 18,
          state: FocusModeState.idle,
        ));

  void startSession({
    required String taskTitle,
    required String objective,
    int durationMinutes = 45,
    AcousticPreset preset = AcousticPreset.binaural40Hz,
  }) {
    _timer?.cancel();
    state = ActiveFocusSession(
      taskTitle: taskTitle,
      objective: objective,
      totalSeconds: durationMinutes * 60,
      remainingSeconds: durationMinutes * 60,
      state: FocusModeState.active,
      acousticPreset: preset,
    );
    _startTicker();
  }

  void pauseSession() {
    _timer?.cancel();
    state = state.copyWith(state: FocusModeState.paused);
  }

  void resumeSession() {
    state = state.copyWith(state: FocusModeState.active);
    _startTicker();
  }

  void togglePlayPause() {
    if (state.state == FocusModeState.active) {
      pauseSession();
    } else if (state.state == FocusModeState.paused ||
        state.state == FocusModeState.idle) {
      resumeSession();
    }
  }

  void completeSession() {
    _timer?.cancel();
    state = state.copyWith(state: FocusModeState.completed);
  }

  void setAcousticPreset(AcousticPreset preset) {
    state = state.copyWith(acousticPreset: preset);
  }

  void _startTicker() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        completeSession();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusSessionProvider =
    StateNotifierProvider<FocusSessionNotifier, ActiveFocusSession>((ref) {
  return FocusSessionNotifier();
});
