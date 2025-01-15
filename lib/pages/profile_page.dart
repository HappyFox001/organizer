import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:organizer/providers/theme_provider.dart';
import '../providers/profile_provider.dart';
import '../models/profile.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          final profile = profileProvider.profile;
          return ListView(
            children: [
              _buildHeader(context, profile),
              _buildStatistics(context, profile),
              _buildActivityFeed(context, profile),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Profile profile) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.only(top: 32, bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            themeProvider.accentColor.withOpacity(0.2),
            themeProvider.accentColor.withOpacity(0.05),
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(right: 16),
              alignment: Alignment.topRight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: themeProvider.accentColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileEditPage(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.share,
                      color: themeProvider.accentColor,
                    ),
                    onPressed: () => _showShareOptions(context, profile),
                  ),
                ],
              ),
            ),
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                final currentProfile = profileProvider.profile;
                return Center(
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: themeProvider.accentColor.withOpacity(0.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(1.0),
                          blurRadius: 2,
                          offset: const Offset(0, 0.5),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: currentProfile.avatarUrl != null
                          ? currentProfile.avatarUrl!.startsWith('/')
                              ? Image.file(
                                  File(currentProfile.avatarUrl!),
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  currentProfile.avatarUrl!,
                                  fit: BoxFit.cover,
                                )
                          : Icon(
                              Icons.person,
                              size: 48,
                              color: themeProvider.accentColor,
                            ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              profile.name.isNotEmpty ? profile.name : 'Your Name',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                profile.bio.isNotEmpty ? profile.bio : 'Your Bio',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/github.png',
                    width: 24,
                    height: 24,
                    color: themeProvider.accentColor,
                  ),
                  onPressed: () async {
                    const url = 'https://github.com/yourusername';
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                  tooltip: 'GitHub Profile',
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () async {
                    const url = 'https://yourwebsite.com';
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                  color: themeProvider.accentColor,
                  tooltip: 'Personal Website',
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Image.asset(
                    'assets/wechat.png',
                    width: 24,
                    height: 24,
                    color: themeProvider.accentColor,
                  ),
                  onPressed: () async {
                    const url = 'https://github.com/yourusername';
                    if (await canLaunch(url)) {
                      await launch(url);
                    }
                  },
                  tooltip: 'GitHub Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context, Profile profile) {
    final String shareText = '''
━━━━━━━━━━━━━ 🌟 个人资料 🌟 ━━━━━━━━━━━━━
💼 姓名: ${profile.name}
📖 个人简介: ${profile.bio.isNotEmpty ? profile.bio : '❌ 暂无个人简介'}

🌐 GitHub: ${profile.githubUrl != null ? '🔗 ${profile.githubUrl}' : '❌ 未设置'}
💬 微信: ${profile.wechatUrl != null ? '🔗 ${profile.wechatUrl}' : '❌ 未设置'}
🌍 网站: ${profile.webUrl != null ? '🔗 ${profile.webUrl}' : '❌ 未设置'}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
''';

    Share.share(shareText);
  }

  Widget _buildStatistics(BuildContext context, Profile profile) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                themeProvider.accentColor.withOpacity(0.1),
                themeProvider.accentColor.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: profile.statistics.entries.map((entry) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeProvider.accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      entry.value.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.accentColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.key,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityFeed(BuildContext context, Profile profile) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, size: 20),
              SizedBox(width: 8),
              Text(
                'Recent Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profile.recentActivity.length,
            itemBuilder: (context, index) {
              final activity = profile.recentActivity[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: themeProvider.accentColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getActivityIcon(activity.action),
                      color: themeProvider.accentColor,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    activity.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    DateFormat.yMMMd().add_Hm().format(activity.timestamp),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'task':
        return Icons.task_alt;
      case 'note':
        return Icons.note;
      case 'category':
        return Icons.category;
      case 'goal':
        return Icons.emoji_events;
      default:
        return Icons.access_time;
    }
  }
}
