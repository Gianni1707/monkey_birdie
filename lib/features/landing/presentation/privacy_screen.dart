import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/contenuto_centrato.dart';

/// Pagina privacy minima e onesta (collegata dal footer della landing).
/// Nessun link morto; il testo vive in l10n (`privacyBody`).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/landing'),
        ),
      ),
      body: ContenutoCentrato(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.privacyBody,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
          ),
        ),
      ),
    );
  }
}
