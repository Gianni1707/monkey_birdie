import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/location/location_service.dart' as loc;
import '../../../data/models/avvistamento.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../../shared/widgets/state_views.dart';
import '../../collection/application/collection_controller.dart';
import '../application/geocoding_repository.dart';
import 'mappa_base.dart';

/// UT03 — mappa degli avvistamenti dell'utente. Un marcatore (foto reale, o
/// thumbnail specie in fallback) per ogni avvistamento CON posizione. La RLS
/// garantisce che si vedano solo i propri (i condivisi da amici: UT08).
class MappaScreen extends ConsumerStatefulWidget {
  const MappaScreen({super.key});

  @override
  ConsumerState<MappaScreen> createState() => _MappaScreenState();
}

class _MappaScreenState extends ConsumerState<MappaScreen> {
  final MapController _controller = MapController();
  final TextEditingController _ricercaCtrl = TextEditingController();

  static const LatLng _centroDefault = LatLng(45.0, 10.0); // Europa

  List<RisultatoLuogo> _risultati = const [];
  bool _cercando = false;
  bool _cercato = false;

  @override
  void dispose() {
    _controller.dispose();
    _ricercaCtrl.dispose();
    super.dispose();
  }

  Future<void> _cercaLuogo(String q) async {
    if (q.trim().length < 2) return;
    setState(() => _cercando = true);
    final res = await ref.read(geocodingRepositoryProvider).cerca(q);
    if (!mounted) return;
    setState(() {
      _risultati = res;
      _cercando = false;
      _cercato = true;
    });
  }

  void _vaiAlLuogo(RisultatoLuogo r) {
    FocusScope.of(context).unfocus();
    // Zoom in base al tipo (via -> vicino, paese -> largo): niente dezoom
    // eccessivo sui luoghi piccoli.
    _controller.move(LatLng(r.lat, r.lng), r.zoom);
    setState(() {
      _risultati = const [];
      _cercato = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncColl = ref.watch(collezioneProvider);

    return asyncColl.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: '$e',
        onRetry: () => ref.invalidate(collezioneProvider),
      ),
      data: (tutti) {
        final conPosizione = tutti
            .where((a) => a.lat != null && a.lng != null)
            .toList(growable: false);
        // La mappa si mostra SEMPRE (anche senza avvistamenti) cosi' la ricerca
        // luogo e' sempre usabile.
        final centro = conPosizione.isNotEmpty
            ? LatLng(conPosizione.first.lat!, conPosizione.first.lng!)
            : _centroDefault;
        return Stack(
          children: [
            MappaBase(
              controller: _controller,
              options: MapOptions(
                initialCenter: centro,
                initialZoom: conPosizione.isNotEmpty ? 9 : 5,
                interactionOptions: kMappaInteraction,
                onTap: (_, __) => FocusScope.of(context).unfocus(),
              ),
              sopra: [
                MarkerLayer(
                  markers: [
                    for (final a in conPosizione)
                      Marker(
                        point: LatLng(a.lat!, a.lng!),
                        width: 56,
                        height: 56,
                        // Isola il repaint del marcatore dal resto della mappa
                        // (meno lavoro grafico durante pan/zoom).
                        child: RepaintBoundary(
                          child: _MarcatoreFoto(
                            avvistamento: a,
                            onTap: () => _apriDettaglio(context, a),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            // Barra di ricerca luogo (in alto).
            Positioned(
              top: 8,
              left: 8,
              right: 8,
              child: SafeArea(
                bottom: false,
                child: _BarraRicerca(
                  controller: _ricercaCtrl,
                  cercando: _cercando,
                  risultati: _risultati,
                  nessunRisultato:
                      _cercato && !_cercando && _risultati.isEmpty,
                  onSubmit: _cercaLuogo,
                  onScegli: _vaiAlLuogo,
                ),
              ),
            ),
            Positioned(
              right: 12,
              bottom: 12,
              child: FloatingActionButton.small(
                heroTag: 'miaPosizione',
                tooltip: l10n.myLocation,
                onPressed: _vaiAllaMiaPosizione,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _vaiAllaMiaPosizione() async {
    final l10n = AppLocalizations.of(context);
    try {
      final p = await ref.read(loc.locationServiceProvider).posizioneCorrente();
      _controller.move(LatLng(p.lat, p.lng), 16);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locationUnavailable)),
      );
    }
  }

  void _apriDettaglio(BuildContext context, AvvistamentoDettaglio a) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _DettaglioAvvistamento(a),
    );
  }
}

/// Marcatore = foto dell'avvistamento in un cerchio con bordo.
class _MarcatoreFoto extends StatelessWidget {
  const _MarcatoreFoto({required this.avvistamento, required this.onTap});
  final AvvistamentoDettaglio avvistamento;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: scheme.surface, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
        ),
        child: ClipOval(
          child: AvvistamentoFoto(
            fotoUrl: avvistamento.fotoUrl,
            nomeScientifico: avvistamento.specieNomeScientifico,
            size: 50,
            borderRadius: 25,
          ),
        ),
      ),
    );
  }
}

/// Barra di ricerca luogo (geocoding) in cima alla mappa.
class _BarraRicerca extends StatelessWidget {
  const _BarraRicerca({
    required this.controller,
    required this.cercando,
    required this.risultati,
    required this.nessunRisultato,
    required this.onSubmit,
    required this.onScegli,
  });

  final TextEditingController controller;
  final bool cercando;
  final List<RisultatoLuogo> risultati;
  final bool nessunRisultato;
  final ValueChanged<String> onSubmit;
  final ValueChanged<RisultatoLuogo> onScegli;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 3,
          borderRadius: BorderRadius.circular(28),
          color: scheme.surface,
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            onSubmitted: onSubmit,
            decoration: InputDecoration(
              hintText: l10n.searchPlaceHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: cercando
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () => onSubmit(controller.text),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: scheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        if (risultati.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final r in risultati)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      r.etichetta,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => onScegli(r),
                  ),
              ],
            ),
          ),
        if (nessunRisultato)
          Card(
            margin: const EdgeInsets.only(top: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(l10n.searchNoResults),
            ),
          ),
      ],
    );
  }
}

/// Scheda che si apre toccando un marcatore: foto, specie, data + link alla
/// scheda specie esistente.
class _DettaglioAvvistamento extends StatelessWidget {
  const _DettaglioAvvistamento(this.a);
  final AvvistamentoDettaglio a;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: AvvistamentoFoto(
              fotoUrl: a.fotoUrl,
              nomeScientifico: a.specieNomeScientifico,
              size: 160,
              borderRadius: 12,
            ),
          ),
          const SizedBox(height: 12),
          Text(a.specieNomeComune, style: theme.textTheme.titleLarge),
          Text(
            a.specieNomeScientifico,
            style: theme.textTheme.titleSmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.event, size: 16, color: theme.colorScheme.outline),
              const SizedBox(width: 6),
              Text(_formatData(a.avvistatoIl)),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/specie/${a.specieId}');
            },
            icon: const Icon(Icons.menu_book_outlined),
            label: Text(l10n.speciesCardButton),
          ),
        ],
      ),
    );
  }

  static String _formatData(DateTime d) {
    String due(int n) => n.toString().padLeft(2, '0');
    return '${due(d.day)}/${due(d.month)}/${d.year}';
  }
}
