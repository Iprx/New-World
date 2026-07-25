import 'package:flutter/material.dart';

/// Mingla's design tokens and the light/dark [ThemeData] built from them.
///
/// Minimal & elegant: a near-monochrome ink/ivory palette carries almost
/// everything (buttons, nav, focus states), with a single muted sage accent
/// spent deliberately in a few places — the mark, the like button's heart,
/// small interactive text — rather than spread across every control.
class MinglaColors {
  MinglaColors._();

  static const accent = Color(0xFF5B6B4C);
  static const accentLight = Color(0xFF93A87F);

  static const paper = Color(0xFFF7F4EF);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const inkLight = Color(0xFF22201C);
  static const mutedLight = Color(0xFF8D8577);
  static const lineLight = Color(0xFFE3DED3);

  static const nightBackground = Color(0xFF1B1912);
  static const nightSurface = Color(0xFF221F17);
  static const inkDark = Color(0xFFECE7DD);
  static const mutedDark = Color(0xFFA79E8E);
  static const lineDark = Color(0xFF37342A);
}

class MinglaTheme {
  MinglaTheme._();

  static TextTheme _textTheme(Color ink, Color muted) {
    // No bundled display face — weight, tracking, and size carry the
    // hierarchy on the platform's own system font (Roboto/SF), so both
    // platforms render identically with no silent-fallback risk. Open
    // tracking and lighter weights (vs. a bold/tight display style) are
    // what read as "elegant" rather than "loud" here.
    return TextTheme(
      headlineMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: ink,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: ink,
        height: 1.25,
      ),
      titleLarge: TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        color: ink,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: ink,
      ),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: ink, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ink, height: 1.5),
      bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: muted, height: 1.45),
      labelLarge: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: muted,
      ),
    );
  }

  static ThemeData light = _build(
    brightness: Brightness.light,
    background: MinglaColors.paper,
    surface: MinglaColors.surfaceLight,
    ink: MinglaColors.inkLight,
    muted: MinglaColors.mutedLight,
    line: MinglaColors.lineLight,
    primary: MinglaColors.inkLight,
    onPrimary: MinglaColors.paper,
    secondary: MinglaColors.accent,
    onSecondary: Colors.white,
  );

  static ThemeData dark = _build(
    brightness: Brightness.dark,
    background: MinglaColors.nightBackground,
    surface: MinglaColors.nightSurface,
    ink: MinglaColors.inkDark,
    muted: MinglaColors.mutedDark,
    line: MinglaColors.lineDark,
    primary: MinglaColors.inkDark,
    onPrimary: MinglaColors.nightBackground,
    secondary: MinglaColors.accentLight,
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
      primaryContainer: Color.alphaBlend(primary.withValues(alpha: 0.10), surface),
      onPrimaryContainer: ink,
      secondary: secondary,
      onSecondary: onSecondary,
      // "My message" chat bubbles: a quiet sage tint rather than a solid
      // fill, so the one accent color shows up softly instead of loudly.
      secondaryContainer: Color.alphaBlend(secondary.withValues(alpha: 0.16), surface),
      onSecondaryContainer: ink,
      tertiary: secondary,
      onTertiary: onSecondary,
      error: const Color(0xFFA23B34),
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
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(color: muted),
        floatingLabelStyle: TextStyle(color: ink),
        helperStyle: TextStyle(color: muted, fontSize: 12),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: line)),
        border: UnderlineInputBorder(borderSide: BorderSide(color: line)),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: ink, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(54),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: BorderSide(color: line, width: 1.2),
          minimumSize: const Size.fromHeight(54),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: secondary, textStyle: textTheme.bodyMedium),
      ),
      // No global IconButtonThemeData: it would apply to every plain
      // IconButton (back arrows, the logout/delete icons), not just
      // IconButton.filled. The chat send button gets its filled ink circle
      // from Material 3's own default filled-variant styling, which already
      // reads colorScheme.primary/onPrimary.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: surface,
        foregroundColor: ink,
        elevation: 0,
        shape: CircleBorder(side: BorderSide(color: line)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? ink : muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(color: selected ? ink : muted);
        }),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: line),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: background),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      dividerTheme: DividerThemeData(color: line, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: ink),
    );
  }
}
