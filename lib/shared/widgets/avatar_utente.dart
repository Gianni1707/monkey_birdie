import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/profilo.dart';
import '../../data/repositories/profilo_repository.dart';

/// Avatar di un utente in sola lettura (foto profilo o iniziale dello username).
/// Riusato da tile amici, ricerca utenti e profilo pubblico. La foto sta in
/// `dati_personali['avatar']` (path nel bucket pubblico `avatar`).
class AvatarUtente extends ConsumerWidget {
  const AvatarUtente({super.key, required this.profilo, this.size = 44});
  final Profilo profilo;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final path = profilo.datiPersonali['avatar'];
    if (path is String && path.isNotEmpty) {
      final url = ref.read(profiloRepositoryProvider).urlAvatar(path);
      return ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          errorBuilder: (_, __, ___) => _iniziale(scheme),
        ),
      );
    }
    return _iniziale(scheme);
  }

  Widget _iniziale(ColorScheme scheme) => CircleAvatar(
        radius: size / 2,
        backgroundColor: scheme.primaryContainer,
        child: Text(
          profilo.username.isEmpty ? '?' : profilo.username[0].toUpperCase(),
          style: TextStyle(
            fontSize: size * 0.44,
            color: scheme.onPrimaryContainer,
          ),
        ),
      );
}
