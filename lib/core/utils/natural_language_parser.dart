import '../../domain/models/task.dart';

class ParsedTaskResult {
  final String title;
  final TaskPriority priority;
  final CognitiveTier cognitiveTier;
  final int estimatedMinutes;
  final int estimatedPomodoros;
  final DateTime? dueDate;
  final String? projectTag;

  const ParsedTaskResult({
    required this.title,
    this.priority = TaskPriority.p1,
    this.cognitiveTier = CognitiveTier.medium2x,
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
    TaskPriority priority = TaskPriority.p1;
    CognitiveTier cognitiveTier = CognitiveTier.medium2x;
    int estimatedMinutes = 45;
    DateTime? dueDate;
    String? projectTag;

    // 1. Priority parsing: !p0, !p1, !p2, !urgent
    if (RegExp(r'!p0|!urgent', caseSensitive: false).hasMatch(working)) {
      priority = TaskPriority.p0;
      working = working.replaceAll(RegExp(r'!p0|!urgent', caseSensitive: false), '');
    } else if (RegExp(r'!p1|!high', caseSensitive: false).hasMatch(working)) {
      priority = TaskPriority.p1;
      working = working.replaceAll(RegExp(r'!p1|!high', caseSensitive: false), '');
    } else if (RegExp(r'!p2|!low', caseSensitive: false).hasMatch(working)) {
      priority = TaskPriority.p2;
      working = working.replaceAll(RegExp(r'!p2|!low', caseSensitive: false), '');
    }

    // 2. Cognitive Tier parsing: @deep, @deep3x, @medium, @shallow
    if (RegExp(r'@deep3x|@deep', caseSensitive: false).hasMatch(working)) {
      cognitiveTier = CognitiveTier.deep3x;
      working = working.replaceAll(RegExp(r'@deep3x|@deep', caseSensitive: false), '');
    } else if (RegExp(r'@medium2x|@medium', caseSensitive: false).hasMatch(working)) {
      cognitiveTier = CognitiveTier.medium2x;
      working = working.replaceAll(RegExp(r'@medium2x|@medium', caseSensitive: false), '');
    } else if (RegExp(r'@shallow1x|@shallow', caseSensitive: false).hasMatch(working)) {
      cognitiveTier = CognitiveTier.shallow1x;
      working = working.replaceAll(RegExp(r'@shallow1x|@shallow', caseSensitive: false), '');
    }

    // 3. Duration parsing: ~45m, ~60m, ~1h, ~2h, ~90min
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

    // 4. Project Tag parsing: #dsa, #career, #project, #health
    final tagMatch = RegExp(r'#(\w+)').firstMatch(working);
    if (tagMatch != null) {
      projectTag = tagMatch.group(1);
      working = working.replaceFirst(tagMatch.group(0)!, '');
    }

    // 5. Date parsing: today, tomorrow, monday, friday
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
      cognitiveTier: cognitiveTier,
      estimatedMinutes: estimatedMinutes,
      estimatedPomodoros: estimatedPomodoros,
      dueDate: dueDate,
      projectTag: projectTag,
    );
  }
}
