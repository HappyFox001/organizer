class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String category;
  final String priority;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<String> tags;
  final double progress;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    required this.priority,
    this.isCompleted = false,
    this.completedAt,
    this.tags = const [],
    this.progress = 0.0,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    String? priority,
    bool? isCompleted,
    DateTime? completedAt,
    List<String>? tags,
    double? progress,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      progress: progress ?? this.progress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'category': category,
      'priority': priority,
      'isCompleted': isCompleted,
      'completedAt': completedAt?.toIso8601String(),
      'tags': tags,
      'progress': progress,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['dueDate']),
      category: json['category'],
      priority: json['priority'],
      isCompleted: json['isCompleted'] ?? false,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : [],
      progress: json['progress']?.toDouble() ?? 0.0,
    );
  }
}
