import 'package:flutter/material.dart';

import '../../../core/versione_locale.dart';
import '../../../l10n/app_localizations.dart';

/// Sotto-schermata "Informazioni" (da Impostazioni). Per ora SOLO versione app
/// + nota sul progetto: Termini/Privacy verranno alla pubblicazione (non
/// esistono ancora, niente link morti).
class InformazioniScreen extends StatelessWidget {
  const InformazioniScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('MonkeyBirdie'),
                  subtitle: Text('${l10n.versionLabel} $kVersioneApp'),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.nonCommercialNote,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
