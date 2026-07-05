import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/avvistamento.dart';
import '../nome_specie.dart';
import 'avvistamento_foto.dart';

/// Tile di un avvistamento, riusata da Collezione e dal dettaglio Raccolta.
/// [trailing] e [onTap] sono personalizzabili (es. menu ⋮ nella Collezione,
/// "togli" nel dettaglio raccolta). Default: apertura della scheda specie.
/// Aspetto "guida da campo": foto grande arrotondata, nome comune in serif,
/// nome scientifico in corsivo attenuato, metadati leggeri.
class AvvistamentoTile extends StatelessWidget {
  const AvvistamentoTile(this.a, {super.key, this.trailing, this.onTap});

  final AvvistamentoDettaglio a;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final conf = a.confidenza == null
        ? ''
        : ' · ${(a.confidenza! * 100).toStringAsFixed(0)}%';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap ?? () => context.push('/specie/${a.specieId}'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AvvistamentoFoto(
                  fotoUrl: a.fotoUrl,
                  nomeScientifico: a.specieNomeScientifico,
                  size: 64,
                  borderRadius: 14,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      a.specieNomeDaMostrare,
                      style: t.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      a.specieNomeScientifico,
                      style: t.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 14,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatData(a.avvistatoIl)}$conf',
                          style: t.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }

  static String _formatData(DateTime d) {
    String due(int n) => n.toString().padLeft(2, '0');
    return '${due(d.day)}/${due(d.month)}/${d.year}';
  }
}
