import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../services/storage_service.dart';

class GoalProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Goal> _goals = [];

  GoalProvider(this._storageService);

  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((goal) => !goal.isAchieved).toList();
  List<Goal> get achievedGoals => _goals.where((goal) => goal.isAchieved).toList();

  Future<void> loadGoals() async {
    final data = await _storageService.getGoals();
    if (data != null) {
      _goals = data
          .map((item) => Goal.fromJson(item as Map<String, dynamic>))
          .toList();
      notifyListeners();
    }
  }

  Future<void> addGoal(Goal goal) async {
    _goals.add(goal);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> updateGoal(Goal goal) async {
    final index = _goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      _goals[index] = goal;
      await _saveGoals();
      notifyListeners();
    }
  }

  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((goal) => goal.id == id);
    await _saveGoals();
    notifyListeners();
  }

  Future<void> toggleMilestone(String goalId, String milestone) async {
    final index = _goals.indexWhere((g) => g.id == goalId);
    if (index != -1) {
      final goal = _goals[index];
      List<String> completedMilestones = List.from(goal.completedMilestones);
      
      if (completedMilestones.contains(milestone)) {
        completedMilestones.remove(milestone);
      } else {
        completedMilestones.add(milestone);
      }

      _goals[index] = goal.copyWith(
        completedMilestones: completedMilestones,
        isAchieved: completedMilestones.length == goal.milestones.length,
        achievedAt: completedMilestones.length == goal.milestones.length 
          ? DateTime.now() 
          : null,
      );
      
      await _saveGoals();
      notifyListeners();
    }
  }

  Future<void> toggleAchievement(String id) async {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final goal = _goals[index];
      _goals[index] = goal.copyWith(
        isAchieved: !goal.isAchieved,
        achievedAt: !goal.isAchieved ? DateTime.now() : null,
      );
      await _saveGoals();
      notifyListeners();
    }
  }

  Future<void> _saveGoals() async {
    await _storageService.setGoals(
      _goals.map((goal) => goal.toJson()).toList(),
    );
  }
}
