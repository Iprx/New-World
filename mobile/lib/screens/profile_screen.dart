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
    if (picked == null || !mounted) return;

    final profileRepo = context.read<ProfileRepository>();
    final authService = context.read<AuthService>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _uploadingPhoto = true);
    try {
      await profileRepo.uploadPhoto(File(picked.path));
      await authService.refreshProfile();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Something went wrong. Please try again.')));
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _deletePhoto(int photoId) async {
    final profileRepo = context.read<ProfileRepository>();
    final authService = context.read<AuthService>();
    final messenger = ScaffoldMessenger.of(context);

    try {
      await profileRepo.deletePhoto(photoId);
      await authService.refreshProfile();
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Something went wrong. Please try again.')));
    }
  }

  Future<void> _saveBio() async {
    final profileRepo = context.read<ProfileRepository>();
    final authService = context.read<AuthService>();
    final messenger = ScaffoldMessenger.of(context);

    setState(() => _savingBio = true);
    try {
      await profileRepo.updateProfile(bio: _bioController.text.trim());
      await authService.refreshProfile();
      messenger.showSnackBar(const SnackBar(content: Text('Bio updated')));
    } on ApiException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('Something went wrong. Please try again.')));
    } finally {
      if (mounted) setState(() => _savingBio = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    if (user == null) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
        actions: [
          IconButton(
            onPressed: () => context.read<AuthService>().logout(),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Log out',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text(user.email, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),
          Text('Photos', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ...user.photos.map(
                  (photo) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            '$apiBaseUrl${photo.url}',
                            width: 100,
                            height: 130,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: GestureDetector(
                            onTap: () => _deletePhoto(photo.id),
                            child: const CircleAvatar(
                              radius: 13,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 130,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.primary,
                      side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
                    ),
                    onPressed: _uploadingPhoto ? null : _pickAndUploadPhoto,
                    child: _uploadingPhoto
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: scheme.primary),
                          )
                        : const Icon(Icons.add_a_photo_rounded),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Bio', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 8),
          TextField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Tell people a little about yourself'),
          ),
          const SizedBox(height: 16),
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
