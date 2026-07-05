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

  /// Lato del quadrato. `null` = riempi il genitore (per griglie/hero).
  final double? size;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget contenuto;
    if (fotoUrl != null) {
      final async = ref.watch(fotoAvvistamentoUrlProvider(fotoUrl!));
      contenuto = async.maybeWhen(
        // Se il signed URL non si carica (es. Safari/CanvasKit su cross-origin),
        // ripiega sulla thumbnail della specie invece di restare vuoto.
        data: (url) => url == null
            ? _SpecieFallback(nomeScientifico)
            : _rete(url, fallback: _SpecieFallback(nomeScientifico)),
        orElse: () => const _Placeholder(),
      );
    } else {
      contenuto = _SpecieFallback(nomeScientifico);
    }
    final clip = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: contenuto,
    );
    // size null -> riempie il genitore (il chiamante fornisce i vincoli).
    return size == null
        ? SizedBox.expand(child: clip)
        : SizedBox(width: size, height: size, child: clip);
  }

  static Widget _rete(String url, {Widget fallback = const _Placeholder()}) =>
      Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
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
      data: (url) =>
          url == null ? const _Placeholder() : AvvistamentoFoto._rete(url),
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
