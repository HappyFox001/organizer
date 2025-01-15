import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'pages/tasks_page.dart';
import 'pages/notes_page.dart';
import 'pages/settings_page.dart';
import 'pages/categories_page.dart';
import 'pages/goals_page.dart';
import 'pages/profile_page.dart';
import 'services/storage_service.dart';
import 'providers/task_provider.dart';
import 'providers/note_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/category_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(storageService)..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => TaskProvider(storageService)..loadTasks(),
        ),
        ChangeNotifierProvider(
          create: (_) => NoteProvider(storageService)..loadNotes(),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalProvider(storageService)..loadGoals(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(storageService)..loadProfile(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Task Manager',
          theme: themeProvider.theme,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomePage(),
            '/tasks': (context) => const TasksPage(),
            '/notes': (context) => const NotesPage(),
            '/categories': (context) => const CategoriesPage(),
            '/goals': (context) => const GoalsPage(),
            '/profile': (context) => const ProfilePage(),
            '/settings': (context) => const SettingsPage(),
          },
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Sync profile statistics when the app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = this.context;
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      final noteProvider = Provider.of<NoteProvider>(context, listen: false);
      final categoryProvider =
          Provider.of<CategoryProvider>(context, listen: false);

      profileProvider.syncStatistics(
        taskProvider: taskProvider,
        noteProvider: noteProvider,
        categoryProvider: categoryProvider,
      );

      // Listen to changes in other providers
      taskProvider.addListener(() {
        profileProvider.syncStatistics(
          taskProvider: taskProvider,
          noteProvider: noteProvider,
          categoryProvider: categoryProvider,
        );
      });

      noteProvider.addListener(() {
        profileProvider.syncStatistics(
          taskProvider: taskProvider,
          noteProvider: noteProvider,
          categoryProvider: categoryProvider,
        );
      });

      categoryProvider.addListener(() {
        profileProvider.syncStatistics(
          taskProvider: taskProvider,
          noteProvider: noteProvider,
          categoryProvider: categoryProvider,
        );
      });
    });
  }

  final List<Widget> _pages = const [
    TasksPage(),
    NotesPage(),
    CategoriesPage(),
    GoalsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    String title;
    switch (_selectedIndex) {
      case 0:
        title = 'Tasks';
        break;
      case 1:
        title = 'Notes';
        break;
      case 2:
        title = 'Categories';
        break;
      case 3:
        title = 'Goals';
        break;
      case 4:
        title = 'Profile';
        break;
      default:
        title = 'Organizer';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: GoogleFonts.playfairDisplay(
            textStyle: TextStyle(
              color: themeProvider.accentColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        height: 65,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.note_outlined),
            selectedIcon: Icon(Icons.note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withOpacity(0.9),
                        child: Icon(
                          Icons.check_circle_outline,
                          size: 36,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      Text(
                        'Organize your life',
                        style: GoogleFonts.playfairDisplay(
                          textStyle: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.accentColor.withOpacity(1.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Material(
                color: Theme.of(context).colorScheme.surface,
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    ListTile(
                      selected: _selectedIndex == 0,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.15),
                      leading: Icon(
                        Icons.task_outlined,
                        color: _selectedIndex == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        'Tasks',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: _selectedIndex == 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight:
                                _selectedIndex == 0 ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      onTap: () {
                        setState(() => _selectedIndex = 0);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      selected: _selectedIndex == 1,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.15),
                      leading: Icon(
                        Icons.note_outlined,
                        color: _selectedIndex == 1
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        'Notes',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: _selectedIndex == 1
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight:
                                _selectedIndex == 1 ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      onTap: () {
                        setState(() => _selectedIndex = 1);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      selected: _selectedIndex == 2,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.15),
                      leading: Icon(
                        Icons.category_outlined,
                        color: _selectedIndex == 2
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        'Categories',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: _selectedIndex == 2
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight:
                                _selectedIndex == 2 ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      onTap: () {
                        setState(() => _selectedIndex = 2);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      selected: _selectedIndex == 3,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.15),
                      leading: Icon(
                        Icons.emoji_events_outlined,
                        color: _selectedIndex == 3
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        'Goals',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: _selectedIndex == 3
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight:
                                _selectedIndex == 3 ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      onTap: () {
                        setState(() => _selectedIndex = 3);
                        Navigator.pop(context);
                      },
                    ),
                    ListTile(
                      selected: _selectedIndex == 4,
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.15),
                      leading: Icon(
                        Icons.person_outline_rounded,
                        color: _selectedIndex == 4
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        'Profile',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: _selectedIndex == 4
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight:
                                _selectedIndex == 4 ? FontWeight.bold : null,
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      onTap: () {
                        setState(() => _selectedIndex = 4);
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16, height: 32),
                    ListTile(
                      selectedTileColor: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.15),
                      leading: Icon(
                        Icons.settings_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        'Settings',
                        style: GoogleFonts.lato(
                          textStyle: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(); // Close drawer first
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        );
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16, height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Theme Color',
                            style: GoogleFonts.lato(
                              textStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.palette_outlined,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: () {
                              Provider.of<ThemeProvider>(context, listen: false)
                                  .cycleAccentColor();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
