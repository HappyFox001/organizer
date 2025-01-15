
class Note {
  final String id;
  final String title;
  final String content;
  final List<String> tags;
  final String? category;
  final String? color;
  final bool isPinned;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<NoteHistory> history;

  Note({
    String? id,
    required this.title,
    required this.content,
    List<String>? tags,
    this.category,
    this.color,
    this.isPinned = false,
    this.isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<NoteHistory>? history,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        history = history ?? [];

  Note copyWith({
    String? title,
    String? content,
    List<String>? tags,
    String? category,
    String? color,
    bool? isPinned,
    bool? isArchived,
    DateTime? updatedAt,
    List<NoteHistory>? history,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      tags: tags ?? List.from(this.tags),
      category: category ?? this.category,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      history: history ?? List.from(this.history),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'tags': tags,
      'category': category,
      'color': color,
      'isPinned': isPinned,
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'history': history.map((h) => h.toJson()).toList(),
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      tags: (json['tags'] as List).cast<String>(),
      category: json['category'] as String?,
      color: json['color'] as String?,
      isPinned: json['isPinned'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      history: (json['history'] as List?)
              ?.map((h) => NoteHistory.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Note addHistory() {
    final newHistory = List<NoteHistory>.from(history)
      ..add(NoteHistory(
        title: title,
        content: content,
        tags: tags,
        category: category,
        color: color,
        timestamp: DateTime.now(),
      ));
    return copyWith(history: newHistory);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content;

  @override
  int get hashCode => id.hashCode ^ title.hashCode ^ content.hashCode;
}

class NoteHistory {
  final String title;
  final String content;
  final List<String> tags;
  final String? category;
  final String? color;
  final DateTime timestamp;

  NoteHistory({
    required this.title,
    required this.content,
    required this.tags,
    this.category,
    this.color,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'tags': tags,
      'category': category,
      'color': color,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NoteHistory.fromJson(Map<String, dynamic> json) {
    return NoteHistory(
      title: json['title'] as String,
      content: json['content'] as String,
      tags: (json['tags'] as List).cast<String>(),
      category: json['category'] as String?,
      color: json['color'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
