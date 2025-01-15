import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/profile.dart';
import 'task_provider.dart';
import 'note_provider.dart';
import 'category_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';

class ProfileProvider with ChangeNotifier {
  Profile _profile = Profile.empty();
  Profile get profile => _profile;
  final _uuid = const Uuid();
  static const String _profileKey = 'user_profile';
  final StorageService _storageService;

  ProfileProvider(this._storageService) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      // Try to load from storage service first
      final profileMap = await _storageService.getProfile();
      if (profileMap != null) {
        _profile = Profile(
          name: profileMap['name'] ?? '',
          bio: profileMap['bio'] ?? '',
          avatarUrl: profileMap['avatarUrl'],
          githubUrl: profileMap['githubUrl'],
          webUrl: profileMap['webUrl'],
          wechatUrl: profileMap['wechatUrl'],
          statistics: Map<String, int>.from(profileMap['statistics'] ?? {}),
          pinnedCategories:
              List<String>.from(profileMap['pinnedCategories'] ?? []),
          recentActivity: (profileMap['recentActivity'] as List? ?? [])
              .map((e) => ActivityEntry(
                    timestamp: DateTime.parse(e['timestamp']),
                    action: e['action'],
                    description: e['description'],
                    category: e['category'],
                  ))
              .toList(),
        );
        notifyListeners();
        return;
      }

      // Fallback to SharedPreferences if storage service has no data
      final prefs = await SharedPreferences.getInstance();
      final String? profileJson = prefs.getString(_profileKey);
      if (profileJson != null) {
        final Map<String, dynamic> profileMap = json.decode(profileJson);
        _profile = Profile(
          name: profileMap['name'] ?? '',
          bio: profileMap['bio'] ?? '',
          avatarUrl: profileMap['avatarUrl'],
          githubUrl: profileMap['githubUrl'],
          webUrl: profileMap['webUrl'],
          wechatUrl: profileMap['wechatUrl'],
          statistics: Map<String, int>.from(profileMap['statistics'] ?? {}),
          pinnedCategories:
              List<String>.from(profileMap['pinnedCategories'] ?? []),
          recentActivity: (profileMap['recentActivity'] as List? ?? [])
              .map((e) => ActivityEntry(
                    timestamp: DateTime.parse(e['timestamp']),
                    action: e['action'],
                    description: e['description'],
                    category: e['category'],
                  ))
              .toList(),
        );
        notifyListeners();

        // Save to storage service for future use
        await _storageService.setProfile(profileMap);
      }
    } catch (e) {
      print('Error loading profile: $e');
    }
  }

  Future<void> _saveProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileMap = {
        'name': _profile.name,
        'bio': _profile.bio,
        'avatarUrl': _profile.avatarUrl,
        'githubUrl': _profile.githubUrl,
        'webUrl': _profile.webUrl,
        'wechatUrl': _profile.wechatUrl,
        'statistics': _profile.statistics,
        'pinnedCategories': _profile.pinnedCategories,
        'recentActivity': _profile.recentActivity
            .map((e) => {
                  'timestamp': e.timestamp.toIso8601String(),
                  'action': e.action,
                  'description': e.description,
                  'category': e.category,
                })
            .toList(),
      };
      await prefs.setString(_profileKey, json.encode(profileMap));
      // Also save to storage service for backup
      await _storageService.setProfile(profileMap);
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  void syncStatistics({
    required TaskProvider taskProvider,
    required NoteProvider noteProvider,
    required CategoryProvider categoryProvider,
  }) {
    final statistics = {
      'Tasks': taskProvider.tasks.length,
      'Completed': taskProvider.tasks.where((task) => task.isCompleted).length,
      'Categories': categoryProvider.categories.length,
      'Notes': noteProvider.notes.length,
    };
    updateStatistics(statistics);
  }

  Future<String?> saveProfileImage(File imageFile) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final profileImagesDir = Directory('${directory.path}/profile_images');
      if (!await profileImagesDir.exists()) {
        await profileImagesDir.create(recursive: true);
      }

      final filename = '${_uuid.v4()}${path.extension(imageFile.path)}';
      final savedImage =
          await imageFile.copy('${profileImagesDir.path}/$filename');

      return savedImage.path;
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteProfileImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      // Handle error if needed
    }
  }

  void updateProfile({
    required String name,
    required String bio,
    String? avatarUrl,
    String? githubUrl,
    String? webUrl,
    String? wechatUrl,
  }) {
    if (avatarUrl != null && _profile.avatarUrl != null) {
      if (_profile.avatarUrl!.startsWith('/')) {
        deleteProfileImage(_profile.avatarUrl!);
      }
    }

    _profile = Profile(
      name: name,
      bio: bio,
      avatarUrl: avatarUrl,
      githubUrl: githubUrl,
      webUrl: webUrl,
      wechatUrl: wechatUrl,
      statistics: _profile.statistics,
      pinnedCategories: _profile.pinnedCategories,
      recentActivity: _profile.recentActivity,
    );
    notifyListeners();
    _saveProfile();
  }

  void updateStatistics(Map<String, int> statistics) {
    _profile = Profile(
      name: _profile.name,
      bio: _profile.bio,
      avatarUrl: _profile.avatarUrl,
      githubUrl: _profile.githubUrl,
      webUrl: _profile.webUrl,
      wechatUrl: _profile.wechatUrl,
      statistics: statistics,
      pinnedCategories: _profile.pinnedCategories,
      recentActivity: _profile.recentActivity,
    );
    notifyListeners();
    _saveProfile();
  }

  void setPinnedCategories(List<String> categories) {
    _profile = Profile(
      name: _profile.name,
      bio: _profile.bio,
      avatarUrl: _profile.avatarUrl,
      githubUrl: _profile.githubUrl,
      webUrl: _profile.webUrl,
      wechatUrl: _profile.wechatUrl,
      statistics: _profile.statistics,
      pinnedCategories: categories,
      recentActivity: _profile.recentActivity,
    );
    notifyListeners();
    _saveProfile();
  }

  void addActivity(ActivityEntry entry) {
    final updatedActivity = [entry, ..._profile.recentActivity];
    if (updatedActivity.length > 30) {
      updatedActivity.removeLast();
    }

    _profile = Profile(
      name: _profile.name,
      bio: _profile.bio,
      avatarUrl: _profile.avatarUrl,
      githubUrl: _profile.githubUrl,
      webUrl: _profile.webUrl,
      wechatUrl: _profile.wechatUrl,
      statistics: _profile.statistics,
      pinnedCategories: _profile.pinnedCategories,
      recentActivity: updatedActivity,
    );
    notifyListeners();
    _saveProfile();
  }

  void clearActivity() {
    _profile = Profile(
      name: _profile.name,
      bio: _profile.bio,
      avatarUrl: _profile.avatarUrl,
      githubUrl: _profile.githubUrl,
      webUrl: _profile.webUrl,
      wechatUrl: _profile.wechatUrl,
      statistics: _profile.statistics,
      pinnedCategories: _profile.pinnedCategories,
      recentActivity: [],
    );
    notifyListeners();
    _saveProfile();
  }

  void resetProfile() {
    if (_profile.avatarUrl != null && _profile.avatarUrl!.startsWith('/')) {
      deleteProfileImage(_profile.avatarUrl!);
    }
    _profile = Profile.empty();
    notifyListeners();
    _saveProfile();
  }

  void removePinnedCategory(String category) {
    final updatedCategories = List<String>.from(_profile.pinnedCategories)
      ..remove(category);

    _profile = Profile(
      name: _profile.name,
      bio: _profile.bio,
      avatarUrl: _profile.avatarUrl,
      githubUrl: _profile.githubUrl,
      webUrl: _profile.webUrl,
      wechatUrl: _profile.wechatUrl,
      statistics: _profile.statistics,
      pinnedCategories: updatedCategories,
      recentActivity: _profile.recentActivity,
    );
    notifyListeners();
    _saveProfile();
  }
}
