import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/avvistamento.dart';
import '../../../data/models/specie.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/nome_specie.dart';
import '../../../shared/widgets/avatar_utente.dart';
import '../../../shared/widgets/avvistamento_foto.dart';
import '../../../shared/widgets/avvistamento_tile.dart';
import '../../../shared/widgets/state_views.dart';
import '../../amici/application/condivisione_providers.dart';
import '../../amici/presentation/pulsante_amicizia.dart';
import '../application/profilo_providers.dart';

/// Profilo PUBBLICO di un altro utente (UT08), sola lettura: header + pulsante
/// amicizia, due contatori (avvistamenti CONDIVISI visibili + specie distinte),
/// preferiti (visibili se amici, RLS 0008) e avvistamenti condivisi recenti.
class ProfiloPubblicoScreen extends ConsumerWidget {
  const ProfiloPubblicoScreen({super.key, required this.utenteId});
  final String utenteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final async = ref.watch(profiloDiProvider(utenteId));
    final condivisi =
        ref.watch(avvistamentiCondivisiDiProvider(utenteId)).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(async.valueOrNull?.username ?? '')),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(
          message: '$e',
          onRetry: () => ref.invalidate(profiloDiProvider(utenteId)),
        ),
        data: (profilo) {
          final sub = profilo.bio?.trim().isNotEmpty == true
              ? profilo.bio!.trim()
              : _campo(profilo.datiPersonali, 'localita');
          final nAvv = condivisi?.length;
          final nSpecie = condivisi?.map((a) => a.specieId).toSet().length;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            children: [
              Column(
                children: [
                  AvatarUtente(profilo: profilo, size: 104),
                  const SizedBox(height: 12),
                  Text(profilo.username, style: t.headlineSmall),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      textAlign: TextAlign.center,
                      style: t.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                  const SizedBox(height: 14),
                  PulsanteAmicizia(
                    utenteId: utenteId,
                    username: profilo.username,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _Contatori(avvistamenti: nAvv, specie: nSpecie),
              const SizedBox(height: 24),
              _Preferiti(utenteId),
              const SizedBox(height: 20),
              _Recenti(utenteId),
            ],
          );
        },
      ),
    );
  }
}

/// Due contatori: "Avvistamenti condivisi" (sottoinsieme visibile) e "Specie".
class _Contatori extends StatelessWidget {
  const _Contatori({required this.avvistamenti, required this.specie});
  final int? avvistamenti;
  final int? specie;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: _Stat(
                valore: avvistamenti,
                etichetta: l10n.statSharedSightings,
              ),
            ),
            Expanded(child: _Stat(valore: specie, etichetta: l10n.statSpecies)),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.valore, required this.etichetta});
  final int? valore;
  final String etichetta;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          valore?.toString() ?? '—',
          style: t.headlineMedium?.copyWith(color: scheme.primary),
        ),
        const SizedBox(height: 2),
        Text(
          etichetta,
          textAlign: TextAlign.center,
          style: t.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// Preferiti dell'amico (visibili solo se amici, RLS 0008), in orizzontale.
class _Preferiti extends ConsumerWidget {
  const _Preferiti(this.utenteId);
  final String utenteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final async = ref.watch(preferitiDiProvider(utenteId));
    return async.maybeWhen(
      data: (preferiti) {
        if (preferiti.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.favoriteBirds, style: t.titleMedium),
            const SizedBox(height: 8),
            SizedBox(
              height: 168,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: preferiti.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _SpecieCard(preferiti[i]),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _SpecieCard extends StatelessWidget {
  const _SpecieCard(this.specie);
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

/// Avvistamenti condivisi recenti dell'amico (la RLS restituisce solo condiviso).
class _Recenti extends ConsumerWidget {
  const _Recenti(this.utenteId);
  final String utenteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final t = Theme.of(context).textTheme;
    final async = ref.watch(avvistamentiCondivisiDiProvider(utenteId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.recentSightings, style: t.titleMedium),
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
              children: [
                for (final AvvistamentoDettaglio a in avvistamenti)
                  AvvistamentoTile(a),
              ],
            );
          },
        ),
      ],
    );
  }
}

String? _campo(Map<String, dynamic> dati, String chiave) {
  final v = dati[chiave];
  return (v is String && v.trim().isNotEmpty) ? v.trim() : null;
}
