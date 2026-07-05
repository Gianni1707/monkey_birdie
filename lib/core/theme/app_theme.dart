import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema centralizzato "guida da campo" (restyle UI).
/// - Titoli in **Source Serif 4** (serif), corpo/etichette in **Inter**.
/// - Card chiare, angoli morbidi, ombra tenue; molto spazio bianco.
/// I colori passano da [AppColors] (token) → ruoli Material 3, così un tema
/// scuro futuro sarà una seconda mappatura senza toccare le schermate.
abstract final class AppTheme {
  static const _serif = 'SourceSerif4';
  static const _sans = 'Inter';

  static ThemeData light() {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.background,
      onSurface: AppColors.neutral,
      onSurfaceVariant: AppColors.neutralMuted,
      surfaceContainerLowest: AppColors.surfaceWhite,
      surfaceContainerLow: AppColors.surfaceLow,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: AppColors.surfaceHighest,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: AppColors.shadow,
    );

    final text = _textTheme(scheme.onSurface, scheme.onSurfaceVariant);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: _sans,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.shadow,
        elevation: 1.5,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceWhite,
        selectedColor: AppColors.primaryContainer,
        checkmarkColor: AppColors.onPrimaryContainer,
        side: const BorderSide(color: AppColors.outline),
        shape: const StadiumBorder(),
        labelStyle: text.labelLarge,
        secondaryLabelStyle: text.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          textStyle: text.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: text.labelLarge,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceWhite,
        hintStyle: text.bodyMedium?.copyWith(color: AppColors.neutralMuted),
        prefixIconColor: AppColors.neutralMuted,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surfaceWhite,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.primaryContainer,
        elevation: 3,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (s) => text.labelMedium?.copyWith(
            color: s.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.neutralMuted,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (s) => IconThemeData(
            color: s.contains(WidgetState.selected)
                ? AppColors.onPrimaryContainer
                : AppColors.neutralMuted,
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      iconTheme: const IconThemeData(color: AppColors.neutral),
    );
  }

  /// Titoli/display/headline in serif; corpo ed etichette in Inter.
  static TextTheme _textTheme(Color onSurface, Color muted) {
    TextStyle serif(double size, FontWeight w, {double h = 1.2}) => TextStyle(
          fontFamily: _serif,
          fontSize: size,
          fontWeight: w,
          height: h,
          color: onSurface,
        );
    TextStyle sans(double size, FontWeight w, {Color? c, double h = 1.4}) =>
        TextStyle(
          fontFamily: _sans,
          fontSize: size,
          fontWeight: w,
          height: h,
          color: c ?? onSurface,
        );

    return TextTheme(
      displayLarge: serif(40, FontWeight.w600),
      displayMedium: serif(32, FontWeight.w600),
      displaySmall: serif(28, FontWeight.w600),
      headlineLarge: serif(26, FontWeight.w600),
      headlineMedium: serif(22, FontWeight.w600),
      headlineSmall: serif(20, FontWeight.w600),
      titleLarge: serif(20, FontWeight.w600),
      titleMedium: serif(17, FontWeight.w600),
      titleSmall: sans(14, FontWeight.w600),
      bodyLarge: sans(16, FontWeight.w400),
      bodyMedium: sans(14, FontWeight.w400),
      bodySmall: sans(12, FontWeight.w400, c: muted),
      labelLarge: sans(14, FontWeight.w600),
      labelMedium: sans(12, FontWeight.w600),
      labelSmall: sans(11, FontWeight.w500, c: muted),
    );
  }
}
