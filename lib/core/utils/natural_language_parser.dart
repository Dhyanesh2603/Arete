import '../../domain/models/task.dart';

class ParsedTaskResult {
  final String title;
  final TaskPriority priority;
  final int estimatedMinutes;
  final int estimatedPomodoros;
  final DateTime? dueDate;
  final String? projectTag;

  const ParsedTaskResult({
    required this.title,
    this.priority = TaskPriority.medium,
    this.estimatedMinutes = 45,
    this.estimatedPomodoros = 1,
    this.dueDate,
    this.projectTag,
  });
}

class NaturalLanguageTaskParser {
  static ParsedTaskResult parse(String input) {
    if (input.trim().isEmpty) {
      return const ParsedTaskResult(title: 'Untitled Task');
    }

    String working = input.trim();
    TaskPriority priority = TaskPriority.medium;
    int estimatedMinutes = 45;
    DateTime? dueDate;
    String? projectTag;

    // 1. Priority parsing: !high, !p0, !urgent -> High (Red)
    //                      !med, !medium, !p1 -> Medium (Yellow)
    //                      !low, !p2 -> Low (Green)
    if (RegExp(r'!high|!p0|!urgent', caseSensitive: false).hasMatch(working)) {
      priority = TaskPriority.high;
      working = working.replaceAll(RegExp(r'!high|!p0|!urgent', caseSensitive: false), '');
    } else if (RegExp(r'!low|!p2', caseSensitive: false).hasMatch(working)) {
      priority = TaskPriority.low;
      working = working.replaceAll(RegExp(r'!low|!p2', caseSensitive: false), '');
    } else if (RegExp(r'!med|!medium|!p1', caseSensitive: false).hasMatch(working)) {
      priority = TaskPriority.medium;
      working = working.replaceAll(RegExp(r'!med|!medium|!p1', caseSensitive: false), '');
    }

    // 2. Duration parsing: ~45m, ~60m, ~1h, ~2h, ~90min
    final durationMatch = RegExp(r'~(\d+)(m|min|h|hr)?', caseSensitive: false).firstMatch(working);
    if (durationMatch != null) {
      final value = int.tryParse(durationMatch.group(1) ?? '45') ?? 45;
      final unit = durationMatch.group(2)?.toLowerCase();
      if (unit == 'h' || unit == 'hr') {
        estimatedMinutes = value * 60;
      } else {
        estimatedMinutes = value;
      }
      working = working.replaceFirst(durationMatch.group(0)!, '');
    }

    // 3. Project Tag parsing: #dsa, #career, #project, #health
    final tagMatch = RegExp(r'#(\w+)').firstMatch(working);
    if (tagMatch != null) {
      projectTag = tagMatch.group(1);
      working = working.replaceFirst(tagMatch.group(0)!, '');
    }

    // 4. Date parsing: today, tomorrow, next week
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (RegExp(r'\btoday\b', caseSensitive: false).hasMatch(working)) {
      dueDate = today;
      working = working.replaceAll(RegExp(r'\btoday\b', caseSensitive: false), '');
    } else if (RegExp(r'\btomorrow\b', caseSensitive: false).hasMatch(working)) {
      dueDate = today.add(const Duration(days: 1));
      working = working.replaceAll(RegExp(r'\btomorrow\b', caseSensitive: false), '');
    } else if (RegExp(r'\bnext week\b', caseSensitive: false).hasMatch(working)) {
      dueDate = today.add(const Duration(days: 7));
      working = working.replaceAll(RegExp(r'\bnext week\b', caseSensitive: false), '');
    }

    // Clean up extra spaces
    String cleanedTitle = working.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanedTitle.isEmpty) {
      cleanedTitle = 'New Captured Task';
    }

    final estimatedPomodoros = (estimatedMinutes / 25).ceil().clamp(1, 10);

    return ParsedTaskResult(
      title: cleanedTitle,
      priority: priority,
      estimatedMinutes: estimatedMinutes,
      estimatedPomodoros: estimatedPomodoros,
      dueDate: dueDate,
      projectTag: projectTag,
    );
  }
}
