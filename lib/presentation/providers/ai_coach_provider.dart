import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_coach_report.dart';

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
  AiCoachNotifier() : super(_initialReportState());

  static AiCoachState _initialReportState() {
    final report = AiCoachReport(
      date: DateTime.now(),
      assessment:
          'Exceptional deep work focus logged today (3.5 hours). You solved 4 Striver A2Z problems across Binary Trees with a 98% habit consistency score. Morning focus window (08:00 - 10:30) yielded peak velocity.',
      frictionDiagnosis:
          'Zero critical path blockers. Slight energy dip noted at 15:00; recommend inserting a 15-minute physical walk between Deep Work blocks to maintain evening retention.',
      deepWorkLoggedHours: 3.5,
      problemsSolved: 4,
      habitsCompleted: 4,
      tomorrowPlan: [
        const TomorrowTaskPlan(
          timeSlot: '08:00 - 10:00',
          title: 'Deep Work: Binary Tree Vertical Order & Top/Bottom View',
          cognitiveTier: 'Deep 3x',
        ),
        const TomorrowTaskPlan(
          timeSlot: '10:30 - 11:30',
          title: 'DSA Squad Peer Study Session',
          cognitiveTier: 'Medium 2x',
        ),
        const TomorrowTaskPlan(
          timeSlot: '14:00 - 16:00',
          title: 'GPU Triton Kernel: Benchmark Shared Memory Bandwidth',
          cognitiveTier: 'Deep 3x',
        ),
        const TomorrowTaskPlan(
          timeSlot: '17:30 - 18:30',
          title: 'Physical Training & Evening Recovery',
          cognitiveTier: 'Shallow 1x',
        ),
      ],
    );

    return AiCoachState(
      latestReport: report,
      historicalReports: [report],
    );
  }

  Future<void> triggerSynthesis() async {
    state = state.copyWith(isAnalyzing: true);
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(isAnalyzing: false);
  }
}

final aiCoachProvider =
    StateNotifierProvider<AiCoachNotifier, AiCoachState>((ref) {
  return AiCoachNotifier();
});
