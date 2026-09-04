import 'package:flutter/material.dart';

enum FlightPlanItemType {
  dsaRevision,
  dsaTarget,
  highPriorityTask,
  scheduledBlock,
  habitCheck,
}

class FlightPlanItem {
  final String id;
  final String title;
  final String subtitle;
  final FlightPlanItemType type;
  final int estimatedMinutes;
  final String badgeText;
  final Color badgeColor;
  final Color badgeBgColor;
  final IconData icon;
  final String? actionRoute;
  final bool isCompleted;

  const FlightPlanItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.estimatedMinutes,
    required this.badgeText,
    required this.badgeColor,
    required this.badgeBgColor,
    required this.icon,
    this.actionRoute,
    this.isCompleted = false,
  });

  FlightPlanItem copyWith({
    String? id,
    String? title,
    String? subtitle,
    FlightPlanItemType? type,
    int? estimatedMinutes,
    String? badgeText,
    Color? badgeColor,
    Color? badgeBgColor,
    IconData? icon,
    String? actionRoute,
    bool? isCompleted,
  }) {
    return FlightPlanItem(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      type: type ?? this.type,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      badgeText: badgeText ?? this.badgeText,
      badgeColor: badgeColor ?? this.badgeColor,
      badgeBgColor: badgeBgColor ?? this.badgeBgColor,
      icon: icon ?? this.icon,
      actionRoute: actionRoute ?? this.actionRoute,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
