# Arete OS — Navigation and Routing Architecture (GoRouter)

---

## 1. Routing Architecture Overview

Arete utilizes **GoRouter 14+** configured with clean browser path URLs (`usePathUrlStrategy()`), preserving state across multi-tab workflows via `StatefulShellRoute.indexedStack`. This architecture enables instant web navigation, clean browser history back/forward traversal, and deep linking.

---

## 2. Declarative Route Tree

```dart
final goRouter = GoRouter(
  initialLocation: '/app/dashboard',
  redirect: (context, state) {
    final authState = ref.read(authNotifierProvider);
    final isLoggingIn = state.matchedLocation.startsWith('/auth');
    if (!authState.isAuthenticated && !isLoggingIn) return '/auth';
    if (authState.isAuthenticated && isLoggingIn) return '/app/dashboard';
    return null;
  },
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Fullscreen Overlay for Distraction-Free Focus Mode
    GoRoute(
      path: '/app/focus',
      pageBuilder: (context, state) => const CustomTransitionPage(
        child: FullscreenFocusScreen(),
        transitionsBuilder: AppTransitions.fadeCrossScale,
      ),
    ),
    // Main Application Stateful Shell (Sidebar + Command Deck)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => AppShellLayout(
        navigationShell: navigationShell,
      ),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/app/dashboard', builder: (c, s) => const DashboardView()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/app/goals',
            builder: (c, s) => const GoalsView(),
            routes: [
              GoRoute(path: ':goalId', builder: (c, s) => GoalDetailView(id: s.pathParameters['goalId']!)),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/app/projects',
            builder: (c, s) => const ProjectsView(),
            routes: [
              GoRoute(path: ':projectId', builder: (c, s) => ProjectDetailView(id: s.pathParameters['projectId']!)),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/app/tasks', builder: (c, s) => const TasksView()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/app/habits', builder: (c, s) => const HabitsView()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/app/calendar', builder: (c, s) => const CalendarView()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/app/analytics', builder: (c, s) => const AnalyticsView()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/app/knowledge',
            builder: (c, s) => const KnowledgeView(),
            routes: [
              GoRoute(path: ':noteId', builder: (c, s) => NoteEditorView(id: s.pathParameters['noteId']!)),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/app/resources', builder: (c, s) => const ResourcesView()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/app/coach', builder: (c, s) => const AICoachView()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/app/friends', builder: (c, s) => const FriendsWarRoomsView()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/app/settings', builder: (c, s) => const SettingsView()),
        ]),
      ],
    ),
  ],
);
```

---

## 3. Global Keyboard Navigation and Shortcuts

| Key Binding (macOS / Windows) | Action / Target Route |
|---|---|
| `Cmd + K` / `Ctrl + K` | Toggle Universal Command Palette Overlay |
| `Cmd + Enter` / `Ctrl + Enter` | Engage Focus Session for current Next-Action |
| `Cmd + 1` ... `Cmd + 9` | Switch between main modules (Dashboard, Goals, Projects, etc.) |
| `Cmd + B` / `Ctrl + B` | Toggle Right Telemetry Sidebar visibility |
| `Cmd + \` / `Ctrl + \` | Toggle Left Command Rail (Collapse / Expand) |
| `Esc` | Close Command Palette, dismiss modals, or exit Focus Mode |
| `j` / `k` | Move cursor down / up across task and milestone lists |
| `x` or `Space` | Toggle completed state of highlighted task or habit |
