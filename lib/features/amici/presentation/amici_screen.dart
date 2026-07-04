import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/profilo.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/avatar_utente.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/amici_providers.dart';
import 'pulsante_amicizia.dart';

/// UT08 — Amici e richieste. Raggiunta da una riga nel Profilo.
class AmiciScreen extends ConsumerWidget {
  const AmiciScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.friends),
          actions: [
            IconButton(
              tooltip: l10n.searchUsers,
              icon: const Icon(Icons.person_search),
              onPressed: () => mostraCercaUtenti(context),
            ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.friends),
              Tab(text: l10n.requests),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_TabAmici(), _TabRichieste()],
        ),
      ),
    );
  }
}

class _TabAmici extends ConsumerWidget {
  const _TabAmici();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(relazioniProvider);
    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: '$e',
        onRetry: () => ref.invalidate(relazioniProvider),
      ),
      data: (_) {
        final amici = ref.watch(amiciProvider);
        if (amici.isEmpty) {
          return EmptyState(
            icon: Icons.group_outlined,
            title: l10n.noFriendsTitle,
            subtitle: l10n.noFriendsSubtitle,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [for (final p in amici) _UtenteTile(p)],
        );
      },
    );
  }
}

class _TabRichieste extends ConsumerWidget {
  const _TabRichieste();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(relazioniProvider);
    return async.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: '$e',
        onRetry: () => ref.invalidate(relazioniProvider),
      ),
      data: (_) {
        final inArrivo = ref.watch(richiesteInArrivoProvider);
        final inUscita = ref.watch(richiesteInUscitaProvider);
        if (inArrivo.isEmpty && inUscita.isEmpty) {
          return EmptyState(
            icon: Icons.mark_email_unread_outlined,
            title: l10n.noRequestsTitle,
            subtitle: l10n.noRequestsSubtitle,
          );
        }
        return ListView(
          padding: const EdgeInsets.all(12),
          children: [
            if (inArrivo.isNotEmpty) ...[
              _Sezione(l10n.requestsIncoming),
              for (final p in inArrivo) _UtenteTile(p),
            ],
            if (inUscita.isNotEmpty) ...[
              _Sezione(l10n.requestsOutgoing),
              for (final p in inUscita) _UtenteTile(p),
            ],
          ],
        );
      },
    );
  }
}

class _Sezione extends StatelessWidget {
  const _Sezione(this.titolo);
  final String titolo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
      child: Text(
        titolo,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
      ),
    );
  }
}

class _UtenteTile extends StatelessWidget {
  const _UtenteTile(this.profilo);
  final Profilo profilo;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: AvatarUtente(profilo: profilo),
        title: Text(profilo.username),
        subtitle: (profilo.bio == null || profilo.bio!.trim().isEmpty)
            ? null
            : Text(
                profilo.bio!.trim(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        trailing: PulsanteAmicizia(
          utenteId: profilo.id,
          username: profilo.username,
        ),
        onTap: () => context.push('/profilo/${profilo.id}'),
      ),
    );
  }
}

/// Foglio di ricerca utenti per username (+ pulsante amicizia sui risultati).
Future<void> mostraCercaUtenti(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _CercaUtentiSheet(),
  );
}

class _CercaUtentiSheet extends ConsumerStatefulWidget {
  const _CercaUtentiSheet();

  @override
  ConsumerState<_CercaUtentiSheet> createState() => _CercaUtentiSheetState();
}

class _CercaUtentiSheetState extends ConsumerState<_CercaUtentiSheet> {
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
              l10n.searchUsers,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _q,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: l10n.searchUsersHint,
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
          l10n.searchUsersTypeHint,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }
    final async = ref.watch(ricercaUtentiProvider(_query.trim()));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (utenti) {
        if (utenti.isEmpty) {
          return Center(child: Text(l10n.searchUsersNoResults));
        }
        return ListView.builder(
          itemCount: utenti.length,
          itemBuilder: (_, i) {
            final p = utenti[i];
            return ListTile(
              leading: AvatarUtente(profilo: p),
              title: Text(p.username),
              trailing: PulsanteAmicizia(utenteId: p.id, username: p.username),
              onTap: () => context.push('/profilo/${p.id}'),
            );
          },
        );
      },
    );
  }
}
