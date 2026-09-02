import 'package:flutter/material.dart';

class PeerMember {
  final String id;
  final String name;
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

  const PeerMember({
    required this.id,
    required this.name,
    required this.handle,
    required this.avatarColor,
    this.isOnline = true,
    this.isFocusingNow = false,
    this.currentFocusTask,
    this.focusRemainingSeconds,
    this.problemsSolvedToday = 0,
    this.totalProblemsSolved = 0,
    this.deepWorkHoursToday = 3.5,
    this.totalFocusMinutesWeek = 0,
    this.streakDays = 1,
    required this.currentDsaTopic,
  });

  PeerMember copyWith({
    String? id,
    String? name,
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
  }) {
    return PeerMember(
      id: id ?? this.id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      avatarColor: avatarColor ?? this.avatarColor,
      isOnline: isOnline ?? this.isOnline,
      isFocusingNow: isFocusingNow ?? this.isFocusingNow,
      currentFocusTask: currentFocusTask ?? this.currentFocusTask,
      focusRemainingSeconds: focusRemainingSeconds ?? this.focusRemainingSeconds,
      problemsSolvedToday: problemsSolvedToday ?? this.problemsSolvedToday,
      totalProblemsSolved: totalProblemsSolved ?? this.totalProblemsSolved,
      deepWorkHoursToday: deepWorkHoursToday ?? this.deepWorkHoursToday,
      totalFocusMinutesWeek: totalFocusMinutesWeek ?? this.totalFocusMinutesWeek,
      streakDays: streakDays ?? this.streakDays,
      currentDsaTopic: currentDsaTopic ?? this.currentDsaTopic,
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

  int get totalGroupProblemsToday =>
      members.fold(0, (sum, m) => sum + m.problemsSolvedToday);

  int get totalGroupFocusHoursWeek =>
      (members.fold(0, (sum, m) => sum + m.totalFocusMinutesWeek) / 60).round();

  int get activeFocusingMembersCount =>
      members.where((m) => m.isFocusingNow).length;
}
