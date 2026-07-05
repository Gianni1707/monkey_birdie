import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/nome_specie.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../profilo/application/profilo_providers.dart' show ricercaCatalogoProvider;
import 'desiderio_button.dart';

/// Foglio di ricerca nel catalogo per aggiungere una specie ai desideri (UT07).
/// Riusa `ricercaCatalogoProvider` (cercaCatalogo) e il toggle sincronizzato.
Future<void> mostraAggiungiDesiderio(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _AggiungiDesiderioSheet(),
  );
}

class _AggiungiDesiderioSheet extends ConsumerStatefulWidget {
  const _AggiungiDesiderioSheet();

  @override
  ConsumerState<_AggiungiDesiderioSheet> createState() =>
      _AggiungiDesiderioSheetState();
}

class _AggiungiDesiderioSheetState
    extends ConsumerState<_AggiungiDesiderioSheet> {
  final TextEditingController _q = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.addToWishlist,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _q,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l10n.searchSpeciesHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _risultati(context, l10n)),
          ],
        ),
      ),
    );
  }

  Widget _risultati(BuildContext context, AppLocalizations l10n) {
    if (_query.trim().length < 2) {
      return Center(
        child: Text(
          l10n.searchSpeciesTypeHint,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }
    final async = ref.watch(ricercaCatalogoProvider(_query.trim()));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (specie) {
        if (specie.isEmpty) {
          return Center(child: Text(l10n.searchSpeciesNoResults));
        }
        return ListView.builder(
          itemCount: specie.length,
          itemBuilder: (_, i) {
            final s = specie[i];
            return ListTile(
              leading: AvvistamentoFoto(
                fotoUrl: null,
                nomeScientifico: s.nomeScientifico,
                size: 44,
              ),
              title: Text(s.nomeDaMostrare),
              subtitle: Text(
                s.nomeScientifico,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              trailing: DesiderioIconButton(specieId: s.id),
            );
          },
        );
      },
    );
  }
}
