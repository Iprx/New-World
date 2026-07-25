import 'package:flutter/material.dart';

import '../config.dart';
import '../models/profile.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile.photos.isNotEmpty ? '$apiBaseUrl${profile.photos.first.url}' : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: photoUrl != null
                ? Image.network(
                    photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const _PlaceholderPhoto(),
                  )
                : const _PlaceholderPhoto(),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${profile.name}, ${profile.age}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (profile.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(profile.bio, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceholderPhoto extends StatelessWidget {
  const _PlaceholderPhoto();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.person, size: 96)),
    );
  }
}
