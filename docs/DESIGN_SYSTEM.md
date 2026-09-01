# Arete OS — Design System and Token Specification

---

## 1. Design Tokens and Color Architecture

Arete employs a multi-tiered atmospheric dark palette engineered to eliminate glare while avoiding the visual flatness of stark black and white.

### Surface and Depth Tokens
| Token Name | Hex Value | RGBA Equivalent | Usage Purpose |
|---|---|---|---|
| `surface-canvas` | `#0B0D13` | `rgba(11, 13, 19, 1.0)` | Application root background (Deep Space Slate) |
| `surface-tier-1` | `#121520` | `rgba(18, 21, 32, 1.0)` | Primary cards, main command dock, navigation rail |
| `surface-tier-2` | `#181C2B` | `rgba(24, 28, 43, 1.0)` | Grouped containers, milestone nodes, HUD sub-cards |
| `surface-hover` | `#202538` | `rgba(32, 37, 56, 1.0)` | Interactive hovered rows, active selection tiles |
| `surface-glass` | `#121520` | `rgba(18, 21, 32, 0.75)` | Backdrop-filtered modals, command palette (`blur 16px`) |

### Border and Hairline Tokens
| Token Name | Hex Value | RGBA Equivalent | Usage Purpose |
|---|---|---|---|
| `border-subtle` | `#2A3047` | `rgba(42, 48, 71, 0.45)` | Standard 1px card separators and layout dividers |
| `border-active` | `#3E4766` | `rgba(62, 71, 102, 0.70)` | Focused inputs, hovered cards, active milestone nodes |
| `border-glow-cyan` | `#38BDF8` | `rgba(56, 189, 248, 0.40)` | Active focus mode card glow, single next-action outline |

### Atmospheric Functional Accents
| Domain / Signal | Base Pill Fill | Line / Accent Tone | Text Contrast Accent |
|---|---|---|---|
| **Identity & Strategic Goals** | `#1E1B4B` (Cosmic Indigo) | `#818CF8` (Soft Lavender) | `#C7D2FE` |
| **Active Execution & Tasks** | `#083344` (Deep Cyan) | `#38BDF8` (Cyber Azure) | `#BAE6FD` |
| **Habits & Consistency** | `#064E3B` (Forest Emerald) | `#34D399` (Phosphor Mint) | `#A7F3D0` |
| **Focus Mode & Time-Blocks** | `#451A03` (Espresso Amber)| `#FBBF24` (Golden Ochre) | `#FDE68A` |
| **Friction & Critical Alerts**| `#4C0519` (Deep Crimson) | `#FB7185` (Muted Rose) | `#FECDD3` |

---

## 2. Typography Hierarchy and Type Scale

### Font Family Allocations
- **Display and Headers**: `Geist Display` / `Inter Display`
- **Body and Standard Interface**: `Inter`
- **Telemetry, Timers, Code and Shortcut Pills**: `JetBrains Mono` / `Geist Mono`

### Type Scale Matrix
| Token | Font Family | Size (px) | Line Height (px) | Weight | Tracking (em) |
|---|---|---|---|---|---|
| `display-xl` | Geist Display | 40px | 48px | 700 (Bold) | `-0.03em` |
| `display-lg` | Geist Display | 32px | 38px | 600 (SemiBold) | `-0.025em` |
| `heading-1` | Geist Display | 24px | 30px | 600 (SemiBold) | `-0.02em` |
| `heading-2` | Inter Display | 18px | 24px | 600 (SemiBold) | `-0.015em` |
| `body-large` | Inter | 16px | 24px | 400 (Regular) | `0.00em` |
| `body-base` | Inter | 14px | 20px | 400 / 500 | `0.00em` |
| `caption-sm` | Inter | 12px | 16px | 500 (Medium) | `+0.01em` |
| `mono-timer` | JetBrains Mono | 56px | 64px | 500 (Medium) | `-0.02em (tnum)` |
| `mono-code` | JetBrains Mono | 13px | 18px | 400 (Regular) | `0.00em (tnum)` |
| `mono-badge` | JetBrains Mono | 11px | 14px | 600 (SemiBold) | `+0.02em (tnum)` |

---

## 3. Spacing Scale and Responsive Grid System

### 8-Point Base Spacing System
```
space-1:  4px
space-2:  8px
space-3: 12px
space-4: 16px
space-6: 24px
space-8: 32px
space-12: 48px
space-16: 64px
```

### Responsive Web Breakpoints
- **Desktop Widescreen (Primary)**: $\ge 1440\text{px}$ (Fixed 56px Command Rail + Center Canvas max-w 1100px + 320px Telemetry Drawer).
- **Laptop Standard**: $1024\text{px}$ to $1439\text{px}$ (Collapsible Right Drawer).
- **Tablet**: $768\text{px}$ to $1023\text{px}$ (Collapsible Command Rail, full-width canvas).
- **Mobile Web**: $< 768\text{px}$ (Bottom navigation matrix and full-width single-column flow).

---

## 4. Elevation, Radius, and Material Specs

- **Corner Radii**:
  - Small Controls / Shortcut Badges: `4px`
  - Standard Cards / List Items: `8px`
  - Primary Hero Cards / Modals: `12px`
  - Command Palette Modal: `16px`
- **Surface Material**:
  - Cards use an opaque background fill with a 1px border (`#2A3047`) to prevent GPU overhead.
  - Floating overlays use `backdrop-filter: blur(16px)` with 75% surface opacity.
