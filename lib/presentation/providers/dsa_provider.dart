import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/striver_a2z_data.dart';
import '../../core/services/supabase_service.dart';
import '../../domain/models/dsa_problem.dart';
import 'auth_provider.dart';

class DsaState {
  final List<DsaProblem> problems;
  final int? selectedStepNumber;
  final DsaDifficulty? selectedDifficulty;
  final DsaStatus? selectedStatus;
  final bool filterDueForRevisionOnly;
  final String searchQuery;
  final bool isLoading;

  const DsaState({
    required this.problems,
    this.selectedStepNumber,
    this.selectedDifficulty,
    this.selectedStatus,
    this.filterDueForRevisionOnly = false,
    this.searchQuery = '',
    this.isLoading = false,
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
    bool? isLoading,
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
      isLoading: isLoading ?? this.isLoading,
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
      if (filterDueForRevisionOnly && !p.isDueForRevision) return false;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchesTitle = p.title.toLowerCase().contains(q);
        final matchesPattern = p.pattern.toLowerCase().contains(q);
        final matchesStep = p.stepTitle.toLowerCase().contains(q);
        if (!matchesTitle && !matchesPattern && !matchesStep) return false;
      }
      return true;
    }).toList();
  }

  int get solvedCount =>
      problems.where((p) => p.status == DsaStatus.solved).length;

  int get totalCount => problems.length;

  int get revisionDueCount =>
      problems.where((p) => p.isDueForRevision).length;

  double get overallProgressPercentage =>
      totalCount == 0 ? 0.0 : (solvedCount / totalCount) * 100.0;

  List<DsaStepSummary> get stepSummaries {
    final Map<int, List<DsaProblem>> grouped = {};
    for (final p in problems) {
      grouped.putIfAbsent(p.stepNumber, () => []).add(p);
    }

    final titles = StriverA2ZData.getStepTitles();

    final List<DsaStepSummary> list = [];
    for (int stepNum = 1; stepNum <= 18; stepNum++) {
      final stepProblems = grouped[stepNum] ?? [];
      final defaultTitle =
          stepNum < titles.length ? titles[stepNum] : 'Step $stepNum';
      final stepTitle = stepProblems.isNotEmpty
          ? stepProblems.first.stepTitle
          : defaultTitle;
      final solved =
          stepProblems.where((p) => p.status == DsaStatus.solved).length;
      final total = stepProblems.length;

      list.add(DsaStepSummary(
        stepNumber: stepNum,
        title: stepTitle,
        totalProblems: total,
        solvedProblems: solved,
        progressPercentage: total == 0 ? 0.0 : (solved / total) * 100.0,
      ));
    }
    return list;
  }
}

class DsaStepSummary {
  final int stepNumber;
  final String title;
  final int totalProblems;
  final int solvedProblems;
  final double progressPercentage;

  const DsaStepSummary({
    required this.stepNumber,
    required this.title,
    required this.totalProblems,
    required this.solvedProblems,
    required this.progressPercentage,
  });
}

class DsaNotifier extends StateNotifier<DsaState> {
  final Ref _ref;
  String? _currentUserId;

  DsaNotifier(this._ref)
      : super(DsaState(
          problems: _getCleanStriverProblems(),
        )) {
    // Listen to user auth changes
    _ref.listen<AuthState>(authProvider, (previous, next) {
      final newUserId = next.user?.id;
      if (newUserId != _currentUserId) {
        _currentUserId = newUserId;
        if (newUserId != null) {
          loadUserDsaProgress(newUserId);
        } else {
          state = DsaState(problems: _getCleanStriverProblems());
        }
      }
    });

    final initialUser = _ref.read(authProvider).user;
    if (initialUser != null) {
      _currentUserId = initialUser.id;
      loadUserDsaProgress(initialUser.id);
    }
  }

  static List<DsaProblem> _getCleanStriverProblems() {
    // Clean initial state: All problems in todo status (0 solved)
    return StriverA2ZData.problems.map((p) => p.copyWith(
      status: DsaStatus.todo,
      reviewCount: 0,
    )).toList();
  }

  Future<void> loadUserDsaProgress(String userId) async {
    state = state.copyWith(isLoading: true);
    final userProgress = await SupabaseService.fetchUserDsaProgress(userId);

    final updatedProblems = _getCleanStriverProblems().map((p) {
      if (userProgress.containsKey(p.id)) {
        final data = userProgress[p.id] as Map<String, dynamic>;
        final statusStr = data['status'] as String? ?? 'todo';
        final status = DsaStatus.values.firstWhere(
          (s) => s.name == statusStr,
          orElse: () => DsaStatus.todo,
        );
        final reviewCount = data['reviewCount'] as int? ?? 0;
        final nextRevStr = data['nextRevisionDate'] as String?;
        final nextRevision = nextRevStr != null ? DateTime.tryParse(nextRevStr) : null;

        return p.copyWith(
          status: status,
          reviewCount: reviewCount,
          nextRevisionDate: nextRevision,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(problems: updatedProblems, isLoading: false);
  }

  Future<void> toggleProblemStatus(String problemId) async {
    final now = DateTime.now();

    final updated = state.problems.map((p) {
      if (p.id == problemId) {
        final newStatus = p.status == DsaStatus.solved
            ? DsaStatus.todo
            : DsaStatus.solved;

        int newReviewCount = p.reviewCount;
        DateTime? nextRevisionDate;

        if (newStatus == DsaStatus.solved) {
          newReviewCount += 1;
          int intervalDays = 1;
          if (newReviewCount == 1) {
            intervalDays = 1;
          } else if (newReviewCount == 2) {
            intervalDays = 3;
          } else if (newReviewCount == 3) {
            intervalDays = 7;
          } else if (newReviewCount == 4) {
            intervalDays = 21;
          } else {
            intervalDays = 45;
          }
          nextRevisionDate = now.add(Duration(days: intervalDays));
        }

        if (_currentUserId != null) {
          SupabaseService.saveUserDsaProblemStatus(
            _currentUserId!,
            problemId,
            newStatus,
            reviewCount: newReviewCount,
            nextRevisionDate: nextRevisionDate,
          );
        }

        return p.copyWith(
          status: newStatus,
          lastSolvedAt: newStatus == DsaStatus.solved ? now : null,
          reviewCount: newReviewCount,
          nextRevisionDate: nextRevisionDate,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(problems: updated);
  }

  void setStepFilter(int? stepNumber) {
    if (stepNumber == null) {
      state = state.copyWith(clearStep: true);
    } else {
      state = state.copyWith(selectedStepNumber: stepNumber);
    }
  }

  void setDifficultyFilter(DsaDifficulty? diff) {
    if (diff == null) {
      state = state.copyWith(clearDifficulty: true);
    } else {
      state = state.copyWith(selectedDifficulty: diff);
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
        filterDueForRevisionOnly: !state.filterDueForRevisionOnly);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final dsaProvider = StateNotifierProvider<DsaNotifier, DsaState>((ref) {
  return DsaNotifier(ref);
});
