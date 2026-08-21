import 'package:flutter/material.dart';

/// Centralized design tokens for Dev Rumble.
///
/// Everything in the app (colors, spacing, radii, button styles, type
/// hierarchy) is pulled from this single file. When the real Dev Rumble
/// theme is confirmed, update the values here — no other file needs to
/// change.
class AppTheme {
  AppTheme._();

  // --- Color tokens ---------------------------------------------------
  // Neutral-premium placeholder palette. Swap for the brand palette later.
  static const Color primary = Color(0xFF3B4CCA);
  static const Color background = Color(0xFFFAFAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF15171F);
  static const Color textSecondary = Color(0xFF6B6F7B);
  static const Color divider = Color(0xFFE6E7EC);

  // --- Spacing tokens (4pt scale) --------------------------------------
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;

  // --- Radius tokens ----------------------------------------------------
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusPill = 100;

  static ThemeData get light {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ).copyWith(surface: surface, primary: primary),
      scaffoldBackgroundColor: background,
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: base.textTheme.displaySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.15,
          letterSpacing: -0.5,
        ),
        headlineMedium: base.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: textPrimary,
          height: 1.2,
          letterSpacing: -0.3,
        ),
        bodyLarge: base.textTheme.bodyLarge?.copyWith(
          color: textSecondary,
          height: 1.5,
        ),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(
          color: textSecondary,
          height: 1.5,
        ),
        labelLarge: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: divider, width: 1.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusPill),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textSecondary,
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
    );
  }
}