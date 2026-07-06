import 'package:flutter/material.dart';

/// Larghezza massima dei contenuti "a colonna" (mobile-first). Su desktop/web
/// evita che le schermate si stirino a tutta larghezza; su telefono non ha
/// effetto (lo schermo è più stretto).
const double kLarghezzaMassimaContenuto = 640;

/// Centra il figlio e ne limita la larghezza a [kLarghezzaMassimaContenuto].
/// Usato per Home e Collezione (Avvistati/Raccolte/Desideri); Mappa e Profilo
/// restano a piena larghezza.
class ContenutoCentrato extends StatelessWidget {
  const ContenutoCentrato({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kLarghezzaMassimaContenuto),
        child: child,
      ),
    );
  }
}
