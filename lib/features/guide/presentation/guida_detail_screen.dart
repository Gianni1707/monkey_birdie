import 'package:flutter/material.dart';

import '../../../data/models/guida.dart';
import '../../../l10n/app_localizations.dart';

/// Dettaglio di una guida/consiglio: chip categoria + titolo serif + corpo.
class GuidaDetailScreen extends StatelessWidget {
  const GuidaDetailScreen({super.key, required this.guida});
  final Guida guida;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.guidesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ChipCategoria(guida.categoria),
          const SizedBox(height: 14),
          Text(guida.titolo, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          Text(
            guida.corpo,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}

/// Chip categoria (tono primario tenue), riusato in lista e dettaglio.
class _ChipCategoria extends StatelessWidget {
  const _ChipCategoria(this.categoria);
  final String categoria;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        categoria,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
