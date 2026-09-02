class KnowledgeNote {
  final String id;
  final String title;
  final String contentMarkdown;
  final String category;
  final List<String> tags;
  final List<String> linkedEntities;
  final DateTime updatedAt;

  const KnowledgeNote({
    required this.id,
    required this.title,
    required this.contentMarkdown,
    required this.category,
    this.tags = const [],
    this.linkedEntities = const [],
    required this.updatedAt,
  });

  KnowledgeNote copyWith({
    String? id,
    String? title,
    String? contentMarkdown,
    String? category,
    List<String>? tags,
    List<String>? linkedEntities,
    DateTime? updatedAt,
  }) {
    return KnowledgeNote(
      id: id ?? this.id,
      title: title ?? this.title,
      contentMarkdown: contentMarkdown ?? this.contentMarkdown,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      linkedEntities: linkedEntities ?? this.linkedEntities,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
