# Arete OS — Component Library Specification

---

## 1. Component Architecture Overview

All Flutter components in Arete are built as atomic, high-performance, stateless or Riverpod-connected widgets. To guarantee 60-120 FPS buttery smooth responsiveness, complex visual elements are isolated inside `RepaintBoundary` wrappers and avoid deep widget tree rebuilds.

---

## 2. Core UI Component Catalog

### Component 1: `CommandPaletteOverlay`
- **Purpose**: Global fuzzy command and search palette triggered via `Cmd+K` / `Ctrl+K`.
- **Visual Spec**: Centered floating modal (680px width, max 480px height), `surface-glass` background with `blur(16px)` backdrop filter, 1px active border (`#3E4766`), zero outer elevation shadow.
- **Sub-elements**: Search text field (with leading search icon and trailing `Esc` badge), categorized search results list (Recent, Goals, Tasks, Actions), footer keyboard guide (`↑↓ Navigate`, `↵ Select`, `Tab Actions`).
- **Performance**: Isolates list filtering in an isolate/Web Worker; renders results in a `ListView.builder` with fixed extent items.

### Component 2: `GlanceableTelemetryHUD`
- **Purpose**: Top dashboard telemetry strip communicating day momentum in under 2 seconds.
- **Visual Spec**: 3 concentric circular vector arcs:
  - Outer Ring: Focus Hours logged (Amber Gold `#FBBF24`).
  - Middle Ring: Habit Consistency percentage (Phosphor Mint `#34D399`).
  - Inner Ring: Milestone Velocity factor (Cyber Cyan `#38BDF8`).
- **Interaction**: Hovering over any ring highlights the exact numerical score with an animated tooltip.

### Component 3: `HeroNextActionCard`
- **Purpose**: The central focal point of the Mission Control Dashboard answering "What do I do next?".
- **Visual Spec**: Elevated `surface-tier-1` card with a 1px `#38BDF8` border glow.
- **Content**:
  - Top: Identity tag and linked milestone badge.
  - Middle: Task title (20px bold `Geist Display`) and estimated duration badge (`45m`).
  - Cognitive tier badge (`Deep Work 3x`).
  - Primary CTA: `[ ENGAGE FOCUS SESSION (Cmd+Enter) ]` rendered in Cyber Cyan fill.

### Component 4: `FocusTimerWidget`
- **Purpose**: Fullscreen countdown timer for deep work sessions.
- **Visual Spec**: Monospaced 56px `JetBrains Mono` digital timer (`45:00.00`).
- **Features**: Smooth linear progress track circling the viewport border; bottom acoustic controller showing the active soundscape waveform.

### Component 5: `MilestoneDAGNode`
- **Purpose**: Interactive node representing a milestone within a goal's dependency graph.
- **Visual Spec**: Rounded rectangle with title, weight indicator (`Weight: 2.5x`), status pill (`Active`, `Blocked`, `Completed`), and a hairline progress bar.
- **Interactivity**: Dragging nodes connects dependency lines; clicking expands child projects.

### Component 6: `HabitConsistencyMatrix`
- **Purpose**: 365-day grid heatmap displaying habit execution frequency over the year.
- **Visual Spec**: 52 columns x 7 rows of 10px rounded squares.
- **Color Gradients**: Obsidian base (`#121520`), 25% Mint (`#064E3B`), 50% Mint (`#047857`), 75% Mint (`#059669`), 100% Mint (`#34D399`).
- **Rendering**: Implemented as a single `CustomPainter` to draw all 365 cells in a single GPU draw call.

### Component 7: `TimelineFlowBar`
- **Purpose**: Horizontal time-block stream showing the day's scheduled deep work blocks.
- **Visual Spec**: 24-hour horizontal bar with a pulsing vertical cyan line indicating the current minute. Blocks are color-coded by cognitive load.

### Component 8: `FrictionRadarCard`
- **Purpose**: Diagnostic card highlighting stalled tasks or dependency bottlenecks.
- **Visual Spec**: `surface-tier-2` container with subtle crimson accent border (`#FB7185`).
- **Content**: Highlights tasks postponed >2 times and provides an instant one-click AI Deconstruction action.

### Component 9: `ShortcutBadge`
- **Purpose**: Reusable monospaced key indicator for keyboard shortcut hints.
- **Visual Spec**: Rounded 4px badge with `#181C2B` background, `#2A3047` border, and `#8290A7` text (e.g. `⌘K`, `↵`, `ESC`).

### Component 10: `MarkdownContextEditor`
- **Purpose**: Distraction-free markdown editor for project architectures and knowledge notes.
- **Features**: Live syntax highlighting, support for mathematical formulas (`$$`), code blocks with copy action, and automatic `[[wiki-link]]` autocompletion.
