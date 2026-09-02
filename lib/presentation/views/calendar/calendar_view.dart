import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../domain/models/calendar_event.dart';
import '../../providers/calendar_provider.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _displayedMonth = DateTime(now.year, now.month, 1);
    });
    ref.read(calendarProvider.notifier).setSelectedDate(
          DateTime(now.year, now.month, now.day),
        );
  }

  void _showAddBlockDialog(BuildContext context, DateTime targetDate) {
    final titleCtrl = TextEditingController();
    final subCtrl = TextEditingController();
    CalendarBlockType selectedType = CalendarBlockType.deepWork;
    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 11, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Container(
                width: 440,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier1,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderActive),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.cyanBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: AppColors.cyan.withValues(alpha: 0.3)),
                          ),
                          child: const Icon(Icons.add_task_rounded,
                              size: 16, color: AppColors.cyan),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Schedule Calendar Block',
                          style: AppTypography.heading2.copyWith(fontSize: 16),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close_rounded,
                              size: 18, color: AppColors.textMuted),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Date: ${DateFormat('EEEE, MMM d, yyyy').format(targetDate)}',
                      style: AppTypography.caption.copyWith(color: AppColors.cyan),
                    ),
                    const SizedBox(height: 18),

                    // Title
                    Text('Block Title',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMedium)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTier2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: TextField(
                        controller: titleCtrl,
                        style: AppTypography.bodyMedium,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Striver Binary Trees LCA',
                          hintStyle: TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Subtitle
                    Text('Objective / Notes',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMedium)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTier2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: TextField(
                        controller: subCtrl,
                        style: AppTypography.bodyMedium,
                        decoration: const InputDecoration(
                          hintText: 'e.g. Solve 3 medium problems',
                          hintStyle: TextStyle(
                              fontSize: 12, color: AppColors.textMuted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Category Selector
                    Text('Block Category',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMedium)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CalendarBlockType.values.map((type) {
                        final isSelected = selectedType == type;
                        final label = switch (type) {
                          CalendarBlockType.deepWork => 'Deep Work',
                          CalendarBlockType.studyCohort => 'Study Squad',
                          CalendarBlockType.habitRoutine => 'Habit',
                          CalendarBlockType.meeting => 'Sync',
                          CalendarBlockType.recovery => 'Recovery',
                        };
                        return InkWell(
                          onTap: () {
                            setDialogState(() => selectedType = type);
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.cyanBg
                                  : AppColors.surfaceTier2,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.cyan
                                    : AppColors.borderSubtle,
                              ),
                            ),
                            child: Text(
                              label,
                              style: AppTypography.monoBadge.copyWith(
                                color: isSelected
                                    ? AppColors.cyan
                                    : AppColors.textMedium,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 22),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          child: Text('Cancel',
                              style: AppTypography.bodyMedium
                                  .copyWith(color: AppColors.textMuted)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            final title = titleCtrl.text.trim();
                            if (title.isEmpty) return;

                            final start = DateTime(
                              targetDate.year,
                              targetDate.month,
                              targetDate.day,
                              startTime.hour,
                              startTime.minute,
                            );
                            final end = DateTime(
                              targetDate.year,
                              targetDate.month,
                              targetDate.day,
                              endTime.hour,
                              endTime.minute,
                            );

                            ref.read(calendarProvider.notifier).addBlock(
                                  title: title,
                                  subtitle: subCtrl.text.trim().isNotEmpty
                                      ? subCtrl.text.trim()
                                      : 'Dedicated focus block',
                                  startTime: start,
                                  endTime: end,
                                  type: selectedType,
                                );

                            Navigator.of(dialogCtx).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cyan,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 11),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                          ),
                          child: Text(
                            'SCHEDULE BLOCK',
                            style: AppTypography.monoBadge.copyWith(
                              color: const Color(0xFF0B0D13),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final calState = ref.watch(calendarProvider);
    final selectedDate = calState.selectedDate;
    final selectedBlocks = calState.selectedDateBlocks;

    final monthName = DateFormat('MMMM yyyy').format(_displayedMonth);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Sleek Calendar Header
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CALENDAR', style: AppTypography.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Interactive monthly schedule and deep work blocks.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _goToToday,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.borderSubtle),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text('Today',
                      style: AppTypography.bodyMedium.copyWith(fontSize: 13)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () => _showAddBlockDialog(context, selectedDate),
                  icon: const Icon(Icons.add_rounded,
                      size: 16, color: Color(0xFF0B0D13)),
                  label: Text(
                    'SCHEDULE BLOCK',
                    style: AppTypography.monoBadge.copyWith(
                      color: const Color(0xFF0B0D13),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cyan,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 2. Main Calendar Content: Grid + Selected Day Schedule
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 920;

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month Calendar Grid
                      Expanded(
                        flex: 6,
                        child: _buildMonthCalendarCard(
                            monthName, calState, selectedDate),
                      ),
                      const SizedBox(width: 24),
                      // Selected Day Schedule
                      Expanded(
                        flex: 4,
                        child: _buildDayScheduleCard(
                            selectedDate, selectedBlocks, calState),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildMonthCalendarCard(
                          monthName, calState, selectedDate),
                      const SizedBox(height: 20),
                      _buildDayScheduleCard(
                          selectedDate, selectedBlocks, calState),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthCalendarCard(
      String monthName, CalendarState calState, DateTime selectedDate) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        children: [
          // Month Controls Header
          Row(
            children: [
              Text(
                monthName,
                style: AppTypography.heading2.copyWith(fontSize: 16),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded,
                    size: 20, color: AppColors.textMedium),
                onPressed: _prevMonth,
                tooltip: 'Previous Month',
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded,
                    size: 20, color: AppColors.textMedium),
                onPressed: _nextMonth,
                tooltip: 'Next Month',
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Day-of-Week Headers
          Row(
            children: const [
              _WeekdayHeader('MON'),
              _WeekdayHeader('TUE'),
              _WeekdayHeader('WED'),
              _WeekdayHeader('THU'),
              _WeekdayHeader('FRI'),
              _WeekdayHeader('SAT'),
              _WeekdayHeader('SUN'),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 8),

          // Monthly Calendar Grid Days
          _buildMonthGrid(calState, selectedDate),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(CalendarState calState, DateTime selectedDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final firstDayOfMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;

    // weekday is 1 for Mon, 7 for Sun
    final startingWeekday = firstDayOfMonth.weekday; // 1 to 7

    final daysInPrevMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month, 0).day;

    final List<Widget> dayCells = [];

    // Preceding month filler days
    for (int i = startingWeekday - 1; i > 0; i--) {
      final dayNum = daysInPrevMonth - i + 1;
      final date = DateTime(
          _displayedMonth.year, _displayedMonth.month - 1, dayNum);
      dayCells.add(_buildDayCell(date, dayNum,
          isCurrentMonth: false,
          isToday: date == today,
          isSelected: date == selectedDate,
          calState: calState));
    }

    // Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final date =
          DateTime(_displayedMonth.year, _displayedMonth.month, day);
      dayCells.add(_buildDayCell(date, day,
          isCurrentMonth: true,
          isToday: date == today,
          isSelected: date == selectedDate,
          calState: calState));
    }

    // Trailing month filler days to complete 7-column rows
    final remainingCells = (7 - (dayCells.length % 7)) % 7;
    for (int day = 1; day <= remainingCells; day++) {
      final date =
          DateTime(_displayedMonth.year, _displayedMonth.month + 1, day);
      dayCells.add(_buildDayCell(date, day,
          isCurrentMonth: false,
          isToday: date == today,
          isSelected: date == selectedDate,
          calState: calState));
    }

    // Build rows of 7
    final List<Widget> rows = [];
    for (int i = 0; i < dayCells.length; i += 7) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: dayCells.sublist(i, i + 7),
          ),
        ),
      );
    }

    return Column(children: rows);
  }

  Widget _buildDayCell(
    DateTime date,
    int dayNum, {
    required bool isCurrentMonth,
    required bool isToday,
    required bool isSelected,
    required CalendarState calState,
  }) {
    // Check if this day has any blocks
    final dayBlocks = calState.blocks.where((b) {
      return b.startTime.year == date.year &&
          b.startTime.month == date.month &&
          b.startTime.day == date.day;
    }).toList();

    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(calendarProvider.notifier).setSelectedDate(date);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 48,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.cyan.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppColors.cyan
                  : isToday
                      ? AppColors.borderActive
                      : Colors.transparent,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$dayNum',
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 13,
                  fontWeight:
                      isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AppColors.cyan
                      : isCurrentMonth
                          ? AppColors.textHigh
                          : AppColors.textSubtle,
                ),
              ),
              if (dayBlocks.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: dayBlocks.take(3).map((b) {
                    final color = switch (b.type) {
                      CalendarBlockType.deepWork => AppColors.cyan,
                      CalendarBlockType.studyCohort => AppColors.lavender,
                      CalendarBlockType.habitRoutine => AppColors.mint,
                      CalendarBlockType.meeting => AppColors.amber,
                      CalendarBlockType.recovery => AppColors.rose,
                    };
                    return Container(
                      width: 4,
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayScheduleCard(DateTime selectedDate,
      List<CalendarBlock> blocks, CalendarState calState) {
    final dateStr = DateFormat('EEEE, MMM d').format(selectedDate);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceTier1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dateStr,
                      style: AppTypography.heading2.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${blocks.length} block${blocks.length == 1 ? '' : 's'} scheduled',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded,
                    size: 20, color: AppColors.cyan),
                onPressed: () => _showAddBlockDialog(context, selectedDate),
                tooltip: 'Add block for this date',
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.borderSubtle, height: 1),
          const SizedBox(height: 14),

          if (blocks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.event_available_rounded,
                        size: 32, color: AppColors.textSubtle),
                    const SizedBox(height: 10),
                    Text(
                      'No blocks scheduled for this date.',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textMuted, fontSize: 13),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () =>
                          _showAddBlockDialog(context, selectedDate),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                      ),
                      child: Text('Schedule a Block',
                          style:
                              AppTypography.bodyMedium.copyWith(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            )
          else
            ...blocks.map((block) {
              final color = switch (block.type) {
                CalendarBlockType.deepWork => AppColors.cyan,
                CalendarBlockType.studyCohort => AppColors.lavender,
                CalendarBlockType.habitRoutine => AppColors.mint,
                CalendarBlockType.meeting => AppColors.amber,
                CalendarBlockType.recovery => AppColors.rose,
              };

              final startStr = DateFormat('HH:mm').format(block.startTime);
              final endStr = DateFormat('HH:mm').format(block.endTime);

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceTier2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: block.isCompleted
                        ? AppColors.mint.withValues(alpha: 0.3)
                        : AppColors.borderSubtle,
                  ),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        ref
                            .read(calendarProvider.notifier)
                            .toggleBlockCompleted(block.id);
                      },
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: color, width: 1.5),
                        ),
                        child: block.isCompleted
                            ? Icon(Icons.check_rounded, size: 14, color: color)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            block.title,
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              decoration: block.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '$startStr - $endStr',
                                style: AppTypography.monoBadge.copyWith(
                                    fontSize: 10, color: AppColors.textMuted),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${block.subtitle}',
                                style: AppTypography.caption.copyWith(
                                    fontSize: 10, color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          size: 16, color: AppColors.textSubtle),
                      onPressed: () {
                        ref
                            .read(calendarProvider.notifier)
                            .deleteBlock(block.id);
                      },
                      tooltip: 'Remove block',
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  final String label;
  const _WeekdayHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: AppTypography.monoBadge.copyWith(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
