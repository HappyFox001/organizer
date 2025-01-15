import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../providers/category_provider.dart';
import '../providers/theme_provider.dart';

class TaskEditPage extends StatefulWidget {
  final Task? task;

  const TaskEditPage({super.key, this.task});

  @override
  State<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends State<TaskEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late List<String> _tags;
  late double _progress;
  String? _categoryId;
  late String _priority;
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _dueDate =
        widget.task?.dueDate ?? DateTime.now().add(const Duration(days: 1));
    _tags = widget.task?.tags ?? [];
    _progress = widget.task?.progress ?? 0.0;
    _categoryId = widget.task?.category;
    _priority = widget.task?.priority ?? 'Medium';

    // Schedule category initialization for after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCategory();
    });
  }

  void _initializeCategory() {
    if (!mounted) return;

    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final categories = categoryProvider.categories;
    if (categories.isNotEmpty && _categoryId == null) {
      setState(() {
        _categoryId = categories[0].id;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _addTag() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(
            'Add Tag',
            style: TextStyle(color: themeProvider.accentColor),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Tag Name',
              labelStyle: TextStyle(color: themeProvider.accentColor),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: themeProvider.accentColor),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: themeProvider.accentColor),
              ),
            ),
            TextButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _tags.add(controller.text);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text(
                'Add',
                style: TextStyle(color: themeProvider.accentColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Task _createTask() {
    return Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      dueDate: _dueDate,
      category: _categoryId ?? 'default',
      priority: _priority,
      isCompleted: widget.task?.isCompleted ?? false,
      progress: _progress,
      tags: _tags,
    );
  }

  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Category'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Category Name',
                hintText: 'Enter category name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a category name';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final categoryProvider =
                      Provider.of<CategoryProvider>(context, listen: false);
                  categoryProvider.addCategory(
                    Category(
                      id: const Uuid().v4(),
                      name: nameController.text,
                      color: null,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.task == null ? 'New Task' : 'Edit Task',
          style: TextStyle(color: themeProvider.accentColor),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: themeProvider.accentColor),
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                Navigator.pop(context, _createTask());
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: themeProvider.accentColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeProvider.accentColor),
                ),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: themeProvider.accentColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: themeProvider.accentColor),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Due Date: ',
                  style: TextStyle(color: themeProvider.accentColor),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text(
                    _dueDate.toString().split(' ')[0],
                    style: TextStyle(color: themeProvider.accentColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Category: ',
                  style: TextStyle(color: themeProvider.accentColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Consumer<CategoryProvider>(
                    builder: (context, categoryProvider, child) {
                      final categories = categoryProvider.categories;
                      return Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _categoryId ??
                                  (categories.isNotEmpty
                                      ? categories[0].id
                                      : null),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                      color: themeProvider.accentColor),
                                ),
                              ),
                              items: categories.map((category) {
                                return DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _categoryId = value;
                                });
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _showAddCategoryDialog(context),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Priority: ',
                  style: TextStyle(color: themeProvider.accentColor),
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _priority,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _priority = newValue;
                        });
                      }
                    },
                    items: _priorities
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: themeProvider.accentColor),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Progress: ',
                  style: TextStyle(color: themeProvider.accentColor),
                ),
                Expanded(
                  child: Slider(
                    value: _progress,
                    onChanged: (value) {
                      setState(() {
                        _progress = value;
                      });
                    },
                    activeColor: themeProvider.accentColor,
                    inactiveColor: themeProvider.accentColor.withOpacity(0.3),
                    divisions: 20,
                    label: '${(_progress * 100).round()}%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Row(
              children: [
                Text(
                  'Tags: ',
                  style: TextStyle(color: themeProvider.accentColor),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add,
                    color: themeProvider.accentColor,
                  ),
                  onPressed: _addTag,
                ),
              ],
            ),
            Wrap(
              spacing: 8.0,
              children: _tags
                  .map((tag) => Chip(
                        label: Text(
                          tag,
                          style: TextStyle(color: themeProvider.accentColor),
                        ),
                        backgroundColor:
                            themeProvider.accentColor.withOpacity(0.1),
                        deleteIconColor: themeProvider.accentColor,
                        onDeleted: () {
                          setState(() {
                            _tags.remove(tag);
                          });
                        },
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
