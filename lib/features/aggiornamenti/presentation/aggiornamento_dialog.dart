import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/models/app_versione.dart';
import '../../../l10n/app_localizations.dart';

/// Avviso NON bloccante "Aggiornamento disponibile": mostra versione + eventuali
/// novità, "Scarica" (apre l'URL dell'APK nel browser) e "Più tardi" (chiude).
/// `barrierDismissible: true` → l'utente può continuare a usare l'app.
Future<void> mostraAggiornamentoDialog(
  BuildContext context,
  AppVersione versione,
) {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);

  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) => AlertDialog(
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
        ],
      ),
      actions: [
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
            if (ctx.mounted) Navigator.of(ctx).pop();
          },
          child: Text(l10n.updateDownload),
        ),
      ],
    ),
  );
}
