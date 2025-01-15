class Goal {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime targetDate;
  final bool isAchieved;
  final DateTime? achievedAt;
  final List<String> milestones;
  final List<String> completedMilestones;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.targetDate,
    this.isAchieved = false,
    this.achievedAt,
    this.milestones = const [],
    this.completedMilestones = const [],
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? targetDate,
    bool? isAchieved,
    DateTime? achievedAt,
    List<String>? milestones,
    List<String>? completedMilestones,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      targetDate: targetDate ?? this.targetDate,
      isAchieved: isAchieved ?? this.isAchieved,
      achievedAt: achievedAt ?? this.achievedAt,
      milestones: milestones ?? this.milestones,
      completedMilestones: completedMilestones ?? this.completedMilestones,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'targetDate': targetDate.toIso8601String(),
      'isAchieved': isAchieved,
      'achievedAt': achievedAt?.toIso8601String(),
      'milestones': milestones,
      'completedMilestones': completedMilestones,
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      targetDate: DateTime.parse(json['targetDate']),
      isAchieved: json['isAchieved'] ?? false,
      achievedAt: json['achievedAt'] != null ? DateTime.parse(json['achievedAt']) : null,
      milestones: List<String>.from(json['milestones'] ?? []),
      completedMilestones: List<String>.from(json['completedMilestones'] ?? []),
    );
  }
}
