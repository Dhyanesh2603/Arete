import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/calendar_event.dart';

class CalendarState {
  final DateTime selectedDate;
  final List<CalendarBlock> blocks;

  const CalendarState({
    required this.selectedDate,
    required this.blocks,
  });

  CalendarState copyWith({
    DateTime? selectedDate,
    List<CalendarBlock>? blocks,
  }) {
    return CalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      blocks: blocks ?? this.blocks,
    );
  }

  List<CalendarBlock> get todayBlocks {
    return blocks.where((b) {
      return b.startTime.year == selectedDate.year &&
          b.startTime.month == selectedDate.month &&
          b.startTime.day == selectedDate.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier() : super(_initialCalendar());

  static CalendarState _initialCalendar() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return CalendarState(
      selectedDate: today,
      blocks: [
        CalendarBlock(
          id: 'cb-1',
          title: 'Deep Work: DSA Striver Step 13',
          subtitle: 'Binary Trees LCA & Diameter',
          startTime: DateTime(now.year, now.month, now.day, 8, 0),
          endTime: DateTime(now.year, now.month, now.day, 10, 30),
          type: CalendarBlockType.deepWork,
          isCompleted: true,
        ),
        CalendarBlock(
          id: 'cb-2',
          title: 'Deep Work: LeetCode 124 Max Path Sum',
          subtitle: 'Recursive subtree reduction',
          startTime: DateTime(now.year, now.month, now.day, 11, 0),
          endTime: DateTime(now.year, now.month, now.day, 12, 30),
          type: CalendarBlockType.deepWork,
          isCompleted: false,
        ),
        CalendarBlock(
          id: 'cb-3',
          title: 'Study Squad War-Room Sync',
          subtitle: 'Review Step 13 with Alex & Maya',
          startTime: DateTime(now.year, now.month, now.day, 14, 30),
          endTime: DateTime(now.year, now.month, now.day, 15, 30),
          type: CalendarBlockType.studyCohort,
          isCompleted: false,
        ),
        CalendarBlock(
          id: 'cb-4',
          title: 'GPU Kernel Lab: FlashAttention',
          subtitle: 'Triton SRAM memory layout profiling',
          startTime: DateTime(now.year, now.month, now.day, 16, 0),
          endTime: DateTime(now.year, now.month, now.day, 17, 30),
          type: CalendarBlockType.deepWork,
          isCompleted: false,
        ),
        CalendarBlock(
          id: 'cb-5',
          title: 'Physical Training & Cardio',
          subtitle: '45m Zone-2 running session',
          startTime: DateTime(now.year, now.month, now.day, 18, 0),
          endTime: DateTime(now.year, now.month, now.day, 19, 0),
          type: CalendarBlockType.recovery,
          isCompleted: false,
        ),
      ],
    );
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void toggleBlockCompleted(String id) {
    state = state.copyWith(
      blocks: state.blocks.map((b) {
        if (b.id == id) return b.copyWith(isCompleted: !b.isCompleted);
        return b;
      }).toList(),
    );
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier();
});
