import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: Text(themeProvider.isDarkMode ? 'On' : 'Off'),
                value: themeProvider.isDarkMode,
                onChanged: (bool value) => themeProvider.toggleTheme(),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('About'),
            leading: const Icon(Icons.info),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Organizer',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2025 Qian Zhang',
              );
            },
          ),
        ],
      ),
    );
  }
}
