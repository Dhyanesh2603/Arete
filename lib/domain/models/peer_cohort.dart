import 'package:flutter/material.dart';

class PeerMember {
  final String id;
  final String name;
  final String email;
  final String handle;
  final Color avatarColor;
  final bool isOnline;
  final bool isFocusingNow;
  final String? currentFocusTask;
  final int? focusRemainingSeconds;
  final int problemsSolvedToday;
  final int totalProblemsSolved;
  final double deepWorkHoursToday;
  final int totalFocusMinutesWeek;
  final int streakDays;
  final String currentDsaTopic;
  final bool isInvited;

  const PeerMember({
    required this.id,
    required this.name,
    this.email = '',
    required this.handle,
    required this.avatarColor,
    this.isOnline = true,
    this.isFocusingNow = false,
    this.currentFocusTask,
    this.focusRemainingSeconds,
    this.problemsSolvedToday = 0,
    this.totalProblemsSolved = 0,
    this.deepWorkHoursToday = 0.0,
    this.totalFocusMinutesWeek = 0,
    this.streakDays = 0,
    this.currentDsaTopic = 'General Practice',
    this.isInvited = false,
  });

  PeerMember copyWith({
    String? id,
    String? name,
    String? email,
    String? handle,
    Color? avatarColor,
    bool? isOnline,
    bool? isFocusingNow,
    String? currentFocusTask,
    int? focusRemainingSeconds,
    int? problemsSolvedToday,
    int? totalProblemsSolved,
    double? deepWorkHoursToday,
    int? totalFocusMinutesWeek,
    int? streakDays,
    String? currentDsaTopic,
    bool? isInvited,
  }) {
    return PeerMember(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      handle: handle ?? this.handle,
      avatarColor: avatarColor ?? this.avatarColor,
      isOnline: isOnline ?? this.isOnline,
      isFocusingNow: isFocusingNow ?? this.isFocusingNow,
      currentFocusTask: currentFocusTask ?? this.currentFocusTask,
      focusRemainingSeconds:
          focusRemainingSeconds ?? this.focusRemainingSeconds,
      problemsSolvedToday: problemsSolvedToday ?? this.problemsSolvedToday,
      totalProblemsSolved: totalProblemsSolved ?? this.totalProblemsSolved,
      deepWorkHoursToday: deepWorkHoursToday ?? this.deepWorkHoursToday,
      totalFocusMinutesWeek:
          totalFocusMinutesWeek ?? this.totalFocusMinutesWeek,
      streakDays: streakDays ?? this.streakDays,
      currentDsaTopic: currentDsaTopic ?? this.currentDsaTopic,
      isInvited: isInvited ?? this.isInvited,
    );
  }
}

class PeerCohort {
  final String id;
  final String name;
  final String targetGoal;
  final List<PeerMember> members;
  final int sprintTargetProblems;
  final DateTime sprintDeadline;

  const PeerCohort({
    required this.id,
    required this.name,
    required this.targetGoal,
    required this.members,
    this.sprintTargetProblems = 50,
    required this.sprintDeadline,
  });

  PeerCohort copyWith({
    String? id,
    String? name,
    String? targetGoal,
    List<PeerMember>? members,
    int? sprintTargetProblems,
    DateTime? sprintDeadline,
  }) {
    return PeerCohort(
      id: id ?? this.id,
      name: name ?? this.name,
      targetGoal: targetGoal ?? this.targetGoal,
      members: members ?? this.members,
      sprintTargetProblems:
          sprintTargetProblems ?? this.sprintTargetProblems,
      sprintDeadline: sprintDeadline ?? this.sprintDeadline,
    );
  }

  int get totalGroupProblemsToday =>
      members.fold(0, (sum, m) => sum + m.problemsSolvedToday);

  int get totalGroupFocusHoursWeek =>
      (members.fold(0, (sum, m) => sum + m.totalFocusMinutesWeek) / 60).round();

  int get activeFocusingMembersCount =>
      members.where((m) => m.isFocusingNow).length;
}
