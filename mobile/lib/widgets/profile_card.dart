import 'package:flutter/material.dart';

import '../config.dart';
import '../models/profile.dart';
import '../theme.dart';

/// A full-bleed photo card with name/age/bio legible over a bottom scrim —
/// the text always sits on the photo's gradient, so it stays white-on-dark
/// regardless of the app's light/dark theme.
class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key, required this.profile});

  final PublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final photoUrl = profile.photos.isNotEmpty ? '$apiBaseUrl${profile.photos.first.url}' : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          photoUrl != null
              ? Image.network(
                  photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _PlaceholderPhoto(),
                )
              : const _PlaceholderPhoto(),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.5, 1],
                colors: [Colors.transparent, Color(0xCC1A0E13)],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      profile.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${profile.age}',
                      style: const TextStyle(
                        color: Color(0xFFEBD9DC),
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                if (profile.bio.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    profile.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFF2E6E9), fontSize: 14, height: 1.35),
                  ),
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [MinglaColors.plum.withValues(alpha: 0.55), MinglaColors.coral.withValues(alpha: 0.55)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.person_rounded, size: 96, color: Colors.white70),
      ),
    );
  }
}
