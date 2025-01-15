import 'package:flutter/material.dart';
import 'package:organizer/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _githubUrlController;
  late TextEditingController _webUrlController;
  late TextEditingController _wechatUrlController;
  File? _selectedImage;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final profile =
        Provider.of<ProfileProvider>(context, listen: false).profile;
    _nameController = TextEditingController(text: profile.name);
    _bioController = TextEditingController(text: profile.bio);
    _githubUrlController = TextEditingController(text: profile.githubUrl ?? '');
    _webUrlController = TextEditingController(text: profile.webUrl ?? '');
    _wechatUrlController = TextEditingController(text: profile.wechatUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _githubUrlController.dispose();
    _webUrlController.dispose();
    _wechatUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              if (Provider.of<ProfileProvider>(context, listen: false)
                      .profile
                      .avatarUrl !=
                  null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Current Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                    });
                  },
                ),
            ],
          ),
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
          'Edit Profile',
          style: TextStyle(color: themeProvider.accentColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildBasicInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : Provider.of<ProfileProvider>(context)
                                  .profile
                                  .avatarUrl !=
                              null
                          ? _getAvatarImage()
                          : null,
                  child: _selectedImage == null &&
                          Provider.of<ProfileProvider>(context)
                                  .profile
                                  .avatarUrl ==
                              null
                      ? Text(
                          _nameController.text.isNotEmpty
                              ? _nameController.text[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getAvatarImage() {
    final avatarUrl = Provider.of<ProfileProvider>(context).profile.avatarUrl!;
    if (avatarUrl.startsWith('/')) {
      return FileImage(File(avatarUrl));
    }
    return NetworkImage(avatarUrl);
  }

  Widget _buildBasicInfoSection() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _bioController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Bio',
            hintText: 'Tell us about yourself',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _githubUrlController,
          decoration: InputDecoration(
            labelText: 'GitHub URL',
            hintText: 'https://github.com/username',
            border: const OutlineInputBorder(),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/github.png',
                width: 24,
                height: 24,
                color: themeProvider.accentColor,
              ),
            ),
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _webUrlController,
          decoration: InputDecoration(
            labelText: 'Website URL',
            hintText: 'https://example.com',
            border: const OutlineInputBorder(),
            prefixIcon: Icon(
              Icons.language,
              size: 24,
              color: themeProvider.accentColor,
            ),
          ),
          keyboardType: TextInputType.url,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _wechatUrlController,
          decoration: InputDecoration(
            labelText: 'WeChat URL',
            hintText: 'Your WeChat URL',
            border: const OutlineInputBorder(),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                'assets/wechat.png',
                width: 24,
                height: 24,
                color: themeProvider.accentColor,
              ),
            ),
          ),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    String? avatarUrl = profileProvider.profile.avatarUrl;

    if (_selectedImage != null) {
      // Save the new image and get its path
      avatarUrl = await profileProvider.saveProfileImage(_selectedImage!);
    } else if (avatarUrl == null && _selectedImage == null) {
      // If user removed the avatar
      if (profileProvider.profile.avatarUrl != null) {
        await profileProvider
            .deleteProfileImage(profileProvider.profile.avatarUrl!);
      }
      avatarUrl = null;
    }

    profileProvider.updateProfile(
      name: _nameController.text,
      bio: _bioController.text,
      avatarUrl: avatarUrl,
      githubUrl: _githubUrlController.text.isNotEmpty
          ? _githubUrlController.text
          : null,
      webUrl: _webUrlController.text.isNotEmpty ? _webUrlController.text : null,
      wechatUrl: _wechatUrlController.text.isNotEmpty
          ? _wechatUrlController.text
          : null,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }
}
