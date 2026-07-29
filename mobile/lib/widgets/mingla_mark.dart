import 'package:flutter/material.dart';

import '../theme.dart';

/// The Mingla mark: a thin ink ring with a solid sage dot resting on its
/// edge — two forms meeting, drawn with a single deliberate spot of color
/// rather than a bold two-tone logo.
class MinglaMark extends StatelessWidget {
  const MinglaMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? MinglaColors.inkDark : MinglaColors.inkLight;
    final accent = isDark ? MinglaColors.accentLight : MinglaColors.accent;
    final dot = size * 0.4;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ink, width: size * 0.035),
            ),
          ),
          Positioned(
            right: -dot * 0.22,
            bottom: -dot * 0.22,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
            ),
          ),
        ],
      ),
    );
  }
}
