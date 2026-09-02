import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../views/analytics/analytics_view.dart';
import '../views/auth/auth_view.dart';
import '../views/calendar/calendar_view.dart';
import '../views/coach/ai_coach_view.dart';
import '../views/cohort/cohort_war_room_view.dart';
import '../views/dashboard/mission_control_view.dart';
import '../views/dsa/dsa_roadmap_view.dart';
import '../views/dsa/mock_interview_view.dart';
import '../views/focus/fullscreen_focus_view.dart';
import '../views/goals/goals_view.dart';
import '../views/habits/habits_view.dart';
import '../views/knowledge/knowledge_view.dart';
import '../views/landing/landing_view.dart';
import '../views/projects/projects_view.dart';
import '../views/resources/resources_view.dart';
import '../views/settings/settings_view.dart';
import '../views/shell_scaffold.dart';
import '../views/tasks/tasks_view.dart';

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final loc = state.matchedLocation;
    final isAuthRoute = loc == '/auth';
    final isLandingRoute = loc == '/';
    final isAuthenticated = _ref.read(authProvider).isAuthenticated;

    // Strict Auth Protection:
    // If not authenticated, the user can ONLY view the landing page or the auth page.
    // Any direct attempt to navigate to any other page redirects directly to /auth.
    if (!isAuthenticated) {
      if (!isLandingRoute && !isAuthRoute) {
        return '/auth';
      }
      return null;
    }

    // If authenticated and visiting landing or auth, redirect straight into Mission Control.
    if (isLandingRoute || isAuthRoute) {
      return '/dashboard';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

List<RouteBase> _buildRoutes() {
  return [
    // Landing Page (Public)
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const NoTransitionPage(
        child: LandingView(),
      ),
    ),
    // Auth Page (Login / Sign Up)
    GoRoute(
      path: '/auth',
      pageBuilder: (context, state) {
        final mode = state.uri.queryParameters['mode'];
        final isSignUp = mode == 'signup';
        return NoTransitionPage(
          child: AuthView(initialIsSignUp: isSignUp),
        );
      },
    ),
    // Fullscreen Overlay for Distraction-Free Focus Mode (Protected)
    GoRoute(
      path: '/focus',
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: FullscreenFocusView(),
      ),
    ),
    // Fullscreen Overlay for 45-Minute Timed Mock Interview (Protected)
    GoRoute(
      path: '/mock-interview',
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: MockInterviewView(),
      ),
    ),
    // Main Shell Navigation with slideable Drawer Sidebar (Protected)
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
          path: '/projects',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ProjectsView(),
          ),
        ),
        GoRoute(
          path: '/tasks',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TasksView(),
          ),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: CalendarView(),
          ),
        ),
        GoRoute(
          path: '/habits',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HabitsView(),
          ),
        ),
        GoRoute(
          path: '/knowledge',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: KnowledgeView(),
          ),
        ),
        GoRoute(
          path: '/resources',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: ResourcesView(),
          ),
        ),
        GoRoute(
          path: '/coach',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: AICoachView(),
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
  ];
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: _buildRoutes(),
  );
});

// Fallback router for standalone testing
final appRouter = GoRouter(
  initialLocation: '/',
  routes: _buildRoutes(),
);
