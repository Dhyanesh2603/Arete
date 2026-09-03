import 'package:flutter/material.dart';

class AppColors {
  // Surface & Depth Tokens
  static const Color canvas = Color(0xFF000000); // Pure OLED Black
  static const Color surfaceTier1 = Color(0x38D8B4FE); // ~22% Translucent Very Light Purple Matte Card
  static const Color surfaceTier2 = Color(0x50D8B4FE); // ~31% Translucent Light Purple (Chips / Nested)
  static const Color surfaceHover = Color(0x66D8B4FE); // ~40% Translucent Light Purple (Hover)
  static const Color surfaceGlass = Color(0x38D8B4FE); // Matte Frosted Light Purple Glass

  // Hairline Frosted Light Purple Borders
  static const Color borderSubtle = Color(0x55D8B4FE); // 33% Frosted Light Purple Border
  static const Color borderActive = Color(0x99D8B4FE); // 60% Active Light Purple Border
  static const Color borderGlowCyan = Color(0x66C084FC); // Soft Purple Glow

  // Typography Tones
  static const Color textHigh = Color(0xFFFFFFFF); // Crisp Pure White
  static const Color textMedium = Color(0xFFE9D5FF); // Soft Lavender
  static const Color textMuted = Color(0xFFA799B7); // Muted Lavender-Grey
  static const Color textSubtle = Color(0xFF6B5E7B); // Deep Purple-Grey

  // Domain & Status Signals (Variable names kept for codebase compatibility)
  static const Color cyan = Color(0xFFC084FC); // Electric Light Purple (Primary Accent)
  static const Color cyanBg = Color(0x3DC084FC); // Translucent Light Purple Badge Fill

  static const Color mint = Color(0xFF2DD4BF); // Bright Teal (Solved)
  static const Color mintBg = Color(0x2B2DD4BF);

  static const Color lavender = Color(0xFFE9D5FF); // Soft Lilac
  static const Color lavenderBg = Color(0x2BE9D5FF);

  static const Color amber = Color(0xFFFBBF24); // Warm Gold (Focus & Med)
  static const Color amberBg = Color(0x2BFBBF24);

  static const Color rose = Color(0xFFF43F5E); // Neon Rose (High Priority)
  static const Color roseBg = Color(0x2BF43F5E);
}
