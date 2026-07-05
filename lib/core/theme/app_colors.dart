import 'package:flutter/material.dart';

/// Token colore del design system "guida da campo" (restyle UI).
/// Sono i valori GREZZI: il `ColorScheme` in [AppTheme] li mappa nei ruoli
/// Material 3. Strutturati come token così un tema scuro sarà possibile in
/// futuro (basterà una seconda mappa, senza cambiare le schermate).
abstract final class AppColors {
  // --- Brand ---
  /// Verde bosco (primario).
  static const primary = Color(0xFF234F3E);
  static const primaryHover = Color(0xFF1B3E31);
  static const onPrimary = Color(0xFFF8F6EF);

  /// Verde tenue per superfici/contenitori primari.
  static const primaryContainer = Color(0xFFD8E4DC);
  static const onPrimaryContainer = Color(0xFF12271E);

  /// Rosso mattone (secondario).
  static const secondary = Color(0xFFA14743);
  static const onSecondary = Color(0xFFF8F6EF);
  static const secondaryContainer = Color(0xFFF0DAD8);
  static const onSecondaryContainer = Color(0xFF3A1614);

  /// Accento caldo terroso (usato con parsimonia: es. marcatori "amici").
  static const tertiary = Color(0xFF9C7A3C);
  static const onTertiary = Color(0xFFF8F6EF);
  static const tertiaryContainer = Color(0xFFEFE3C9);
  static const onTertiaryContainer = Color(0xFF2E230F);

  // --- Neutri / superfici ---
  /// Crema di sfondo (scaffold).
  static const background = Color(0xFFF8F6EF);

  /// Testo principale.
  static const neutral = Color(0xFF2A2A24);

  /// Testo attenuato / etichette secondarie.
  static const neutralMuted = Color(0xFF5C5B52);

  /// Superfici card, dalla più chiara (bianca) alle tonalità crema.
  static const surfaceWhite = Color(0xFFFFFFFF);
  static const surfaceLow = Color(0xFFFCFBF7);
  static const surface = Color(0xFFF3F0E7);
  static const surfaceHigh = Color(0xFFEDE9DE);
  static const surfaceHighest = Color(0xFFE7E2D5);

  /// Bordi tenui.
  static const outline = Color(0xFFD8D3C4);
  static const outlineVariant = Color(0xFFE7E2D5);

  // --- Stati ---
  static const error = Color(0xFFB3261E);
  static const onError = Color(0xFFF8F6EF);
  static const success = Color(0xFF3E6B4A);

  /// Ombra tenue delle card.
  static const shadow = Color(0x1A2A2A24);
}
