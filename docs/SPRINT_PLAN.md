# Arete OS — Agile Sprint Execution Plan

---

## 1. Sprint Architecture and Delivery Cadence

The engineering execution of Arete is structured into 2-week sprints, executing the **Web-First MVP (Sprints 1 through 10)** followed by the **Android Native Deployment (Sprints 11 and 12)**.

---

## 2. Sprint-by-Sprint Execution Matrix

### Sprint 1: Core Foundation, Design Tokens, and Routing (Weeks 1 - 2)
- **Primary Goals**: Establish Flutter Web Wasm project scaffold, design system tokens, and declarative GoRouter shell routing.
- **Key Deliverables**:
  - Flutter 3.x project setup with Riverpod 2.x and `riverpod_generator`.
  - Design token implementation: Atmospheric slate surfaces, border glows, and typography scale.
  - GoRouter setup with stateful shell navigators and path URL strategies (`/app/dashboard`, etc.).
  - Supabase Auth integration (email/password, OAuth, session management).
- **Definition of Done**: User can authenticate and navigate between blank shell views via keyboard shortcuts.

### Sprint 2: Local Persistence & Offline Sync Engine (Weeks 3 - 4)
- **Primary Goals**: Build offline-first data layer with IndexedDB/Hive and Supabase synchronization.
- **Key Deliverables**:
  - Abstract repository interfaces and local storage DAOs.
  - Offline mutation queue with background retry and online/offline listener.
  - PostgreSQL schema migration and RLS policies on Supabase.
- **Definition of Done**: Data operations execute locally in sub-5ms and sync to PostgreSQL when network is restored.

### Sprint 3: Goal Engine & Milestone DAG System (Weeks 5 - 6)
- **Primary Goals**: Implement Identity models, Strategic Goals, and Weighted Milestone DAG.
- **Key Deliverables**:
  - Goal and Milestone domain entities with mathematical weighting algorithms.
  - Directed Acyclic Graph resolver with cyclic dependency validation.
  - Interactive Goal view with milestone drag-and-drop and progress rollups.
- **Definition of Done**: Creating or updating subtasks correctly recalculates parent milestone and goal completion percentages.

### Sprint 4: Task Engine & Habit Consistency Engine (Weeks 7 - 8)
- **Primary Goals**: Build Task management and the 30-day Rolling Consistency Habit Engine.
- **Key Deliverables**:
  - Task creation, cognitive demand tiering (Deep 3x, Medium 2x, Shallow 1x), and priority sorting.
  - Habit engine with mathematical consistency vector formulas.
  - One-tap habit check micro-interactions on the HUD.
- **Definition of Done**: Habits record daily execution and accurately update 30-day rolling resilience scores.

### Sprint 5: Mission Control HUD & Distraction-Free Focus Mode (Weeks 9 - 10)
- **Primary Goals**: Build the primary dashboard HUD and fullscreen Focus environment.
- **Key Deliverables**:
  - Glanceable Telemetry HUD with 3 concentric vector progress rings.
  - Hero Next-Action recommendation card.
  - Fullscreen Focus Mode with monospaced digital timer and ambient audio player (`just_audio_web`).
- **Definition of Done**: Clicking "Engage Focus" opens the fullscreen view with audio playback and logs telemetry on completion.

### Sprint 6: Analytics Engine & Custom GPU Painters (Weeks 11 - 12)
- **Primary Goals**: Build data visualization dashboards and heatmaps.
- **Key Deliverables**:
  - 365-day habit consistency heatmap rendered with GPU `CustomPainter`.
  - Velocity vs Target burn-up curve with statistical prediction cone.
  - Friction Radar identifying tasks postponed >2 times.
- **Definition of Done**: Analytics views render smoothly at 60+ FPS with zero UI thread stutter.

### Sprint 7: Knowledge Base & Semantic Vector Search (Weeks 13 - 14)
- **Primary Goals**: Implement Markdown note editor and pgvector semantic search.
- **Key Deliverables**:
  - Distraction-free markdown editor with code syntax highlighting and `[[wiki-links]]`.
  - Supabase Edge Function to generate text embeddings on note save.
  - HNSW vector index search query pipeline.
- **Definition of Done**: Searching by natural language concepts returns relevant notes in sub-50ms.

### Sprint 8: AI Cognitive Coach & Nightly Retrospective (Weeks 15 - 16)
- **Primary Goals**: Build serverless AI analysis and dynamic scheduling pipeline.
- **Key Deliverables**:
  - Supabase Edge Function integrating Claude 3.5 Sonnet / Gemini 2.0 Flash.
  - Nightly retrospective synthesis prompt and structured JSON response parser.
  - Automated tomorrow schedule recommendation dialog.
- **Definition of Done**: Nightly review produces actionable trajectory feedback and schedule adjustments without sycophancy.

### Sprint 9: Universal Command Palette (`Cmd+K`) (Weeks 17 - 18)
- **Primary Goals**: Build global keyboard-first command deck.
- **Key Deliverables**:
  - Global keyboard listener intercepting `Cmd+K` / `Ctrl+K`.
  - In-memory Trie and fuzzy search algorithm for sub-16ms query execution.
  - Command action dispatchers (`> create task`, `> focus`, `> goto`).
- **Definition of Done**: User can execute 100% of core app operations using keyboard shortcuts alone.

### Sprint 10: Wasm Optimization, Testing & Web Public Beta (Weeks 19 - 20)
- **Primary Goals**: Performance tuning, end-to-end testing, and Phase 1 Web launch.
- **Key Deliverables**:
  - Flutter Wasm compilation optimization, asset pre-caching, and bundle tree-shaking.
  - End-to-end user journey tests and security audit.
  - Public Web Beta release.
- **Definition of Done**: Web application achieves sub-1.2s cold load and 0 critical security/sync vulnerabilities.

---

### Sprint 11: Android Native Adaptation & Background Sync (Weeks 21 - 22)
- **Primary Goals**: Port application to native Android and implement OS-level services.
- **Key Deliverables**:
  - Native Android Flutter build with ARM64 optimizations.
  - Android WorkManager background sync service.
  - Precision local notifications and alarms for scheduled focus blocks.
- **Definition of Done**: Background sync operates reliably without excessive battery drain.

### Sprint 12: Android Widgets, Biometrics & Play Store Release (Weeks 23 - 24)
- **Primary Goals**: Android home/lock screen widgets, biometric auth, and store deployment.
- **Key Deliverables**:
  - Home screen glanceable widgets (Next-Action tile, Habit Matrix).
  - Biometric fingerprint/face authentication.
  - Google Play Store production release.
- **Definition of Done**: Android app published to Google Play with 99.9% crash-free session rate.
