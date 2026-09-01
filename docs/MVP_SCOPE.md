# Arete OS — MVP Scope and Feature Boundary Specification

---

## 1. Scope Strategy and Release Philosophy

To guarantee world-class execution quality, speed, and aesthetic refinement, the **Web MVP (v1.0)** focuses ruthlessly on the core **Identity-to-Execution Pipeline** on desktop and tablet web. All secondary social, wearable, and experimental features are strictly deferred to V2 and V3 releases.

---

## 2. In Scope: The Web MVP (v1.0 Release Boundary)

### 1. Identity & Goal Hierarchy Engine
- Identity declaration (Title, Vision, Color Token).
- Strategic Goals (Title, Target Deadline, Priority P0/P1/P2, Weighted Progress).
- Milestone Directed Acyclic Graph (DAG) with dependency validation and weight multipliers.

### 2. Project & Task Execution Engine
- Project organization with markdown architecture context.
- Task management: Cognitive tiers (Deep 3x, Medium 2x, Shallow 1x), estimated minutes, priority, subtasks.
- Automatic "Next Action" calculation based on energy fit and priority.

### 3. Habit & Consistency Engine
- Daily morning/evening and weekly target habit tracking.
- Mathematical 30-Day Rolling Consistency Vector (non-punitive streak resilience).
- One-click completion triggers on the dashboard HUD.

### 4. Mission Control Dashboard
- Concentric vector telemetry arcs (Focus Hours, Habit Consistency, Milestone Velocity).
- Dominant Hero Next-Action Card with 1-click Focus launch.
- Horizontal daily time-block stream with live current-time indicator.

### 5. Fullscreen Distraction-Free Focus Mode
- Monospaced digital countdown timer (`JetBrains Mono`).
- Ambient acoustic soundscapes (Binaural 40Hz, Brown Noise, Obsidian Rain, Terminal Hum) powered by `just_audio_web`.
- Session telemetry logging (duration, focus quality score, tasks completed).

### 6. Universal Command Palette (`Cmd+K`)
- Sub-16ms global fuzzy search across all entities.
- Direct command dispatch (`> create task`, `> focus [mins]`, `> goto [module]`).
- 100% keyboard navigable.

### 7. Core Analytics & Life Telemetry
- 365-Day Activity & Consistency Heatmap (GPU CustomPainter).
- Velocity vs Target Burn-Up Curve with projection cone.
- Friction Radar highlighting tasks postponed >2 times.

### 8. AI Cognitive Coach & Nightly Retrospective (Supabase Edge Function)
- Automated nightly review analyzing focus hours, completed vs missed tasks, and energy.
- Automated tomorrow schedule recommendation dialog.
- One-click AI Goal Deconstruction into draft milestones and tasks.

### 9. Distraction-Free Knowledge Base
- GitHub-flavored markdown editor with code block syntax highlighting and `[[wiki-links]]`.
- Semantic vector search via `pgvector`.

### 10. Platform & Infrastructure (Web-First)
- Compiled via Flutter 3.x with WebAssembly (Wasm) and CanvasKit.
- Offline-first local persistence (IndexedDB + Hive/SQLite Wasm) with Supabase cloud sync.

---

## 3. Explicitly Deferred to V2 (Post-Web Launch)

- **Native Android App**: ARM64 native APK/AAB build, WorkManager background sync, Android home/lock screen widgets.
- **Biometric Wearables Synchronization**: Google Health Connect / Apple Health integration for sleep and HRV correlation.
- **Peer Accountability War-Rooms**: Realtime WebRTC/WebSocket multi-user study sessions.
- **Collaborative Group Challenges & Leaderboards**.

---

## 4. Explicitly Deferred to V3 (Future Horizon)

- **On-Device Local LLM Engine**: Running quantized small language models locally in-browser via WebGPU.
- **Multi-Modal Voice Command Interface**: Ambient voice-driven task capture and daily briefs.
- **Autonomous Trajectory Simulation Engine**: Multi-year Monte Carlo milestone delivery simulations.
