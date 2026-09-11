import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/goal.dart';
import '../../../domain/models/knowledge_note.dart';
import '../../../domain/models/task.dart';
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
  int _defaultFocusMinutes = 45;
  int _defaultBreakMinutes = 5;

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
      'settings': {
        'defaultFocusMinutes': _defaultFocusMinutes,
        'defaultBreakMinutes': _defaultBreakMinutes,
      },
      'tasks': tasks.map((t) => {
        'id': t.id,
        'title': t.title,
        'priority': t.priority.name,
        'estimatedMinutes': t.estimatedMinutes,
        'isCompleted': t.isCompleted,
        'notes': t.notes,
        'projectTag': t.projectTag,
        'dueDate': t.dueDate?.toIso8601String(),
        'subtasks': t.subtaskItems.map((s) => {'id': s.id, 'title': s.title, 'isCompleted': s.isCompleted}).toList(),
      }).toList(),
      'goals': goals.goals.map((g) => {
        'id': g.id,
        'title': g.title,
        'identityTitle': g.identityTitle,
        'objectiveStatement': g.objectiveStatement,
        'targetDeadline': g.targetDeadline.toIso8601String(),
        'priority': g.priority.name,
        'progress': g.weightedProgress,
      }).toList(),
      'habits': habits.map((h) => {
        'id': h.id,
        'title': h.title,
        'frequency': h.frequency.name,
        'consistencyScore': h.consistencyScore,
        'isCompletedToday': h.isCompletedToday,
      }).toList(),
      'notes': notes.map((n) => {
        'id': n.id,
        'title': n.title,
        'category': n.category,
        'contentMarkdown': n.contentMarkdown,
        'updatedAt': n.updatedAt.toIso8601String(),
      }).toList(),
      'projectsCount': projects.length,
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
                  'Your entire productivity database (Tasks, Goals, Habits, Notes, Milestones) formatted as standard portable JSON.',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  height: 220,
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
                    OutlinedButton.icon(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: jsonString));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('JSON copied to clipboard!'), backgroundColor: AppColors.surfaceTier2),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 14, color: AppColors.textHigh),
                      label: Text('Copy to Clipboard', style: AppTypography.caption.copyWith(color: AppColors.textHigh)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cyan,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      child: Text('Close', style: AppTypography.monoBadge.copyWith(color: const Color(0xFF0B0D13), fontWeight: FontWeight.bold)),
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

  void _importJsonData() {
    final importCtrl = TextEditingController();

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
              border: Border.all(color: AppColors.borderActive),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.file_upload_outlined, size: 20, color: AppColors.mint),
                    const SizedBox(width: 10),
                    Text('RESTORE FROM BACKUP (JSON)', style: AppTypography.heading2),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18, color: AppColors.textMuted),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Paste your exported Arete JSON payload below to restore tasks, goals, habits, and notes.',
                  style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF08090E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: TextField(
                    controller: importCtrl,
                    maxLines: null,
                    style: AppTypography.monoCode.copyWith(fontSize: 11, color: AppColors.textHigh),
                    decoration: const InputDecoration(
                      hintText: 'Paste Arete JSON backup here...',
                      hintStyle: TextStyle(color: AppColors.textSubtle, fontSize: 11),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        try {
                          final data = jsonDecode(importCtrl.text.trim()) as Map<String, dynamic>;

                          // 1. Restore Tasks
                          if (data['tasks'] is List) {
                            for (final item in data['tasks']) {
                              final tm = item as Map<String, dynamic>;
                              final pStr = tm['priority'] as String? ?? 'medium';
                              final p = TaskPriority.values.firstWhere((e) => e.name == pStr, orElse: () => TaskPriority.medium);
                              final subRaw = tm['subtasks'] as List<dynamic>? ?? [];
                              final subItems = subRaw.map((s) => SubTaskItem(
                                id: s['id'] as String? ?? 'st-${DateTime.now().millisecondsSinceEpoch}',
                                title: s['title'] as String? ?? '',
                                isCompleted: s['isCompleted'] as bool? ?? false,
                              )).toList();

                              final task = Task(
                                id: tm['id'] as String? ?? 't-${DateTime.now().millisecondsSinceEpoch}',
                                title: tm['title'] as String? ?? 'Restored Task',
                                priority: p,
                                estimatedMinutes: tm['estimatedMinutes'] as int? ?? 45,
                                isCompleted: tm['isCompleted'] as bool? ?? false,
                                notes: tm['notes'] as String?,
                                projectTag: tm['projectTag'] as String?,
                                subtaskItems: subItems,
                              );
                              ref.read(tasksProvider.notifier).addTask(task);
                            }
                          }

                          // 2. Restore Notes
                          if (data['notes'] is List) {
                            for (final item in data['notes']) {
                              final nm = item as Map<String, dynamic>;
                              final note = KnowledgeNote(
                                id: nm['id'] as String? ?? 'n-${DateTime.now().millisecondsSinceEpoch}',
                                title: nm['title'] as String? ?? 'Restored Note',
                                category: nm['category'] as String? ?? 'Engineering',
                                contentMarkdown: nm['contentMarkdown'] as String? ?? '',
                                updatedAt: DateTime.now(),
                              );
                              ref.read(knowledgeProvider.notifier).addNote(note);
                            }
                          }

                          // 3. Restore Goals
                          if (data['goals'] is List) {
                            for (final item in data['goals']) {
                              final gm = item as Map<String, dynamic>;
                              final pStr = gm['priority'] as String? ?? 'p1Strategic';
                              final p = GoalPriority.values.firstWhere((e) => e.name == pStr, orElse: () => GoalPriority.p1Strategic);
                              ref.read(goalsProvider.notifier).createGoal(
                                identityTitle: gm['identityTitle'] as String? ?? 'Engineer',
                                title: gm['title'] as String? ?? 'Restored Goal',
                                objectiveStatement: gm['objectiveStatement'] as String? ?? '',
                                targetDeadline: DateTime.now().add(const Duration(days: 90)),
                                priority: p,
                              );
                            }
                          }

                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Backup data restored successfully!'),
                              backgroundColor: AppColors.mint,
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Import failed: Invalid JSON format ($e)'), backgroundColor: AppColors.rose),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mint,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      ),
                      child: Text('RESTORE BACKUP', style: AppTypography.monoBadge.copyWith(color: const Color(0xFF09090B), fontWeight: FontWeight.bold)),
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
            Text('PLATFORM SETTINGS & PREFERENCES', style: AppTypography.heading1),
            const SizedBox(height: 4),
            Text(
              'Customize your circadian workflow rhythms, focus timer defaults, and export or restore data.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),

            // Chronotype Selector Card
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
                  Text('CHRONOTYPE & PEAK COGNITIVE WINDOWS', style: AppTypography.heading2),
                  const SizedBox(height: 6),
                  Text(
                    'Informs the AI Cognitive Coach and Flight Plan algorithm of your circadian focus peaks.',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildChronotypeTile('Morning Lark', 'Peak Focus: 08:00 - 12:00', Chronotype.morningLark),
                      const SizedBox(width: 12),
                      _buildChronotypeTile('Afternoon Peak', 'Peak Focus: 13:00 - 17:00', Chronotype.afternoonPeak),
                      const SizedBox(width: 12),
                      _buildChronotypeTile('Night Owl', 'Peak Focus: 20:00 - 02:00', Chronotype.nightOwl),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Deep Work Timer Configuration
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
                  Text('DEEP WORK FOCUS INTERVALS', style: AppTypography.heading2),
                  const SizedBox(height: 6),
                  Text(
                    'Configure standard work session lengths and rest intervals.',
                    style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Work duration
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceTier2,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.timer_outlined, size: 18, color: AppColors.cyan),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Default Session Duration', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text('$_defaultFocusMinutes Minutes', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Spacer(),
                              Wrap(
                                spacing: 6,
                                children: [25, 45, 60].map((mins) {
                                  final isSel = _defaultFocusMinutes == mins;
                                  return InkWell(
                                    onTap: () => setState(() => _defaultFocusMinutes = mins),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSel ? AppColors.cyanBg : AppColors.surfaceHover,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: isSel ? AppColors.cyan : AppColors.borderSubtle),
                                      ),
                                      child: Text('${mins}m', style: AppTypography.monoBadge.copyWith(fontSize: 9, color: isSel ? AppColors.cyan : AppColors.textMuted)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      // Break duration
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceTier2,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.coffee_outlined, size: 18, color: AppColors.amber),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Breather Duration', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                                  const SizedBox(height: 2),
                                  Text('$_defaultBreakMinutes Minutes', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const Spacer(),
                              Wrap(
                                spacing: 6,
                                children: [5, 10, 15].map((mins) {
                                  final isSel = _defaultBreakMinutes == mins;
                                  return InkWell(
                                    onTap: () => setState(() => _defaultBreakMinutes = mins),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isSel ? AppColors.amberBg : AppColors.surfaceHover,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: isSel ? AppColors.amber : AppColors.borderSubtle),
                                      ),
                                      child: Text('${mins}m', style: AppTypography.monoBadge.copyWith(fontSize: 9, color: isSel ? AppColors.amber : AppColors.textMuted)),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Sovereign Data Backup & Restore Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceTier1,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('TWO-WAY DATA SOVEREIGNTY', style: AppTypography.heading2),
                        const SizedBox(height: 4),
                        Text(
                          'Export your entire database (Goals, Tasks, Habits, Notes, Milestones) or restore from an existing JSON backup.',
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _importJsonData,
                    icon: const Icon(Icons.file_upload_outlined, size: 16, color: AppColors.mint),
                    label: Text(
                      'RESTORE (JSON)',
                      style: AppTypography.monoBadge.copyWith(color: AppColors.mint, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderSubtle),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 10),
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
