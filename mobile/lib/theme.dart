import 'package:flutter/material.dart';

/// Mingla's design tokens and the light/dark [ThemeData] built from them.
///
/// Colors are hand-picked rather than generated from a single seed so the
/// palette reads as chosen: a warm coral for primary actions and matches,
/// a muted plum for secondary emphasis, and warm (not pure white/black)
/// neutrals throughout.
class MinglaColors {
  MinglaColors._();

  static const coral = Color(0xFFD6455A);
  static const coralLight = Color(0xFFF0768A);
  static const plum = Color(0xFF5B3A4B);
  static const plumLight = Color(0xFFD8B4C4);
  static const gold = Color(0xFFCF9A3E);

  static const creamBackground = Color(0xFFFDF6F3);
  static const creamSurface = Color(0xFFFFFFFF);
  static const inkLight = Color(0xFF241B1F);
  static const mutedLight = Color(0xFF7C6B70);
  static const lineLight = Color(0xFFEBDFDD);

  static const nightBackground = Color(0xFF1C1417);
  static const nightSurface = Color(0xFF261C20);
  static const inkDark = Color(0xFFF5E9E7);
  static const mutedDark = Color(0xFFB9A6AC);
  static const lineDark = Color(0xFF3A2C31);
}

class MinglaTheme {
  MinglaTheme._();

  static TextTheme _textTheme(Color ink, Color muted) {
    // No bundled display face — weight, tracking, and size carry the
    // hierarchy on the platform's own system font (Roboto/SF), so both
    // platforms render identically with no silent-fallback risk.
    return TextTheme(
      headlineMedium: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: ink,
        height: 1.15,
      ),
      headlineSmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: ink,
        height: 1.2,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, color: ink, height: 1.4),
      bodyMedium: TextStyle(fontSize: 14, color: ink, height: 1.45),
      bodySmall: TextStyle(fontSize: 13, color: muted, height: 1.4),
      labelLarge: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: muted,
      ),
    );
  }

  static ThemeData light = _build(
    brightness: Brightness.light,
    background: MinglaColors.creamBackground,
    surface: MinglaColors.creamSurface,
    ink: MinglaColors.inkLight,
    muted: MinglaColors.mutedLight,
    line: MinglaColors.lineLight,
    primary: MinglaColors.coral,
    onPrimary: Colors.white,
    secondary: MinglaColors.plum,
    onSecondary: Colors.white,
  );

  static ThemeData dark = _build(
    brightness: Brightness.dark,
    background: MinglaColors.nightBackground,
    surface: MinglaColors.nightSurface,
    ink: MinglaColors.inkDark,
    muted: MinglaColors.mutedDark,
    line: MinglaColors.lineDark,
    primary: MinglaColors.coralLight,
    onPrimary: MinglaColors.nightBackground,
    secondary: MinglaColors.plumLight,
    onSecondary: MinglaColors.nightBackground,
  );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color ink,
    required Color muted,
    required Color line,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      // A soft tint of primary over the surface — used for "my message"
      // chat bubbles — rather than the full-strength accent, which would
      // need white text and compete with the button/nav uses of primary.
      primaryContainer: Color.alphaBlend(primary.withValues(alpha: 0.20), surface),
      onPrimaryContainer: ink,
      secondary: secondary,
      onSecondary: onSecondary,
      tertiary: MinglaColors.gold,
      onTertiary: MinglaColors.inkLight,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: surface,
      onSurface: ink,
      surfaceContainerHighest: line,
      onSurfaceVariant: muted,
      outline: line,
      outlineVariant: line,
    );

    final textTheme = _textTheme(ink, muted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: ink),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shadowColor: ink.withValues(alpha: 0.18),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: muted),
        floatingLabelStyle: TextStyle(color: primary),
        helperStyle: TextStyle(color: muted, fontSize: 12),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: line)),
        border: UnderlineInputBorder(borderSide: BorderSide(color: line)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primary, width: 2)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(52),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: line, width: 1.5),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary, textStyle: textTheme.bodyMedium),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: surface,
        foregroundColor: primary,
        elevation: 3,
        shape: const CircleBorder(),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: primary.withValues(alpha: brightness == Brightness.dark ? 0.28 : 0.16),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? primary : muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? primary : muted);
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: line, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: primary),
    );
  }
}
