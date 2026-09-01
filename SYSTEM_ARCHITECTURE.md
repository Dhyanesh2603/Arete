# Arete OS — System Architecture and Technical Blueprints

---

## 1. High-Level Architectural Paradigm

Arete is architected according to **Clean Architecture** principles with a strict unidirectional data flow. The system is designed to run seamlessly on the web using **Flutter Web with WebAssembly (Wasm) and CanvasKit**, maintaining identical business logic when compiled to native Android.

```
+-------------------------------------------------------------------------+
|                        PRESENTATION LAYER                               |
|   Flutter Widgets | Custom Painters | Rive Runtimes | Keyboard Dispatch |
+------------------------------------+------------------------------------+
                                     | (Watches State / Dispatches Intents)
                                     v
+-------------------------------------------------------------------------+
|                    APPLICATION / CONTROLLER LAYER                       |
|   Riverpod AsyncNotifiers | State Machines | Focus Audio Orchestrator   |
+------------------------------------+------------------------------------+
                                     | (Invokes Domain Logic)
                                     v
+-------------------------------------------------------------------------+
|                          DOMAIN LAYER                                   |
|   Pure Dart Entities | Mathematical Models | DAG Resolvers | Rules      |
+------------------------------------+------------------------------------+
                                     | (Fetches / Persists Data)
                                     v
+-------------------------------------------------------------------------+
|                           DATA LAYER                                    |
|   Repositories | Local Storage (Hive/IndexedDB) | Supabase Remote API   |
|   Offline Mutation Sync Queue | Vector Embedding Client                 |
+-------------------------------------------------------------------------+
```

---

## 2. Layer Separation & Responsibilities

### 1. Presentation Layer
- **Components**: Declarative Flutter widgets, high-performance `CustomPainter` widgets for trajectory curves and heatmaps, Rive state machine controllers for dynamic rings.
- **Rules**: Absolutely zero business logic or direct database access. Widgets only consume typed states from Riverpod providers and dispatch user actions via controller methods.

### 2. Application Layer
- **Components**: Riverpod `AsyncNotifier<T>` controllers (e.g. `GoalListNotifier`, `ActiveFocusSessionNotifier`, `CommandPaletteNotifier`).
- **Rules**: Orchestrates workflows, handles loading/error states, coordinates optimistic UI updates, and interacts with domain services.

### 3. Domain Layer
- **Components**: Immutable Dart data classes (built with `freezed`), domain validation rules, DAG milestone traversal algorithms, Exponential Moving Average velocity calculators, and consistency vector formulas.
- **Rules**: Pure Dart with zero Flutter or external framework dependencies. 100% unit-testable in isolation.

### 4. Data Layer
- **Components**: Repository implementations (`GoalRepositoryImpl`, `TaskRepositoryImpl`), Local Data Source (IndexedDB / Hive via Wasm), Remote Data Source (Supabase GoTrue, PostgREST, Realtime, pgvector).
- **Rules**: Implements the Offline-First strategy, abstracting data origins from the rest of the application.

---

## 3. Offline-First Synchronization Engine

```
[ User Action (e.g. Complete Task) ]
                 |
                 v
[ Presentation Layer: Immediate Optimistic UI Update ]
                 |
                 v
[ Local Repository: Append Mutation to Local Hive/IndexedDB ]
                 |
                 +--------------------------------+
                 | (If Online)                    | (If Offline)
                 v                                v
[ Remote Push: Supabase REST/RPC ]       [ Enqueue in Offline Mutation Queue ]
                 |                                |
                 | (Success)                      | (On Reconnect)
                 v                                v
[ Mark Mutation Reconciled ]             [ Drain Queue & Sync LWW/CRDT ]
```

### Conflict Resolution Strategy
- **Last-Write-Wins (LWW) with Field-Level Merging**: Each record contains an ISO-8601 `updated_at` timestamp. When syncing, non-conflicting field edits are merged automatically; conflicting fields resolve to the highest timestamp.
- **Immutable Log Appends**: High-volume telemetry entities (such as `focus_sessions` and `habit_logs`) are append-only, preventing synchronization collision.

---

## 4. WebAssembly (WASM) & Flutter Web Optimization

1. **Compilation Strategy**: Flutter 3.x compiles Dart code directly to Wasm bytecode with Skwasm/CanvasKit rendering for near-native CPU execution speeds in modern browsers (Chrome, Edge, Firefox, Safari).
2. **Asset Pre-caching**: Core fonts (`Geist`, `Inter`, `JetBrains Mono`) and ambient acoustic audio loops are pre-cached in browser CacheStorage during the initial splash screen.
3. **Bundle Splitting**: Modular sub-packages are dynamically loaded to guarantee sub-800ms initial page load times.
