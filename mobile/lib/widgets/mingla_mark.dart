import 'package:flutter/material.dart';

import '../theme.dart';

/// The Mingla mark: two overlapping circles standing in for two people
/// "mingling" — the overlap reads as a third, blended tone.
class MinglaMark extends StatelessWidget {
  const MinglaMark({super.key, this.size = 56});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final coral = isDark ? MinglaColors.coralLight : MinglaColors.coral;
    final plum = isDark ? MinglaColors.plumLight : MinglaColors.plum;
    final circle = size * 0.72;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: _Circle(diameter: circle, color: coral),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: _Circle(diameter: circle, color: plum.withValues(alpha: 0.88)),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
