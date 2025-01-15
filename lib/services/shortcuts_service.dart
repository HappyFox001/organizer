import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ShortcutsService {
  static final Map<ShortcutActivator, Intent> noteShortcuts = {
    // Create
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyN):
        const CreateNoteIntent(),

    // Save
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS):
        const SaveNoteIntent(),

    // Delete
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.delete):
        const DeleteNoteIntent(),

    // Search
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyF):
        const SearchIntent(),

    // Toggle view
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyV):
        const ToggleViewIntent(),

    // Archive
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE):
        const ArchiveNoteIntent(),

    // Pin/Unpin
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyP):
        const TogglePinIntent(),

    // Categories
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyL):
        const ChangeCategoryIntent(),

    // Sort
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyR):
        const ChangeSortIntent(),

    // Share
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyH):
        const ShareNoteIntent(),

    // Export
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyB):
        const ExportIntent(),

    // Import
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyI):
        const ImportIntent(),
  };
}

// Intents
class CreateNoteIntent extends Intent {
  const CreateNoteIntent();
}

class SaveNoteIntent extends Intent {
  const SaveNoteIntent();
}

class DeleteNoteIntent extends Intent {
  const DeleteNoteIntent();
}

class SearchIntent extends Intent {
  const SearchIntent();
}

class ToggleViewIntent extends Intent {
  const ToggleViewIntent();
}

class ArchiveNoteIntent extends Intent {
  const ArchiveNoteIntent();
}

class TogglePinIntent extends Intent {
  const TogglePinIntent();
}

class ChangeCategoryIntent extends Intent {
  const ChangeCategoryIntent();
}

class ChangeSortIntent extends Intent {
  const ChangeSortIntent();
}

class ShareNoteIntent extends Intent {
  const ShareNoteIntent();
}

class ExportIntent extends Intent {
  const ExportIntent();
}

class ImportIntent extends Intent {
  const ImportIntent();
}
