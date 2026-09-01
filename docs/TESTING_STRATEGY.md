# Arete OS — Testing Strategy and Quality Assurance Specification

---

## 1. Quality Engineering Pyramid

Arete enforces rigorous automated testing to guarantee that the system remains lightning fast, mathematically accurate, and completely resilient to network disruptions.

```
                  / \
                 / E2E \       (Patrol / Web Integration: 10% of suite)
                /-------\
               / Widget  \     (Flutter Golden & Component Tests: 25% of suite)
              /-----------\
             / Riverpod    \   (State Notifier & Workflow Tests: 25% of suite)
            /---------------\
           / Domain & Math   \ (Pure Dart Unit Tests: 40% of suite - 95%+ coverage)
          +-------------------+
```

---

## 2. Test Suites and Coverage Targets

### 1. Domain & Mathematical Unit Tests (Target: 95%+ Coverage)
Tests pure Dart business logic in complete isolation from the Flutter framework or databases:
- **Weighted DAG Resolver**: Validates that milestone progress properly aggregates to parent goals, and that cyclic dependencies are caught and rejected.
- **Consistency Vector Formula**: Verifies rolling 30-day resilience calculations under various completion/missed-day patterns.
- **Velocity EMA Calculator**: Validates Exponential Moving Average smoothing and statistical confidence intervals for completion dates.
- **Next-Action Ranking Algorithm**: Verifies that tasks are correctly scored and ranked based on energy fit, priority, and deadline proximity.

### 2. Riverpod State & Workflow Tests
Tests `AsyncNotifier` state transitions and optimistic UI mutations using `ProviderContainer`:
- Verifies that toggling a task immediately updates local state.
- Verifies that repository exceptions trigger clean rollbacks without corrupting the active UI state.
- Verifies that command palette queries return correctly filtered and ranked results.

### 3. Widget and Interaction Tests
- **Golden Tests**: Pixel-perfect rendering validation across standard viewports (1440px desktop web, tablet, mobile).
- **Keyboard Shortcut Interception**: Tests that pressing `Cmd+K`, `Cmd+Enter`, `j`, `k`, and `Esc` trigger the correct navigation events and focus states.

### 4. End-to-End & Offline-First Resilience Tests (Patrol / Web Driver)
- **Offline Disconnection Test**: Simulates complete network loss, performs 10 task completions and 2 habit checks, restores network, and verifies that all mutations reconcile with PostgreSQL without data loss.
- **Full Onboarding Flow**: Tests identity selection, goal framing, automated AI deconstruction, and transition to dashboard.

### 5. Performance and Frame Budget Benchmarks
- Automated Flutter driver performance profiles running on WebAssembly.
- Asserts that UI and GPU thread frame times remain strictly under 16.6ms (60 FPS) and 8.33ms (120 FPS) during heavy animations and chart paints.

### 6. Supabase Row Level Security (RLS) Tests (pgTAP)
- Automated SQL test suites verifying that User A cannot read, update, or delete any record belonging to User B across all 15 database tables.
