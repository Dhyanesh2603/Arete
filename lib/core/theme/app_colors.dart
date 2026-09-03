import 'package:flutter/material.dart';

class AppColors {
  // Surface & Depth Tokens
  static const Color canvas = Color(0xFF000000); // Pure OLED Black
  static const Color surfaceTier1 = Color(0x1AA855F7); // 10% Light Purple Glass
  static const Color surfaceTier2 = Color(0x26A855F7); // 15% Light Purple Glass
  static const Color surfaceHover = Color(0x33A855F7); // 20% Light Purple Glass
  static const Color surfaceGlass = Color(0x1AA855F7); // 10% Light Purple Glass (Matte)

  // Hairline Borders
  static const Color borderSubtle = Color(0x33A855F7); // 20% Purple border
  static const Color borderActive = Color(0x66A855F7); // 40% Purple border
  static const Color borderGlowCyan = Color(0x66A855F7); // Purple glow

  // Typography Tones
  static const Color textHigh = Color(0xFFFFFFFF); // Crisp White
  static const Color textMedium = Color(0xFFE2E8F0); // Light Silver
  static const Color textMuted = Color(0xFF94A3B8); // Muted Silver
  static const Color textSubtle = Color(0xFF64748B); // Slate Grey

  // Domain & Status Signals (Variable names kept for codebase compatibility)
  static const Color cyan = Color(0xFFA855F7); // Electric Purple (Primary Accent)
  static const Color cyanBg = Color(0xFF3B0764); 

  static const Color mint = Color(0xFF2DD4BF); // Bright Cyan/Teal
  static const Color mintBg = Color(0xFF115E59);

  static const Color lavender = Color(0xFFC4B5FD); // Soft Lilac
  static const Color lavenderBg = Color(0xFF2E1065);

  static const Color amber = Color(0xFFFBBF24); // Warm Yellow
  static const Color amberBg = Color(0xFF451A03);

  static const Color rose = Color(0xFFF43F5E); // Neon Magenta
  static const Color roseBg = Color(0xFF4C0519);
}
