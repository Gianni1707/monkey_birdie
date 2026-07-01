import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/avvistamento.dart';
import '../../../shared/widgets/state_views.dart';
import '../application/collection_controller.dart';

/// UT04 — collezione dei volatili avvistati.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncColl = ref.watch(collezioneProvider);

    return asyncColl.when(
      loading: () => const LoadingView(),
      error: (e, _) => ErrorView(
        message: '$e',
        onRetry: () => ref.invalidate(collezioneProvider),
      ),
      data: (avvistamenti) {
        if (avvistamenti.isEmpty) {
          return const EmptyState(
            icon: Icons.photo_camera_back_outlined,
            title: 'Collezione vuota',
            subtitle: 'Registra il canto di un uccello per iniziare.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(collezioneProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: avvistamenti.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) => _AvvistamentoTile(avvistamenti[i]),
          ),
        );
      },
    );
  }
}

class _AvvistamentoTile extends StatelessWidget {
  const _AvvistamentoTile(this.a);
  final AvvistamentoDettaglio a;

  @override
  Widget build(BuildContext context) {
    final conf =
        a.confidenza == null ? '' : ' · ${(a.confidenza! * 100).toStringAsFixed(0)}%';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            a.specieNomeComune.isEmpty
                ? '?'
                : a.specieNomeComune[0].toUpperCase(),
          ),
        ),
        title: Text(a.specieNomeComune),
        subtitle: Text('${a.specieNomeScientifico}\n${_formatData(a.avvistatoIl)}$conf'),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/specie/${a.specieId}'),
      ),
    );
  }

  static String _formatData(DateTime d) {
    String due(int n) => n.toString().padLeft(2, '0');
    return '${due(d.day)}/${due(d.month)}/${d.year}';
  }
}
