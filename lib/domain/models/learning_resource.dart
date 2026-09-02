enum ResourceType { book, course, researchPaper, documentation }

class LearningResource {
  final String id;
  final String title;
  final String authorOrPlatform;
  final ResourceType type;
  final int totalUnits;
  final int completedUnits;
  final String keyTakeaways;
  final String? externalUrl;

  const LearningResource({
    required this.id,
    required this.title,
    required this.authorOrPlatform,
    required this.type,
    required this.totalUnits,
    this.completedUnits = 0,
    this.keyTakeaways = '',
    this.externalUrl,
  });

  double get progressPercentage =>
      totalUnits == 0 ? 0.0 : (completedUnits / totalUnits) * 100.0;

  LearningResource copyWith({
    String? id,
    String? title,
    String? authorOrPlatform,
    ResourceType? type,
    int? totalUnits,
    int? completedUnits,
    String? keyTakeaways,
    String? externalUrl,
  }) {
    return LearningResource(
      id: id ?? this.id,
      title: title ?? this.title,
      authorOrPlatform: authorOrPlatform ?? this.authorOrPlatform,
      type: type ?? this.type,
      totalUnits: totalUnits ?? this.totalUnits,
      completedUnits: completedUnits ?? this.completedUnits,
      keyTakeaways: keyTakeaways ?? this.keyTakeaways,
      externalUrl: externalUrl ?? this.externalUrl,
    );
  }
}
