import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/note.dart';

class StorageService {
  static const String _tasksKey = 'tasks';
  static const String _notesKey = 'notes';
  static const String _categoriesKey = 'categories';
  static const String _goalsKey = 'goals';
  static const String _profileKey = 'profile';
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Tasks
  Future<List<Task>> loadTasks() async {
    final tasksJson = _prefs.getStringList(_tasksKey) ?? [];
    return tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
  }

  Future<void> saveTasks(List<Task> tasks) async {
    final tasksJson = tasks.map((task) => jsonEncode(task.toJson())).toList();
    await _prefs.setStringList(_tasksKey, tasksJson);
  }

  // Notes
  Future<List<Note>> loadNotes() async {
    final notesJson = _prefs.getStringList(_notesKey) ?? [];
    return notesJson.map((json) => Note.fromJson(jsonDecode(json))).toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final notesJson = notes.map((note) => jsonEncode(note.toJson())).toList();
    await _prefs.setStringList(_notesKey, notesJson);
  }

  // Categories
  Future<List<dynamic>?> getCategories() async {
    final categoriesJson = _prefs.getStringList(_categoriesKey) ?? [];
    return categoriesJson.map((json) => jsonDecode(json)).toList();
  }

  Future<void> setCategories(List<dynamic> categories) async {
    final categoriesJson =
        categories.map((category) => jsonEncode(category)).toList();
    await _prefs.setStringList(_categoriesKey, categoriesJson);
  }

  // Goals
  Future<List<dynamic>?> getGoals() async {
    final goalsJson = _prefs.getString(_goalsKey);
    if (goalsJson == null) return null;
    return jsonDecode(goalsJson) as List<dynamic>;
  }

  Future<void> setGoals(List<dynamic> goals) async {
    await _prefs.setString(_goalsKey, jsonEncode(goals));
  }

  // Profile
  Future<void> setProfile(Map<String, dynamic> profile) async {
    await _prefs.setString(_profileKey, jsonEncode(profile));
  }

  Future<Map<String, dynamic>?> getProfile() async {
    final profileJson = _prefs.getString(_profileKey);
    if (profileJson != null) {
      return jsonDecode(profileJson);
    }
    return null;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Backup and Restore
  Future<String> exportData() async {
    final data = {
      'tasks': _prefs.getStringList(_tasksKey) ?? [],
      'notes': _prefs.getStringList(_notesKey) ?? [],
      'categories': _prefs.getStringList(_categoriesKey),
      'goals': _prefs.getString(_goalsKey),
      'profile': _prefs.getString(_profileKey),
    };
    return jsonEncode(data);
  }

  Future<void> importData(String jsonData) async {
    final data = jsonDecode(jsonData);
    await _prefs.setStringList(_tasksKey, List<String>.from(data['tasks']));
    await _prefs.setStringList(_notesKey, List<String>.from(data['notes']));
    if (data['categories'] != null) {
      await _prefs.setStringList(
          _categoriesKey, List<String>.from(data['categories']));
    }
    if (data['goals'] != null) {
      await _prefs.setString(_goalsKey, data['goals']);
    }
    if (data['profile'] != null) {
      await _prefs.setString(_profileKey, data['profile']);
    }
  }
}
