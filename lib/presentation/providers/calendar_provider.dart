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

  List<CalendarBlock> get selectedDateBlocks {
    return blocks.where((b) {
      return b.startTime.year == selectedDate.year &&
          b.startTime.month == selectedDate.month &&
          b.startTime.day == selectedDate.day;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
  }

  List<CalendarBlock> get todayBlocks => selectedDateBlocks;
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  CalendarNotifier() : super(_initialCalendar());

  static CalendarState _initialCalendar() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return CalendarState(
      selectedDate: today,
      blocks: [],
    );
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void addBlock({
    required String title,
    required String subtitle,
    required DateTime startTime,
    required DateTime endTime,
    required CalendarBlockType type,
  }) {
    final block = CalendarBlock(
      id: 'cb-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      subtitle: subtitle,
      startTime: startTime,
      endTime: endTime,
      type: type,
    );
    state = state.copyWith(blocks: [...state.blocks, block]);
  }

  void deleteBlock(String id) {
    state = state.copyWith(
      blocks: state.blocks.where((b) => b.id != id).toList(),
    );
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
