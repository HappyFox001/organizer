import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:organizer/providers/theme_provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart'
    show NoteProvider, NoteSortBy, SortOrder;
import '../services/file_service.dart';
import 'note_edit_page.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final String _filterTag = '';
  String _searchQuery = '';
  String? _selectedCategory;
  bool _isListView = false;
  bool _showArchived = false;
  String _filterCategory = '';
  final TextEditingController _searchController = TextEditingController();
  final FileService _fileService = FileService();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addNote() async {
    final note = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (context) => const NoteEditPage()),
    );
    if (note != null) {
      if (!mounted) return;
      Provider.of<NoteProvider>(context, listen: false).addNote(note);
    }
  }

  Future<void> _editNote(Note note) async {
    final editedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (context) => NoteEditPage(note: note)),
    );
    if (editedNote != null) {
      if (!mounted) return;
      Provider.of<NoteProvider>(context, listen: false).updateNote(editedNote);
    }
  }

  void _deleteNote(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<NoteProvider>(context, listen: false)
                  .deleteNote(note.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Notes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<NoteSortBy>(
              title: const Text('Title'),
              value: NoteSortBy.title,
              groupValue: noteProvider.sortBy,
              onChanged: (value) {
                noteProvider.setSortBy(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<NoteSortBy>(
              title: const Text('Created Date'),
              value: NoteSortBy.createdAt,
              groupValue: noteProvider.sortBy,
              onChanged: (value) {
                noteProvider.setSortBy(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<NoteSortBy>(
              title: const Text('Updated Date'),
              value: NoteSortBy.updatedAt,
              groupValue: noteProvider.sortBy,
              onChanged: (value) {
                noteProvider.setSortBy(value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<NoteSortBy>(
              title: const Text('Category'),
              value: NoteSortBy.category,
              groupValue: noteProvider.sortBy,
              onChanged: (value) {
                noteProvider.setSortBy(value!);
                Navigator.pop(context);
              },
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Ascending Order'),
              value: noteProvider.sortOrder == SortOrder.ascending,
              onChanged: (value) {
                noteProvider.setSortOrder(
                  value ? SortOrder.ascending : SortOrder.descending,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Notes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show Archived Notes'),
              value: _showArchived,
              onChanged: (value) {
                setState(() {
                  _showArchived = value ?? false;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('Filter by Category:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterCategory.isEmpty,
                  onSelected: (selected) {
                    setState(() {
                      _filterCategory = '';
                    });
                    Navigator.pop(context);
                  },
                ),
                ...noteProvider.categories
                    .map((category) => FilterChip(
                          label: Text(category),
                          selected: _filterCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              _filterCategory = selected ? category : '';
                            });
                            Navigator.pop(context);
                          },
                        ))
                    .toList(),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final noteProvider = Provider.of<NoteProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.backup),
              title: const Text('Export Notes'),
              onTap: () async {
                final data = await noteProvider.exportData();
                await _fileService.exportToFile(data, 'notes_backup.json');
                if (!mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notes exported successfully')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('Import Notes'),
              onTap: () async {
                final data = await _fileService.importFromFile();
                if (data != null) {
                  await noteProvider.importData(data);
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Notes imported successfully')),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive),
              title: Text(_showArchived ? 'Hide Archived' : 'Show Archived'),
              onTap: () {
                setState(() {
                  _showArchived = !_showArchived;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sort Notes'),
              onTap: () {
                Navigator.pop(context);
                _showSortDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_forever),
              title: const Text('Clear All Notes'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Notes'),
                    content: const Text(
                      'Are you sure you want to delete all notes? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await noteProvider.clearAll();
                          if (!mounted) return;
                          Navigator.pop(context);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All notes cleared successfully'),
                            ),
                          );
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        final notes = noteProvider.getNotes(
          searchQuery: _searchQuery,
          filterTag: _filterTag,
          filterCategory: _filterCategory,
          showArchived: _showArchived,
        );

        return Scaffold(
          drawer: Drawer(
            child: Column(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primaryContainer,
                        Theme.of(context).colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(24),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white70,
                          child: Icon(Icons.note_alt_outlined, size: 32),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Notes',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Organize your thoughts',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.8),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Material(
                    color: Theme.of(context).colorScheme.surface,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        const SizedBox(height: 8),
                        ListTile(
                          leading: Icon(Icons.backup_outlined,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Export Notes'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          onTap: () async {
                            final data = await noteProvider.exportData();
                            await _fileService.exportToFile(
                                data, 'notes_backup.json');
                            if (!mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Notes exported successfully')),
                            );
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.restore_outlined,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Import Notes'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          onTap: () async {
                            final data = await _fileService.importFromFile();
                            if (data != null) {
                              await noteProvider.importData(data);
                              if (!mounted) return;
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Notes imported successfully')),
                              );
                            }
                          },
                        ),
                        const Divider(indent: 16, endIndent: 16),
                        ListTile(
                          leading: Icon(
                            Icons.archive_outlined,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          title: Text(_showArchived
                              ? 'Hide Archived'
                              : 'Show Archived'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          onTap: () {
                            setState(() {
                              _showArchived = !_showArchived;
                            });
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.sort_outlined,
                              color: Theme.of(context).colorScheme.primary),
                          title: const Text('Sort Notes'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _showSortDialog();
                          },
                        ),
                        const Divider(indent: 16, endIndent: 16),
                        ListTile(
                          leading: Icon(Icons.delete_forever_outlined,
                              color: Theme.of(context).colorScheme.error),
                          title: const Text('Clear All Notes'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Clear All Notes'),
                                content: const Text(
                                    'Are you sure you want to delete all notes? This action cannot be undone.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await noteProvider.clearAll();
                                      if (!mounted) return;
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'Clear All',
                                      style: TextStyle(
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          themeProvider.accentColor.withOpacity(0.1),
                          themeProvider.accentColor.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search notes...',
                                    prefixIcon: Icon(Icons.search,
                                        color: themeProvider.accentColor),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: Icon(
                                  Icons.filter_list,
                                  color: themeProvider.accentColor,
                                ),
                                onPressed: _showFilterDialog,
                                tooltip: 'Filter Notes',
                              ),
                              IconButton(
                                icon: Icon(
                                  _isListView
                                      ? Icons.grid_view
                                      : Icons.view_list,
                                  color: themeProvider.accentColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isListView = !_isListView;
                                  });
                                },
                                tooltip:
                                    _isListView ? 'Grid View' : 'List View',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: _isListView
                    ? SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildNoteCard(context, notes[index]),
                          childCount: notes.length,
                        ),
                      )
                    : SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.8,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildNoteCard(context, notes[index]),
                          childCount: notes.length,
                        ),
                      ),
              ),
            ],
          ),
          floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [themeProvider.accentColor, themeProvider.accentColor],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: themeProvider.accentColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _addNote,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Add Note',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final color = note.color != null
        ? Color(int.parse(note.color!.substring(1), radix: 16) + 0xFF000000)
        : themeProvider.isDarkMode
            ? Colors.grey[850]
            : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _editNote(note),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (note.isPinned)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.push_pin,
                          size: 16,
                          color: Colors.blue[700],
                        ),
                      ),
                    Expanded(
                      child: Text(
                        note.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    style: TextStyle(
                      color: Colors.black87.withOpacity(0.7),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (note.tags.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: note.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
