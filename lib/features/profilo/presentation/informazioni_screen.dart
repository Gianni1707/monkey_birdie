import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/link_esterni.dart';
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
                ListTile(
                  leading: const Icon(Icons.code),
                  title: Text(l10n.aboutGithub),
                  subtitle: Text(l10n.aboutGithubSubtitle),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _apri(kUrlGithubProfilo),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.favorite_border),
                  title: Text(l10n.aboutDonate),
                  subtitle: Text(l10n.aboutDonateSubtitle),
                  trailing: const Icon(Icons.open_in_new, size: 18),
                  onTap: () => _apri(kUrlDonazioni),
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

  Future<void> _apri(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
