enum CalendarBlockType { deepWork, studyCohort, habitRoutine, meeting, recovery }

class CalendarBlock {
  final String id;
  final String title;
  final String subtitle;
  final DateTime startTime;
  final DateTime endTime;
  final CalendarBlockType type;
  final bool isCompleted;

  const CalendarBlock({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.isCompleted = false,
  });

  int get durationMinutes => endTime.difference(startTime).inMinutes;

  CalendarBlock copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? startTime,
    DateTime? endTime,
    CalendarBlockType? type,
    bool? isCompleted,
  }) {
    return CalendarBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
