import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/mappa_providers.dart';

/// Interazioni mappa condivise: tutto TRANNE la rotazione (niente mappa storta a
/// 360°). Usata da schermata mappa e conferma-posizione.
const InteractionOptions kMappaInteraction = InteractionOptions(
  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
);

/// Base mappa riusata da schermata mappa e conferma-posizione: tile RASTER
/// OpenStreetMap con cache persistente su disco. I livelli sopra (marker, pin
/// trascinabile...) sono forniti da chi la usa.
class MappaBase extends ConsumerWidget {
  const MappaBase({
    super.key,
    required this.controller,
    required this.options,
    required this.sopra,
  });

  final MapController controller;
  final MapOptions options;

  /// Livelli sopra le tile (MarkerLayer, DragMarkers, ...).
  final List<Widget> sopra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storeAsync = ref.watch(tileCacheStoreProvider);
    // Con la cache pronta -> provider cache-first (offline-friendly); mentre si
    // inizializza -> provider di rete semplice, cosi' la mappa parte subito.
    final TileProvider tileProvider = storeAsync.maybeWhen(
      data: (store) => CachedTileProvider(
        store: store,
        maxStale: const Duration(days: 30),
        dio: Dio(BaseOptions(headers: const {'User-Agent': tileUserAgent})),
      ),
      orElse: () => NetworkTileProvider(
        headers: const {'User-Agent': tileUserAgent},
      ),
    );

    return FlutterMap(
      mapController: controller,
      options: options,
      children: [
        TileLayer(
          urlTemplate: osmTileUrl,
          userAgentPackageName: 'com.monkeybird.monkey_bird',
          maxNativeZoom: 19,
          tileProvider: tileProvider,
        ),
        ...sopra,
        // Attribuzione richiesta da OpenStreetMap.
        const RichAttributionWidget(
          alignment: AttributionAlignment.bottomLeft,
          attributions: [
            TextSourceAttribution('© OpenStreetMap'),
          ],
        ),
      ],
    );
  }
}
