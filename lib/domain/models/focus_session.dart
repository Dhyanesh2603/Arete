enum AcousticPreset {
  binaural40Hz,
  brownNoise,
  obsidianRain,
  terminalHum,
  silent,
}

class FocusSession {
  final String id;
  final String taskTitle;
  final int durationSeconds;
  final AcousticPreset acousticPreset;
  final double focusQualityScore;
  final DateTime startedAt;
  final DateTime endedAt;

  const FocusSession({
    required this.id,
    required this.taskTitle,
    required this.durationSeconds,
    this.acousticPreset = AcousticPreset.binaural40Hz,
    this.focusQualityScore = 9.5,
    required this.startedAt,
    required this.endedAt,
  });
}
