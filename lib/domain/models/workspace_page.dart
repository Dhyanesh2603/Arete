enum PageBlockType {
  paragraph,
  heading1,
  heading2,
  todoItem,
  codeBlock,
  callout,
  toggle,
  divider,
}

class PageBlock {
  final String id;
  final PageBlockType type;
  final String content;
  final bool isChecked;
  final bool isExpanded;
  final String? language;
  final String? calloutType; // info, tip, warning

  const PageBlock({
    required this.id,
    required this.type,
    this.content = '',
    this.isChecked = false,
    this.isExpanded = true,
    this.language,
    this.calloutType,
  });

  PageBlock copyWith({
    String? id,
    PageBlockType? type,
    String? content,
    bool? isChecked,
    bool? isExpanded,
    String? language,
    String? calloutType,
  }) {
    return PageBlock(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      isChecked: isChecked ?? this.isChecked,
      isExpanded: isExpanded ?? this.isExpanded,
      language: language ?? this.language,
      calloutType: calloutType ?? this.calloutType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'isChecked': isChecked,
      'isExpanded': isExpanded,
      'language': language,
      'calloutType': calloutType,
    };
  }

  factory PageBlock.fromJson(Map<String, dynamic> json) {
    return PageBlock(
      id: json['id'] as String? ?? UniqueKeyString.generate(),
      type: PageBlockType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PageBlockType.paragraph,
      ),
      content: json['content'] as String? ?? '',
      isChecked: json['isChecked'] as bool? ?? false,
      isExpanded: json['isExpanded'] as bool? ?? true,
      language: json['language'] as String?,
      calloutType: json['calloutType'] as String?,
    );
  }
}

class WorkspacePage {
  final String id;
  final String? parentId;
  final String title;
  final String icon;
  final String? coverGradient;
  final List<PageBlock> blocks;
  final bool isPinned;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  const WorkspacePage({
    required this.id,
    this.parentId,
    required this.title,
    this.icon = 'article',
    this.coverGradient,
    this.blocks = const [],
    this.isPinned = false,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  WorkspacePage copyWith({
    String? id,
    String? parentId,
    bool clearParent = false,
    String? title,
    String? icon,
    String? coverGradient,
    bool clearCover = false,
    List<PageBlock>? blocks,
    bool? isPinned,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkspacePage(
      id: id ?? this.id,
      parentId: clearParent ? null : (parentId ?? this.parentId),
      title: title ?? this.title,
      icon: icon ?? this.icon,
      coverGradient: clearCover ? null : (coverGradient ?? this.coverGradient),
      blocks: blocks ?? this.blocks,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentId': parentId,
      'title': title,
      'icon': icon,
      'coverGradient': coverGradient,
      'blocks': blocks.map((b) => b.toJson()).toList(),
      'isPinned': isPinned,
      'isFavorite': isFavorite,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory WorkspacePage.fromJson(Map<String, dynamic> json) {
    return WorkspacePage(
      id: json['id'] as String,
      parentId: json['parentId'] as String?,
      title: json['title'] as String? ?? 'Untitled Page',
      icon: json['icon'] as String? ?? 'article',
      coverGradient: json['coverGradient'] as String?,
      blocks: (json['blocks'] as List<dynamic>?)
              ?.map((b) => PageBlock.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      isPinned: json['isPinned'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class UniqueKeyString {
  static int _counter = 0;
  static String generate() {
    _counter++;
    return '${DateTime.now().millisecondsSinceEpoch}_$_counter';
  }
}
