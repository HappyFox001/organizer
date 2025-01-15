class Profile {
  final String name;
  final String bio;
  final String? avatarUrl;
  final String? githubUrl; // Add GitHub URL
  final String? webUrl; // Add Web URL
  final String? wechatUrl;
  final Map<String, int> statistics;
  final List<String> pinnedCategories;
  final List<ActivityEntry> recentActivity;

  Profile({
    required this.name,
    required this.bio,
    this.avatarUrl,
    this.githubUrl,
    this.webUrl,
    this.wechatUrl,
    required this.statistics,
    required this.pinnedCategories,
    required this.recentActivity,
  });

  factory Profile.empty() {
    return Profile(
      name: '',
      bio: '',
      statistics: {
        'Tasks': 0,
        'Completed': 0,
        'Categories': 0,
        'Notes': 0,
      },
      pinnedCategories: [],
      recentActivity: [],
      githubUrl: null,
      webUrl: null,
      wechatUrl: null,
    );
  }
}

class ActivityEntry {
  final DateTime timestamp;
  final String action;
  final String description;
  final String? category;

  ActivityEntry({
    required this.timestamp,
    required this.action,
    required this.description,
    this.category,
  });
}
