import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskProvider with ChangeNotifier {
  final StorageService _storage;
  List<Task> _tasks = [];
  bool _initialized = false;

  TaskProvider(this._storage);

  List<Task> get tasks => List.unmodifiable(_tasks);
  bool get isInitialized => _initialized;

  Future<void> loadTasks() async {
    if (!_initialized) {
      _tasks = await _storage.loadTasks();
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      await _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await _storage.saveTasks(_tasks);
    notifyListeners();
  }

  List<Task> filterTasks({String? tag, bool? showCompleted}) {
    return _tasks.where((task) {
      if (showCompleted != null && !showCompleted && task.isCompleted) {
        return false;
      }
      if (tag != null && tag.isNotEmpty && !task.tags.contains(tag)) {
        return false;
      }
      return true;
    }).toList();
  }

  Set<String> getAllTags() {
    return _tasks.expand((task) => task.tags).toSet();
  }
}
