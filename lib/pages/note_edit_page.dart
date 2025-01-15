import 'package:organizer/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../providers/note_provider.dart';
import '../providers/category_provider.dart';

class NoteEditPage extends StatefulWidget {
  final Note? note;

  const NoteEditPage({super.key, this.note});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  String? _selectedColor;
  List<String> _tags = [];
  bool _isPinned = false;
  bool _isArchived = false;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _tags = List.from(widget.note!.tags);
      _selectedCategory = widget.note!.category;
      _selectedColor = widget.note!.color;
      _isPinned = widget.note!.isPinned;
      _isArchived = widget.note!.isArchived;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && !_tags.contains(trimmedTag)) {
      setState(() {
        _tags.add(trimmedTag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _showColorPicker() {
    final colors = {
      'Default': null,
      'Red': '#FFCDD2',
      'Green': '#C8E6C9',
      'Blue': '#BBDEFB',
      'Yellow': '#FFF9C4',
      'Purple': '#E1BEE7',
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: colors.entries.map((entry) {
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedColor = entry.value;
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.value != null
                      ? Color(int.parse(entry.value!.substring(1), radix: 16) +
                          0xFF000000)
                      : Colors.white,
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _selectedColor == entry.value
                    ? const Icon(Icons.check)
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAddTagDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: _tagController,
          decoration: const InputDecoration(
            hintText: 'Tag Name',
          ),
          autofocus: true,
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              _addTag(value);
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_tagController.text.trim().isNotEmpty) {
                _addTag(_tagController.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<NoteProvider>(context, listen: false)
                  .deleteNote(widget.note!.id);
              if (!mounted) return;
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit page
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final note = Note(
      id: widget.note?.id,
      title: _titleController.text,
      content: _contentController.text,
      tags: _tags,
      category: _selectedCategory,
      color: _selectedColor,
      isPinned: _isPinned,
      isArchived: _isArchived,
    );

    if (widget.note == null) {
      await Provider.of<NoteProvider>(context, listen: false).addNote(note);
    } else {
      await Provider.of<NoteProvider>(context, listen: false).updateNote(note);
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.note == null ? 'New Note' : 'Edit Note',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: themeProvider.accentColor),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.accentColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.note != null) // 只在编辑现有笔记时显示删除按钮
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              onPressed: _showDeleteConfirmation,
              tooltip: 'Delete Note',
            ),
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: themeProvider.accentColor,
            ),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
            tooltip: 'Pin Note',
          ),
          IconButton(
            icon: Icon(
              Icons.palette_outlined,
              color: themeProvider.accentColor,
            ),
            onPressed: _showColorPicker,
            tooltip: 'Change Color',
          ),
          IconButton(
            icon: Icon(
              Icons.check,
              color: themeProvider.accentColor,
            ),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
        ],
      ),
      body: Container(
        color: _selectedColor != null
            ? Color(
                int.parse(_selectedColor!.substring(1), radix: 16) + 0xFF000000)
            : Theme.of(context).scaffoldBackgroundColor,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'Title',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.accentColor,
                          ),
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const Divider(height: 24),
                      TextFormField(
                        controller: _contentController,
                        decoration: InputDecoration(
                          hintText: 'Write your note here...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                            fontSize: 16,
                            color: themeProvider.accentColor,
                          ),
                        ),
                        maxLines: null,
                        minLines: 5,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tags',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.accentColor,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add,
                                color: themeProvider.accentColor),
                            onPressed: () {
                              _tagController.clear();
                              _showAddTagDialog();
                            },
                            tooltip: 'Add Tag',
                          ),
                        ],
                      ),
                      if (_tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tags
                              .map((tag) => Chip(
                                    label: Text(tag),
                                    onDeleted: () => _removeTag(tag),
                                    backgroundColor: themeProvider.accentColor
                                        .withOpacity(0.1),
                                    deleteIconColor: themeProvider.accentColor,
                                    labelStyle: TextStyle(
                                        color: themeProvider.accentColor),
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Category',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.accentColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer<CategoryProvider>(
                        builder: (context, categoryProvider, child) {
                          return DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            hint: const Text('Select category'),
                            isExpanded: true,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 12),
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('No category'),
                              ),
                              ...categoryProvider.categories
                                  .map((category) => DropdownMenuItem(
                                        value: category.name,
                                        child: Text(category.name),
                                      ))
                                  .toList(),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
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
      ),
    );
  }
}
