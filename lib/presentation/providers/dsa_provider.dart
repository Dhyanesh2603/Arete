import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/striver_a2z_data.dart';
import '../../domain/models/dsa_problem.dart';

class DsaState {
  final List<DsaProblem> problems;
  final int? selectedStepNumber; // null means All Steps
  final DsaDifficulty? selectedDifficulty; // null means All
  final DsaStatus? selectedStatus; // null means All
  final String searchQuery;

  const DsaState({
    required this.problems,
    this.selectedStepNumber,
    this.selectedDifficulty,
    this.selectedStatus,
    this.searchQuery = '',
  });

  DsaState copyWith({
    List<DsaProblem>? problems,
    int? selectedStepNumber,
    bool clearStep = false,
    DsaDifficulty? selectedDifficulty,
    bool clearDifficulty = false,
    DsaStatus? selectedStatus,
    bool clearStatus = false,
    String? searchQuery,
  }) {
    return DsaState(
      problems: problems ?? this.problems,
      selectedStepNumber:
          clearStep ? null : (selectedStepNumber ?? this.selectedStepNumber),
      selectedDifficulty: clearDifficulty
          ? null
          : (selectedDifficulty ?? this.selectedDifficulty),
      selectedStatus:
          clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  int get totalCount => problems.length;
  int get solvedCount =>
      problems.where((p) => p.status == DsaStatus.solved).length;
  double get overallProgress =>
      totalCount == 0 ? 0.0 : (solvedCount / totalCount) * 100.0;

  int get easyTotal =>
      problems.where((p) => p.difficulty == DsaDifficulty.easy).length;
  int get easySolved => problems
      .where((p) =>
          p.difficulty == DsaDifficulty.easy && p.status == DsaStatus.solved)
      .length;

  int get mediumTotal =>
      problems.where((p) => p.difficulty == DsaDifficulty.medium).length;
  int get mediumSolved => problems
      .where((p) =>
          p.difficulty == DsaDifficulty.medium && p.status == DsaStatus.solved)
      .length;

  int get hardTotal =>
      problems.where((p) => p.difficulty == DsaDifficulty.hard).length;
  int get hardSolved => problems
      .where((p) =>
          p.difficulty == DsaDifficulty.hard && p.status == DsaStatus.solved)
      .length;

  List<DsaProblem> get filteredProblems {
    return problems.where((p) {
      if (selectedStepNumber != null && p.stepNumber != selectedStepNumber) {
        return false;
      }
      if (selectedDifficulty != null && p.difficulty != selectedDifficulty) {
        return false;
      }
      if (selectedStatus != null && p.status != selectedStatus) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesTitle = p.title.toLowerCase().contains(query);
        final matchesPattern = p.pattern.toLowerCase().contains(query);
        final matchesSubTopic = p.subTopic.toLowerCase().contains(query);
        if (!matchesTitle && !matchesPattern && !matchesSubTopic) return false;
      }
      return true;
    }).toList();
  }

  List<DsaStepSummary> get stepSummaries {
    final Map<int, List<DsaProblem>> grouped = {};
    for (final p in problems) {
      grouped.putIfAbsent(p.stepNumber, () => []).add(p);
    }

    final List<DsaStepSummary> summaries = [];
    final titles = StriverA2ZData.getStepTitles();

    for (int step = 1; step <= 18; step++) {
      final list = grouped[step] ?? [];
      final solved = list.where((p) => p.status == DsaStatus.solved).length;
      final title = step < titles.length ? titles[step] : 'Step $step';
      summaries.add(DsaStepSummary(
        stepNumber: step,
        title: title,
        totalProblems: list.length,
        solvedProblems: solved,
      ));
    }
    return summaries;
  }
}

class DsaNotifier extends StateNotifier<DsaState> {
  DsaNotifier()
      : super(DsaState(problems: StriverA2ZData.getInitialProblems()));

  void toggleStatus(String id) {
    state = state.copyWith(
      problems: state.problems.map((p) {
        if (p.id == id) {
          final nextStatus = p.status == DsaStatus.solved
              ? DsaStatus.todo
              : p.status == DsaStatus.todo
                  ? DsaStatus.inProgress
                  : DsaStatus.solved;
          return p.copyWith(
            status: nextStatus,
            completedAt: nextStatus == DsaStatus.solved ? DateTime.now() : null,
          );
        }
        return p;
      }).toList(),
    );
  }

  void setStepFilter(int? stepNumber) {
    if (stepNumber == null) {
      state = state.copyWith(clearStep: true);
    } else {
      state = state.copyWith(selectedStepNumber: stepNumber);
    }
  }

  void setDifficultyFilter(DsaDifficulty? difficulty) {
    if (difficulty == null) {
      state = state.copyWith(clearDifficulty: true);
    } else {
      state = state.copyWith(selectedDifficulty: difficulty);
    }
  }

  void setStatusFilter(DsaStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateNotes(String id, String notes) {
    state = state.copyWith(
      problems: state.problems.map((p) {
        if (p.id == id) return p.copyWith(notes: notes);
        return p;
      }).toList(),
    );
  }
}

final dsaProvider = StateNotifierProvider<DsaNotifier, DsaState>((ref) {
  return DsaNotifier();
});
