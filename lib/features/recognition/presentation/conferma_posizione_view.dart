import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../l10n/app_localizations.dart';
import '../../map/presentation/mappa_base.dart';
import '../application/recognition_controller.dart';
import '../application/recognition_state.dart';

/// Passo di conferma posizione (obbligatoria, niente placeholder):
/// - automatica affidabile: pin gia' posizionato, trascinabile per correggere;
/// - ricaduta manuale: nessun pin, l'utente tocca la mappa per posizionarlo.
/// "Conferma" e' attivo solo quando c'e' un pin.
class ConfermaPosizioneView extends ConsumerStatefulWidget {
  const ConfermaPosizioneView({super.key, required this.stato});
  final RecognitionConfermaPosizione stato;

  @override
  ConsumerState<ConfermaPosizioneView> createState() =>
      _ConfermaPosizioneViewState();
}

class _ConfermaPosizioneViewState
    extends ConsumerState<ConfermaPosizioneView> {
  final MapController _controller = MapController();
  LatLng? _pin;

  static const LatLng _centroDefault = LatLng(45.0, 10.0); // Europa

  @override
  void initState() {
    super.initState();
    final p = widget.stato.pinIniziale;
    if (p != null) _pin = LatLng(p.lat, p.lng);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  LatLng get _centroIniziale {
    if (_pin != null) return _pin!;
    final hint = widget.stato.centroHint;
    return hint != null ? LatLng(hint.lat, hint.lng) : _centroDefault;
  }

  double get _zoomIniziale =>
      _pin != null ? 15 : (widget.stato.centroHint != null ? 12 : 4);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ctrl = ref.read(recognitionControllerProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.confirmLocationTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                widget.stato.affidabile
                    ? l10n.confirmLocationAuto
                    : l10n.confirmLocationManual,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Expanded(
          child: MappaBase(
            controller: _controller,
            options: MapOptions(
              initialCenter: _centroIniziale,
              initialZoom: _zoomIniziale,
              interactionOptions: kMappaInteraction,
              onTap: (_, punto) => setState(() => _pin = punto),
            ),
            sopra: [
              if (_pin != null)
                DragMarkers(
                  markers: [
                    DragMarker(
                      point: _pin!,
                      size: const Size(48, 48),
                      offset: const Offset(0, -20),
                      onDragEnd: (_, punto) => setState(() => _pin = punto),
                      builder: (_, __, ___) => Icon(
                        Icons.location_on,
                        size: 48,
                        color: scheme.error,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: ctrl.annullaConferma,
                    child: Text(l10n.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _pin == null
                        ? null
                        : () => ctrl.confermaPosizione(
                              (lat: _pin!.latitude, lng: _pin!.longitude),
                            ),
                    icon: const Icon(Icons.check),
                    label: Text(l10n.confirm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
