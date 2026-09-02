import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle get displayLarge => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.textHigh,
        height: 1.2,
      );

  static TextStyle get heading1 => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: AppColors.textHigh,
        height: 1.3,
      );

  static TextStyle get heading2 => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: AppColors.textHigh,
        height: 1.3,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.1,
        color: AppColors.textMedium,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: AppColors.textMedium,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        color: AppColors.textMuted,
        height: 1.3,
      );

  static TextStyle get monoTimer => GoogleFonts.jetBrainsMono(
        fontSize: 54,
        fontWeight: FontWeight.w500,
        letterSpacing: -1.0,
        color: AppColors.textHigh,
      );

  static TextStyle get monoCode => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
        color: AppColors.textMedium,
      );

  static TextStyle get monoBadge => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: AppColors.textMuted,
      );
}
