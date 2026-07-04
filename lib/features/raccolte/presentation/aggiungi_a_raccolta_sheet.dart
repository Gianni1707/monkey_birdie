import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/raccolte_providers.dart';
import 'raccolta_dialoghi.dart';

/// Apre il foglio "Aggiungi a una raccolta" per un avvistamento.
Future<void> mostraAggiungiARaccolta(
  BuildContext context,
  String avvistamentoId,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _AggiungiARaccoltaSheet(avvistamentoId: avvistamentoId),
  );
}

/// Selezione multipla delle raccolte in cui mettere/togliere un avvistamento.
/// Pre-spunta quelle che gia' lo contengono; su "Fatto" applica solo i diff.
class _AggiungiARaccoltaSheet extends ConsumerStatefulWidget {
  const _AggiungiARaccoltaSheet({required this.avvistamentoId});
  final String avvistamentoId;

  @override
  ConsumerState<_AggiungiARaccoltaSheet> createState() =>
      _AggiungiARaccoltaSheetState();
}

class _AggiungiARaccoltaSheetState
    extends ConsumerState<_AggiungiARaccoltaSheet> {
  Set<String>? _iniziali; // raccolte che gia' lo contengono
  Set<String> _scelte = {};
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carica();
  }

  Future<void> _carica() async {
    final ini = await ref
        .read(raccolteDiAvvistamentoProvider(widget.avvistamentoId).future);
    if (!mounted) return;
    setState(() {
      _iniziali = {...ini};
      _scelte = {...ini};
    });
  }

  Future<void> _nuova() async {
    final r = await mostraNuovaRaccolta(context, ref);
    if (r == null || !mounted) return;
    setState(() => _scelte = {..._scelte, r.id});
  }

  Future<void> _salva() async {
    final iniziali = _iniziali ?? const {};
    final daAggiungere = _scelte.difference(iniziali);
    final daTogliere = iniziali.difference(_scelte);
    if (daAggiungere.isEmpty && daTogliere.isEmpty) {
      Navigator.pop(context);
      return;
    }
    setState(() => _salvando = true);
    final ctrl = ref.read(raccolteControllerProvider);
    try {
      for (final id in daAggiungere) {
        await ctrl.aggiungi(
          raccoltaId: id,
          avvistamentoId: widget.avvistamentoId,
        );
      }
      for (final id in daTogliere) {
        await ctrl.rimuovi(
          raccoltaId: id,
          avvistamentoId: widget.avvistamentoId,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final raccolte = ref.watch(mieRaccolteProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.addToCollection,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.create_new_folder_outlined),
              title: Text(l10n.newCollection),
              onTap: _nuova,
            ),
            const Divider(height: 1),
            Flexible(
              child: raccolte.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('$e'),
                ),
                data: (lista) {
                  if (lista.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.noCollectionsYet,
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (_iniziali == null) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return ListView(
                    shrinkWrap: true,
                    children: [
                      for (final r in lista)
                        CheckboxListTile(
                          value: _scelte.contains(r.id),
                          title: Text(r.nome),
                          onChanged: (v) => setState(() {
                            if (v == true) {
                              _scelte = {..._scelte, r.id};
                            } else {
                              _scelte = {..._scelte}..remove(r.id);
                            }
                          }),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _salvando || _iniziali == null ? null : _salva,
              child: _salvando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }
}
