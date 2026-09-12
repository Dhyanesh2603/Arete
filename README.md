# Arete

### Modular Notion-Grade Productivity Workspace & Engineering Platform

Arete is a modular, high-performance productivity workspace and technical execution platform designed for software engineers, builders, and technical professionals. It integrates modular document editing, task matrices, deep work acoustics, and technical curriculum mastery into a singular, cohesive cockpit.

Built on Flutter Web (CanvasKit / WebAssembly), Riverpod 2.x, and Supabase.

---

## Executive Overview

Most productivity suites isolate notes, roadmaps, task queues, and technical curricula into disconnected silos, forcing developers to manage constant context switching and cognitive fatigue.

Arete unifies Notion-grade modular documents, Striver A2Z DSA curriculum with spaced repetition, hardware-accelerated deep work focus sessions, weighted milestone roadmaps, and an adaptive daily flight plan into a frictionless execution environment.

```
[ Workspace Documents ] <-> [ Priority Matrix ] <-> [ Daily Flight Plan ] <-> [ Deep Work Focus ] <-> [ Striver DSA Track ]
```

---

## Core Platform Capabilities

### 1. Notion-Style Modular Document Studio
- **Block-Based Document Canvas**: Flexible document blocks including Paragraphs, Heading 1, Heading 2, Interactive Checklists, Syntax Code Containers, Callout Notes, Accordion Toggles, and Dividers.
- **Slash Command Menu (`/`)**: Instant block insertion and formatting directly from the keyboard without breaking typing flow.
- **Document Customization**: Custom cover gradients (Obsidian, Cyan Indigo, Emerald Teal, Amber Rose, Violet Dusk) and subpixel vector iconography.
- **Hierarchical Document Trees**: Multi-tier nested child subpages with instant navigation and breadcrumbs.
- **Workspace Navigation**: Dedicated document tree in the sidebar with quick page creation, favorites, and pin toggles.

### 2. Adaptive Daily Execution Engine ("Flight Plan")
- **Automated Sequence Synthesis**: Dynamically links overdue SM-2 spaced repetition DSA problems, top-priority tasks, and scheduled calendar blocks into a single ordered daily queue.
- **Zero-Decision Execution**: One-click flight plan execution loads the next target item directly into the Focus immersion timer without friction.
- **Real-Time Progress Radar**: Visualizes target time allocation, sequential step progress, and completion states.

### 3. Integrated Striver A2Z DSA Mastery Track
- **Canonical 18-Step Curriculum**: Complete curriculum coverage from foundational data structures to advanced graphs, dynamic programming, and tries.
- **SuperMemo-2 (SM-2) Algorithmic Retention**: Calculates optimal review intervals based on difficulty and recall accuracy to prevent memory decay.
- **Socratic Hint Engine**: Multi-tiered hints (Structural, Recurrence, and Edge Cases) that guide problem-solving without revealing full solutions prematurely.
- **Mock Technical Interview Simulations**: Timed live problem environments testing algorithmic communication and time/space complexity analysis.

### 4. Distraction-Free Deep Work Immersion
- **Hardware-Accelerated Focus Shell**: Clean, high-contrast fullscreen interface designed to eliminate visual distractions.
- **Keyboard-Driven Session Controls**: Complete keyboard binding support (`Space` to toggle pause/resume, `Cmd+D`/`Ctrl+D` to complete, `ESC` to exit).
- **Procedural Acoustic Synthesizer**: Web Audio soundscapes including 40Hz Gamma binaural waves, Deep Brown Noise, Rain Wash, and Terminal Hum.

### 5. Unified Priority Task Matrix
- **Tri-Tier Priority Queue**: Categorized into High (Neon Rose), Medium (Golden Amber), and Low (Emerald Mint) tiers.
- **Natural Language Parsing**: Instant extraction of priority tags (`!high`, `!med`, `!low`), duration estimates (`~45m`, `~2h`), and project tags (`#dsa`, `#system`) from single-line text inputs.
- **Task Modals & Subtasks**: Subtask checklists, due date pickers, calendar blocking, and inline priority management.

### 6. Strategic Goals & Projects Kanban
- **Identity-Driven Milestones**: Decompose strategic multi-month goals into actionable, weighted milestone deliverables.
- **Linear-Style Kanban Boards**: Drag-and-drop workflow columns with architecture specs.
- **Life Telemetry**: Quantitative measurement of daily focus hours, solve counts, and milestone completion velocity.
- **Clean Slate Architecture**: Zero hardcoded mock stats. The platform initializes cleanly at zero for authentic personal progression.

### 7. Global Command Deck (`Cmd+K`)
- **Instant Keyboard Navigation**: Search documents, navigate roadmap steps, trigger deep work focus, or create new pages instantly via `Cmd+K` or `Ctrl+K`.

---

## Design System & Ergonomics

Arete features a bespoke **Obsidian Carbon & Titanium Ice** aesthetic engineered for ultra-smooth 60/120fps interactions and zero eye fatigue:

- **Canvas**: Deep Obsidian Void (`#08090C`) delivering true dark contrast without visual glare.
- **Sidebar**: Carbon Deep (`#0D0E12`) with categorized WORKSPACE, DOCUMENTS, and ENGINES tiers.
- **Surfaces**: Multi-Tier Graphite Slate (`#12141A` and `#181B23`) with subpixel titanium hairline borders (`#1E222D`).
- **Typography**: Titanium White (`#F8FAFC`) primary headings and Cool Slate (`#94A3B8`) readable body text.
- **Accent Philosophy**: Electric Ice Cyan (`#38BDF8`) for primary highlights, Precision Indigo (`#6366F1`) for document structures, Emerald Green (`#10B981`) for completed states, and Golden Amber (`#F59E0B`) for focus immersion.

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
│   ├── services/        # Supabase client and per-user persistence abstractions
│   ├── theme/           # Obsidian Carbon AppColors, AppTypography, AppTheme
│   └── utils/           # Natural language task parser and utilities
├── domain/
│   └── models/          # WorkspacePage, PageBlock, Task, DsaProblem, Habit, Project
└── presentation/
    ├── navigation/      # GoRouter declarative app routes (/pages/:id, /dashboard, etc.)
    ├── providers/       # Riverpod state notifiers (Workspace, DSA, Tasks, Focus, FlightPlan)
    ├── views/           # WorkspacePageView, MissionControlView, TasksView, FocusView
    └── widgets/         # AppSidebar, DailyFlightPlanCard, CommandPaletteModal, GlassContainer
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
cd build/web
python -m http.server 8080
```

---

## Automated Test Suite

Arete includes a comprehensive automated test suite verifying auth state, task matrix operations, SM-2 retention calculations, weighted milestone goals, and Notion-style workspace page trees:

```bash
flutter test
```
