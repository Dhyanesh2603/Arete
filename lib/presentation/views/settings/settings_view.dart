import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../providers/dsa_provider.dart';
import '../../providers/goals_provider.dart';
import '../../providers/habits_provider.dart';
import '../../providers/knowledge_provider.dart';
import '../../providers/projects_provider.dart';
import '../../providers/tasks_provider.dart';

enum Chronotype { morningLark, afternoonPeak, nightOwl }

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  Chronotype _chronotype = Chronotype.morningLark;

  void _exportJsonData() {
    final goals = ref.read(goalsProvider);
    final tasks = ref.read(tasksProvider).tasks;
    final habits = ref.read(habitsProvider);
    final notes = ref.read(knowledgeProvider);
    final projects = ref.read(projectsProvider);
    final dsa = ref.read(dsaProvider);

    final exportBundle = {
      'exportedAt': DateTime.now().toIso8601String(),
      'systemVersion': 'Arete 1.0',
      'chronotype': _chronotype.name,
      'goals': goals.goals.map((g) => {'id': g.id, 'title': g.title, 'progress': g.weightedProgress}).toList(),
      'projectsCount': projects.length,
      'tasksCount': tasks.length,
      'habitsCount': habits.length,
      'notesCount': notes.length,
      'dsaSolvedCount': dsa.solvedCount,
      'dsaTotalCount': dsa.totalCount,
    };

    final jsonString = const JsonEncoder.withIndent('  ').convert(exportBundle);

    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 580,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceTier1,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.4)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.file_download_outlined, size: 20, color: AppColors.cyan),
                    const SizedBox(width: 10),
                    Text('SOVEREIGN DATA EXPORT', style: AppTypography.heading2),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Your entire life telemetry, task logs, habit vectors, and DSA solutions exported as standard JSON.',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF08090E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      jsonString,
                      style: AppTypography.monoCode.copyWith(fontSize: 11, color: AppColors.cyan),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      child: Text('Close Export', style: AppTypography.monoBadge.copyWith(color: const Color(0xFF0B0D13), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
              'Biological energy calibration, local-first persistence, shortcuts, and sovereign export.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // Biological Chronotype Scheduling Card
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
                  Row(
                    children: [
                      const Icon(Icons.wb_sunny_outlined, size: 18, color: AppColors.amber),
                      const SizedBox(width: 8),
                      Text('BIOLOGICAL CHRONOTYPE CALIBRATION', style: AppTypography.heading2),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Aligns AI recommendations and calendar time-blocks with your biological cognitive energy peaks.',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildChronotypeTile(
                        'Morning Lark',
                        'Peak: 06:00 - 11:00\nDeep Work morning slots',
                        Chronotype.morningLark,
                      ),
                      const SizedBox(width: 14),
                      _buildChronotypeTile(
                        'Afternoon Peak',
                        'Peak: 13:00 - 17:00\nHigh-focus afternoon coding',
                        Chronotype.afternoonPeak,
                      ),
                      const SizedBox(width: 14),
                      _buildChronotypeTile(
                        'Night Owl',
                        'Peak: 20:00 - 01:00\nLate night focus sessions',
                        Chronotype.nightOwl,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sovereign Data Export Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cyan.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SOVEREIGN DATA OWNERSHIP & BACKUP', style: AppTypography.heading2),
                        const SizedBox(height: 4),
                        Text(
                          'Export your entire database (Goals, Tasks, Habits, Notes, DSA progress) as unencrypted JSON.',
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _exportJsonData,
                    icon: const Icon(Icons.file_download_outlined, size: 16, color: Color(0xFF0B0D13)),
                    label: Text(
                      'EXPORT DATA (JSON)',
                      style: AppTypography.monoBadge.copyWith(color: const Color(0xFF0B0D13), fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyan,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

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
                  _buildShortcutRow('Universal Command Deck / Natural Quick Capture', 'Cmd + K / Ctrl + K'),
                  _buildShortcutRow('Engage Deep Work Focus Session', 'Cmd + Enter'),
                  _buildShortcutRow('Complete Active Focus Session', 'Cmd + D'),
                  _buildShortcutRow('Pause / Resume Focus Timer', 'Space'),
                  _buildShortcutRow('Dismiss Overlay / Exit Focus', 'ESC'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChronotypeTile(String title, String desc, Chronotype type) {
    final isSelected = _chronotype == type;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _chronotype = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surfaceHover : AppColors.surfaceTier2,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.cyan : AppColors.borderSubtle,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  color: isSelected ? AppColors.cyan : AppColors.textHigh,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(desc, style: AppTypography.caption.copyWith(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
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
