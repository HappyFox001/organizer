import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/theme_provider.dart';
import 'task_edit_page.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key});

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  String _filterTag = '';
  bool _showCompleted = true;

  Future<void> _addTask() async {
    final task = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (context) => const TaskEditPage()),
    );
    if (task != null) {
      if (!mounted) return;
      Provider.of<TaskProvider>(context, listen: false).addTask(task);
    }
  }

  Future<void> _editTask(Task task) async {
    final editedTask = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (context) => TaskEditPage(task: task)),
    );
    if (editedTask != null) {
      if (!mounted) return;
      Provider.of<TaskProvider>(context, listen: false).updateTask(editedTask);
    }
  }

  void _deleteTask(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<TaskProvider>(context, listen: false)
                  .deleteTask(task.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Tasks'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Show Completed Tasks'),
              value: _showCompleted,
              onChanged: (value) {
                setState(() {
                  _showCompleted = value ?? true;
                });
                Navigator.pop(context);
              },
            ),
            const Divider(),
            const Text('Filter by Tag:'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterTag.isEmpty,
                  onSelected: (selected) {
                    setState(() {
                      _filterTag = '';
                    });
                    Navigator.pop(context);
                  },
                ),
                ...taskProvider.getAllTags().map((tag) => FilterChip(
                      label: Text(tag),
                      selected: _filterTag == tag,
                      onSelected: (selected) {
                        setState(() {
                          _filterTag = selected ? tag : '';
                        });
                        Navigator.pop(context);
                      },
                    )),
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

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.tasks
            .where((task) =>
                (_showCompleted || !task.isCompleted) &&
                (_filterTag.isEmpty || task.tags.contains(_filterTag)))
            .toList();

        return Scaffold(
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Task Summary',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: themeProvider.accentColor,
                                    ),
                              ),
                              IconButton(
                                icon: Icon(Icons.filter_list,
                                    color: themeProvider.accentColor),
                                onPressed: _showFilterDialog,
                                tooltip: 'Filter Tasks',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${tasks.where((t) => t.isCompleted).length}/${tasks.length} tasks completed',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: themeProvider.accentColor,
                                ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: tasks.isEmpty
                                ? 0
                                : tasks.where((t) => t.isCompleted).length /
                                    tasks.length,
                            backgroundColor:
                                themeProvider.accentColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                themeProvider.accentColor),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent.withOpacity(0.01),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              leading: Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: task.isCompleted,
                                  activeColor: themeProvider.accentColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (value) {
                                    if (value != null) {
                                      final updatedTask = task.copyWith(
                                        isCompleted: value,
                                      );
                                      Provider.of<TaskProvider>(context,
                                              listen: false)
                                          .updateTask(updatedTask);
                                    }
                                  },
                                ),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: task.isCompleted
                                      ? (themeProvider.isDarkMode
                                          ? Colors.white
                                          : Colors.black)
                                      : (themeProvider.isDarkMode
                                          ? Colors.grey
                                          : Colors.black),
                                  fontWeight: task.isCompleted
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (task.description.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      task.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  if (task.tags.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 4,
                                      runSpacing: 4,
                                      children: task.tags
                                          .map((tag) => Chip(
                                                label: Text(tag),
                                                materialTapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                                visualDensity:
                                                    VisualDensity.compact,
                                              ))
                                          .toList(),
                                    ),
                                  ],
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editTask(task);
                                  } else if (value == 'delete') {
                                    _deleteTask(task);
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: tasks.length,
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
                onTap: _addTask,
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
                        'Add Task',
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
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }
}
