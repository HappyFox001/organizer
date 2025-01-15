import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/storage_service.dart';

enum NoteSortBy {
  title,
  createdAt,
  updatedAt,
  category,
}

enum SortOrder {
  ascending,
  descending,
}

class NoteProvider with ChangeNotifier {
  final StorageService _storageService;
  List<Note> _notes = [];
  NoteSortBy _sortBy = NoteSortBy.updatedAt;
  SortOrder _sortOrder = SortOrder.descending;
  Set<String> _categories = {};

  NoteProvider(this._storageService);

  List<Note> get notes => _getSortedNotes();
  List<Note> get pinnedNotes => _notes.where((note) => note.isPinned).toList();
  List<Note> get archivedNotes =>
      _notes.where((note) => note.isArchived).toList();
  Set<String> get categories => _categories;
  NoteSortBy get sortBy => _sortBy;
  SortOrder get sortOrder => _sortOrder;

  Future<void> loadNotes() async {
    _notes = await _storageService.loadNotes();
    _updateCategories();
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    _notes.add(note);
    await _saveNotes();
    _updateCategories();
    notifyListeners();
  }

  Future<void> updateNote(Note updatedNote) async {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      // Add current state to history before updating
      final noteWithHistory = _notes[index].addHistory();
      _notes[index] = updatedNote.copyWith(
        history: noteWithHistory.history,
        updatedAt: DateTime.now(),
      );
      await _saveNotes();
      _updateCategories();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((note) => note.id == id);
    await _saveNotes();
    _updateCategories();
    notifyListeners();
  }

  Future<void> togglePinned(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(isPinned: !_notes[index].isPinned);
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> toggleArchived(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] =
          _notes[index].copyWith(isArchived: !_notes[index].isArchived);
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> setNoteColor(String id, String? color) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(color: color);
      await _saveNotes();
      notifyListeners();
    }
  }

  Future<void> setCategory(String id, String? category) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      _notes[index] = _notes[index].copyWith(category: category);
      await _saveNotes();
      _updateCategories();
      notifyListeners();
    }
  }

  void setSortBy(NoteSortBy sortBy) {
    _sortBy = sortBy;
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (final note in _notes) {
      tags.addAll(note.tags);
    }
    return tags.toList()..sort();
  }

  List<Note> filterNotes({
    String? tag,
    String? searchQuery,
    String? category,
    bool includeArchived = false,
  }) {
    return _getSortedNotes().where((note) {
      if (!includeArchived && note.isArchived) return false;
      if (tag != null && tag.isNotEmpty && !note.tags.contains(tag)) {
        return false;
      }
      if (category != null &&
          category.isNotEmpty &&
          note.category != category) {
        return false;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query));
      }
      return true;
    }).toList();
  }

  List<Note> getNotes({
    String? searchQuery,
    String? filterTag,
    String? filterCategory,
    bool showArchived = false,
  }) {
    return _notes.where((note) {
      if (!showArchived && note.isArchived) return false;
      if (showArchived && !note.isArchived) return false;

      if (filterCategory != null &&
          filterCategory.isNotEmpty &&
          note.category != filterCategory) {
        return false;
      }

      if (filterTag != null &&
          filterTag.isNotEmpty &&
          !note.tags.contains(filterTag)) {
        return false;
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return note.title.toLowerCase().contains(query) ||
            note.content.toLowerCase().contains(query) ||
            note.tags.any((tag) => tag.toLowerCase().contains(query));
      }

      return true;
    }).toList();
  }

  List<Note> _getSortedNotes() {
    final sortedNotes = List<Note>.from(_notes);
    sortedNotes.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }

      int comparison;
      switch (_sortBy) {
        case NoteSortBy.title:
          comparison = a.title.compareTo(b.title);
          break;
        case NoteSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case NoteSortBy.updatedAt:
          comparison = a.updatedAt.compareTo(b.updatedAt);
          break;
        case NoteSortBy.category:
          comparison = (a.category ?? '').compareTo(b.category ?? '');
          break;
      }

      return _sortOrder == SortOrder.ascending ? comparison : -comparison;
    });

    return sortedNotes;
  }

  void _updateCategories() {
    _categories =
        _notes.map((note) => note.category).whereType<String>().toSet();
  }

  Future<void> _saveNotes() async {
    await _storageService.saveNotes(_notes);
  }

  Future<void> restoreNoteVersion(String noteId, int versionIndex) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1 && versionIndex < _notes[index].history.length) {
      final oldVersion = _notes[index].history[versionIndex];
      final updatedNote = _notes[index].copyWith(
        title: oldVersion.title,
        content: oldVersion.content,
        tags: oldVersion.tags,
        updatedAt: DateTime.now(),
      );
      await updateNote(updatedNote);
    }
  }

  Future<void> shareNote(String id) async {
    // TODO: Implement sharing functionality
  }

  Future<String> exportData() async {
    final data = {
      'notes': _notes.map((note) => note.toJson()).toList(),
      'categories': _categories.toList(),
    };
    return jsonEncode(data);
  }

  Future<void> importData(String jsonData) async {
    final data = jsonDecode(jsonData) as Map<String, dynamic>;

    _notes.clear();
    _categories.clear();

    if (data.containsKey('notes')) {
      final notesList = data['notes'] as List;
      for (final noteData in notesList) {
        final note = Note.fromJson(noteData as Map<String, dynamic>);
        _notes.add(note);
      }
    }

    if (data.containsKey('categories')) {
      final categoriesList = data['categories'] as List;
      _categories.addAll(categoriesList.cast<String>());
    }

    notifyListeners();
  }

  Future<void> clearAll() async {
    _notes.clear();
    _categories.clear();
    await _saveNotes();
    notifyListeners();
  }
}
