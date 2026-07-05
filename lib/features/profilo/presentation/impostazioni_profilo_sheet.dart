import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/error/failure.dart';
import '../../../core/locale/locale_controller.dart';
import '../../../data/models/profilo.dart';
import '../../../l10n/app_localizations.dart';
import '../../amici/application/condivisione_providers.dart';
import '../application/profilo_providers.dart';

/// Foglio "Impostazioni": raccoglie i controlli ESISTENTI del profilo —
/// modifica dati (username/bio/località), interruttore di condivisione, lingua.
/// Nessuna funzione nuova: solo riorganizzazione (aspetto).
Future<void> mostraImpostazioni(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _ImpostazioniSheet(),
  );
}

class _ImpostazioniSheet extends ConsumerStatefulWidget {
  const _ImpostazioniSheet();

  @override
  ConsumerState<_ImpostazioniSheet> createState() => _ImpostazioniSheetState();
}

class _ImpostazioniSheetState extends ConsumerState<_ImpostazioniSheet> {
  final _username = TextEditingController();
  final _bio = TextEditingController();
  final _localita = TextEditingController();
  String? _erroreUsername;
  bool _salvando = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _username.dispose();
    _bio.dispose();
    _localita.dispose();
    super.dispose();
  }

  void _prefill(Profilo p) {
    if (_prefilled) return;
    _prefilled = true;
    _username.text = p.username;
    _bio.text = p.bio ?? '';
    final loc = p.datiPersonali[DatiProfilo.localita];
    _localita.text = (loc is String) ? loc : '';
  }

  Future<void> _salva() async {
    final l10n = AppLocalizations.of(context);
    final username = _username.text.trim();
    if (username.length < 3) {
      setState(() => _erroreUsername = l10n.usernameMin);
      return;
    }
    setState(() {
      _salvando = true;
      _erroreUsername = null;
    });
    try {
      final ctrl = ref.read(profiloControllerProvider);
      if (!await ctrl.usernameDisponibile(username)) {
        if (mounted) {
          setState(() {
            _erroreUsername = l10n.usernameTaken;
            _salvando = false;
          });
        }
        return;
      }
      final dati = {
        ...?ref.read(mioProfiloProvider).valueOrNull?.datiPersonali,
      };
      final localita = _localita.text.trim();
      if (localita.isEmpty) {
        dati.remove(DatiProfilo.localita);
      } else {
        dati[DatiProfilo.localita] = localita;
      }
      await ctrl.salvaProfilo(
        username: username,
        bio: _bio.text.trim().isEmpty ? null : _bio.text.trim(),
        datiPersonali: dati,
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
      }
    } catch (e) {
      if (!mounted) return;
      final msg = e is Failure ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final profilo = ref.watch(mioProfiloProvider).valueOrNull;
    if (profilo != null) _prefill(profilo);
    final condividi = ref.watch(condividiTuttiProvider);
    final locale = ref.watch(localeControllerProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.settings, style: t.titleLarge),
            const SizedBox(height: 16),
            Text(l10n.editProfile, style: t.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _username,
              maxLength: 30,
              decoration: InputDecoration(
                labelText: l10n.username,
                errorText: _erroreUsername,
              ),
              onChanged: (_) {
                if (_erroreUsername != null) {
                  setState(() => _erroreUsername = null);
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bio,
              minLines: 2,
              maxLines: 5,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.bio,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _localita,
              maxLength: 80,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: l10n.locationField),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _salvando ? null : _salva,
                child: _salvando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ),
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(condividi ? Icons.public : Icons.public_off),
              title: Text(l10n.shareAllTitle),
              subtitle: Text(l10n.shareAllSubtitle),
              value: condividi,
              onChanged: (v) async {
                try {
                  await ref
                      .read(condivisioneControllerProvider)
                      .impostaTutti(v);
                } catch (e) {
                  if (!context.mounted) return;
                  final msg = e is Failure ? e.message : e.toString();
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(msg)));
                }
              },
            ),
            const Divider(height: 32),
            Text(l10n.language, style: t.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'auto', label: Text(l10n.languageSystem)),
                ButtonSegment(value: 'it', label: Text(l10n.languageItalian)),
                ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
              ],
              selected: {locale?.languageCode ?? 'auto'},
              onSelectionChanged: (s) {
                final v = s.first;
                final loc = switch (v) {
                  'it' => const Locale('it'),
                  'en' => const Locale('en'),
                  _ => null,
                };
                ref.read(localeControllerProvider.notifier).imposta(loc);
              },
            ),
          ],
        ),
      ),
    );
  }
}
