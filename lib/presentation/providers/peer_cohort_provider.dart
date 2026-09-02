import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/peer_cohort.dart';

class PeerCohortState {
  final PeerCohort cohort;
  final String currentUserId;

  const PeerCohortState({
    required this.cohort,
    required this.currentUserId,
  });

  PeerCohortState copyWith({
    PeerCohort? cohort,
    String? currentUserId,
  }) {
    return PeerCohortState(
      cohort: cohort ?? this.cohort,
      currentUserId: currentUserId ?? this.currentUserId,
    );
  }
}

class PeerCohortNotifier extends StateNotifier<PeerCohortState> {
  PeerCohortNotifier() : super(_initialCohortState());

  static PeerCohortState _initialCohortState() {
    final members = [
      const PeerMember(
        id: 'user-dhyan',
        name: 'Dhyanesh',
        handle: '@dhyanesh',
        avatarColor: Color(0xFF38BDF8),
        isOnline: true,
        isFocusingNow: true,
        currentFocusTask: 'Striver A2Z: Binary Trees Traversal & LCA',
        focusRemainingSeconds: 1420,
        problemsSolvedToday: 4,
        totalProblemsSolved: 48,
        totalFocusMinutesWeek: 640,
        streakDays: 14,
        currentDsaTopic: 'Step 13: Binary Trees',
      ),
      const PeerMember(
        id: 'user-alex',
        name: 'Alex Chen',
        handle: '@alex_c',
        avatarColor: Color(0xFF818CF8),
        isOnline: true,
        isFocusingNow: true,
        currentFocusTask: 'LeetCode 15: 3Sum & 4Sum Partitioning',
        focusRemainingSeconds: 840,
        problemsSolvedToday: 3,
        totalProblemsSolved: 52,
        totalFocusMinutesWeek: 580,
        streakDays: 19,
        currentDsaTopic: 'Step 3: Arrays Hard',
      ),
      const PeerMember(
        id: 'user-maya',
        name: 'Maya Patel',
        handle: '@maya_dev',
        avatarColor: Color(0xFF34D399),
        isOnline: true,
        isFocusingNow: false,
        problemsSolvedToday: 2,
        totalProblemsSolved: 39,
        totalFocusMinutesWeek: 420,
        streakDays: 8,
        currentDsaTopic: 'Step 4: Binary Search',
      ),
      const PeerMember(
        id: 'user-ryan',
        name: 'Ryan Miller',
        handle: '@ryan_m',
        avatarColor: Color(0xFFFBBF24),
        isOnline: false,
        isFocusingNow: false,
        problemsSolvedToday: 1,
        totalProblemsSolved: 31,
        totalFocusMinutesWeek: 310,
        streakDays: 5,
        currentDsaTopic: 'Step 6: LinkedList',
      ),
      const PeerMember(
        id: 'user-sarah',
        name: 'Sarah Kim',
        handle: '@sarah_k',
        avatarColor: Color(0xFFFB7185),
        isOnline: true,
        isFocusingNow: false,
        problemsSolvedToday: 3,
        totalProblemsSolved: 44,
        totalFocusMinutesWeek: 510,
        streakDays: 12,
        currentDsaTopic: 'Step 7: Recursion',
      ),
    ];

    return PeerCohortState(
      currentUserId: 'user-dhyan',
      cohort: PeerCohort(
        id: 'cohort-dsa-alpha',
        name: 'DSA Masters Cohort Alpha',
        targetGoal: 'Master Striver A2Z Sheet & Land Top Tier Engineering Roles',
        members: members,
        sprintTargetProblems: 50,
        sprintDeadline: DateTime.now().add(const Duration(days: 4)),
      ),
    );
  }

  void incrementMyProblemsSolved() {
    final updatedMembers = state.cohort.members.map((m) {
      if (m.id == state.currentUserId) {
        return m.copyWith(
          problemsSolvedToday: m.problemsSolvedToday + 1,
          totalProblemsSolved: m.totalProblemsSolved + 1,
        );
      }
      return m;
    }).toList();

    state = state.copyWith(
      cohort: PeerCohort(
        id: state.cohort.id,
        name: state.cohort.name,
        targetGoal: state.cohort.targetGoal,
        members: updatedMembers,
        sprintTargetProblems: state.cohort.sprintTargetProblems,
        sprintDeadline: state.cohort.sprintDeadline,
      ),
    );
  }
}

final peerCohortProvider =
    StateNotifierProvider<PeerCohortNotifier, PeerCohortState>((ref) {
  return PeerCohortNotifier();
});
