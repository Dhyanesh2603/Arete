# Arete OS — Animation and Motion Engineering Guide

---

## 1. Motion Design Principles and Frame Budget

Arete enforces strict performance parameters for all motion. Every animation must serve a structural purpose: communicating state transition, spatial hierarchy, or completion verification.

### Key Rules
- Zero decorative bounce, comical overshoot, or slow animations.
- All animations run at 60 FPS minimum, scaling automatically to 120 FPS on Apple ProMotion and 120Hz/144Hz desktop gaming monitors.
- Total frame budget per frame: 8.33ms (at 120 FPS) / 16.66ms (at 60 FPS).

---

## 2. Animation Curves and Timing Matrix

### Standard Timing Hierarchy
| Animation Type | Duration | Easing Curve | Cubic-Bezier Formula | Usage |
|---|---|---|---|---|
| **Micro-Interactions** | 120ms | Precision Ease-Out | `cubic-bezier(0.16, 1, 0.3, 1)` | Hover states, border glows, checkbox ticks |
| **Command Modal & Sheets** | 200ms | Decelerate Spring | `cubic-bezier(0.22, 1, 0.36, 1)` | `Cmd+K` palette opening, drawer slide-in |
| **Viewport State Changes** | 350ms | Fluid Cross-Fade | `cubic-bezier(0.16, 1, 0.3, 1)` | Transition into Fullscreen Focus Mode |
| **Telemetry Arc Fill** | 500ms | Smooth Damped Progress | `cubic-bezier(0.33, 1, 0.68, 1)` | Concentric HUD vector rings initial load |

---

## 3. Rive 2 State Machine Choreography

### 1. Dynamic HUD Concentric Vector Rings (`momentum_rings.riv`)
- **Inputs**:
  - `focus_ratio` (Number: 0.0 to 1.0)
  - `habit_ratio` (Number: 0.0 to 1.0)
  - `velocity_ratio` (Number: 0.0 to 1.0)
  - `is_active_session` (Boolean)
- **Choreography**: As focus hours are logged, the outer ring smoothly interpolates to the new angle using a damped spring state machine without triggering Flutter widget tree rebuilds.

### 2. Ambient Acoustic Spectrum Visualizer (`acoustic_spectrum.riv`)
- **Inputs**:
  - `soundscape_type` (Enum: `binaural`, `brown_noise`, `rain`, `hum`)
  - `volume_level` (Number: 0.0 to 1.0)
  - `is_playing` (Boolean)
- **Choreography**: Renders 24 subtle vertical hairline bars undulating in harmonic resonance with the audio stream.

---

## 4. Flutter Rendering Performance Optimization Rules

1. **RepaintBoundary Isolation**:
   Every animated component (timers, progress rings, charts) is wrapped inside a dedicated `RepaintBoundary`:
   ```dart
   RepaintBoundary(
     child: FocusCountdownTimer(remainingSeconds: remaining),
   )
   ```
2. **Path Caching in CustomPainters**:
   Custom trajectory curves and 365-day heatmaps pre-compute their `Path` objects in the `shouldRepaint` method, avoiding path re-generation during paint cycles.
3. **Hardware Texture Layering**:
   Modal backdrop blurs use `BackdropFilter` exclusively on isolated layers, ensuring GPU compositing overhead remains under 1.5ms per frame.
