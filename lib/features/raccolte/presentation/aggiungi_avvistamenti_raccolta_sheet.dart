import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/avvistamento.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/nome_specie.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../collection/application/collection_controller.dart';
import '../application/raccolte_providers.dart';

/// Apre il foglio per aggiungere avvistamenti (dalla propria collezione) a una
/// raccolta, dall'INTERNO della raccolta stessa.
Future<void> mostraAggiungiAvvistamentiARaccolta(
  BuildContext context,
  String raccoltaId,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AggiungiAvvistamentiSheet(raccoltaId: raccoltaId),
  );
}

/// Sottotitolo di un avvistamento nel foglio: giorno + luogo (coordinate, se
/// presenti). Le coordinate sono l'unico "luogo" salvato (niente nome-luogo).
String _sottotitolo(AvvistamentoDettaglio a) {
  final d = a.avvistatoIl;
  String due(int n) => n.toString().padLeft(2, '0');
  final data = '${due(d.day)}/${due(d.month)}/${d.year}';
  if (a.lat != null && a.lng != null) {
    return '$data · ${a.lat!.toStringAsFixed(3)}, ${a.lng!.toStringAsFixed(3)}';
  }
  return data;
}

/// Elenca gli avvistamenti dell'utente NON ancora nella raccolta; selezione
/// multipla; su "Aggiungi (N)" li inserisce tutti. Riusa `collezioneProvider`
/// (nessuna query extra) e il `raccolteControllerProvider` esistente.
class _AggiungiAvvistamentiSheet extends ConsumerStatefulWidget {
  const _AggiungiAvvistamentiSheet({required this.raccoltaId});
  final String raccoltaId;

  @override
  ConsumerState<_AggiungiAvvistamentiSheet> createState() =>
      _AggiungiAvvistamentiSheetState();
}

class _AggiungiAvvistamentiSheetState
    extends ConsumerState<_AggiungiAvvistamentiSheet> {
  final Set<String> _scelti = {};
  bool _salvando = false;

  Future<void> _salva() async {
    if (_scelti.isEmpty) return;
    setState(() => _salvando = true);
    final ctrl = ref.read(raccolteControllerProvider);
    try {
      for (final id in _scelti) {
        await ctrl.aggiungi(raccoltaId: widget.raccoltaId, avvistamentoId: id);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      final msg = e is Failure ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final collezione = ref.watch(collezioneProvider);
    final giaDentro =
        ref.watch(contenutoRaccoltaProvider(widget.raccoltaId)).valueOrNull;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.addSightings, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Flexible(
              child: collezione.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('$e'),
                data: (tutti) {
                  final dentro = {...?giaDentro?.map((a) => a.id)};
                  final disponibili = tutti
                      .where((a) => !dentro.contains(a.id))
                      .toList(growable: false);
                  if (disponibili.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        l10n.allSightingsInCollection,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: disponibili.length,
                    itemBuilder: (_, i) {
                      final a = disponibili[i];
                      final scelto = _scelti.contains(a.id);
                      return CheckboxListTile(
                        value: scelto,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.trailing,
                        secondary: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AvvistamentoFoto(
                            fotoUrl: a.fotoUrl,
                            nomeScientifico: a.specieNomeScientifico,
                            size: 48,
                            borderRadius: 8,
                          ),
                        ),
                        title: Text(a.specieNomeDaMostrare),
                        // Giorno + luogo (coordinate) dell'avvistamento: più utili
                        // del nome scientifico per distinguere scatti della stessa
                        // specie.
                        subtitle: Text(
                          _sottotitolo(a),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _scelti.add(a.id);
                          } else {
                            _scelti.remove(a.id);
                          }
                        }),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: (_scelti.isEmpty || _salvando) ? null : _salva,
              child: _salvando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.addSelectedCount(_scelti.length)),
            ),
          ],
        ),
      ),
    );
  }
}
