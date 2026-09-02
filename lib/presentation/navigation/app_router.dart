import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../views/analytics/analytics_view.dart';
import '../views/cohort/cohort_war_room_view.dart';
import '../views/dashboard/mission_control_view.dart';
import '../views/dsa/dsa_roadmap_view.dart';
import '../views/focus/fullscreen_focus_view.dart';
import '../views/goals/goals_view.dart';
import '../views/habits/habits_view.dart';
import '../views/settings/settings_view.dart';
import '../views/shell_scaffold.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    // Fullscreen Overlay for Distraction-Free Focus Mode
    GoRoute(
      path: '/focus',
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: FullscreenFocusView(),
      ),
    ),
    // Main Shell Navigation with persistent Sidebar
    ShellRoute(
      builder: (context, state, child) {
        return ShellScaffold(
          currentRoute: state.matchedLocation,
          child: child,
        );
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MissionControlView(),
          ),
        ),
        GoRoute(
          path: '/dsa',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: DsaRoadmapView(),
          ),
        ),
        GoRoute(
          path: '/cohort',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CohortWarRoomView(),
          ),
        ),
        GoRoute(
          path: '/goals',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: GoalsView(),
          ),
        ),
        GoRoute(
          path: '/habits',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HabitsView(),
          ),
        ),
        GoRoute(
          path: '/analytics',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AnalyticsView(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsView(),
          ),
        ),
      ],
    ),
  ],
);
