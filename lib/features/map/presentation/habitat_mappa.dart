import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../../l10n/app_localizations.dart';
import '../application/gbif_repository.dart';
import '../application/habitat_providers.dart';
import 'mappa_base.dart';

/// UT05 — "Dove vive": distribuzione della specie da GBIF (overlay di densità)
/// + i propri avvistamenti e quelli condivisi dagli amici come pallini.
/// Additivo: riusa [MappaBase] (motore mappa intatto).

/// Mappa non interattiva: la mini-mappa cattura il solo tap (→ full-screen).
const InteractionOptions _kNessunaInterazione =
    InteractionOptions(flags: InteractiveFlag.none);

/// Planisfero: l'intero mondo (poli estremi esclusi, dove Mercatore stira
/// troppo) da inquadrare nella mappa habitat. La distribuzione GBIF si legge
/// così a colpo d'occhio su scala globale, invece di partire zoomati sui propri
/// avvistamenti.
final LatLngBounds _boundsMondo = LatLngBounds(
  const LatLng(-56, -180),
  const LatLng(72, 180),
);

/// Inquadratura "planisfero": fa stare tutto il mondo nella viewport (usata sia
/// dalla mini-mappa sia dalla full-screen come punto di partenza).
CameraFit get _fitMondo =>
    CameraFit.bounds(bounds: _boundsMondo, padding: const EdgeInsets.all(4));

/// Layer sopra le tile OSM: overlay densità GBIF (se `taxonKey` risolto) + i
/// pallini degli avvistamenti (propri vs amici). Condiviso mini/full-screen.
List<Widget> _sopra(
  BuildContext context,
  int? taxonKey,
  AvvistamentiSpecie? dati,
) {
  final scheme = Theme.of(context).colorScheme;
  return [
    if (taxonKey != null)
      TileLayer(
        urlTemplate: GbifRepository.densityTileUrl(taxonKey),
        userAgentPackageName: 'com.monkeybird.monkey_bird',
        // Provider che tratta i tile vuoti/204 (zone senza occorrenze) come
        // trasparenti: niente decodifiche fallite a raffica sul planisfero.
        tileProvider: _GbifTileProvider(),
        // Overlay semitrasparente: la mappa base resta leggibile sotto.
        tileBuilder: (context, tileWidget, tile) =>
            Opacity(opacity: 0.7, child: tileWidget),
        errorTileCallback: (_, __, ___) {},
      ),
    if (dati != null)
      MarkerLayer(
        markers: [
          for (final a in dati.avvistamenti)
            Marker(
              point: LatLng(a.lat!, a.lng!),
              width: 16,
              height: 16,
              child: _Pallino(altrui: a.utenteId != dati.mioId, scheme: scheme),
            ),
        ],
      ),
  ];
}

/// Pallino avvistamento: `primary` per i propri, `tertiary` per gli amici
/// (coerente col bordo dei marcatori-foto della mappa principale).
class _Pallino extends StatelessWidget {
  const _Pallino({required this.altrui, required this.scheme});
  final bool altrui;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: altrui ? scheme.tertiary : scheme.primary,
        border: Border.all(color: scheme.surface, width: 2),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 2)],
      ),
    );
  }
}

/// Attribuzione GBIF (richiesta) come chip discreto in basso a destra.
class _AttribuzioneGbif extends StatelessWidget {
  const _AttribuzioneGbif();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // In ALTO a sinistra: separata da "Tocca per ingrandire" (in basso a
    // sinistra) e dallo spinner (in alto a destra) -> niente sovrapposizioni.
    return Positioned(
      top: 4,
      left: 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(
            AppLocalizations.of(context).distributionSource,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    );
  }
}

/// Mini-mappa dentro la scheda specie: non interattiva, tap → full-screen.
/// La mappa base si mostra SEMPRE; l'overlay GBIF arriva quando il taxonKey è
/// risolto; se non c'è match → nota "distribuzione non disponibile".
class HabitatMiniMappa extends ConsumerStatefulWidget {
  const HabitatMiniMappa({
    super.key,
    required this.specieId,
    required this.nomeScientifico,
  });

  final String specieId;
  final String nomeScientifico;

  @override
  ConsumerState<HabitatMiniMappa> createState() => _HabitatMiniMappaState();
}

class _HabitatMiniMappaState extends ConsumerState<HabitatMiniMappa> {
  final MapController _controller = MapController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncTaxon = ref.watch(gbifTaxonKeyProvider(widget.nomeScientifico));
    final asyncAvv = ref.watch(avvistamentiSpecieProvider(widget.specieId));

    final taxonKey = asyncTaxon.valueOrNull;
    final dati = asyncAvv.valueOrNull;
    // "Non disponibile": il match è finito (non in loading) e non c'è taxonKey.
    final nonDisponibile = !asyncTaxon.isLoading && taxonKey == null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 190,
            child: Stack(
              children: [
                MappaBase(
                  controller: _controller,
                  options: MapOptions(
                    // Planisfero: tutto il mondo nella preview.
                    initialCameraFit: _fitMondo,
                    interactionOptions: _kNessunaInterazione,
                  ),
                  sopra: _sopra(context, taxonKey, dati),
                ),
                const _AttribuzioneGbif(),
                // Overlay tap → full-screen (la mappa qui è non interattiva).
                Positioned.fill(
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => HabitatMappaScreen(
                            specieId: widget.specieId,
                            nomeScientifico: widget.nomeScientifico,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (asyncTaxon.isLoading)
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                Positioned(
                  left: 8,
                  bottom: 8,
                  child: _EtichettaEspandi(testo: l10n.tapToExpand),
                ),
              ],
            ),
          ),
        ),
        if (nonDisponibile) ...[
          const SizedBox(height: 6),
          Text(
            l10n.distributionUnavailable,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ],
    );
  }
}

/// Mappa habitat a schermo intero (interattiva): stessi layer della mini-mappa.
class HabitatMappaScreen extends ConsumerStatefulWidget {
  const HabitatMappaScreen({
    super.key,
    required this.specieId,
    required this.nomeScientifico,
  });

  final String specieId;
  final String nomeScientifico;

  @override
  ConsumerState<HabitatMappaScreen> createState() =>
      _HabitatMappaScreenState();
}

class _HabitatMappaScreenState extends ConsumerState<HabitatMappaScreen> {
  final MapController _controller = MapController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncTaxon = ref.watch(gbifTaxonKeyProvider(widget.nomeScientifico));
    final asyncAvv = ref.watch(avvistamentiSpecieProvider(widget.specieId));

    final taxonKey = asyncTaxon.valueOrNull;
    final dati = asyncAvv.valueOrNull;
    final nonDisponibile = !asyncTaxon.isLoading && taxonKey == null;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.whereItLives)),
      body: Stack(
        children: [
          MappaBase(
            controller: _controller,
            options: MapOptions(
              // Parte dal planisfero (poi l'utente può zoomare sui pallini).
              initialCameraFit: _fitMondo,
              interactionOptions: kMappaInteraction,
            ),
            sopra: _sopra(context, taxonKey, dati),
          ),
          const _AttribuzioneGbif(),
          if (asyncTaxon.isLoading)
            const Positioned(
              top: 12,
              right: 12,
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          if (nonDisponibile)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(l10n.distributionUnavailable),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Piccola etichetta "tocca per ingrandire" sulla mini-mappa.
class _EtichettaEspandi extends StatelessWidget {
  const _EtichettaEspandi({required this.testo});
  final String testo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.zoom_out_map, size: 14, color: scheme.onSurface),
            const SizedBox(width: 4),
            Text(testo, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}

/// TileProvider per l'overlay di densità GBIF. I tile delle zone senza
/// occorrenze arrivano come `204 No Content` a corpo vuoto: decodificarli
/// fallirebbe ("Invalid image data") una volta per tile — rumoroso sul
/// planisfero. Qui, corpo vuoto/204 → tile **trasparente** 1×1.
/// `headers: {}` (mutabile) è necessario: `TileLayer` inietta lo user-agent con
/// `headers.putIfAbsent(...)`, che su una mappa immutabile lancerebbe.
class _GbifTileProvider extends TileProvider {
  _GbifTileProvider() : super(headers: {});

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    return _TileTrasparenteSuVuoto(getTileUrl(coordinates, options), headers);
  }
}

/// ImageProvider che scarica il tile e, se la risposta è vuota/204 o va in
/// errore, ripiega su un pixel trasparente invece di far fallire la decodifica.
class _TileTrasparenteSuVuoto
    extends ImageProvider<_TileTrasparenteSuVuoto> {
  _TileTrasparenteSuVuoto(this.url, this.headers);
  final String url;
  final Map<String, String> headers;

  @override
  Future<_TileTrasparenteSuVuoto> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _TileTrasparenteSuVuoto key,
    ImageDecoderCallback decode,
  ) =>
      OneFrameImageStreamCompleter(_carica(decode));

  Future<ImageInfo> _carica(ImageDecoderCallback decode) async {
    try {
      final resp = await http
          .get(Uri.parse(url), headers: headers)
          .timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200 && resp.bodyBytes.isNotEmpty) {
        final buffer = await ui.ImmutableBuffer.fromUint8List(resp.bodyBytes);
        final codec = await decode(buffer);
        final frame = await codec.getNextFrame();
        return ImageInfo(image: frame.image);
      }
    } catch (_) {
      // rete/decodifica fallita -> tile trasparente (sotto).
    }
    return ImageInfo(image: await _pixelTrasparente());
  }

  /// 1×1 RGBA tutto a zero, costruito senza decodificare alcun formato: non
  /// può fallire (il decoder di alcuni device rifiuta certi PNG/tile vuoti).
  static Future<ui.Image> _pixelTrasparente() async {
    final buffer = await ui.ImmutableBuffer.fromUint8List(
      Uint8List.fromList(const [0, 0, 0, 0]),
    );
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: 1,
      height: 1,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  bool operator ==(Object other) =>
      other is _TileTrasparenteSuVuoto && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
