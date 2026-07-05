import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/raccolta.dart';
import '../../../l10n/app_localizations.dart';
import '../application/raccolte_providers.dart';

/// Dialoghi condivisi per creare/rinominare/eliminare una raccolta, con la
/// gestione dei casi limite (nome vuoto, nome duplicato case-insensitive) in un
/// solo posto. Riusati da elenco, dettaglio e foglio "aggiungi a raccolta".

/// Crea una nuova raccolta; ritorna quella creata (o null se annullato/errore).
Future<Raccolta?> mostraNuovaRaccolta(
  BuildContext context,
  WidgetRef ref,
) async {
  final l10n = AppLocalizations.of(context);
  final dati = await showDialog<({String nome, String? descrizione})>(
    context: context,
    builder: (_) =>
        _DialogoNome(titolo: l10n.newCollection, azione: l10n.create),
  );
  if (dati == null) return null;
  try {
    return await ref
        .read(raccolteControllerProvider)
        .crea(nome: dati.nome, descrizione: dati.descrizione);
  } catch (e) {
    if (context.mounted) _errore(context, e);
    return null;
  }
}

/// Rinomina una raccolta; ritorna true se completata.
Future<bool> mostraRinominaRaccolta(
  BuildContext context,
  WidgetRef ref,
  Raccolta r,
) async {
  final l10n = AppLocalizations.of(context);
  final dati = await showDialog<({String nome, String? descrizione})>(
    context: context,
    builder: (_) => _DialogoNome(
      titolo: l10n.renameCollection,
      azione: l10n.save,
      nomeIniziale: r.nome,
      descrizioneIniziale: r.descrizione,
      escludiId: r.id,
    ),
  );
  if (dati == null) return false;
  try {
    await ref.read(raccolteControllerProvider).rinomina(
          id: r.id,
          nome: dati.nome,
          descrizione: dati.descrizione,
        );
    return true;
  } catch (e) {
    if (context.mounted) _errore(context, e);
    return false;
  }
}

/// Chiede conferma ed elimina la raccolta (gli avvistamenti restano).
/// Ritorna true se eliminata.
Future<bool> mostraEliminaRaccolta(
  BuildContext context,
  WidgetRef ref,
  Raccolta r,
) async {
  final l10n = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.deleteCollection),
      content: Text(l10n.deleteCollectionConfirm(r.nome)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.delete),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  try {
    await ref.read(raccolteControllerProvider).elimina(r.id);
    return true;
  } catch (e) {
    if (context.mounted) _errore(context, e);
    return false;
  }
}

void _errore(BuildContext context, Object e) {
  final msg = e is Failure ? e.message : e.toString();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}

/// Dialogo con campo nome (+ descrizione facoltativa) e validazione
/// vuoto/duplicato. Ritorna (nome, descrizione) via Navigator.pop.
class _DialogoNome extends ConsumerStatefulWidget {
  const _DialogoNome({
    required this.titolo,
    required this.azione,
    this.nomeIniziale = '',
    this.descrizioneIniziale,
    this.escludiId,
  });

  final String titolo;
  final String azione;
  final String nomeIniziale;
  final String? descrizioneIniziale;
  final String? escludiId; // per il rename: non confrontare con se stessa

  @override
  ConsumerState<_DialogoNome> createState() => _DialogoNomeState();
}

class _DialogoNomeState extends ConsumerState<_DialogoNome> {
  late final TextEditingController _nome =
      TextEditingController(text: widget.nomeIniziale);
  late final TextEditingController _descrizione =
      TextEditingController(text: widget.descrizioneIniziale ?? '');
  String? _errore;

  @override
  void dispose() {
    _nome.dispose();
    _descrizione.dispose();
    super.dispose();
  }

  void _conferma() {
    final l10n = AppLocalizations.of(context);
    final nome = _nome.text.trim();
    if (nome.isEmpty) {
      setState(() => _errore = l10n.collectionNameEmpty);
      return;
    }
    final esistenti = ref.read(mieRaccolteProvider).valueOrNull ?? const [];
    final duplicato = ref.read(raccolteControllerProvider).nomeDuplicato(
          esistenti,
          nome,
          escludiId: widget.escludiId,
        );
    if (duplicato) {
      setState(() => _errore = l10n.collectionNameDuplicate);
      return;
    }
    final desc = _descrizione.text.trim();
    Navigator.pop(
      context,
      (nome: nome, descrizione: desc.isEmpty ? null : desc),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.titolo),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nome,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.collectionName,
              errorText: _errore,
            ),
            onChanged: (_) {
              if (_errore != null) setState(() => _errore = null);
            },
            onSubmitted: (_) => _conferma(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descrizione,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.collectionDescriptionOptional,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _conferma, child: Text(widget.azione)),
      ],
    );
  }
}
