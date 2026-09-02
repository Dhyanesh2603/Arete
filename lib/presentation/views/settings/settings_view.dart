import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SYSTEM SETTINGS & CONFIGURATION', style: AppTypography.heading1),
            const SizedBox(height: 4),
            Text(
              'Personalize your operating system environment, sync status, and shortcuts.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // Keyboard Shortcuts Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('GLOBAL KEYBOARD SHORTCUTS', style: AppTypography.heading2),
                  const SizedBox(height: 14),
                  _buildShortcutRow('Universal Command Palette', 'Cmd + K / Ctrl + K'),
                  _buildShortcutRow('Engage Deep Work Focus Session', 'Cmd + Enter'),
                  _buildShortcutRow('Complete Active Focus Session', 'Cmd + D'),
                  _buildShortcutRow('Pause / Resume Focus Timer', 'Space'),
                  _buildShortcutRow('Dismiss Overlay / Exit Focus', 'ESC'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sync and Storage Status
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('LOCAL-FIRST PERSISTENCE & CLOUD SYNC', style: AppTypography.heading2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.mint,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Local IndexedDB / Hive Cache: Healthy (0ms latency)',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.cyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Supabase PostgreSQL 16 Realtime Sync: Connected',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutRow(String description, String shortcut) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(description, style: AppTypography.bodyMedium.copyWith(color: AppColors.textHigh)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceTier2,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(shortcut, style: AppTypography.monoBadge.copyWith(color: AppColors.cyan)),
          ),
        ],
      ),
    );
  }
}
