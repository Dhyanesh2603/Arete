import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../domain/models/calendar_event.dart';
import '../../domain/models/task.dart';
import '../providers/calendar_provider.dart';
import '../providers/focus_session_provider.dart';
import '../providers/tasks_provider.dart';

class TaskDetailModal extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailModal({super.key, required this.task});

  static Future<void> show(BuildContext context, Task task) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => TaskDetailModal(task: task),
    );
  }

  @override
  ConsumerState<TaskDetailModal> createState() => _TaskDetailModalState();
}

class _TaskDetailModalState extends ConsumerState<TaskDetailModal> {
  late TextEditingController _titleCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _newSubtaskCtrl;
  late TextEditingController _tagCtrl;
  late TaskPriority _selectedPriority;
  late int _estimatedMinutes;
  late int _estimatedPomodoros;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _notesCtrl = TextEditingController(text: widget.task.notes ?? '');
    _newSubtaskCtrl = TextEditingController();
    _tagCtrl = TextEditingController(text: widget.task.projectTag ?? '');
    _selectedPriority = widget.task.priority;
    _estimatedMinutes = widget.task.estimatedMinutes;
    _estimatedPomodoros = widget.task.estimatedPomodoros;
    _dueDate = widget.task.dueDate;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    _newSubtaskCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  void _saveChanges() {
    ref.read(tasksProvider.notifier).updateTaskDetails(
          widget.task.id,
          title: _titleCtrl.text.trim().isEmpty ? widget.task.title : _titleCtrl.text.trim(),
          priority: _selectedPriority,
          estimatedMinutes: _estimatedMinutes,
          dueDate: _dueDate,
          notes: _notesCtrl.text.trim(),
          projectTag: _tagCtrl.text.trim().isEmpty ? null : _tagCtrl.text.trim(),
          estimatedPomodoros: _estimatedPomodoros,
        );
  }

  void _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.cyan,
              surface: AppColors.surfaceTier1,
              onSurface: AppColors.textHigh,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
      _saveChanges();
    }
  }

  void _scheduleIntoCalendarToday() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, now.hour + 1, 0);
    final end = start.add(Duration(minutes: _estimatedMinutes));

    ref.read(calendarProvider.notifier).addBlock(
          title: widget.task.title,
          subtitle: 'Scheduled from Task Matrix (${_selectedPriority.label} Priority)',
          startTime: start,
          endTime: end,
          type: CalendarBlockType.deepWork,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Scheduled for today at ${DateFormat('h:mm a').format(start)}'),
        backgroundColor: AppColors.surfaceTier2,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksProvider);
    // Fetch fresh instance of this task
    final currentTask = tasksState.tasks.firstWhere(
      (t) => t.id == widget.task.id,
      orElse: () => widget.task,
    );

    final subtasks = currentTask.subtaskItems;
    final completedSubtasks = subtasks.where((s) => s.isCompleted).length;
    final progress = subtasks.isEmpty ? 0.0 : completedSubtasks / subtasks.length;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 580,
          constraints: const BoxConstraints(maxHeight: 700),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceTier1,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderActive),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _selectedPriority.backgroundColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _selectedPriority.label.toUpperCase(),
                      style: AppTypography.monoBadge.copyWith(
                        color: _selectedPriority.color,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Focus button
                  IconButton(
                    icon: const Icon(Icons.play_arrow_rounded, color: AppColors.cyan, size: 20),
                    tooltip: 'Launch Deep Focus',
                    onPressed: () {
                      Navigator.of(context).pop();
                      ref.read(focusSessionProvider.notifier).startSession(
                            taskTitle: currentTask.title,
                            objective: 'Execute priority task: ${currentTask.title}',
                            durationMinutes: currentTask.estimatedMinutes,
                          );
                      context.go('/focus');
                    },
                  ),
                  // Delete button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.rose, size: 18),
                    tooltip: 'Delete Task',
                    onPressed: () {
                      ref.read(tasksProvider.notifier).deleteTask(widget.task.id);
                      Navigator.of(context).pop();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title input
              TextField(
                controller: _titleCtrl,
                style: AppTypography.heading2.copyWith(fontSize: 18),
                decoration: const InputDecoration(
                  hintText: 'Task Title',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => _saveChanges(),
              ),
              const SizedBox(height: 14),

              // Metadata Chips Bar
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Priority selector dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier2,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TaskPriority>(
                        value: _selectedPriority,
                        dropdownColor: AppColors.surfaceTier2,
                        isDense: true,
                        items: TaskPriority.values.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Row(
                              children: [
                                Container(width: 8, height: 8, decoration: BoxDecoration(color: p.color, shape: BoxShape.circle)),
                                const SizedBox(width: 6),
                                Text(p.label, style: AppTypography.caption.copyWith(color: AppColors.textHigh)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (p) {
                          if (p != null) {
                            setState(() => _selectedPriority = p);
                            _saveChanges();
                          }
                        },
                      ),
                    ),
                  ),

                  // Due Date chip
                  InkWell(
                    onTap: _pickDueDate,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTier2,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _dueDate != null ? AppColors.cyan.withValues(alpha: 0.4) : AppColors.borderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_today_rounded, size: 13, color: _dueDate != null ? AppColors.cyan : AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            _dueDate != null ? DateFormat('MMM d, y').format(_dueDate!) : 'Set Due Date',
                            style: AppTypography.caption.copyWith(
                              color: _dueDate != null ? AppColors.textHigh : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Estimated minutes stepper
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceTier2,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.timer_outlined, size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text('${_estimatedMinutes}m', style: AppTypography.caption.copyWith(color: AppColors.textHigh)),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            if (_estimatedMinutes > 15) {
                              setState(() => _estimatedMinutes -= 15);
                              _saveChanges();
                            }
                          },
                          child: const Icon(Icons.remove, size: 14, color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            setState(() => _estimatedMinutes += 15);
                            _saveChanges();
                          },
                          child: const Icon(Icons.add, size: 14, color: AppColors.cyan),
                        ),
                      ],
                    ),
                  ),

                  // Schedule into Calendar Today action button
                  OutlinedButton.icon(
                    onPressed: _scheduleIntoCalendarToday,
                    icon: const Icon(Icons.schedule_send_rounded, size: 13, color: AppColors.lavender),
                    label: Text(
                      'Block Calendar',
                      style: AppTypography.caption.copyWith(color: AppColors.lavender, fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderSubtle),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.borderSubtle, height: 1),
              const SizedBox(height: 14),

              // Subtasks Section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('SUBTASKS', style: AppTypography.monoBadge.copyWith(color: AppColors.textMedium, fontSize: 11)),
                          const SizedBox(width: 8),
                          if (subtasks.isNotEmpty)
                            Text('$completedSubtasks / ${subtasks.length}', style: AppTypography.caption.copyWith(color: AppColors.textMuted)),
                        ],
                      ),
                      if (subtasks.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: AppColors.surfaceTier2,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.mint),
                            minHeight: 3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),

                      // Subtasks List
                      ...subtasks.map((sub) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceTier2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => ref.read(tasksProvider.notifier).toggleSubtask(widget.task.id, sub.id),
                                child: Icon(
                                  sub.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                  size: 16,
                                  color: sub.isCompleted ? AppColors.mint : AppColors.textSubtle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  sub.title,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontSize: 13,
                                    color: sub.isCompleted ? AppColors.textMuted : AppColors.textHigh,
                                    decoration: sub.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.textSubtle),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                                onPressed: () => ref.read(tasksProvider.notifier).deleteSubtask(widget.task.id, sub.id),
                              ),
                            ],
                          ),
                        );
                      }),

                      // Add Subtask input
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceTier2,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.borderSubtle),
                              ),
                              child: TextField(
                                controller: _newSubtaskCtrl,
                                style: AppTypography.bodyMedium.copyWith(fontSize: 12),
                                decoration: const InputDecoration(
                                  hintText: 'Add subtask and press Enter...',
                                  hintStyle: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                                ),
                                onSubmitted: (val) {
                                  if (val.trim().isNotEmpty) {
                                    ref.read(tasksProvider.notifier).addSubtask(widget.task.id, val);
                                    _newSubtaskCtrl.clear();
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, color: AppColors.cyan, size: 20),
                            onPressed: () {
                              if (_newSubtaskCtrl.text.trim().isNotEmpty) {
                                ref.read(tasksProvider.notifier).addSubtask(widget.task.id, _newSubtaskCtrl.text);
                                _newSubtaskCtrl.clear();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Notes / Specifications textarea
                      Text('NOTES & SPECIFICATIONS', style: AppTypography.monoBadge.copyWith(color: AppColors.textMedium, fontSize: 11)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTier2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: TextField(
                          controller: _notesCtrl,
                          maxLines: 4,
                          style: AppTypography.bodyMedium.copyWith(fontSize: 12, height: 1.5),
                          decoration: const InputDecoration(
                            hintText: 'Add technical notes, reproduction steps, or context...',
                            hintStyle: TextStyle(color: AppColors.textSubtle, fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => _saveChanges(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
