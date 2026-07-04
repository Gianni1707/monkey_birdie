import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/error/failure.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../data/models/profilo.dart';
import '../../../data/models/specie.dart';
import '../../../data/repositories/profilo_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/profilo_providers.dart';
import 'aggiungi_preferito_sheet.dart';
import 'preferito_button.dart';

/// Etichetta localizzata del livello (badge) assegnato dal sistema.
String etichettaLivello(AppLocalizations l10n, LivelloBirder l) => switch (l) {
      LivelloBirder.principiante => l10n.levelBeginner,
      LivelloBirder.appassionato => l10n.levelEnthusiast,
      LivelloBirder.esperto => l10n.levelExpert,
      LivelloBirder.maestro => l10n.levelMaster,
    };

/// UT09 — tab Profilo dell'utente loggato: bio, dati personali, preferiti.
/// La modifica di bio/dati avviene INLINE (nessuna schermata separata).
class ProfiloScreen extends ConsumerStatefulWidget {
  const ProfiloScreen({super.key});

  @override
  ConsumerState<ProfiloScreen> createState() => _ProfiloScreenState();
}

class _ProfiloScreenState extends ConsumerState<ProfiloScreen> {
  final _username = TextEditingController();
  final _bio = TextEditingController();
  final _localita = TextEditingController();
  String? _erroreUsername;
  bool _modifica = false;
  bool _salvando = false;

  @override
  void dispose() {
    _username.dispose();
    _bio.dispose();
    _localita.dispose();
    super.dispose();
  }

  void _entraInModifica(Profilo p) {
    _username.text = p.username;
    _bio.text = p.bio ?? '';
    _localita.text = _campo(p.datiPersonali, DatiProfilo.localita) ?? '';
    setState(() {
      _erroreUsername = null;
      _modifica = true;
    });
  }

  Future<void> _salva() async {
    final l10n = AppLocalizations.of(context);
    final username = _username.text.trim();
    final localita = _localita.text.trim();
    final bio = _bio.text.trim();

    // Nome account (username): obbligatorio, min 3, non gia' in uso.
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
      // Merge nei dati esistenti (preserva avatar e altri campi).
      final dati = {
        ...?ref.read(mioProfiloProvider).valueOrNull?.datiPersonali,
      };
      if (localita.isEmpty) {
        dati.remove(DatiProfilo.localita);
      } else {
        dati[DatiProfilo.localita] = localita;
      }
      await ctrl.salvaProfilo(
        username: username,
        bio: bio.isEmpty ? null : bio,
        datiPersonali: dati,
      );
      if (mounted) setState(() => _modifica = false);
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
    final asyncProfilo = ref.watch(mioProfiloProvider);

    return asyncProfilo.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: '$e',
        onRetry: () => ref.invalidate(mioProfiloProvider),
      ),
      data: (profilo) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(mioProfiloProvider);
          ref.invalidate(preferitiProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _Intestazione(profilo),
            const SizedBox(height: 12),
            const _Badge(),
            const SizedBox(height: 16),
            if (_modifica) _form(l10n) else _vista(l10n, profilo),
            const SizedBox(height: 12),
            _pulsanti(l10n, profilo),
            const Divider(height: 32),
            _SezionePreferiti(),
          ],
        ),
      ),
    );
  }

  // ---- VISTA (sola lettura) -------------------------------------------------
  Widget _vista(AppLocalizations l10n, Profilo p) {
    final localita = _campo(p.datiPersonali, DatiProfilo.localita);
    final bioVuota = p.bio == null || p.bio!.trim().isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            bioVuota ? l10n.profileBioEmpty : p.bio!.trim(),
            style: bioVuota
                ? TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  )
                : null,
          ),
        ),
        if (localita != null) ...[
          const SizedBox(height: 12),
          _riga(Icons.place_outlined, l10n.locationField, localita),
        ],
      ],
    );
  }

  Widget _riga(IconData icona, String etichetta, String valore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icona, size: 20, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 10),
          Text(
            '$etichetta: ',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(valore)),
        ],
      ),
    );
  }

  // ---- FORM (modifica inline) ----------------------------------------------
  Widget _form(AppLocalizations l10n) {
    return Column(
      children: [
        TextField(
          controller: _username,
          maxLength: 30,
          decoration: InputDecoration(
            labelText: l10n.username,
            errorText: _erroreUsername,
            border: const OutlineInputBorder(),
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
          minLines: 3,
          maxLines: 6,
          maxLength: 300,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: l10n.bio,
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _localita,
          maxLength: 80,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: l10n.locationField,
            border: const OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _pulsanti(AppLocalizations l10n, Profilo p) {
    if (!_modifica) {
      return OutlinedButton.icon(
        onPressed: () => _entraInModifica(p),
        icon: const Icon(Icons.edit_outlined),
        label: Text(l10n.editProfile),
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed:
                _salvando ? null : () => setState(() => _modifica = false),
            child: Text(l10n.cancel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
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
      ],
    );
  }
}

class _Intestazione extends StatelessWidget {
  const _Intestazione(this.profilo);
  final Profilo profilo;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _AvatarProfilo(
          username: profilo.username,
          avatarPath: _campo(profilo.datiPersonali, DatiProfilo.avatar),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            profilo.username,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ],
    );
  }
}

/// Avatar profilo, sempre modificabile: tap -> scatta/galleria/rimuovi.
class _AvatarProfilo extends ConsumerStatefulWidget {
  const _AvatarProfilo({required this.username, required this.avatarPath});
  final String username;
  final String? avatarPath;

  @override
  ConsumerState<_AvatarProfilo> createState() => _AvatarProfiloState();
}

class _AvatarProfiloState extends ConsumerState<_AvatarProfilo> {
  final ImagePicker _picker = ImagePicker();
  bool _caricando = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final path = widget.avatarPath;
    final Widget contenuto;
    if (path != null) {
      final url = ref.read(profiloRepositoryProvider).urlAvatar(path);
      contenuto = ClipOval(
        child: Image.network(
          url,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _iniziale(scheme),
        ),
      );
    } else {
      contenuto = _iniziale(scheme);
    }

    return GestureDetector(
      onTap: _caricando ? null : _menu,
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          children: [
            contenuto,
            if (_caricando)
              const Positioned.fill(
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 11,
                backgroundColor: scheme.primary,
                child: Icon(
                  Icons.photo_camera,
                  size: 13,
                  color: scheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iniziale(ColorScheme scheme) => CircleAvatar(
        radius: 32,
        backgroundColor: scheme.primaryContainer,
        child: Text(
          widget.username.isEmpty ? '?' : widget.username[0].toUpperCase(),
          style: TextStyle(fontSize: 28, color: scheme.onPrimaryContainer),
        ),
      );

  Future<void> _menu() async {
    final l10n = AppLocalizations.of(context);
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(ctx);
                _scegli(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.uploadPhoto),
              onTap: () {
                Navigator.pop(ctx);
                _scegli(ImageSource.gallery);
              },
            ),
            if (widget.avatarPath != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(l10n.removePhoto),
                onTap: () {
                  Navigator.pop(ctx);
                  _esegui(
                    () => ref.read(profiloControllerProvider).rimuoviAvatar(),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _scegli(ImageSource sorgente) async {
    final l10n = AppLocalizations.of(context);
    final permessi = ref.read(permissionServiceProvider);
    final ok = sorgente == ImageSource.camera
        ? await permessi.richiediFotocamera()
        : await permessi.richiediGalleria();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sorgente == ImageSource.camera
                ? l10n.cameraPermissionDenied
                : l10n.galleryPermissionDenied,
          ),
        ),
      );
      return;
    }
    final file = await _picker.pickImage(
      source: sorgente,
      maxWidth: 1024,
      imageQuality: 90,
    );
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _esegui(
      () => ref.read(profiloControllerProvider).impostaAvatar(bytes),
    );
  }

  Future<void> _esegui(Future<void> Function() azione) async {
    setState(() => _caricando = true);
    try {
      await azione();
    } catch (e) {
      if (!mounted) return;
      final msg = e is Failure ? e.message : e.toString();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _caricando = false);
    }
  }
}

/// Badge assegnato dal sistema in base alle specie diverse memorizzate.
class _Badge extends ConsumerWidget {
  const _Badge();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(badgeBirderProvider);
    return async.maybeWhen(
      data: (b) {
        final scheme = Theme.of(context).colorScheme;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(b.livello.emoji, style: const TextStyle(fontSize: 34)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      etichettaLivello(l10n, b.livello),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${l10n.speciesCount(b.specie)} · '
                      '${b.mancanti == null ? l10n.levelMax : l10n.levelProgress(b.mancanti!)}',
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _SezionePreferiti extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(preferitiProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.favorites,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextButton.icon(
              onPressed: () => mostraAggiungiPreferito(context),
              icon: const Icon(Icons.add),
              label: Text(l10n.addFavorite),
            ),
          ],
        ),
        const SizedBox(height: 4),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('$e'),
          data: (preferiti) {
            if (preferiti.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  l10n.noFavorites,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Column(
              children: [for (final s in preferiti) _PreferitoTile(s)],
            );
          },
        ),
      ],
    );
  }
}

class _PreferitoTile extends StatelessWidget {
  const _PreferitoTile(this.specie);
  final Specie specie;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: AvvistamentoFoto(
          fotoUrl: null,
          nomeScientifico: specie.nomeScientifico,
          size: 44,
        ),
        title: Text(specie.nomeComune),
        subtitle: Text(
          specie.nomeScientifico,
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
        trailing: PreferitoIconButton(specieId: specie.id),
        onTap: () => context.push('/specie/${specie.id}'),
      ),
    );
  }
}

String? _campo(Map<String, dynamic> dati, String chiave) {
  final v = dati[chiave];
  return (v is String && v.trim().isNotEmpty) ? v.trim() : null;
}
