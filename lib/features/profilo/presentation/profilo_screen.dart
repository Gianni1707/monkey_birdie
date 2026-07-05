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
import '../../../shared/nome_specie.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../../shared/widgets/state_views.dart';
import '../../amici/application/amici_providers.dart';
import '../application/profilo_providers.dart';
import 'aggiungi_preferito_sheet.dart';
import 'impostazioni_screen.dart';

/// Etichetta localizzata del livello (badge) assegnato dal sistema.
String etichettaLivello(AppLocalizations l10n, LivelloBirder l) => switch (l) {
      LivelloBirder.principiante => l10n.levelBeginner,
      LivelloBirder.appassionato => l10n.levelEnthusiast,
      LivelloBirder.esperto => l10n.levelExpert,
      LivelloBirder.maestro => l10n.levelMaster,
    };

/// UT09 — tab Profilo. Aspetto "guida da campo": avatar+nome, card "Identificati"
/// (specie distinte) col badge, preferiti, righe Amici/Impostazioni, "Esci".
/// Modifica dati / condivisione / lingua vivono nel foglio Impostazioni.
class ProfiloScreen extends ConsumerWidget {
  const ProfiloScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mioProfiloProvider);

    return async.when(
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
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          children: [
            _Intestazione(profilo),
            const SizedBox(height: 12),
            const _BadgesBirder(),
            const SizedBox(height: 16),
            const _CardIdentificati(),
            const SizedBox(height: 24),
            _SezionePreferiti(),
            const SizedBox(height: 20),
            const _RigaAmici(),
            const SizedBox(height: 8),
            _RigaImpostazioni(),
          ],
        ),
      ),
    );
  }
}

class _Intestazione extends StatelessWidget {
  const _Intestazione(this.profilo);
  final Profilo profilo;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final sub = profilo.bio?.trim().isNotEmpty == true
        ? profilo.bio!.trim()
        : _campo(profilo.datiPersonali, DatiProfilo.localita);
    return Column(
      children: [
        _AvatarProfilo(
          username: profilo.username,
          avatarPath: _campo(profilo.datiPersonali, DatiProfilo.avatar),
          size: 104,
        ),
        const SizedBox(height: 12),
        Text(profilo.username, style: t.headlineSmall),
        if (sub != null) ...[
          const SizedBox(height: 2),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

/// Card "Identificati" COMPATTA: specie distinte in collezione, su una riga
/// (numero grande + etichetta). Il badge birder vive ora sotto la bio
/// ([_BadgesBirder]).
class _CardIdentificati extends ConsumerWidget {
  const _CardIdentificati();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final specie = ref.watch(badgeBirderProvider).valueOrNull?.specie ?? 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: Row(
          children: [
            Text(
              '$specie',
              style: t.headlineMedium?.copyWith(color: scheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.identified.toUpperCase(),
                    style: t.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    l10n.identifiedSubtitle,
                    style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Badge dell'utente (attuale: livello birder; in futuro altri) sotto la bio,
/// in una riga ORIZZONTALE scorrevole: centrata se pochi, scorre se sforano.
class _BadgesBirder extends ConsumerWidget {
  const _BadgesBirder();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final badge = ref.watch(badgeBirderProvider).valueOrNull;
    if (badge == null) return const SizedBox.shrink();

    final badges = <Widget>[
      _BadgeChip(
        emoji: badge.livello.emoji,
        testo: etichettaLivello(l10n, badge.livello),
      ),
      // Badge futuri: aggiungerli qui (la riga scorre se sforano).
    ];

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < badges.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              badges[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Pill di un badge (emoji + etichetta), tono primario tenue.
class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.emoji, required this.testo});
  final String emoji;
  final String testo;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(
            testo,
            style: t.labelLarge?.copyWith(color: scheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

/// Preferiti in scorrimento orizzontale (foto + nome). Header con "aggiungi".
class _SezionePreferiti extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final async = ref.watch(preferitiProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.favoriteBirds, style: t.titleMedium)),
            IconButton.filled(
              onPressed: () => mostraAggiungiPreferito(context),
              icon: const Icon(Icons.add),
              tooltip: l10n.addFavorite,
              visualDensity: VisualDensity.compact,
              // Forza icona chiara su sfondo verde (di default restava scura).
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
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
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.noFavorites,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: preferiti.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _PreferitoCard(preferiti[i]),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _PreferitoCard extends StatelessWidget {
  const _PreferitoCard(this.specie);
  final Specie specie;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return SizedBox(
      width: 150,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/specie/${specie.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: AvvistamentoFoto(
                  fotoUrl: null,
                  nomeScientifico: specie.nomeScientifico,
                  size: null,
                  borderRadius: 0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Text(
                  specie.nomeDaMostrare,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleSmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Riga "Amici" con contatore (amici accettati) e badge richieste in arrivo.
class _RigaAmici extends ConsumerWidget {
  const _RigaAmici();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final richieste = ref.watch(numeroRichiesteProvider);
    final numAmici = ref.watch(amiciProvider).length;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.group_outlined),
        title: Text(l10n.friends),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (richieste > 0) ...[
              Badge(label: Text('$richieste')),
              const SizedBox(width: 10),
            ],
            Text('$numAmici', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => context.push('/amici'),
      ),
    );
  }
}

/// Riga "Impostazioni": apre il foglio coi controlli esistenti.
class _RigaImpostazioni extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: ListTile(
        leading: const Icon(Icons.settings_outlined),
        title: Text(l10n.settings),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const ImpostazioniScreen()),
        ),
      ),
    );
  }
}

/// Avatar profilo, sempre modificabile: tap -> scatta/galleria/rimuovi.
class _AvatarProfilo extends ConsumerStatefulWidget {
  const _AvatarProfilo({
    required this.username,
    required this.avatarPath,
    this.size = 64,
  });
  final String username;
  final String? avatarPath;
  final double size;

  @override
  ConsumerState<_AvatarProfilo> createState() => _AvatarProfiloState();
}

class _AvatarProfiloState extends ConsumerState<_AvatarProfilo> {
  final ImagePicker _picker = ImagePicker();
  bool _caricando = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = widget.size;
    final path = widget.avatarPath;
    final Widget contenuto;
    if (path != null) {
      final url = ref.read(profiloRepositoryProvider).urlAvatar(path);
      contenuto = ClipOval(
        child: Image.network(
          url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          errorBuilder: (_, __, ___) => _iniziale(scheme),
        ),
      );
    } else {
      contenuto = _iniziale(scheme);
    }

    return GestureDetector(
      onTap: _caricando ? null : _menu,
      child: SizedBox(
        width: size,
        height: size,
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
                radius: 14,
                backgroundColor: scheme.primary,
                child:
                    Icon(Icons.photo_camera, size: 15, color: scheme.onPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iniziale(ColorScheme scheme) => CircleAvatar(
        radius: widget.size / 2,
        backgroundColor: scheme.primaryContainer,
        child: Text(
          widget.username.isEmpty ? '?' : widget.username[0].toUpperCase(),
          style: TextStyle(
            fontSize: widget.size * 0.42,
            color: scheme.onPrimaryContainer,
          ),
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

String? _campo(Map<String, dynamic> dati, String chiave) {
  final v = dati[chiave];
  return (v is String && v.trim().isNotEmpty) ? v.trim() : null;
}
