import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/striver_a2z_data.dart';
import '../../domain/models/dsa_problem.dart';
import 'peer_cohort_provider.dart';

class DsaState {
  final List<DsaProblem> problems;
  final int? selectedStepNumber;
  final DsaDifficulty? selectedDifficulty;
  final DsaStatus? selectedStatus;
  final bool filterDueForRevisionOnly;
  final String searchQuery;

  const DsaState({
    required this.problems,
    this.selectedStepNumber,
    this.selectedDifficulty,
    this.selectedStatus,
    this.filterDueForRevisionOnly = false,
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
    bool? filterDueForRevisionOnly,
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
      filterDueForRevisionOnly:
          filterDueForRevisionOnly ?? this.filterDueForRevisionOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

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
      if (filterDueForRevisionOnly && !p.isDueForRevision) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesTitle = p.title.toLowerCase().contains(query);
        final matchesPattern = p.pattern.toLowerCase().contains(query);
        final matchesSubTopic = p.subTopic.toLowerCase().contains(query);
        final matchesStep = p.stepTitle.toLowerCase().contains(query);
        if (!matchesTitle && !matchesPattern && !matchesSubTopic && !matchesStep) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  int get totalCount => problems.length;
  int get solvedCount =>
      problems.where((p) => p.status == DsaStatus.solved).length;
  int get revisionDueCount =>
      problems.where((p) => p.isDueForRevision).length;

  List<DsaStepSummary> get stepSummaries {
    final Map<int, List<DsaProblem>> grouped = {};
    for (var p in problems) {
      grouped.putIfAbsent(p.stepNumber, () => []).add(p);
    }

    return grouped.entries.map((entry) {
      final stepProblems = entry.value;
      final stepNum = entry.key;
      final title = stepProblems.first.stepTitle;
      final solved =
          stepProblems.where((p) => p.status == DsaStatus.solved).length;
      return DsaStepSummary(
        stepNumber: stepNum,
        title: title,
        totalProblems: stepProblems.length,
        solvedProblems: solved,
      );
    }).toList()
      ..sort((a, b) => a.stepNumber.compareTo(b.stepNumber));
  }
}

class DsaNotifier extends StateNotifier<DsaState> {
  final Ref ref;

  DsaNotifier(this.ref)
      : super(DsaState(problems: StriverA2ZData.problems));

  void toggleProblemStatus(String problemId) {
    state = state.copyWith(
      problems: state.problems.map((p) {
        if (p.id == problemId) {
          final nextStatus = p.status == DsaStatus.solved
              ? DsaStatus.todo
              : DsaStatus.solved;

          DateTime? nextRev;
          int reviewCount = p.reviewCount;
          DateTime? lastSolved;

          if (nextStatus == DsaStatus.solved) {
            lastSolved = DateTime.now();
            reviewCount += 1;
            // SM-2 Spaced Repetition interval calculation
            final days = reviewCount == 1
                ? 1
                : reviewCount == 2
                    ? 3
                    : reviewCount == 3
                        ? 7
                        : reviewCount == 4
                            ? 21
                            : 45;
            nextRev = lastSolved.add(Duration(days: days));
            // Trigger cohort sync
            ref.read(peerCohortProvider.notifier).incrementMyProblemsSolved();
          }

          return p.copyWith(
            status: nextStatus,
            lastSolvedAt: lastSolved,
            nextRevisionDate: nextRev,
            reviewCount: reviewCount,
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

  void toggleRevisionOnlyFilter() {
    state = state.copyWith(
      filterDueForRevisionOnly: !state.filterDueForRevisionOnly,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final dsaProvider = StateNotifierProvider<DsaNotifier, DsaState>((ref) {
  return DsaNotifier(ref);
});
