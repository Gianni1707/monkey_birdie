import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/avvistamento_foto_repository.dart';
import '../../data/repositories/specie_immagine_repository.dart';

/// Immagine di un avvistamento, riusata da mappa, collezione e dettaglio.
///
/// Mostra lo SCATTO REALE dell'utente (da `foto_url`, via signed URL) quando
/// presente; altrimenti fa fallback sulla thumbnail iNaturalist della specie
/// (avvistamenti vecchi/senza foto, es. solo-canto).
class AvvistamentoFoto extends ConsumerWidget {
  const AvvistamentoFoto({
    super.key,
    required this.fotoUrl,
    required this.nomeScientifico,
    this.size = 52,
    this.borderRadius = 8,
  });

  final String? fotoUrl; // path nel bucket (o null)
  final String nomeScientifico;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget contenuto;
    if (fotoUrl != null) {
      final async = ref.watch(fotoAvvistamentoUrlProvider(fotoUrl!));
      contenuto = async.maybeWhen(
        data: (url) => url == null
            ? _SpecieFallback(nomeScientifico)
            : _rete(url),
        orElse: () => const _Placeholder(),
      );
    } else {
      contenuto = _SpecieFallback(nomeScientifico);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(width: size, height: size, child: contenuto),
    );
  }

  static Widget _rete(String url) => Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const _Placeholder(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : const _Placeholder(),
      );
}

/// Fallback: thumbnail della specie (per nome scientifico) da iNaturalist.
class _SpecieFallback extends ConsumerWidget {
  const _SpecieFallback(this.nomeScientifico);
  final String nomeScientifico;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(specieThumbnailProvider(nomeScientifico));
    return async.maybeWhen(
      data: (url) => url == null
          ? const _Placeholder()
          : AvvistamentoFoto._rete(url),
      orElse: () => const _Placeholder(),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.photo_outlined,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
