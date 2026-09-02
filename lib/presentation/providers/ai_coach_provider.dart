import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_coach_report.dart';
import 'dsa_provider.dart';
import 'habits_provider.dart';
import 'tasks_provider.dart';

class AiCoachState {
  final AiCoachReport? latestReport;
  final bool isAnalyzing;
  final List<AiCoachReport> historicalReports;

  const AiCoachState({
    this.latestReport,
    this.isAnalyzing = false,
    this.historicalReports = const [],
  });

  AiCoachState copyWith({
    AiCoachReport? latestReport,
    bool? isAnalyzing,
    List<AiCoachReport>? historicalReports,
  }) {
    return AiCoachState(
      latestReport: latestReport ?? this.latestReport,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      historicalReports: historicalReports ?? this.historicalReports,
    );
  }
}

class AiCoachNotifier extends StateNotifier<AiCoachState> {
  final Ref _ref;

  AiCoachNotifier(this._ref)
      : super(const AiCoachState(latestReport: null, historicalReports: []));

  Future<void> triggerSynthesis() async {
    state = state.copyWith(isAnalyzing: true);
    await Future.delayed(const Duration(milliseconds: 900));

    final dsaState = _ref.read(dsaProvider);
    final tasksState = _ref.read(tasksProvider);
    final habits = _ref.read(habitsProvider);

    final solvedProblems = dsaState.solvedCount;
    final completedTasks = tasksState.completedCount;
    final completedHabits = habits.where((h) => h.isCompletedToday).length;

    final assessmentText = solvedProblems == 0 && completedTasks == 0
        ? 'Clean workspace initialized. Add priority tasks in the Unified Task Matrix and solve Striver A2Z problems to generate personalized cognitive recommendations.'
        : 'Telemetry shows $solvedProblems algorithmic problem${solvedProblems == 1 ? '' : 's'} solved and $completedTasks priority task${completedTasks == 1 ? '' : 's'} completed. Keep momentum high and maintain focused daily execution.';

    final report = AiCoachReport(
      date: DateTime.now(),
      assessment: assessmentText,
      frictionDiagnosis: completedTasks == 0
          ? 'No bottlenecks detected. Recommended action: schedule your first 25-minute deep focus sprint.'
          : 'High velocity noted across completed tasks. Protect your morning focus blocks.',
      deepWorkLoggedHours: 0.0,
      problemsSolved: solvedProblems,
      habitsCompleted: completedHabits,
      tomorrowPlan: tasksState.tasks.where((t) => !t.isCompleted).take(3).map((t) {
        return TomorrowTaskPlan(
          timeSlot: 'Morning Priority',
          title: t.title,
          cognitiveTier: 'Deep 3x',
        );
      }).toList(),
    );

    state = state.copyWith(
      isAnalyzing: false,
      latestReport: report,
      historicalReports: [report, ...state.historicalReports],
    );
  }
}

final aiCoachProvider =
    StateNotifierProvider<AiCoachNotifier, AiCoachState>((ref) {
  return AiCoachNotifier(ref);
});
