import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/profilo.dart';
import '../../../data/models/specie.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/avatar_utente.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../../shared/widgets/avvistamento_tile.dart';
import '../../../shared/widgets/state_views.dart';
import '../../amici/application/condivisione_providers.dart';
import '../../amici/presentation/pulsante_amicizia.dart';
import '../application/profilo_providers.dart';

/// Profilo PUBBLICO di un altro utente (UT08), in sola lettura: avatar,
/// username, bio, località, preferiti (visibili solo se amici, RLS 0008) e
/// pulsante di amicizia. Riusa i componenti del profilo proprio.
/// (Parte B aggiungerà qui i suoi avvistamenti condivisi.)
class ProfiloPubblicoScreen extends ConsumerWidget {
  const ProfiloPubblicoScreen({super.key, required this.utenteId});
  final String utenteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(profiloDiProvider(utenteId));
    return Scaffold(
      appBar: AppBar(title: Text(async.valueOrNull?.username ?? '')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(profiloDiProvider(utenteId)),
        ),
        data: (profilo) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                AvatarUtente(profilo: profilo, size: 64),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    profilo.username,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: PulsanteAmicizia(
                utenteId: utenteId,
                username: profilo.username,
              ),
            ),
            const SizedBox(height: 16),
            _Dati(profilo),
            const Divider(height: 32),
            _Preferiti(utenteId),
            const Divider(height: 32),
            _Condivisi(utenteId),
          ],
        ),
      ),
    );
  }
}

/// Avvistamenti condivisi dell'amico (la RLS restituisce solo condiviso=true).
class _Condivisi extends ConsumerWidget {
  const _Condivisi(this.utenteId);
  final String utenteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(avvistamentiCondivisiDiProvider(utenteId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.sharedSightings,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        async.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('$e'),
          data: (avvistamenti) {
            if (avvistamenti.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  l10n.noSharedSightings,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Column(
              children: [for (final a in avvistamenti) AvvistamentoTile(a)],
            );
          },
        ),
      ],
    );
  }
}

class _Dati extends StatelessWidget {
  const _Dati(this.profilo);
  final Profilo profilo;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bio = profilo.bio;
    final localita = profilo.datiPersonali['localita'];
    final children = <Widget>[];
    if (bio != null && bio.trim().isNotEmpty) {
      children.add(
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(bio.trim()),
        ),
      );
    }
    if (localita is String && localita.trim().isNotEmpty) {
      children.add(const SizedBox(height: 8));
      children.add(
        Row(
          children: [
            Icon(
              Icons.place_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(width: 8),
            Text('${l10n.locationField}: '),
            Expanded(child: Text(localita.trim())),
          ],
        ),
      );
    }
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

class _Preferiti extends ConsumerWidget {
  const _Preferiti(this.utenteId);
  final String utenteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(preferitiDiProvider(utenteId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.favorites,
          style: Theme.of(context).textTheme.titleMedium,
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
        onTap: () => context.push('/specie/${specie.id}'),
      ),
    );
  }
}
