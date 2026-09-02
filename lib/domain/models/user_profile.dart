import 'package:flutter/material.dart';

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String targetRole;
  final Color avatarColor;
  final int streakDays;
  final int totalProblemsSolved;
  final double totalFocusHours;
  final DateTime createdAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.targetRole = 'Software Engineer & DSA Aspirant',
    this.avatarColor = const Color(0xFF38BDF8),
    this.streakDays = 1,
    this.totalProblemsSolved = 0,
    this.totalFocusHours = 0.0,
    required this.createdAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? targetRole,
    Color? avatarColor,
    int? streakDays,
    int? totalProblemsSolved,
    double? totalFocusHours,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      targetRole: targetRole ?? this.targetRole,
      avatarColor: avatarColor ?? this.avatarColor,
      streakDays: streakDays ?? this.streakDays,
      totalProblemsSolved: totalProblemsSolved ?? this.totalProblemsSolved,
      totalFocusHours: totalFocusHours ?? this.totalFocusHours,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
