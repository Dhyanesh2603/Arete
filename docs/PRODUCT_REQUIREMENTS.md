# Arete OS — Product Requirements Document (PRD)

---

## 1. Document Overview

- **Product Name**: Arete Personal Operating System
- **Document Version**: 1.0.0
- **Target Platform Rollout**: Phase 1: Web (Flutter Wasm / CanvasKit) | Phase 2: Android Native (Flutter Engine)
- **Primary Objective**: Transform high-level identity goals into structured, friction-free daily execution through a unified, keyboard-first, telemetry-driven operating system.
- **Tone and Aesthetic Standard**: Precision Minimalist, Atmospheric Tinted Dark Palette, Zero Emojis, 60-120 FPS hardware acceleration.

---

## 2. Platform Architecture and Deployment Strategy

### Phase 1: Web-First Architecture
1. **Desktop & Tablet Web Optimization**:
   - Zero-install web binary rendered via WebAssembly (Wasm) and CanvasKit.
   - Clean URL routing (`/app/dashboard`, `/app/goals/:id`, `/app/focus`, `/app/settings`).
   - Omnipresent global keyboard interception (`Cmd+K`, `Ctrl+K`, `Cmd+Enter`, `Esc`, `j`/`k` navigation).
   - Local-first offline capability using IndexedDB + Hive / Wasm SQLite with background sync queue.
2. **Mobile Web Responsive Adaptation**:
   - Touch gesture ergonomics with bottom command sheet and swipe gestures.

### Phase 2: Android Native Deployment
1. Native Android packaging with background synchronization service via WorkManager.
2. Timed local notifications and alarm manager integration for focus blocks and daily briefs.
3. System lock-screen telemetry widgets and home-screen quick action tiles.

---

## 3. Comprehensive Specifications for the 17 Core Modules

### Module 1: Mission Control Dashboard
Replaces generic home screens with an operational HUD answering "What do I execute next?".
- **Glanceable Telemetry Strip**: 3 concentric vector arcs displaying Focus Hours logged today, Habit Consistency percentage, and Milestone Velocity factor.
- **Hero Next-Action Card**: Displays the single highest-priority task computed by the system. Shows estimated time, cognitive demand tier (High, Medium, Low), linked milestone, and a one-click/shortcut trigger to launch Focus Mode.
- **Today's Flow Timeline**: Linear time-block bar showing scheduled deep work blocks, habit trigger windows, and upcoming deadlines.
- **Nightly AI Brief Card**: Collapsible drawer summarizing yesterday's trajectory and recommendations.

### Module 2: Goal Engine
Supports unlimited multi-year, annual, or quarterly goals anchored to an Identity.
- **Fields**: Identity Tag, Title, Objective Statement, Target Deadline, Priority Tier (P0 Urgent/Crucial, P1 Strategic, P2 Supporting), Category, Estimated Effort (hours), Success Criteria (quantitative metrics), Current Progress (weighted %), Completion Prediction Date (AI computed).
- **Auto-Decomposition**: One-click trigger passing the goal definition to the AI Coach Edge Function to generate draft Milestones, Projects, Habits, and Initial Tasks.

### Module 3: Milestone System
Divides each goal into sequential or parallel gates with mathematical weighting.
- **Fields**: Goal ID, Milestone Name, Mathematical Weight Multiplier (e.g. 1.0x to 5.0x), Deadline, Status (Pending, Active, Completed, Blocked), Dependencies (array of prerequisite Milestone IDs), Completion Percentage.
- **Progress Propagation**: Completing underlying projects and tasks dynamically updates the milestone percentage, which in turn updates the parent goal.

### Module 4: Project Management Engine
Finite scopes of work with architecture and resource context.
- **Views**: Timeline Gantt view, Linear-style Kanban board, and nested list view.
- **Context Capabilities**: Embedded technical markdown notes, architecture diagrams, file attachments, and external links.

### Module 5: Task Engine
Atomic units of daily execution.
- **Attributes**: Priority (P0, P1, P2), Context Tags, Difficulty / Cognitive Load (Deep 3x, Medium 2x, Shallow 1x), Estimated Time (minutes), Actual Time Logged, Pomodoro Sessions Count, Recurrence Rule (RRULE format), Dependency Array, Subtasks Array, Focus Score.
- **Execution**: Can be started directly in Focus Mode with time tracking recorded down to the second.

### Module 6: Habit Engine
Identity-reinforcing daily, weekly, monthly, and yearly recurring rituals.
- **Tracking Frequencies**: Daily (Morning/Evening), Weekly Target (e.g. 4x/week), Monthly milestones.
- **Visuals**: 365-day consistency heatmaps and habit integrity vectors instead of brittle streaks.
- **Friction-Free Logging**: One-tap completion via keyboard shortcut or HUD quick-check.

### Module 7: Calendar & Time-Blocking
Visual time-space allocation for focused deep work.
- **Views**: Daily Agenda (15-minute granularity), Weekly Matrix, Monthly Heatmap.
- **Features**: Drag-and-drop task scheduling, dedicated Deep Work reservation blocks, conflict detection, external calendar read-only synchronization (Google/Outlook iCal import).

### Module 8: Focus Mode (Distraction-Free Deep Work)
Fullscreen immersion environment for high-cognitive execution.
- **Visual State**: Pure obsidian viewport hiding all navigation rails and distracting badges.
- **Components**: Monospaced countdown timer (`JetBrains Mono`), current active task banner, session objective.
- **Acoustic Engine**: Low-latency ambient sound generator (Binaural 40Hz Gamma waves, Deep Brown Noise, Obsidian Rain, Terminal Hum) powered by `just_audio`.
- **Telemetry**: Live focus score calculation and session history logging upon completion.

### Module 9: Analytics and Life Telemetry
High-signal mathematical analytics answering "What is my velocity and what is blocking me?".
- **Metrics**: Goal Velocity vs Projected Cone, 365-Day Activity Heatmap, Cognitive Energy vs Hour-of-Day correlation, Time Distribution by Identity Category, Friction & Bottleneck Radar (identifying tasks postponed >2 times).

### Module 10: Knowledge Base
Personal markdown-based knowledge repository.
- **Features**: GitHub-flavored markdown editor, code block syntax highlighting, bi-directional linking (`[[wiki-links]]`), PDF/image attachment previews.
- **Semantic Search**: Vector embeddings via `pgvector` for instant retrieval based on conceptual meaning.

### Module 11: Resources & Learning Library
Structured tracking for external educational and technical inputs.
- **Types**: Courses, Technical Books, Research Papers, Video Lectures, Documentation.
- **Tracking**: Chapter/page progress percentage, key takeaways notes, linked project references.

### Module 12: AI Cognitive Coach
Nightly serverless pipeline (Supabase Edge Function + Claude 3.5 Sonnet / Gemini 2.0 Flash).
- **Nightly Retrospective**: Analyzes logged focus hours, completed vs missed tasks, energy levels, and milestone delta.
- **Automated Planning**: Generates the next day's proposed time-block schedule, flags emerging bottlenecks, and recommends recovery periods when overtraining/cognitive burnout is detected.

### Module 13: Friends & Peer Accountability (Optional, Zero Social Feed)
Focused peer accountability without social media toxicity.
- **Capabilities**: Study war-rooms, shared accountability groups, comparative weekly focus hour metrics, shared milestone challenges. Zero algorithmic feeds, zero likes, zero vanity metrics.

### Module 14: Challenges & Sprints
Time-boxed intensive execution sprints (e.g. "30-Day Compiler Engineering Sprint", "14-Day Fasting & Cardio Reset").
- **Structure**: Pre-configured sprint templates, daily required habits, sprint velocity leaderboard.

### Module 15: Achievements & Mastery Telemetry
Dignified, mathematical milestones celebrating real discipline.
- **Triggers**: 100 Hours of Deep Work logged in a single domain, 90-Day Habit Integrity > 95%, Zero-Postpone Milestone Delivery. Zero childish cartoon badges.

### Module 16: Universal Command Search (Raycast Engine)
Omnipresent keyboard command deck (`Cmd+K` / `Ctrl+K`).
- **Performance**: Sub-16ms response time.
- **Capabilities**: Global fuzzy search, direct entity creation (`> create task`), instant mode switching (`> start focus 90`), settings toggles, navigation shortcuts.

### Module 17: Settings and System Customization
User configuration, privacy, and backup.
- **Features**: Theme tint adjustments, font scaling, keyboard shortcut remapping, end-to-end encryption key management, local SQLite export, Supabase sync status.

---

## 4. Non-Functional Requirements (NFRs)

1. **Performance & Latency**:
   - Time to Interactive (TTI) on web under 1.2 seconds.
   - UI frame rate strictly maintained at 60 FPS (120 FPS on supported displays).
   - Local database reads executed in sub-5ms.
2. **Offline-First Resilience**:
   - Full read and write capabilities while completely offline.
   - Background mutation queue with deterministic conflict resolution (Last-Write-Wins with CRDT field merges) upon network reconnection.
3. **Accessibility and Keyboard Ergonomics**:
   - 100% of core flows executable without touching a mouse or trackpad.
   - Screen-reader friendly semantic labels and high contrast WCAG AAA compliance.
4. **Data Privacy & Security**:
   - Zero third-party ad tracking or behavioral telemetry selling.
   - End-to-end encryption for private notes and personal reflections.
