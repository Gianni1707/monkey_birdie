import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/contenuto_centrato.dart';
import '../application/dintorni_providers.dart';
import 'dintorni_widgets.dart';

/// Lista completa "Uccelli nei dintorni": due fasce — prima gli avvistamenti
/// community (dato reale), poi le specie GBIF presenti in zona (dato storico).
class DintorniScreen extends ConsumerWidget {
  const DintorniScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(uccelliVicinoProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.nearbyTitle)),
      body: ContenutoCentrato(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => DintorniPermessoNegato(
            onRiprova: () => riprovaDintorni(ref),
          ),
          data: (lista) {
            if (lista.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l10n.nearbyNoData,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              );
            }
            final community = lista.where((s) => s.community).toList();
            final gbif = lista.where((s) => !s.community).toList();
            return ListView(
              children: [
                if (community.isNotEmpty) ...[
                  _Intestazione(l10n.nearbySeenRecently),
                  for (final s in community) SpecieVicinaTile(s),
                ],
                if (gbif.isNotEmpty) ...[
                  _Intestazione(l10n.nearbyPresentInArea),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: Text(
                      l10n.nearbyGbifNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                  for (final s in gbif) SpecieVicinaTile(s),
                ],
                const SizedBox(height: 16),
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<void> riprovaDintorni(WidgetRef ref) async {
  // Su nativo richiede il permesso (e apre le impostazioni se negato per sempre);
  // sul web è il browser a gestire il prompt al retry.
  if (!kIsWeb) {
    final perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
    }
  }
  ref.invalidate(posizioneDintorniProvider);
  ref.invalidate(uccelliVicinoProvider);
}

class _Intestazione extends StatelessWidget {
  const _Intestazione(this.testo);
  final String testo;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        testo,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Messaggio + azione quando la posizione non è disponibile (permesso negato,
/// GPS off). Riusato dalla sezione Home e dalla schermata completa.
class DintorniPermessoNegato extends StatelessWidget {
  const DintorniPermessoNegato({super.key, required this.onRiprova});
  final Future<void> Function() onRiprova;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off_outlined, size: 40, color: scheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              l10n.nearbyEnableLocation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRiprova,
              icon: const Icon(Icons.my_location),
              label: Text(l10n.nearbyEnableButton),
            ),
          ],
        ),
      ),
    );
  }
}
