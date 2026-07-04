import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/avvistamento.dart';
import 'avvistamento_foto.dart';

/// Tile di un avvistamento, riusata da Collezione e dal dettaglio Raccolta.
/// [trailing] e [onTap] sono personalizzabili (es. segnalibro "aggiungi a
/// raccolta" nella Collezione, "togli" nel dettaglio raccolta). Default: freccia
/// + apertura della scheda specie.
class AvvistamentoTile extends StatelessWidget {
  const AvvistamentoTile(this.a, {super.key, this.trailing, this.onTap});

  final AvvistamentoDettaglio a;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final conf = a.confidenza == null
        ? ''
        : ' · ${(a.confidenza! * 100).toStringAsFixed(0)}%';
    return Card(
      child: ListTile(
        leading: AvvistamentoFoto(
          fotoUrl: a.fotoUrl,
          nomeScientifico: a.specieNomeScientifico,
          size: 48,
        ),
        title: Text(a.specieNomeComune),
        subtitle: Text(
          '${a.specieNomeScientifico}\n${_formatData(a.avvistatoIl)}$conf',
        ),
        isThreeLine: true,
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap ?? () => context.push('/specie/${a.specieId}'),
      ),
    );
  }

  static String _formatData(DateTime d) {
    String due(int n) => n.toString().padLeft(2, '0');
    return '${due(d.day)}/${due(d.month)}/${d.year}';
  }
}
