# Arete OS — State Management Architecture (Riverpod 2.x)

---

## 1. State Management Philosophy

Arete utilizes **Riverpod 2.x** with code generation (`@riverpod`) as its core state management solution. The architecture enforces:
1. **Compile-Time Safety**: Zero runtime type mismatches.
2. **Strict Unidirectional Data Flow**: Presentation widgets never mutate state directly; they dispatch intents to Notifiers.
3. **Granular Rebuild Isolation**: Widgets subscribe via `ref.watch(provider.select((s) => s.specificProperty))` to eliminate unnecessary rendering cycles.
4. **Optimistic UI Updates**: State updates locally in 0ms, applying rollbacks only on confirmed network failure.

---

## 2. Core Provider Architecture Matrix

```
[ User Action: Widget ]
         |
         v
[ ref.read(taskNotifierProvider.notifier).toggleTask(taskId) ]
         |
         +------------------------------------------------+
         | (1. Optimistic Update)                         | (2. Persist Local & Remote)
         v                                                v
[ Update In-Memory Riverpod State ]              [ TaskRepository.updateTask() ]
         |                                                |
         v                                                v
[ Re-render only checked row in UI ]             [ Enqueue Offline Mutation / Supabase ]
```

---

## 3. Key Riverpod Provider Definitions

### 1. `GoalListNotifier` (`AsyncNotifier<List<Goal>>`)
Manages the user's active goals, computing weighted rollups and priority sorting.
```dart
@riverpod
class GoalListNotifier extends _$GoalListNotifier {
  @override
  FutureOr<List<Goal>> build() async {
    final repository = ref.watch(goalRepositoryProvider);
    return repository.getActiveGoals();
  }

  Future<void> createGoal(CreateGoalInput input) async {
    final repository = ref.read(goalRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await repository.createGoal(input);
      return repository.getActiveGoals();
    });
  }
}
```

### 2. `TodayNextActionNotifier` (`Notifier<Task?>`)
Computes the single highest-priority task dynamically based on urgency, priority weight, and user energy level.
```dart
@riverpod
class TodayNextActionNotifier extends _$TodayNextActionNotifier {
  @override
  Task? build() {
    final tasks = ref.watch(todaysTaskQueueProvider).valueOrNull ?? [];
    final energy = ref.watch(currentUserEnergyProvider);
    return NextActionCalculator.computeHighestLeverage(tasks, energy);
  }
}
```

### 3. `ActiveFocusSessionNotifier` (`Notifier<FocusSessionState>`)
Controls the fullscreen Focus Mode state machine, countdown ticker, and ambient audio session.
```dart
@riverpod
class ActiveFocusSessionNotifier extends _$ActiveFocusSessionNotifier {
  @override
  FocusSessionState build() => FocusSessionState.idle();

  void startSession({required Task task, required int durationMinutes, required AcousticPreset acousticPreset}) {
    state = FocusSessionState.active(
      task: task,
      remainingSeconds: durationMinutes * 60,
      totalSeconds: durationMinutes * 60,
      preset: acousticPreset,
    );
    ref.read(audioEngineProvider).playPreset(acousticPreset);
    _startTicker();
  }

  void pauseSession() {
    state = state.copyWith(isPaused: true);
    ref.read(audioEngineProvider).pause();
  }

  void completeSession() async {
    final sessionData = state.toCompletedSession();
    state = FocusSessionState.idle();
    ref.read(audioEngineProvider).stop();
    await ref.read(focusRepositoryProvider).logSession(sessionData);
  }
}
```

### 4. `CommandPaletteNotifier` (`Notifier<CommandPaletteState>`)
Controls the Raycast-style command deck search state, in-memory index filtering, and keyboard selection indexes.
```dart
@riverpod
class CommandPaletteNotifier extends _$CommandPaletteNotifier {
  @override
  CommandPaletteState build() => CommandPaletteState.hidden();

  void open() => state = state.copyWith(isOpen: true, query: '', selectedIndex: 0);
  void close() => state = state.copyWith(isOpen: false);
  
  void updateQuery(String query) {
    final searchEngine = ref.read(commandSearchEngineProvider);
    final results = searchEngine.search(query);
    state = state.copyWith(query: query, results: results, selectedIndex: 0);
  }

  void selectNext() {
    if (state.results.isEmpty) return;
    state = state.copyWith(selectedIndex: (state.selectedIndex + 1) % state.results.length);
  }
}
```

---

## 4. Optimistic Updates and Rollback Strategy

When a user marks a task completed or checks a habit:
1. The Notifier immediately computes the new state and emits it to subscribers (0ms UI latency).
2. The Repository writes the mutation to the local IndexedDB/Hive cache.
3. The mutation is sent to Supabase.
4. If the remote request fails due to an irrecoverable server error (not network offline), the Notifier restores the previous snapshot and emits a non-intrusive error notification.
