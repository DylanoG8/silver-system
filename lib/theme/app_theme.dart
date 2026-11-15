import 'package:flutter/material.dart';

class AppPalette {
  AppPalette._();

  static const primary = Color(0xFF6C4DFF);
  static const secondary = Color(0xFFFF4D8D);
  static const tertiary = Color(0xFF00B8D9);
  static const mint = Color(0xFF00E0B8);
  static const amber = Color(0xFFFFB84D);
  static const coral = Color(0xFFFF7A45);
  static const lightBackground = Color(0xFFF6F4FF);
  static const darkBackground = Color(0xFF0D0B1A);
  static const darkSurface = Color(0xFF171329);
}

class AppGradients {
  AppGradients._();

  static const header = LinearGradient(
    colors: [Color(0xFF5B3DF5), Color(0xFF9B4DFF), Color(0xFFFF5E8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0, 0.55, 1],
  );

  static const button = LinearGradient(
    colors: [Color(0xFF6C4DFF), Color(0xFFFF4D8D)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const _accents = <List<Color>>[
    [Color(0xFF6C4DFF), Color(0xFF9B4DFF)],
    [Color(0xFFFF4D8D), Color(0xFFFF8A5C)],
    [Color(0xFF00B8D9), Color(0xFF00E0B8)],
    [Color(0xFFFFB84D), Color(0xFFFF7A45)],
    [Color(0xFF7C4DFF), Color(0xFF00C6FF)],
  ];

  static LinearGradient accentFor(String id) {
    final index =
        id.codeUnits.fold<int>(0, (sum, unit) => sum + unit) % _accents.length;
    return LinearGradient(
      colors: _accents[index],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppPalette.primary,
          brightness: brightness,
        ).copyWith(
          primary: isDark ? const Color(0xFF9B8CFF) : AppPalette.primary,
          secondary: isDark ? const Color(0xFFFF7EB0) : AppPalette.secondary,
          tertiary: isDark ? const Color(0xFF4DD8F0) : AppPalette.tertiary,
          surface: isDark ? AppPalette.darkSurface : Colors.white,
        );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
      scaffoldBackgroundColor: isDark
          ? AppPalette.darkBackground
          : AppPalette.lightBackground,
    );

    final textTheme = base.textTheme.copyWith(
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
      bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.35),
      bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.35),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );

    return base.copyWith(
      textTheme: textTheme,
      iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF2A2442)
            : const Color(0xFF211B3A),
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        actionTextColor: AppPalette.mint,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        elevation: 8,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 10,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        modalBarrierColor: Colors.black54,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppPalette.primary,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.4),
      ),
    );
  }
}
