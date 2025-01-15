import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../providers/goal_provider.dart';
import 'package:uuid/uuid.dart';
import '../providers/theme_provider.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
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
                          Text(
                            'Goals & Achievements',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.accentColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track your progress and celebrate your success',
                            style: TextStyle(
                              color: themeProvider.accentColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: themeProvider.isDarkMode
                        ? Colors.grey[850]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TabBar(
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flag, color: themeProvider.accentColor),
                            const SizedBox(width: 8),
                            Text(
                              'Active Goals',
                              style:
                                  TextStyle(color: themeProvider.accentColor),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emoji_events,
                                color: themeProvider.accentColor),
                            const SizedBox(width: 8),
                            Text(
                              'Achievements',
                              style:
                                  TextStyle(color: themeProvider.accentColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: themeProvider.accentColor.withOpacity(0.1),
                    ),
                    labelColor: themeProvider.accentColor,
                    unselectedLabelColor: Colors.grey,
                    indicatorSize: TabBarIndicatorSize.tab,
                  ),
                ),
              ),
            ];
          },
          body: const TabBarView(
            children: [
              _ActiveGoalsTab(),
              _AchievementsTab(),
            ],
          ),
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
              onTap: () => _showAddGoalDialog(context),
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
                      'Add Goal',
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
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _AddGoalDialog(),
    );
  }
}

class _ActiveGoalsTab extends StatelessWidget {
  const _ActiveGoalsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        final activeGoals = provider.activeGoals;
        if (activeGoals.isEmpty) {
          return const Center(
            child: Text('Add some goals to get started!'),
          );
        }
        return ListView.builder(
          itemCount: activeGoals.length,
          itemBuilder: (context, index) {
            return _GoalCard(goal: activeGoals[index]);
          },
        );
      },
    );
  }
}

class _AchievementsTab extends StatelessWidget {
  const _AchievementsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        final achievedGoals = provider.achievedGoals;
        if (achievedGoals.isEmpty) {
          return const Center(
            child: Text('Keep working towards your goals!'),
          );
        }
        return ListView.builder(
          itemCount: achievedGoals.length,
          itemBuilder: (context, index) {
            return _GoalCard(goal: achievedGoals[index]);
          },
        );
      },
    );
  }
}

class _GoalCard extends StatelessWidget {
  final Goal goal;

  const _GoalCard({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final progress = goal.milestones.isEmpty
        ? 1.0
        : goal.completedMilestones.length / goal.milestones.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
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
          onTap: () {
            // Handle goal tap
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeProvider.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        goal.isAchieved ? Icons.emoji_events : Icons.flag,
                        color: themeProvider.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Due: ${_formatDate(goal.targetDate)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!goal.isAchieved)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline),
                        color: themeProvider.accentColor,
                        onPressed: () {
                          Provider.of<GoalProvider>(context, listen: false)
                              .toggleAchievement(goal.id);
                        },
                      ),
                    if (goal.isAchieved)
                      IconButton(
                        icon: const Icon(Icons.replay_circle_filled_outlined),
                        color: themeProvider.accentColor,
                        onPressed: () {
                          Provider.of<GoalProvider>(context, listen: false)
                              .toggleAchievement(goal.id);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Goal'),
                            content: const Text(
                                'Are you sure you want to delete this goal?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Provider.of<GoalProvider>(context,
                                          listen: false)
                                      .deleteGoal(goal.id);
                                  Navigator.pop(context);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
                if (goal.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    goal.description,
                    style: TextStyle(
                      color: themeProvider.isDarkMode
                          ? Colors.grey[400]
                          : Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: themeProvider.accentColor.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                        themeProvider.accentColor),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(progress * 100).toInt()}% Complete',
                  style: TextStyle(
                    color: themeProvider.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (goal.milestones.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Milestones',
                    style: TextStyle(
                      color: themeProvider.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...goal.milestones.map((milestone) => CheckboxListTile(
                        value: goal.completedMilestones.contains(milestone),
                        onChanged: (value) {
                          if (value != null) {
                            Provider.of<GoalProvider>(context, listen: false)
                                .toggleMilestone(goal.id, milestone);
                          }
                        },
                        title: Text(
                          milestone,
                          style: TextStyle(
                              decoration:
                                  goal.completedMilestones.contains(milestone)
                                      ? TextDecoration.lineThrough
                                      : null,
                              color:
                                  goal.completedMilestones.contains(milestone)
                                      ? Colors.grey
                                      : Colors.grey[600],
                              fontWeight: FontWeight.w600),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                      )),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class _AddGoalDialog extends StatefulWidget {
  final Goal? goal;

  // ignore: unused_element
  const _AddGoalDialog({Key? key, this.goal}) : super(key: key);

  @override
  _AddGoalDialogState createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends State<_AddGoalDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _targetDate;
  final List<TextEditingController> _milestoneControllers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.goal?.description ?? '');
    _targetDate =
        widget.goal?.targetDate ?? DateTime.now().add(const Duration(days: 30));

    if (widget.goal != null) {
      for (final milestone in widget.goal!.milestones) {
        _milestoneControllers.add(TextEditingController(text: milestone));
      }
    }
    if (_milestoneControllers.isEmpty) {
      _milestoneControllers.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    for (final controller in _milestoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.goal == null ? 'Add New Goal' : 'Edit Goal'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Target Date'),
              subtitle: Text(_formatDate(_targetDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            const Text('Milestones'),
            ...List.generate(_milestoneControllers.length, (index) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _milestoneControllers[index],
                      decoration: InputDecoration(
                        labelText: 'Milestone ${index + 1}',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => _removeMilestone(index),
                  ),
                ],
              );
            }),
            TextButton(
              onPressed: _addMilestone,
              child: const Text('Add Milestone'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveGoal,
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _addMilestone() {
    setState(() {
      _milestoneControllers.add(TextEditingController());
    });
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestoneControllers[index].dispose();
      _milestoneControllers.removeAt(index);
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _saveGoal() {
    if (_titleController.text.isEmpty) {
      return;
    }

    final milestones = _milestoneControllers
        .map((controller) => controller.text)
        .where((text) => text.isNotEmpty)
        .toList();

    final goal = Goal(
      id: widget.goal?.id ?? const Uuid().v4(),
      title: _titleController.text,
      description: _descriptionController.text,
      createdAt: widget.goal?.createdAt ?? DateTime.now(),
      targetDate: _targetDate,
      milestones: milestones,
      completedMilestones: widget.goal?.completedMilestones ?? [],
      isAchieved: widget.goal?.isAchieved ?? false,
      achievedAt: widget.goal?.achievedAt,
    );

    if (widget.goal == null) {
      context.read<GoalProvider>().addGoal(goal);
    } else {
      context.read<GoalProvider>().updateGoal(goal);
    }

    Navigator.pop(context);
  }
}
