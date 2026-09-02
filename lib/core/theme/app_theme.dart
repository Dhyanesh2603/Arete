import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.canvas,
      cardColor: AppColors.surfaceTier1,
      dividerColor: AppColors.borderSubtle,
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surfaceTier1,
        primary: AppColors.cyan,
        secondary: AppColors.mint,
        tertiary: AppColors.lavender,
        error: AppColors.rose,
        onSurface: AppColors.textHigh,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        headlineMedium: AppTypography.heading1,
        titleMedium: AppTypography.heading2,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.caption,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceTier1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.all(AppColors.borderActive),
        radius: const Radius.circular(4),
        thickness: WidgetStateProperty.all(6),
      ),
    );
  }
}
