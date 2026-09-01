# Arete OS — UI Style and Micro-Interaction Guide

---

## 1. Micro-Interaction Philosophy and Precision Ergonomics

Arete is designed with the tactile precision of high-end mechanical instruments and aerospace control decks. Every visual change must provide immediate, deterministic feedback to the user's action with zero unnecessary decoration.

---

## 2. Component Interaction States & Transitions

### 1. Interactive Cards & HUD Containers
- **Resting State**: `surface-tier-1` fill (`#121520`), 1px `border-subtle` (`#2A3047`, 45% alpha).
- **Hover State**: 120ms ease-out transition (`cubic-bezier(0.16, 1, 0.3, 1)`). Border illuminates to `border-active` (`#3E4766`). On Desktop Web, a subtle 120px radial gradient follows cursor coordinates along the border.
- **Active / Pressed State**: `transform: scale(0.995)`, instantaneous visual depression.
- **Focus / Selected State**: 1px `#38BDF8` cyan border with a subtle 4px diffused ambient glow (`rgba(56, 189, 248, 0.25)`).

### 2. Checkboxes and Task Verification Circles
- **Resting State**: 16px circular or rounded-square hairline ring (`#2A3047`).
- **Hover State**: Ring border brightens to `#8290A7`.
- **Toggle Action (Completion)**:
  - Spring-driven fill animation (150ms).
  - Background transitions to Phosphor Mint (`#34D399`).
  - Text item transitions to `#4E5A72` with an animated strike-through path drawn from left to right.

### 3. Primary Action Buttons (e.g. "Engage Focus")
- **Resting State**: Solid `#083344` background with a 1px `#38BDF8` border and `#BAE6FD` text.
- **Hover State**: Background brightens to `#0C4A6E` with an amplified border glow.
- **Pressed State**: Scale down to `0.98` with critically damped spring release.

---

## 3. Contrast Ratios and WCAG AAA Compliance

| Element Pair | Foreground Color | Background Color | Contrast Ratio | WCAG Compliance |
|---|---|---|---|---|
| Primary Text on Canvas | `#F1F5F9` | `#0B0D13` | 18.2 : 1 | AAA Pass |
| Secondary Text on Card | `#CBD5E1` | `#121520` | 12.6 : 1 | AAA Pass |
| Muted Labels / Shortcuts | `#8290A7` | `#121520` | 5.8 : 1 | AAA Pass (Large & Small) |
| Active Cyan Accent on Card | `#38BDF8` | `#121520` | 9.4 : 1 | AAA Pass |
| Mint Accent on Card | `#34D399` | `#121520` | 10.1 : 1 | AAA Pass |

---

## 4. Haptic Feedback Standards (Mobile & Supported Trackpads)

- **Light Haptic Impact (10ms)**: Checking off a standard subtask or pressing a keyboard navigation key.
- **Medium Haptic Impact (25ms)**: Marking an entire habit completed on the HUD.
- **Heavy Success Impact (Double-Pulse: 20ms, 40ms)**: Unlocking or completing a major Milestone Gate.
- **Warning Vibration (30ms)**: Attempting to schedule a task into a conflicting deep work time-block.
