# Arete

### Unified Productivity Platform for Engineering & Deep Work

Arete is an integrated cognitive productivity and technical mastery platform designed for software engineers, founders, and technical professionals. It bridges the gap between long-term career milestones and daily, zero-friction execution.

Built on Flutter Web (CanvasKit / WebAssembly), Riverpod 2.x, and Supabase.

---

## Executive Overview

Most productivity applications isolate tasks, calendars, and technical curricula into disconnected silos, forcing developers to manage cognitive overhead and decision fatigue. 

Arete unifies technical study (Striver A2Z DSA Tracker with Spaced Repetition), deep work immersion (Distraction-Free Focus sessions), task management (Weighted Priority Matrix), and automated daily planning into a cohesive execution environment.

```
[ Strategic Goals ] -> [ Weighted Milestones ] -> [ Daily Flight Plan ] -> [ Deep Work Focus ] -> [ Telemetry & Review ]
```

---

## Core Platform Capabilities

### 1. Adaptive Daily Execution Engine ("Flight Plan")
- **Automated Sequence Synthesis**: Dynamically links overdue SM-2 spaced repetition DSA problems, top-priority tasks, and scheduled calendar blocks into a single ordered daily queue.
- **Zero-Decision Execution**: One-click flight plan execution loads the next target item directly into the Focus immersion timer without context switching.
- **Real-Time Progress Metrics**: Visualizes target time allocation, sequential step progress, and completion states.

### 2. Striver A2Z DSA Mastery & Spaced Repetition
- **Canonical 18-Step Curriculum**: Complete coverage from foundational data structures to advanced graphs, dynamic programming, and tries.
- **SuperMemo-2 (SM-2) Algorithmic Retention**: Calculates optimal review intervals based on difficulty and recall accuracy to prevent memory decay.
- **Socratic Hint Engine**: Multi-tiered hints (Structural, Recurrence, and Edge Cases) that guide problem-solving without revealing full solutions prematurely.
- **Mock Technical Interview Simulations**: Timed live problem environments testing algorithmic communication and time/space complexity analysis.

### 3. Distraction-Free Deep Work Immersion
- **Hardware-Accelerated Focus Shell**: Clean, high-contrast fullscreen interface designed to eliminate visual distractions.
- **Keyboard-Driven Session Controls**: Complete keyboard binding support (`Space` to toggle pause/resume, `Cmd+D`/`Ctrl+D` to complete, `ESC` to exit).
- **Acoustic Presets**: Integrated soundscape profiles including 40Hz Gamma waves, Deep Brown Noise, and Terminal Hum.

### 4. Unified Task Matrix
- **Tri-Tier Priority Queue**: Categorized into High (Rose), Medium (Amber), and Low (Mint) tiers.
- **Natural Language Parsing**: Instant extraction of priority tags (`!high`, `!med`, `!low`), duration estimates (`~45m`, `~2h`), and project tags (`#dsa`, `#system`) from single-line text inputs.
- **In-Place Priority Management**: Upfront priority selector chips on creation and inline dropdown selectors on task cards across dashboard and matrix views.

### 5. Strategic Goals & Weighted Milestones
- **Identity-Driven Milestones**: Decompose strategic multi-month goals into actionable, weighted milestone deliverables.
- **Progress Computation**: Dynamic progress calculation reflecting completed milestones and habit consistency.

### 6. Life Telemetry & Velocity Analytics
- **Consistency Vectors**: 30-day trailing habit consistency tracking.
- **Velocity Metrics**: Quantitative measurement of daily focus hours, solve counts, and milestone completion velocity.
- **Clean Slate Architecture**: Zero hardcoded mock stats. The platform initializes cleanly at zero for authentic personal progression.

### 7. Global Command Deck (`Cmd+K`)
- **Instant Keyboard Navigation**: Access any roadmap step, problem, task, or view from anywhere in the platform via `Cmd+K` or `Ctrl+K`.

---

## Design System & Ergonomics

Arete features a balanced, eye-friendly dark aesthetic engineered for long engineering sessions:

- **Canvas**: Pure Deep Neutral Black (`#09090B`) delivering high OLED contrast without glare.
- **Surfaces**: Neutral Dark Charcoal (`#131316` and `#1B1B20`) eliminating monochromatic eye fatigue.
- **Hairline Dividers**: Subtle 1px neutral borders (`#222228`) for crisp component definition.
- **Typography**: Clean Off-White (`#FAFAFA`) primary headings and Cool Silver Gray (`#A1A1AA`) body text.
- **Accent Philosophy**: Electric Violet (`#8B5CF6`) strictly reserved for primary actions, active indicators, and progress highlights.
- **Semantic Domain Colors**: Emerald Green (`#10B981`) for solved problems, Golden Amber (`#F59E0B`) for streaks and focus, Crimson Coral (`#EF4444`) for high-priority items, and Indigo (`#6366F1`) for strategic milestones.

---

## Technical Stack

| Layer | Technologies |
| :--- | :--- |
| **Frontend Framework** | Flutter Web 3.x (CanvasKit / WebAssembly compilation) |
| **State Management** | Riverpod 2.x (`StateNotifier`, `ProviderScope`, unidirectional flow) |
| **Routing** | GoRouter 14+ with declarative path strategy |
| **Typography** | Google Fonts (Inter, JetBrains Mono) |
| **Persistence & Backend** | Supabase (PostgreSQL 16, Row Level Security) + Local Storage |
| **Build & Tooling** | Dart 3.x, Flutter Tooling |

---

## Directory Layout

```
lib/
├── core/
│   ├── constants/       # Canonical Striver A2Z curriculum data and topics
│   ├── services/        # Supabase client and persistence abstractions
│   ├── theme/           # AppColors, AppTypography, AppTheme definitions
│   └── utils/           # Natural language task parser and utilities
├── domain/
│   └── models/          # Task, DsaProblem, FlightPlanItem, Habit, CalendarEvent
└── presentation/
    ├── providers/       # Riverpod state notifiers (DSA, Tasks, Focus, FlightPlan)
    ├── views/           # MissionControl, DsaRoadmap, Tasks, Focus, Analytics, Auth
    └── widgets/         # DailyFlightPlanCard, AppSidebar, CommandPalette, GlassContainer
```

---

## Getting Started

### Prerequisites

- Flutter SDK version 3.24.x or later
- Dart SDK version 3.5.x or later
- A modern web browser supporting CanvasKit / WebAssembly (Chrome, Edge, Firefox, Brave)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Dhyanesh2603/Arete.git
   cd Arete
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the development server:
   ```bash
   flutter run -d chrome
   ```

### Production Build

To compile an optimized production web bundle:

```bash
flutter build web --release
```

The output bundle will be generated in `build/web/`. You can serve it locally using any static HTTP server:

```bash
python -m http.server 8080 --directory build/web
```

---

## Verification & Testing

The project maintains a continuous quality verification suite:

```bash
# Run unit and widget tests
flutter test

# Run static analysis
flutter analyze
```

---

## License

This project is open source and available under the [MIT License](LICENSE).
