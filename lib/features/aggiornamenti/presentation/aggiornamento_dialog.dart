import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/app_versione.dart';
import '../../../l10n/app_localizations.dart';

/// Avviso "Aggiornamento disponibile".
/// - Normale (`obbligatorio=false`): NON bloccante — "Più tardi" + "Scarica",
///   richiudibile, l'utente può continuare a usare l'app.
/// - Obbligatorio (`obbligatorio=true`): BLOCCANTE — niente "Più tardi", non si
///   chiude (né col barrier né col tasto Indietro); "Scarica" apre il download ma
///   non sblocca (l'utente deve installare il nuovo APK per proseguire).
Future<void> mostraAggiornamentoDialog(
  BuildContext context,
  AppVersione versione,
) {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final obbligatorio = versione.obbligatorio;

  return showDialog<void>(
    context: context,
    barrierDismissible: !obbligatorio,
    builder: (ctx) => PopScope(
      canPop: !obbligatorio,
      child: AlertDialog(
        title: Text(l10n.updateAvailableTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.updateAvailableBody(versione.versione)),
            if (versione.note != null && versione.note!.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                versione.note!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (obbligatorio) ...[
              const SizedBox(height: 12),
              Text(
                l10n.updateMandatory,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (!obbligatorio)
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l10n.updateLater),
            ),
          FilledButton(
            onPressed: () async {
              final uri = Uri.tryParse(versione.urlApk);
              if (uri != null) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              // Se obbligatorio NON chiudiamo: resta bloccato finché non aggiorna.
              if (!obbligatorio && ctx.mounted) Navigator.of(ctx).pop();
            },
            child: Text(l10n.updateDownload),
          ),
        ],
      ),
    ),
  );
}
