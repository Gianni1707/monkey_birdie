import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_preview.dart';

/// Entrypoint SEPARATO solo per rendere la galleria del design system:
///   flutter run -t lib/theme_preview_main.dart -d <device>
/// Non tocca `main.dart`/`app.dart`: l'app vera resta col tema attuale finché
/// il nuovo tema non è approvato e cablato.
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MonkeyBirdie — Design system',
      theme: AppTheme.light(),
      home: const ThemePreviewScreen(),
    ),
  );
}
