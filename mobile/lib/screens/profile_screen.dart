import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../config.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _bioController;
  bool _savingBio = false;
  bool _uploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _bioController = TextEditingController(text: context.read<AuthService>().currentUser?.bio);
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      await context.read<ProfileRepository>().uploadPhoto(File(picked.path));
      await context.read<AuthService>().refreshProfile();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    try {
      await context.read<ProfileRepository>().deletePhoto(photoId);
      await context.read<AuthService>().refreshProfile();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
  }

  Future<void> _saveBio() async {
    setState(() => _savingBio = true);
    try {
      await context.read<ProfileRepository>().updateProfile(bio: _bioController.text.trim());
      await context.read<AuthService>().refreshProfile();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bio updated')));
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _savingBio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthService>().logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
          Text(user.email, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...user.photos.map(
                  (photo) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            '$apiBaseUrl${photo.url}',
                            width: 100,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.black54),
                            onPressed: () => _deletePhoto(photo.id),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 120,
                  child: OutlinedButton(
                    onPressed: _uploadingPhoto ? null : _pickAndUploadPhoto,
                    child: _uploadingPhoto
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.add_a_photo),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Bio'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _savingBio ? null : _saveBio,
            child: _savingBio
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Save bio'),
          ),
        ],
      ),
    );
  }
}
