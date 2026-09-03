import 'package:flutter/material.dart';

class AppColors {
  // Surface & Depth Tokens (Neutral Dark Zinc / Graphite for eye comfort)
  static const Color canvas = Color(0xFF09090B); // Pure Deep Neutral Black (OLED-friendly)
  static const Color surfaceTier1 = Color(0xFF131316); // Sleek Dark Charcoal Surface (Cards / Modals)
  static const Color surfaceTier2 = Color(0xFF1B1B20); // Elevated Neutral (Inputs / Nested Cards / Search)
  static const Color surfaceHover = Color(0xFF24242C); // Clean Neutral Hover
  static const Color surfaceGlass = Color(0xEB131316); // 92% Matte Frosted Dark Glass

  // Hairline Neutral Borders (Crisp and subtle, zero harsh glare)
  static const Color borderSubtle = Color(0xFF222228); // 1px Neutral Divider / Card Outline
  static const Color borderActive = Color(0xFF3B3B46); // Neutral Active Border
  static const Color borderGlowCyan = Color(0x338B5CF6); // Subtle Violet Accent Glow

  // Typography Tones (Clean, natural neutral whites & cool grays)
  static const Color textHigh = Color(0xFFFAFAFA); // Crisp Pure White
  static const Color textMedium = Color(0xFFA1A1AA); // Cool Silver Neutral Gray (No color fatigue)
  static const Color textMuted = Color(0xFF71717A); // Slate Zinc Gray
  static const Color textSubtle = Color(0xFF52525B); // Dim Zinc Gray

  // Primary Brand Accent - Tasteful Electric Violet (Used for key focal actions only!)
  static const Color cyan = Color(0xFF8B5CF6); // Vivid Violet (Primary CTA Buttons, Key Highlights)
  static const Color cyanBg = Color(0x248B5CF6); // 14% Subtle Violet Tint (Badges / Active pills only)

  // Rich Balanced Domain Signals (Multi-color harmony so UI never feels monochromatic)
  static const Color mint = Color(0xFF10B981); // Emerald Green (Solved DSA, Completed Items)
  static const Color mintBg = Color(0x1F10B981); // 12% Emerald Tint

  static const Color amber = Color(0xFFF59E0B); // Golden Amber (Streaks, Focus Timers, Medium Priority)
  static const Color amberBg = Color(0x1FF59E0B); // 12% Amber Tint

  static const Color rose = Color(0xFFEF4444); // Crimson Coral (High Priority, Blockers, Sign Out)
  static const Color roseBg = Color(0x1FEF4444); // 12% Crimson Tint

  static const Color lavender = Color(0xFF6366F1); // Indigo Blue (Strategic Milestones, Roadmaps)
  static const Color lavenderBg = Color(0x1F6366F1); // 12% Indigo Tint
}
