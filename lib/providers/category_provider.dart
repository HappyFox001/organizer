import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/storage_service.dart';

class CategoryProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<Category> _categories = [];

  CategoryProvider(this._storageService);

  List<Category> get categories => _categories;

  Future<void> loadCategories() async {
    final data = await _storageService.getCategories();
    if (data != null) {
      _categories = data.map((item) => Category.fromJson(item)).toList();
      notifyListeners();
    }
  }

  Future<void> addCategory(Category category) async {
    _categories.add(category);
    await _saveCategories();
    notifyListeners();
  }

  Future<void> updateCategory(Category category) async {
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      await _saveCategories();
      notifyListeners();
    }
  }

  Future<void> deleteCategory(String id) async {
    _categories.removeWhere((category) => category.id == id);
    await _saveCategories();
    notifyListeners();
  }

  Future<void> _saveCategories() async {
    await _storageService.setCategories(
      _categories.map((category) => category.toJson()).toList(),
    );
  }
}
